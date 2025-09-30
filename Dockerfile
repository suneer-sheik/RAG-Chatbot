# Stage 1: The Builder Stage
# Use a full Python image to ensure all necessary build tools (compilers, headers) are available
FROM python:3.10 AS builder

## Essential environment variables (can be set here or in the final stage)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# 1. Install System Build Dependencies
# Note: This step is combined and cleaned up immediately to minimize layer size.
# build-essential is required for packages like torch, numpy, etc., that compile C/C++ extensions.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
    && rm -rf /var/lib/apt/lists/*

# 2. Copy only the dependency file first for optimal Docker layer caching
# Assuming your direct dependencies are in setup.py (due to -e .) or requirements.txt
COPY requirements.txt .
COPY setup.py .

# 3. Install Python dependencies using the user directory to easily copy them later
# We install the package in editable mode (-e .) to ensure all code is properly installed
# and place the dependencies in the user's home path, which is easy to copy.
# NOTE: If you are using setuptools, ensure your setup.py installs dependencies.
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir -e . --user

# ---
# Stage 2: The Final (Runtime) Stage
# Use the minimal 'slim' image for the smallest production image size
FROM python:3.10-slim

## Essential environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# 4. Copy the installed dependencies from the 'builder' stage
# This copies the entire python site-packages/user-site-packages content, leaving build-essential behind.
# We explicitly specify python3.10 in the path.
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /root/.local/lib/python3.10/site-packages /root/.local/lib/python3.10/site-packages
# If your project installs scripts (e.g., an entry point), copy those too
COPY --from=builder /usr/local/bin /usr/local/bin

# 5. Copy the rest of the application code
# This step is last, so changes to your app code don't invalidate the slow dependency install step.
COPY . .

## Expose only flask port
EXPOSE 5000

## Run the Flask app
# CMD will likely need to reference the entry point script or the app location
CMD ["python", "app/application.py"]