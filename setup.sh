#!/bin/bash
# PetalSwarm Bootstrap Script for WSL
set -e

echo "🌸 PetalSwarm - Initializing Swarm Environment..."

# 1. Clone llama.cpp
if [ ! -d "llama.cpp" ]; then
    echo ">> Cloning llama.cpp (Commit c46583b)..."
    git clone https://github.com/ggerganov/llama.cpp.git
    cd llama.cpp
    git checkout c46583b
    cd ..
else
    echo ">> llama.cpp already exists."
fi

# 2. Clone nakshatra
if [ ! -d "nakshatra" ]; then
    echo ">> Cloning nakshatra..."
    git clone https://github.com/fthrvi/nakshatra.git
else
    echo ">> nakshatra already exists."
fi

# 3. Apply Nakshatra M4 patches
echo ">> Applying Nakshatra M4 patches..."
cd llama.cpp
for p in ../nakshatra/experiments/v0.0/m4_patches/*.patch; do
    echo "   Applying $p..."
    git apply "$p" || echo "   [Warning] Patch $p failed (maybe already applied)"
done

# 4. Apply custom PetalSwarm worker patch
echo ">> Applying custom worker patch..."
git apply ../patches/llama-cpp-nakshatra.patch || echo "   [Warning] Custom patch failed"
cd ..

# 5. Build in WSL (CPU mode for now)
echo ">> Building llama-nakshatra-worker..."
cd llama.cpp
cmake -B build
cmake --build build --target llama-nakshatra-worker -j$(nproc)
cd ..

# 6. Setup Python venv
echo ">> Setting up Python virtual environment..."
cd nakshatra
python3 -m venv venv
./venv/bin/pip install --upgrade pip
./venv/bin/pip install grpcio grpcio-tools pyyaml gguf-py numpy tqdm llama-cpp-python
./venv/bin/pip install ../llama.cpp/gguf-py

# 7. Generate gRPC stubs
echo ">> Generating gRPC stubs..."
./venv/bin/python -m grpc_tools.protoc -I proto --python_out=scripts --grpc_python_out=scripts proto/nakshatra.proto
cd ..

echo "🌸 PetalSwarm - Setup Complete! Ready for inference."
