FROM python:3.10-slim

## Essential environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

## Set work directory inside docker container
WORKDIR /app

## Installing system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

## copying all files to the working directory
COPY . /app/

## Install python dependencies
RUN pip install --no-cache-dir -e .

## Expose flask port
EXPOSE 5000

## Run the flask app
CMD ["python", "app/application.py"]