# Run the following command to open an bash terminal for configuring rclone and gpg configuration after creating volumes

docker run --rm -it        \
    --entrypoint /bin/bash \
    -v backup:/root/:rw    \
    backup/latest:1.0

# Run
gpg --full-generate-key

# Run
rclone config

# Run to extract keys from gpg for storing
gpg --export -a --output [path-to-public-key].pub.asc [USER/ID]
gpg --export-secret-key -a --output [path-to-public-key].prv.asc [USER/ID]
