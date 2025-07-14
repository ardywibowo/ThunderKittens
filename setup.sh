sudo apt update
sudo apt install gcc-11 g++-11

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 --slave /usr/bin/g++ g++ /usr/bin/g++-11

sudo apt update
sudo apt install clang

sudo apt install npm

mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc   # or .zshrc
source ~/.bashrc            # reload your shell
npm install -g @anthropic-ai/claude-code

conda create -n kittens python=3.11
conda activate kittens
pip install cuda==12.4.0 -c nvidia
pip install pytorch torchvision torchaudio
pip install pybind11

pip install -e .
