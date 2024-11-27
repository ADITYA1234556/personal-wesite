# Use the official Python image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY wait.sh /wait.sh
RUN chmod +x /wait.sh
COPY . /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libmariadb-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the Flask app's port
EXPOSE 5002

# Run the application
CMD ["/wait.sh", "mysql:3306", "--", "python", "main.py"]

