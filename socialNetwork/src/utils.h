#ifndef SOCIAL_NETWORK_MICROSERVICES_UTILS_H
#define SOCIAL_NETWORK_MICROSERVICES_UTILS_H

#include <string>
#include <fstream>
#include <iostream>
#include <nlohmann/json.hpp>
#include <thrift/transport/TServerSocket.h>
#include <thrift/transport/TSSLSocket.h>
#include <thrift/transport/TSSLServerSocket.h>

#include "logger.h"

namespace social_network{
using json = nlohmann::json;
using apache::thrift::transport::TServerSocket;
using apache::thrift::transport::TSSLServerSocket;
using apache::thrift::transport::TSSLSocketFactory;

int load_config_file(const std::string &file_name, json *config_json) {
  std::ifstream json_file;
  json_file.open(file_name);
  if (json_file.is_open()) {
    json_file >> *config_json;
    json_file.close();
    return 0;
  }
  else {
    LOG(error) << "Cannot open service-config.json";
    return -1;
  }
};

std::shared_ptr<TServerSocket> get_server_socket(const json &config_json, const std::string &address, int port) {
  bool ssl_enabled = config_json["ssl"]["enabled"];
  if (ssl_enabled) {
    std::string cert_path = config_json["ssl"]["serverCertPath"];
    std::string key_path = config_json["ssl"]["serverKeyPath"];
    std::string ca_path = config_json["ssl"]["caPath"];
    std::string ciphers = config_json["ssl"]["ciphers"];

    std::shared_ptr<TSSLSocketFactory> ssl_socket_factory;
    ssl_socket_factory = std::make_shared<TSSLSocketFactory>();
    ssl_socket_factory->loadCertificate(cert_path.c_str());
    ssl_socket_factory->loadPrivateKey(key_path.c_str());
    ssl_socket_factory->ciphers(ciphers);
    if (config_json["ssl"]["verifyClient"]) {
      ssl_socket_factory->loadTrustedCertificates(ca_path.c_str());
      ssl_socket_factory->authenticate(true);
    }
    return std::make_shared<TSSLServerSocket>(address, port, ssl_socket_factory);
  }
  return std::make_shared<TServerSocket>(address, port);
};

} //namespace social_network

#endif //SOCIAL_NETWORK_MICROSERVICES_UTILS_H
