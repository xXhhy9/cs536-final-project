#include <unistd.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <errno.h>
#include <cstring>
#include <iostream>
#include <vector>
#include "tls.hpp"

int close_tls_socket(tls_socket* socket) {
    std::cout << "[close_tls_socket] Closing TLS socket fd " << socket->socket_fd;

    char inet_pres[INET_ADDRSTRLEN];
    if (inet_ntop(socket->addr.sin_family, &(socket->addr.sin_addr), inet_pres, INET_ADDRSTRLEN)) {
        std::cout << " from " << inet_pres;
    }
    std::cout << std::endl;
    int status = close(socket->socket_fd);
    if (status != 0) {
        std::cout << "failed to close socket\n";
    }

    std::cout << "[close_tls_socket] Closing TLS socket fd " << socket->socket_fd;
    SSL_free(socket->ssl);
    delete socket;

    return 0;
}

int tls_read(tls_socket *socket, std::vector<char>& buf) {
    if (buf.size() == 0) {
        return -1;
    }
    int status = SSL_read(socket->ssl, buf.data(), buf.size());
    if (status <= 0) {
        std::cerr << "ssl_read failed with status: " << status << std::endl;
        ERR_print_errors_fp(stderr);
    }
    return status;
}

int tls_write(tls_socket *socket, const std::string& str) {
    if (str.empty()) {
        return -1;
    }
    int status = SSL_write(socket->ssl, str.data(), str.size());
    if (status <= 0) {
        ERR_print_errors_fp(stderr);
    }
    return status;
}

tls_acceptor* create_tls_acceptor(int port) {
    auto acceptor = new tls_acceptor;

    acceptor->addr.sin_family = AF_INET;
    acceptor->addr.sin_port = htons(port);
    acceptor->addr.sin_addr.s_addr = htonl(INADDR_ANY);

    acceptor->master_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (acceptor->master_socket < 0) {
        fprintf(stderr, "Unable to create socket: %s\n", strerror(errno));
        return NULL;
    }

    int optval = 1;
    if (setsockopt(acceptor->master_socket,
                    SOL_SOCKET,
                    SO_REUSEADDR,
                    &optval,
                    sizeof(optval)) < 0) {
        fprintf(stderr, "Unable to set socket options: %s\n", strerror(errno));
    }
    if (bind(acceptor->master_socket,
            (struct sockaddr*) &acceptor->addr,
            sizeof(acceptor->addr)) < 0) {
        fprintf(stderr, "Unable to bind to socket: %s\n", strerror(errno));
    }

    if (listen(acceptor->master_socket, 50) < 0) {
        fprintf(stderr, "Unable to listen to socket: %s\n", strerror(errno));
    }


    // Initialization required by openssl
    printf("initializing ssl\n");
    SSL_load_error_strings();	
    OpenSSL_add_ssl_algorithms();

    // Get SSL method, this is a version-flexible method and supports mutiple protocols on the server's side
    printf("creating context\n");
    const SSL_METHOD *method = TLS_server_method();
    SSL_CTX *ctx = SSL_CTX_new(method);
    // New a context with method created above
    if (!ctx) {
        perror("Unable to create SSL context");
        ERR_print_errors_fp(stderr);
    }

    printf("configuring context\n");
    SSL_CTX_set_ecdh_auto(ctx, 1);

    // Load certificate into context
    if (SSL_CTX_use_certificate_file(ctx, "certificate.pem", SSL_FILETYPE_PEM) <= 0) {
        ERR_print_errors_fp(stderr);
        exit(EXIT_FAILURE);
    }

    // Add the private key into context
    if (SSL_CTX_use_PrivateKey_file(ctx, "privatekey.pem", SSL_FILETYPE_PEM) <= 0 ) {
        ERR_print_errors_fp(stderr);
        exit(EXIT_FAILURE);
    }

    acceptor->ssl_ctx = ctx;

    return acceptor;
}

tls_socket* accept_tls_connection(tls_acceptor* acceptor) {
    struct sockaddr_in addr = { 0 };
    socklen_t addr_len = sizeof(addr);
    int socket_fd = accept(acceptor->master_socket, (struct sockaddr*)&addr, &addr_len);
    if (socket_fd == -1) {
        std::cerr << "Unable to accept connection: " << strerror(errno) << std::endl;
        return nullptr;
    }

    auto socket = new tls_socket;
    socket->socket_fd = socket_fd;
    socket->addr = addr;

    char inet_pres[INET_ADDRSTRLEN];
    if (inet_ntop(addr.sin_family,
            &(addr.sin_addr),
            inet_pres,
            INET_ADDRSTRLEN)) {
        printf("Received a connection from %s\n", inet_pres);
    }
    printf("set up connection with ssl context\n");
    // Set the connected socket with ssl context
    SSL *ssl = SSL_new(acceptor->ssl_ctx);
    SSL_set_fd(ssl, socket_fd);
    if (SSL_accept(ssl) <= 0) {
        printf("SSL_accept failed\n");
        ERR_print_errors_fp(stderr);
    }
    socket->ssl = ssl;

    return socket;
}

int close_tls_acceptor(tls_acceptor* acceptor) {
    std::cout << "Closing socket " << acceptor->master_socket << std::endl;
    int status = close(acceptor->master_socket);
    if (status != 0) {
        std::cout << "failed to close acceptor's master socket\n";
    }

    SSL_CTX_free(acceptor->ssl_ctx);
    delete acceptor;
    return status;
}
