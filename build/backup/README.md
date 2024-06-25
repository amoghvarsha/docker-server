# Run the following commands to open an bash terminal for configuring rclone and gpg configuration after creating volumes

# Run 
docker run --rm -it                                  \
    --entrypoint /bin/bash                           \
    -v backup-rclone-config:/root/.config/rclone:rw  \
    -v backup-gpg-config:/root/.gnupg:rw             \
    backup:latest

# Run
gpg --full-generate-key

# Run
rclone config

# Run to extract keys from gpg for storing
gpg --export -a --output [path-to-public-key].pub.asc [USER/ID]
gpg --export-secret-key -a --output [path-to-public-key].prv.asc [USER/ID]
