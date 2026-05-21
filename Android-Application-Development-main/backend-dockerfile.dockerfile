FROM python:3.10-slim

WORKDIR /app

# Install system dependencies needed for AI models / OpenCV if applicable
RUN apt-get update && apt-get install -y \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install python libraries
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your backend code
COPY . .

EXPOSE 8000

# Adjust this command depending on your entry point (e.g., uvicorn main:app)
CMD ["python", "main.py"]