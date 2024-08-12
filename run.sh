#!/bin/bash
# Define the path to the command we'll be running
COMMAND_PATH=${HOME}/app/streamlit_app.py

# Set an empty variable to store the process ID
APP_PID=

# Define a function to stop the running process
stopRunningProcess() {
    # Check if the process is running
    if test ! "${APP_PID}" = '' && ps -p ${APP_PID} > /dev/null ; then
        # Log that we're stopping the process
        > /proc/1/fd/1 echo "Stopping ${COMMAND_PATH} which is running with process ID ${APP_PID}"

        # Send a termination signal to the process
        kill -TERM ${APP_PID}
        > /proc/1/fd/1 echo "Waiting for ${COMMAND_PATH} to process SIGTERM signal"

        # Wait for the process to finish
        wait ${APP_PID}
        > /proc/1/fd/1 echo "All processes have stopped running"
    else
        # Log if the process wasn't running
        > /proc/1/fd/1 echo "${COMMAND_PATH} was not started when the signal was sent or it has already been stopped"
    fi
}

# Set up a trap to catch EXIT and TERM signals and run stopRunningProcess
trap stopRunningProcess EXIT TERM

# Activate the virtual environment
source ${VIRTUAL_ENV}/bin/activate

# Run the Streamlit app in the background
streamlit run ${COMMAND_PATH} &
# Capture the process ID of the Streamlit app
APP_PID=$!

# Wait for the Streamlit app to finish
wait ${APP_PID}
