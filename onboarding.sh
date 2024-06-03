#!/bin/bash

# Function to check and install Homebrew
install_homebrew() {
  if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

# Function to install required tools
install_required_tools() {
  # Install 1Password CLI
  if ! command -v op &> /dev/null; then
    echo "1Password CLI not found. Installing 1Password CLI..."
    brew install 1password-cli
  fi

  # Install GitHub CLI
  if ! command -v gh &> /dev/null; then
    echo "GitHub CLI not found. Installing GitHub CLI..."
    brew install gh
  fi

  # Install OrbStack
  if [ ! -d "/Applications/OrbStack.app" ]; then
    echo "OrbStack not found. Installing OrbStack..."
    brew install --cask orbstack
  else
    echo "OrbStack is already installed."
  fi

  # Install mkcert
  if ! command -v mkcert &> /dev/null; then
    echo "mkcert not found. Installing mkcert..."
    brew install mkcert
  fi
}

# Function to sign in to 1Password and check organization membership
signin_op_cli() {
  eval $(op signin)

  # Check if the user has the Lhotse Technologies account
  if ! op account list | grep -q "lhotsetechnologiesgmbh.1password.com"; then
    echo "You must be a member of the Lhotse Technologies organization in 1Password."
    exit 1
  fi
}

# Function to log in to GitHub CLI
login_github_cli() {
  if ! gh auth status &> /dev/null; then
    echo "Please log in to GitHub using the GitHub CLI."
    gh auth login

    # Check if the user is logged in
    while ! gh auth status &> /dev/null; do
      echo "Waiting for GitHub login to complete..."
      sleep 2
    done

    echo "GitHub login successful."
  else
    echo "Already logged in to GitHub CLI."
  fi
}

# Function to create project folder and set as environment variable
create_project_folder() {
  PROJECT_DIR=$(pwd)/lhotse-onboarding
  if [ ! -d "$PROJECT_DIR" ]; then
    mkdir -p "$PROJECT_DIR"
    echo "Created project folder at $PROJECT_DIR"
  else
    echo "Folder already exists at $PROJECT_DIR"
  fi
  export PROJECT_DIR
  echo "export PROJECT_DIR=$PROJECT_DIR" >> ~/.zshrc
  source ~/.zshrc
  cd "$PROJECT_DIR" || exit
}

# Function to check if projects exist or clone them using GitHub CLI
check_and_clone_projects() {
  if [ ! -d "supercharger" ]; then
    gh repo clone Lhotse-Technologies/supercharger
  fi
  if [ ! -d "supercharger-be" ]; then
    gh repo clone Lhotse-Technologies/supercharger-be
  fi
  if [ ! -d "customer-portal" ]; then
    gh repo clone Lhotse-Technologies/customer-portal
  fi
}

# Function to prompt the user to continue with project setup
prompt_project_setup() {
  read -p "Do you want to continue with the setup for supercharger-be? (yes/no) " response
  if [[ "$response" == "yes" ]]; then
    cd "$PROJECT_DIR/supercharger-be" || exit
    ./project_setup.sh
  else
    echo "Skipping supercharger-be setup."
  fi
}

# Main script execution
install_homebrew
install_required_tools
signin_op_cli
login_github_cli
create_project_folder
check_and_clone_projects
prompt_project_setup

echo "Onboarding script completed successfully."
