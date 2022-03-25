# Make sure to start the docker process on your computer!

# Turn this on in mac to enable comments to be ignored
setopt interactive_comments

# Lets create a local name for our docker image to track our built docker file
# Feel free to update this name
DOCKER_LOCAL_NAME=hello-name

# Lets also create a tag for the image when its pushed to the ECR
# The default here is "latest"
DOCKER_ECR_TAG=latest

# Build the docker file
docker build . -t $DOCKER_LOCAL_NAME

# Show docker images
docker image ls

# Launch the docker file without a variable, note the (extraordinarily helpful!) error message
docker run $DOCKER_LOCAL_NAME

# Launch the docker file with the required variable
# Make sure to update "YourName" to your name! 
docker run -e MY_NAME=Kyler $DOCKER_LOCAL_NAME

# Print a few variables well pull from our terraform state
terraform output -raw ecr_repo_url
terraform output -raw region_name

# Map those variables to bash variables for commands:
ECR_URL=$(terraform output -raw ecr_repo_url)
REGION_NAME=$(terraform output -raw region_name)

# Tag container to link it to our ECR for pushing
docker tag \
    $DOCKER_LOCAL_NAME \
    ${ECR_URL}:$DOCKER_ECR_TAG

# Show docker images, note how new one listed with new tag, but image ID is the same
docker image ls

# Attempt to push to ECR from authenticated terminal
# AWS CLI is authenticated, but docker isnt, so this fails
docker push ${ECR_URL}:$DOCKER_ECR_TAG

# First set a variable we will need - the account ID
ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

# The AWS CLI can give us auth credentials that we can send to docker
# The sed part removes "-e none" which our terminal cannot interpret and would error out
aws ecr get-login-password \
    --region ${REGION_NAME} \
| docker login \
    --username AWS \
    --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION_NAME}.amazonaws.com

# Try push again now that we are authenticated, and we see it still fails due to policy
docker push ${ECR_URL}:$DOCKER_ECR_TAG

# Go to console, check policy and delete the deny rule

# Try push again now that we are authenticated and resource policy fixed, will succeed
docker push ${ECR_URL}:$DOCKER_ECR_TAG

# Profit


# Helpful commands

# Remove all stopped containers
docker rm $(docker ps --filter status=exited -q)

# Remove all unused images, do not prompt for confirmation
# WARN: Will delete all local images, make sure do not need anything in them
docker image prune -af