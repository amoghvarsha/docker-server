# General Instructions for setting running vaultwarden

# Follow the instructions in the link for logging setup
https://github.com/dani-garcia/vaultwarden/wiki/Logging

# Mount the log directory volume to the docker container
-v /var/log/docker/vaultwarden/:/log/
LOG_FILE=/log/vaultwarden.log

# Start the docker container 
VAR=VALUE VAR=VALUE docker-compose up -d

# Stop the docker container using
VAR=VALUE VAR=VALUE docker-compose down

# Generate Admin Token for vaultwarden
openssl rand -base64 54

# Generate RSA Key in PEM for Vaultwarden Database 
openssl genrsa -out rsa_key.pem 4096
openssl rsa -in rsa_key.pem -outform PEM -pubout -out rsa_key.pub.pem