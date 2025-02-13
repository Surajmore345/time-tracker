#!/bin/bash

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token
USERNAME=$username
TOKEN=$token

# User and Repository information
REPO_OWNER=$1
REPO_NAME=$2

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send a GET request to the GitHub API with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access to the repository
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    # Fetch the list of collaborators on the repository
    response=$(github_api_get "$endpoint")

    # Check if the response is empty or invalid
    if [[ -z "$response" || "$response" == *"Not Found"* ]]; then
        echo "Error: Unable to fetch collaborators for ${REPO_OWNER}/${REPO_NAME}. Please check the repository or access permissions."
        exit 1
    fi

    # Check if the response is a valid JSON array
    if [[ $(echo "$response" | jq 'type') == "\"array\"" ]]; then
        # Filter for collaborators with read (pull) access
        collaborators=$(echo "$response" | jq -r '.[] | select(.permissions.pull == true) | .login')

        # Display the list of collaborators with read access
        if [[ -z "$collaborators" ]]; then
            echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
        else
            echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
            echo "$collaborators"
        fi
    else
        # If no array or unexpected structure, print raw response for debugging
        echo "Unexpected response format. Raw response:"
        echo "$response"
    fi
}

# Main script

if [ -z "$REPO_OWNER" ] || [ -z "$REPO_NAME" ]; then
    echo "Please provide both repository owner and repository name."
    exit 1
fi

echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access

