#!/bin/bash

set -eu

# Assumes that ${GOOGLE_CREDENTIALS} is set to a service account 
# that has the roles/resourceManager.projectCreator, 
# roles/resourceManager.projectIamAdmin, roles/iam.serviceAccountAdmin

ORG_ID=
PROJECT_NAME=
PLAN_ONLY=1

function usage {
    echo "$0 [-a] <organization id> <project id> <project name>"
    echo ""
    echo "     -a: Runs the application of the terraform script"
    echo ""
    echo "The project id must start with a letter and contain only alphanumerics "
    echo "and dashes."
    exit 1
}

while getopts "a" OPT; do
    case $OPT in
        a)
            PLAN_ONLY=0
            ;;
        \?)
            usage
            ;;
    esac
done

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

PROJECT_DIR=projects/${PROJECT_ID}
VAR_FILE=${PROJECT_DIR}/${PROJECT_ID}.tfvars
PLAN_FILE=${PROJECT_DIR}/${PROJECT_ID}.plan.tf
TFSTATE_FILE=${PROJECT_DIR}/terraform.tfstate

terraform init -input=false projects/${PROJECT_ID}

terraform plan -input=false -var-file=${VAR_FILE} -out=${PLAN_FILE} ${PROJECT_DIR}

if [[ PLAN_ONLY -eq 0 ]]
then
    terraform apply -input=false -state=${TFSTATE_FILE} ${PLAN_FILE}
fi
