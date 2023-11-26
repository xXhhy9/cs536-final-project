#include <unistd.h>
#include <errno.h>
#include <iostream>
#include <vector>
#include <iostream>
#include <cstring>
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include "tcp.hpp"

int close_tcp_socket(tcp_socket *socket) {
  std::cout << "Closing TCP socket fd " << socket->socket_fd;
  char inet_pres[INET_ADDRSTRLEN];
  if (inet_ntop(socket->addr.sin_family,
                &(socket->addr.sin_addr),
                inet_pres,
                INET_ADDRSTRLEN)) {
    std::cout << " from " << inet_pres;
  }
  std::cout << std::endl;
  int status = close(socket->socket_fd);
  delete socket;
  return status;
}

int tcp_read(tcp_socket *socket, std::vector<char>& buf) {
  if (buf.size() == 0) {
        std::cerr << "size error" << std::endl;
        return -1;
    }
    else{
        int r = recv(socket->socket_fd, buf.data(), buf.size(), 0);
        if (r == -1){
        std::cerr << "Unable to read a character\n";
        return r;
        }
        return r;
    }
}

int tcp_write(tcp_socket *socket, const std::string& str) {
  if (str.empty()) {
        return -1;
    }

  size_t sent = send(socket->socket_fd, str.data(), str.size(), 0);
  if (sent < 0) {
    return sent;
  }
  else if (sent != str.size()) {
    std::cerr << "Could not write all bytes." << std::endl;
    return -1;
  }

  return 0;
}

tcp_acceptor *create_tcp_acceptor(int port) {
  auto acceptor = new tcp_acceptor;

  acceptor->addr.sin_family = AF_INET;
  acceptor->addr.sin_port = htons(port);
  acceptor->addr.sin_addr.s_addr = htonl(INADDR_ANY);
  acceptor->master_socket = socket(AF_INET, SOCK_STREAM, 0);

  if (acceptor->master_socket < 0) {
    std::cerr << "Unable to create socket: " << strerror(errno) << std::endl;
    return nullptr;
  }

  int optval = 1;
  if (setsockopt(acceptor->master_socket,
                 SOL_SOCKET,
                 SO_REUSEADDR,
                 &optval,
                 sizeof(optval)) < 0) {
    std::cerr << "Unable to set socket options: " << strerror(errno) << std::endl;
  }
  if (bind(acceptor->master_socket,
           (struct sockaddr*) &acceptor->addr,
           sizeof(acceptor->addr)) < 0) {
    std::cerr << "Unable to bind to socket: " << strerror(errno) << std::endl;
  }
  if (listen(acceptor->master_socket, 50) < 0) {
    std::cerr << "Unable to listen to socket: " << strerror(errno) << std::endl;
  }

  return acceptor;
}

tcp_socket *accept_tcp_connection(tcp_acceptor *acceptor) {
  struct sockaddr_in addr = { 0 };
  socklen_t addr_len = sizeof(addr);
  int socket_fd = accept(acceptor->master_socket,
                         (struct sockaddr*) &addr,
                         &addr_len);
  if (socket_fd == -1) {
    std::cerr << "Unable to accept connection: " << strerror(errno) << std::endl;
    return nullptr;
  }

  auto socket = new tcp_socket;
  socket->socket_fd = socket_fd;
  socket->addr = addr;
  char inet_pres[INET_ADDRSTRLEN];
  if (inet_ntop(addr.sin_family,
                &(addr.sin_addr),
                inet_pres,
                INET_ADDRSTRLEN)) {
    std::cout << "Received a connection from " << inet_pres << std::endl;
  }

  return socket;
}

int close_tcp_acceptor(tcp_acceptor *acceptor) {
    std::cout << "Closing socket " << acceptor->master_socket << std::endl;
    int status = close(acceptor->master_socket);
    if (status != 0) {
        std::cout << "failed to close acceptor's master socket\n";
    }

    delete acceptor;
    return status;
}
