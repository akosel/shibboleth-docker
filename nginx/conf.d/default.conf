server {

    listen 80;

    # server_name is important because it is used by shibboleth for generating SAML URLs
    # Using the catch-all '_' will NOT work.
    server_name ${CLIENT_APP_HOSTNAME:-your-app.localdomain.com};

    # FastCGI authorizer for Auth Request module
    location = /shibauthorizer {
        internal;
        include fastcgi_params;
        fastcgi_pass unix:/tmp/shibauthorizer.sock;
    }

    # FastCGI responder
    location ${SHIBBOLETH_RESPONDER_PATH:-/saml} {
        include fastcgi_params;
        fastcgi_param  HTTPS on;
        fastcgi_param  SERVER_PORT 443;
        fastcgi_param  SERVER_PROTOCOL https;
        fastcgi_param  X_FORWARDED_PROTO https;
        fastcgi_param  X_FORWARDED_PORT 443;
        fastcgi_pass unix:/tmp/shibresponder.sock;
    }

    # Resources for the Shibboleth error pages. This can be customised.
    location /shibboleth-sp {
        alias /etc/shibboleth/;
    }

    location / {
        # 172.17.42.1 is the default Docker container HOST IP
        proxy_pass ${NGINX_PROXY_DESTINATION:-http://172.17.42.1:8001};

        ### Set headers ####
        proxy_set_header        Accept-Encoding   "";
        proxy_set_header        Host            $host;
        proxy_set_header        X-Real-IP       $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;

        location ${CLIENT_APP_SECURE_PATH:-/app} {
            more_clear_input_headers 'Variable-*' 'Shib-*' 'Remote-User' 'REMOTE_USER' 'Auth-Type' 'AUTH_TYPE';
            # Add your attributes here. They get introduced as headers
            # by the FastCGI authorizer so we must prevent spoofing.
            more_clear_input_headers 'displayName' 'mail' 'persistent-id';
            shib_request /shibauthorizer;

            proxy_pass ${NGINX_PROXY_DESTINATION:-http://172.17.42.1:8001};

            ### Set headers ####
            proxy_set_header        Accept-Encoding   "";
            proxy_set_header        Host            $host;
            proxy_set_header        X-Real-IP       $remote_addr;
            proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
