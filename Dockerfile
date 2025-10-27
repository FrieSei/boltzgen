# syntax=docker/dockerfile:1.6
FROM nvidia/cuda:12.1.1-cudnn-runtime-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG MINIFORGE_VERSION=24.7.1-0
ARG MINIFORGE_SHA256=b64f77042cf8eafd31ced64f9253a74fb85db63545fe167ba5756aea0e8125be

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    wget \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Miniforge (conda) under /opt/conda
RUN wget -q https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-${MINIFORGE_VERSION}-Linux-x86_64.sh \
    && echo "${MINIFORGE_SHA256}  Miniforge3-${MINIFORGE_VERSION}-Linux-x86_64.sh" | sha256sum -c - \
    && bash Miniforge3-${MINIFORGE_VERSION}-Linux-x86_64.sh -b -p /opt/conda \
    && rm Miniforge3-${MINIFORGE_VERSION}-Linux-x86_64.sh

ENV PATH=/opt/conda/bin:$PATH

SHELL ["/bin/bash", "-lc"]

RUN conda update -n base -c defaults conda -y && conda clean -afy
RUN conda create -n boltzgen python=3.12 -y && conda clean -afy
RUN conda install -n boltzgen -c conda-forge rdkit=2024.09.1 -y && conda clean -afy

WORKDIR /workspace
COPY . /workspace

# Upgrade pip/setuptools first
RUN conda run -n boltzgen pip install --upgrade pip setuptools wheel

# Install CUDA-enabled PyTorch (cu121)
RUN conda run -n boltzgen pip install --no-cache-dir \
    torch==2.4.1+cu121 \
    torchvision==0.19.1+cu121 \
    torchaudio==2.4.1+cu121 \
    --index-url https://download.pytorch.org/whl/cu121

# Install remaining Python dependencies (many are already listed in boltzgen's pyproject)
RUN conda run -n boltzgen pip install --no-cache-dir \
    numpy==2.1.3 \
    numba==0.61.0 \
    hydride \
    pdbeccdutils \
    pydssp \
    einops \
    einx \
    mashumaro \
    logomaker \
    biotite \
    gemmi==0.6.5 \
    edit_distance \
    pandas \
    matplotlib \
    biopython \
    scikit-learn \
    huggingface_hub \
    tqdm \
    && conda clean -afy

# Install BoltzGen in editable mode (uses the copy shipped with this repo)
RUN conda run -n boltzgen pip install --no-cache-dir -e /workspace/BoltzGen/external/boltzgen

# Install CUDA equivariance kernels after boltzgen is available
RUN conda run -n boltzgen pip install --no-cache-dir \
    cuequivariance_ops_cu12==0.5.0 \
    cuequivariance_ops_torch_cu12==0.5.0 \
    cuequivariance_torch==0.5.0

# Create cache directories for model weights / plots
RUN mkdir -p /opt/boltzgen_cache /opt/boltzgen_logs

ENV HF_HOME=/opt/boltzgen_cache \
    HF_HUB_CACHE=/opt/boltzgen_cache \
    BOLTZGEN_CACHE=/opt/boltzgen_cache \
    MPLCONFIGDIR=/opt/boltzgen_logs \
    PYTHONUNBUFFERED=1

# Default entrypoint drops into the boltzgen conda environment
ENTRYPOINT ["/opt/conda/bin/conda", "run", "--no-capture-output", "-n", "boltzgen"]
CMD ["bash"]
