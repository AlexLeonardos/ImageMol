# Use a Miniconda3 image as the base
FROM continuumio/miniconda3

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container
COPY . .

# Create and activate the imagemol conda environment
RUN conda create -n imagemol python=3.9 -y && \
    echo "conda activate imagemol" >> ~/.bashrc && \
    /bin/bash -c "source ~/.bashrc"

# Install dependencies in the imagemol environment
RUN conda run -n imagemol pip install --no-cache-dir -r requirements.txt

# Set environment variables for GCP authentication
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/service-account-key.json

# Set the default command to start a bash shell
CMD ["/bin/bash"]