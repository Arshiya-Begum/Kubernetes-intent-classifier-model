FROM python:3.10-slim

# Prevent Python from writing .pyc files - Because we will be executing model as a container.
ENV PYTHONDONTWRITEBYTECODE=1
# Enable stdout/stderr flushing
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .

# Update system dependencies on base image by running sudo apt update and install requirements.txt.
# Running as one commad to reduce execution time.
# Removing unnecessary system dependencies to reduce docker image size
RUN apt-get update \
&& apt-get install -y --no-install-recommends gcc libc-dev \
&& pip install --no-cache-dir -r requirements.txt \
&& apt-get remove -y gcc libc-dev \
&& apt-get autoremove -y \
&& rm -rf /var/lib/apt/lists/*

# COPY the entire source code
COPY . .

# Run train.py to generate model file in model/artificats folder
RUN python3 model/train.py

# ONLY METADATA for reading the dockerfile
EXPOSE 6000

# Start the app with gunicorn for concurrency (4 workers, bind to 0.0.0.0:6000)
CMD ["gunicorn", "--workers", "4", "--bind", "0.0.0.0:6000", "app:app"]