# Python imgafe for container
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy dependencies
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code and model to container
COPY inference.py .
COPY doubleit_model.pt .

# Command to run the script
CMD ["python", "inference.py"]
