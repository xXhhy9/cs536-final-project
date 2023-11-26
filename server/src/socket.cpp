#include "header.hpp"


int socket_read(socket_t *socket, std::vector<char>& buf) {
#ifdef USE_TLS
  return tls_read(socket, buf);
#else
  return tcp_read(socket, buf);
#endif
} /* socket_read() */

int socket_write(socket_t *socket, const std::string& str) {
#ifdef USE_TLS
  return tls_write(socket, str);
#else
  return tcp_write(socket, str);
#endif
} /* socket_write() */

int close_socket(socket_t *socket) {
#ifdef USE_TLS
  return close_tls_socket(socket);
#else
  return close_tcp_socket(socket);
#endif
} /* close_socket() */

acceptor *create_socket_acceptor(int port) {
#ifdef USE_TLS
  return create_tls_acceptor(port);
#else
  return create_tcp_acceptor(port);
#endif
} /* create_socket_acceptor() */


socket_t *accept_connection(acceptor *socket_acceptor) {
#ifdef USE_TLS
  return accept_tls_connection(socket_acceptor);
#else
  return accept_tcp_connection(socket_acceptor);
#endif
} /* accept_connection() */


int close_socket_acceptor(acceptor* socket_acceptor) {
#ifdef USE_TLS
  return close_tls_acceptor(socket_acceptor);
#else
  return close_tcp_acceptor(socket_acceptor);
#endif
} /* close_socket_acceptor() */
