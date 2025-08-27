cd "$(dirname "$0")"
nix build .
sudo rm -rf ../result
mkdir ../result
cp -r result/* ../result/
sudo chown -R $(whoami) ../result
sudo chmod -R +rw ../result