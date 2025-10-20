FROM python:3.11-slim AS builder

WORKDIR /app

# Install build tools and SSL certificates
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY app/requirements.txt .

# Upgrade pip and install dependencies
RUN pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt --prefix=/install
