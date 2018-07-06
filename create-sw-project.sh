#!/bin/bash

set -eu

# Assumes that ${GOOGLE_CREDENTIALS} is set to a service account 
# that has the roles/resourceManager.projectCreator, 
# roles/resourceManager.projectIamAdmin, roles/iam.serviceAccountAdmin

ORG_ID=
PROJECT_NAME=
PROJECT_ID=
DOMAIN=
SUBDOMAIN=
BILLING_ACCT=
PLAN_ONLY=1

function usage {
    echo "$0 -o <organization id> -p <project id> -d <domain> -b <billing account name> [-n <project name] [-s <subdomain>] [-a]"
    echo ""
    echo "     -o <organization id> The GCP Organization ID [required]"
    echo "     -p <project ID> The GCP Project ID to create in the Organization [required]"
    echo "     -d <domain> The domain where the website will be created [required]"
    echo "     -b <billing accout name> The display name of the billing account [required]"
    echo "     -s <subdomain> The name of the subdomain to be built off the domain [optional]"
    echo "     -n <project name> [optional]"
    echo "     -a: Runs terraform apply to actually build the resources"
    echo ""
    echo "The project id must start with a letter and contain only alphanumerics "
    echo "and dashes."
    echo ""
    echo "If the subdomain or project name are not provided, the project ID will be used"
    exit 1
}

while getopts "an:d:b:s:o:p:" OPT; do
    case $OPT in
        a)
            PLAN_ONLY=0
            ;;
        n)
            PROJECT_NAME=${OPTARG}
            ;;
        d)
            DOMAIN=${OPTARG}
            ;;
        b)
            BILLING_ACCT=${OPTARG}
            ;;
        s)
            SUBDOMAIN=${OPTARG}
            ;;
        o)
            ORG_ID=${OPTARG}
            ;;
        p)
            PROJECT_ID=${OPTARG}
            ;;
        \?)
            usage
            ;;
    esac
done

# Check for the required arguments

if [[ -z ${ORG_ID} || -z ${PROJECT_ID} || -z ${DOMAIN} || -z ${BILLING_ACCT} ]]
then
    echo "One of the required arguments was not set"
    echo ""
    echo "ORG_ID=\'${ORG_ID}\' PROJECT_ID=\'${PROJECT_ID}\' DOMAIN=\'${DOMAIN}\' BILLING_ACCT=\'${BILLING_ACCT}\'"
    usage
fi

# Set from defaults

if [[ -z ${SUBDOMAIN} ]]
then
    SUBDOMAIN=${PROJECT_ID}
fi

if [[ -z ${PROJECT_NAME} ]]
then
    PROJECT_NAME=${PROJECT_ID}
fi

PROJECT_DIR=projects/${PROJECT_ID}
VAR_FILE=${PROJECT_ID}.tfvars
PLAN_FILE=${PROJECT_ID}.plan.tf

# TODO: Need to test that this is a valid project name and if it already exists
if [[ ! -a projects ]]
then
    mkdir projects
elif [[ ! -d projects || ! -w projects ]]
then
    echo "The projects file is not a directory or could not be written to"
    exit 1
fi

# Check if we already have a directory

if [[ -a ${PROJECT_DIR} ]]
then
    echo "A file associated with ${PROJECT_ID} already exists"
    exit 1
fi

cp -R create-project projects/${PROJECT_ID}

pushd projects/${PROJECT_ID}

cat << EOF > ${VAR_FILE}
org_id = "$ORG_ID"
project_id = "$PROJECT_ID"
project_name = "$PROJECT_NAME"
domain = "$DOMAIN"
subdomain = "$SUBDOMAIN"
billing_acct_name = "$BILLING_ACCT"
EOF

terraform init -input=false

terraform plan -input=false \
               -var-file=${VAR_FILE} \
               -out=${PLAN_FILE}

if [[ PLAN_ONLY -eq 0 ]]
then
    terraform apply -input=false ${PLAN_FILE}
fi

popd
