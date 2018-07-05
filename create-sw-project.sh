#!/bin/bash

set -eu

# Assumes that ${GOOGLE_CREDENTIALS} is set to a service account 
# that has the roles/resourceManager.projectCreator, 
# roles/resourceManager.projectIamAdmin, roles/iam.serviceAccountAdmin

ORG_ID=
PROJECT_NAME=

function usage {
    echo "$0 <organization id> <project id> <project name>"
    echo ""
    echo "The project id must start with a letter and contain only alphanumerics "
    echo "and dashes."
    exit 1
}

if [[ $# -ne 3 ]]
then
    usage
fi

ORG_ID=$1
PROJECT_ID=$2
PROJECT_NAME=$3

if [[ -a ${PROJECT_ID} ]]
then
    echo "A file associated with ${PROJECT_ID} already exists"
    exit 1
fi

# Need to test that this is a valid project name
if [[ ! -a projects ]]
then
    mkdir projects
elif [[ ! -d projects || ! -w projects ]]
then
    echo "The projects file is not a directory or could not be written to"
    exit 1
fi

cp -R create-project projects/${PROJECT_ID}

cat << EOF > projects/${PROJECT_ID}/${PROJECT_ID}.tfvars
org_id = "$ORG_ID"
project_id = "$PROJECT_ID"
project_name = "$PROJECT_NAME"
EOF

terraform init -input=false projects/${PROJECT_ID}

terraform plan -input=false -var-file=projects/${PROJECT_ID}/${PROJECT_ID}.tfvars \
               -out=projects/${PROJECT_ID}/create-project.plan.tf \
               projects/${PROJECT_ID}
