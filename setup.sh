#!/bin/bash

# Exit on any error
set -e

echo "=== ThunderKittens Setup Script ==="

# ----------------------------------------------------------------------
# 1. System packages
# ----------------------------------------------------------------------
echo "Installing system packages..."
sudo apt update
sudo apt install -y gcc-11 g++-11 clang-17 npm

# Make gcc-11 the default (also sets g++)
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 \
                          --slave /usr/bin/g++ g++ /usr/bin/g++-11

# ----------------------------------------------------------------------
# 2. npm global directory
# ----------------------------------------------------------------------
echo "Setting up npm..."
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/.npm-global/bin:$PATH"
npm install -g @anthropic-ai/claude-code

# ----------------------------------------------------------------------
# 3. Conda environment
# ----------------------------------------------------------------------
echo "Setting up conda environment..."
conda create -n kittens python=3.11 -y

echo "Activating conda environment..."
eval "$(conda shell.bash hook)"
conda activate kittens

# ----------------------------------------------------------------------
# 4. CUDA-enabled PyTorch & build tools
# ----------------------------------------------------------------------
echo "Installing CUDA-enabled PyTorch and build tools..."
pip install torch torchvision torchaudio \
            --index-url https://download.pytorch.org/whl/cu121
pip install pybind11 ninja

# ----------------------------------------------------------------------
# 5. CUDA environment variables
# ----------------------------------------------------------------------
echo "Configuring CUDA environment..."
export CUDA_HOME=/usr/local/cuda
export PATH="${CUDA_HOME}/bin:${PATH}"
echo 'export CUDA_HOME=/usr/local/cuda' >> ~/.bashrc
echo 'export PATH="${CUDA_HOME}/bin:${PATH}"' >> ~/.bashrc

# Add PyTorch’s CUDA libs to LD_LIBRARY_PATH
echo "Setting up library paths..."
TORCH_LIB_PATH=$(python - <<'PY'
import os, torch
print(os.path.join(os.path.dirname(torch.__file__), "lib"))
PY
)
export LD_LIBRARY_PATH="${TORCH_LIB_PATH}:${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}"
echo "export LD_LIBRARY_PATH=\"${TORCH_LIB_PATH}:${CUDA_HOME}/lib64:\$LD_LIBRARY_PATH\"" >> ~/.bashrc

# ----------------------------------------------------------------------
# 6. ThunderKittens environment
# ----------------------------------------------------------------------
echo "Setting up ThunderKittens environment..."
export THUNDERKITTENS_ROOT=$(pwd)
echo "export THUNDERKITTENS_ROOT=$(pwd)" >> ~/.bashrc

# ----------------------------------------------------------------------
# 7. ThunderKittens source build
# ----------------------------------------------------------------------
echo "Installing ThunderKittens from source..."
export CC=/usr/bin/gcc-11
export CXX=/usr/bin/g++-11
pip install -e .

# ----------------------------------------------------------------------
# 8. Quick import test
# ----------------------------------------------------------------------
echo "Testing installation..."
python -c "import thunderkittens as tk; print('✓ ThunderKittens imported successfully!')"

echo "=== Setup Complete! ==="
echo "Run  'source ~/.bashrc'  (or restart your shell) to pick up new variables, "
echo "then activate the environment with:  conda activate kittens"
