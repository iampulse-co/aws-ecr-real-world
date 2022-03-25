#!/bin/bash
set -e

# Test if required variable $MY_NAME is empty, and if so exit with helpful error message
if [ -z "$MY_NAME" ]; then
  echo 1>&2 "Oh no, did you set the \$MY_NAME variable when launching? Try that :)"
  echo 1>&2 "The command should look like this: docker run -e MY_NAME=Kyler hello-name "
  exit 1
fi

# Now that variable is set, we can use it
echo "Hi ${MY_NAME}! Learning Docker isn't too scary, huh?"
echo "We're just printing the variable, but imagine what else you could do, huh?"

