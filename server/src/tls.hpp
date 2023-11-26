#ifndef TLS_HPP
#define TLS_HPP

#include <arpa/inet.h>
#include <openssl/ssl.h>
#include <vector>
#include <string>


typedef struct {
  int socket_fd;
  struct sockaddr_in addr;
  SSL *ssl;
} tls_socket;

int close_tls_socket(tls_socket *socket);
int tls_read(tls_socket *socket, std::vector<char>& buf);
int tls_write(tls_socket *socket, const std::string& str);

typedef struct {
  int master_socket;
  struct sockaddr_in addr;
  SSL_CTX *ssl_ctx;
} tls_acceptor;

tls_acceptor *create_tls_acceptor(int port);
tls_socket *accept_tls_connection(tls_acceptor *acceptor);
int close_tls_acceptor(tls_acceptor *acceptor);

#endif // TLS_HPP
