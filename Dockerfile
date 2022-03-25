FROM ubuntu:20.04

# Copy our startup script and mark as executable
COPY ./docker_start.sh .
RUN chmod +x docker_start.sh

# Set this script to launch on container launch
# Note: This blocks interactive docker mode, make sure to comment out and rebuild if you want interactive mode
ENTRYPOINT [ "./docker_start.sh" ]
