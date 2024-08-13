# Use Python 3.8 slim image as the base
FROM python:3.8-slim

# Create a non-root user 'appuser' with UID 1000 and GID 1000
RUN groupadd --gid 1000 appuser \
    && useradd --uid 1000 --gid 1000 -ms /bin/bash appuser

# Upgrade pip and install virtualenv
RUN pip3 install --no-cache-dir --upgrade \
    pip \
    virtualenv

# Update package lists and install necessary build tools and git
RUN apt-get update && apt-get install -y \
    build-essential \
    software-properties-common \
    git

# Switch to the non-root user
USER appuser
# Set the working directory
WORKDIR /home/appuser

# Clone the streamlit example repository
RUN git clone https://github.com/streamlit/streamlit-example.git app

# Set up a virtual environment
ENV VIRTUAL_ENV=/home/appuser/venv
RUN virtualenv ${VIRTUAL_ENV}
# Activate the virtual environment and install requirements
RUN . ${VIRTUAL_ENV}/bin/activate && pip install -r app/requirements.txt

# Expose port 8501 for Streamlit
EXPOSE 8501

# Copy the run script to the container
COPY run.sh /home/appuser
# Make the run.sh file executable
RUN chmod +x /home/appuser/run.sh
# Set the entrypoint to the run script
ENTRYPOINT ["./run.sh"]
