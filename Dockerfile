# Define the base image tag as an argument
ARG ROS_DISTRO=humble

# Set the base image to use for subsequent instructions
FROM ros:${ROS_DISTRO}  AS build

# Define additional build arguments
ARG PACKAGE_NAME

# Copy any source file(s) required for the action
COPY ./test-folder/ ./build-bed




COPY . /build-bed

WORKDIR /build-bed/${PACKAGE_NAME}

ENV DEBIAN_FRONTEND=noninteractive

RUN <<EOF
apt-get update 
apt-get install -y python3-bloom python3-rosdep fakeroot debhelper dh-python
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
rm /etc/ros/rosdep/sources.list.d/20-default.list
sudo rosdep init
rosdep update
apt update
rosdep install --from-path . -y 
EOF

COPY <<EOF /binary-builder.sh
#!/bin/bash

# Find all directories containing package.xml
find . -type f -name "package.xml" | while read -r package_file; do
    dir=$(dirname "\$package_file")
    echo "Processing directory: \$dir"

    # Change to the directory
    (cd "\$dir" || { echo "Failed to enter directory \$dir"; exit 1; }

    # Run the commands
    bloom-generate rosdebian
    fakeroot debian/rules binary
    )
done
EOF

RUN <<EOF
chmod +x /binary-builder.sh
/binary-builder.sh
EOF

