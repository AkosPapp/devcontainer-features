cd "$(dirname "$0")"
nix build .
sudo rm -rf ../result
mkdir ../result
cp -r result/* ../result/