# Stage 1: Build Stage
FROM python:3.10-slim as builder

# Essential environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set work directory inside docker container
WORKDIR /app

# Installing build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy the current directory content into the container
COPY . .

# Install python dependencies (in a virtual environment to isolate them)
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime Stage
FROM python:3.10-slim

# Essential environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app

# Install only the runtime dependencies (no build tools)
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy only the necessary files from the builder stage (no build dependencies)
COPY --from=builder /app /app

# Install Python dependencies (no need to run "pip install" again)
RUN pip install --no-cache-dir -e .

# Expose the port for flask app
EXPOSE 5000

# Set the command to run the app
CMD ["python", "app/application.py"]