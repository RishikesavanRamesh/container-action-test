# Define the base image tag as an argument
ARG ROS_DISTRO=humble

# Set the base image to use for subsequent instructions
FROM ros:${ROS_DISTRO}

# Define additional build arguments
ARG PACKAGE_NAME

# Set the working directory inside the container
WORKDIR /usr/src

# Copy any source file(s) required for the action
COPY ./test-folder/${PACKAGE_NAME} ./${PACKAGE_NAME}

# Copy any source file(s) required for the action
COPY entrypoint.sh .

# Make the entrypoint script executable
RUN chmod +x entrypoint.sh

# Configure the container to be run as an executable
ENTRYPOINT ["/usr/src/entrypoint.sh"]
