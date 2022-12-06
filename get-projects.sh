#!/bin/bash

set -e

#Get ORGNAME from user
if [[ $# -ne 1 ]]; then
  echo "Error: Unsupported number of arguments"
  echo
  echo "USAGE:"
  echo "    get-projects.sh <organization> "
  echo
  echo "WHERE:"
  echo "    organization   The Google Cloud Organization name"
  echo "                   - You have access to the follwing Organizations:"
  echo 
  echo "                    " $(gcloud organizations list --format="value[separator="\\n"](displayName)")
  echo 
  echo 

  exit 1
fi

ORGNAME=$1

#if [ ${#ORGNAME} -gt 30 ]; then
#  echo "Length of 'Organization' input argument must not exceed 30 characters"
#  exit 1
#fi

if [[ ! $ORGNAME =~ ^["."a-z0-9\-]+$ ]]; then
  echo "'name' input argument should only contain lowercase alphanumeric characters, hyphens, and periods"
  exit 1
fi

# Get Organization ID
echo "Getting Organization ID for ${ORGNAME}"
ORG_ID=$(gcloud organizations list --filter displayName="${ORGNAME}" --format="value(ID)")

export PROJECTS=""

# Get Folders in Organization
echo "Getting Folders and Projects for Organization ${ORGNAME}: ${ORG_ID}"
PROJECTS+=($(gcloud projects list --filter parent.type="organization" --filter parent.id="${ORG_ID}" --format="csv[no-heading](projectId,parent.id)" ))

  for folder1 in $(gcloud resource-manager folders list --organization="${ORG_ID}"  --format="value(ID)") 
  do 
    echo "${ORG_ID} -->  ${folder1}"
    PROJECTS+=($(gcloud projects list --filter parent.type="folder" --filter parent.id="${folder1}" --format="csv[no-heading](projectId,parent.id)" ))
    for folder2 in $(gcloud resource-manager folders list --folder="${folder1}"  --format="value(ID)")  
      do
        echo "${ORG_ID} --> ${folder1} --> ${folder2}"
        PROJECTS+=($(gcloud projects list --filter parent.type="folder" --filter parent.id="${folder2}"  --format="csv[no-heading](projectId,parent.id)" ))
    done
  done

# Get all Projects in Organization by Folder
echo "projectId,parent_id" > projects.temp
for each in "${PROJECTS[@]}"
do
  echo "$each" >> projects.temp
done

echo 

cat projects.temp | grep -v '^[[:space:]]*$' > projects.csv
rm -f projects.temp

cat projects.csv
