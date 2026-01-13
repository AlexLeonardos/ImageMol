# ==========================================
# STAGE 1: The Builder
# ==========================================
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04 AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget bzip2 git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

# Create the environment and install everything
# We use 'conda clean' and '--no-cache-dir' to keep the size down immediately
ENV PATH=/opt/conda/bin:$PATH
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
RUN conda create -y -n imagemol python=3.10 && \
    conda install -y -n imagemol -c conda-forge rdkit
RUN /opt/conda/envs/imagemol/bin/pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121 && \
    /opt/conda/envs/imagemol/bin/pip install --no-build-isolation torch-cluster torch-scatter torch-sparse torch-spline-conv -f https://data.pyg.org/whl/torch-2.9.1+cpu.html && \
    conda clean -afy


# Copy and install your requirements
COPY requirements.txt /tmp/requirements.txt
RUN /opt/conda/envs/imagemol/bin/pip install --no-cache-dir -r /tmp/requirements.txt

# CRITICAL: Remove conda index caches and package tarballs
RUN conda clean -afy

# ==========================================
# STAGE 2: The Final Runtime
# ==========================================
FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

# Only install the bare essentials for the OS to run
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxrender1 libxext6 && \
    rm -rf /var/lib/apt/lists/*

# Copy the entire conda environment from the builder stage
COPY --from=builder /opt/conda /opt/conda


# Set environment paths
ENV PATH=/opt/conda/envs/imagemol/bin:/opt/conda/bin:$PATH

WORKDIR /workspace

# 4. Copy over application files
COPY . /workspace

CMD ["/bin/bash"]