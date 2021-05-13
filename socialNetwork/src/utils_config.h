#ifndef SOCIAL_NETWORK_MICROSERVICES_SRC_UTILS_CONFIG_H_
#define SOCIAL_NETWORK_MICROSERVICES_SRC_UTILS_CONFIG_H_

#include <fstream>
#include <nlohmann/json.hpp>

using nlohmann::json;

namespace social_network {
    bool is_config_ssl_enabled() {
        bool is_ssl;

        std::ifstream f;
        try {
            f.open("/social-network-microservices/config/service-config.json");

            json j = json::parse(f);
            is_ssl = j["ssl"]["enabled"].get<bool>();

            f.close();
        } catch (...) {
            is_ssl = false;
            if (f.is_open())
            {
                f.close();
            }
        }
        
        return is_ssl;
    }

    std::string get_config_ca_file() {
        std::string ca_file;

        std::ifstream f;
        try {
            f.open("/social-network-microservices/config/service-config.json");

            json j = json::parse(f);
            ca_file = j["ssl"]["caPath"].get<std::string>();

            f.close();
        } catch (...) {
            ca_file = "";
            if (f.is_open())
            {
                f.close();
            }
        }
        
        return ca_file;
    }
}

#endif
