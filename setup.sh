#!/bin/bash

# Exit on any error
set -e

echo "=== ThunderKittens Setup Script ==="

# System packages
echo "Installing system packages..."
sudo apt update
sudo apt install gcc-11 g++-11 clang-17 npm

# Set up gcc-11 as default
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 --slave /usr/bin/g++ g++ /usr/bin/g++-11

# Set up npm global directory
echo "Setting up npm..."
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/.npm-global/bin:$PATH"
npm install -g @anthropic-ai/claude-code

# Create conda environment
echo "Setting up conda environment..."
conda create -n kittens python=3.11 -y
echo "Activating conda environment..."
eval "$(conda shell.bash hook)"
conda activate kittens

# Install CUDA and PyTorch with proper CUDA support
echo "Installing CUDA and PyTorch..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
pip install pybind11 ninja

# Set up CUDA environment (must be done before building)
echo "Setting up CUDA environment..."
export CUDA_HOME=/usr/local/cuda
export PATH=${CUDA_HOME}/bin:${PATH}
echo "export CUDA_HOME=/usr/local/cuda" >> ~/.bashrc
echo "export PATH=\"\${CUDA_HOME}/bin:\${PATH}\"" >> ~/.bashrc

# Set up library path for PyTorch CUDA libraries
echo "Setting up library paths..."
TORCH_LIB_PATH=$(python -c "import torch; import os; print(os.path.join(os.path.dirname(torch.__file__), 'lib'))")
echo "export LD_LIBRARY_PATH=\"$TORCH_LIB_PATH:\${CUDA_HOME}/lib64:\$LD_LIBRARY_PATH\"" >> ~/.bashrc
export LD_LIBRARY_PATH="$TORCH_LIB_PATH:${CUDA_HOME}/lib64:$LD_LIBRARY_PATH"

# Install ThunderKittens
echo "Installing ThunderKittens..."
export CC=/usr/bin/gcc-11
export CXX=/usr/bin/g++-11
pip install -e .

# Test the installation
echo "Testing installation..."
python -c "import thunderkittens as tk; print('✓ ThunderKittens imported successfully!')"

echo "=== Setup Complete! ==="
echo "Please run 'source ~/.bashrc' or restart your shell to ensure all environment variables are loaded."
echo "Then activate the environment with: conda activate kittens"
