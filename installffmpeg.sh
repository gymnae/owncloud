# thanks to https://unix.stackexchange.com/questions/7641/download-and-install-latest-deb-package-from-github-via-terminal
# Find the URL of the .deb file
url=$(wget -O- -q --no-check-certificate https://github.com/jellyfin/jellyfin-ffmpeg/releases |
       sed -ne 's/^.*"\([^"]* jellyfin-ffmpeg6_[^"]*-bullseye_amd64\.deb\)".*/\1/p')
case $url in
  http://*|https://*) :;;
  /*) url=https://github.com$url;;
  *) url=https://github.comjellyfin/jellyfin-ffmpeg/$url;;
esac
# Create a temporary directory
dir=$(mktemp -dt)
cd "$dir"
# Download the .deb file
wget "$url"
# Install the package
sudo dpkg -i "${url##*/}"
# Clean up
rm "${url##*/}"
cd /
rmdir "$dir"
