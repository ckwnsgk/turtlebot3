FROM dnldnwls1123/ros:${ROS_DISTRO:-jazzy}-camera-ros

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3-argcomplete \
    python3-colcon-common-extensions \
    libboost-system-dev \
    build-essential \
    ros-jazzy-hls-lfcd-lds-driver \
    ros-jazzy-turtlebot3-msgs \
    ros-jazzy-dynamixel-sdk \
    libudev-dev \
    && rm -rf /var/lib/apt/lists/*

# Create workspace and clone repositories
WORKDIR /root
RUN mkdir -p /root/turtlebot3_ws/src
WORKDIR /root/turtlebot3_ws/src
RUN git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3.git && \
    git clone -b jazzy https://github.com/ROBOTIS-GIT/ld08_driver.git && \
    cd turtlebot3 && \
    rm -r turtlebot3_cartographer turtlebot3_navigation2

# Source ROS setup file
RUN echo 'source /opt/ros/jazzy/setup.bash' >> /root/.bashrc

# Build the workspace
WORKDIR /root/turtlebot3_ws
RUN /bin/bash -c "source /opt/ros/jazzy/setup.bash && \
    colcon build --symlink-install --parallel-workers 1"

# Source workspace setup file
RUN echo 'source /root/turtlebot3_ws/install/setup.bash' >> /root/.bashrc

# Setup udev rules
RUN /bin/bash -c "source /opt/ros/jazzy/setup.bash && \
    mkdir -p /etc/udev/rules.d && \
    cp \$(ros2 pkg prefix turtlebot3_bringup)/share/turtlebot3_bringup/script/99-turtlebot3-cdc.rules /etc/udev/rules.d/"

# Set environment variables
RUN echo 'export LDS_MODEL=LDS-02' >> /root/.bashrc
RUN echo 'export TURTLEBOT3_MODEL=burger' >> /root/.bashrc

# Set the entrypoint
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["source /root/.bashrc && bash"]
