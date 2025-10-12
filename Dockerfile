# Dockerfile
# Build stage
FROM python:3.11-slim AS builder
WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt --prefix=/install

# Final stage
FROM python:3.11-slim
ENV PATH=/install/bin:$PATH
WORKDIR /app
COPY --from=builder /install /install
COPY app /app
ENV PYTHONUNBUFFERED=1
ENV IMAGE_TAG=${IMAGE_TAG:-local}
EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app", "--workers", "2", "--threads", "4"]
