# Use a lightweight base image with Miniconda pre-installed
FROM continuumio/miniconda3:latest

# Set the working directory inside the container
WORKDIR /model

# Copy the project files into the container
COPY . /model

# Install system dependencies (if needed)
RUN apt-get update && apt-get install -y \
    fuse \
    gcsfuse \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy the conda environment file into the container
COPY environment.yml /model/environment.yml
# Create the conda environment and activate it
RUN conda env create -f /model/environment.yml

# Make sure the conda environment is activated by default
SHELL ["conda", "run", "-n", "imagemol", "/bin/bash", "-c"]

# Install additional Python dependencies (if needed)
RUN pip install --no-cache-dir -r requirements.txt

# Set the default command to open an interactive shell - for mounting dataset
CMD ["/bin/bash"]