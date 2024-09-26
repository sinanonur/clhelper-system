#!/bin/bash

# Create a temporary directory
TEMP_DIR=$(mktemp -d)

# Function to clean up the temporary directory on exit
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Step 1: Clone the repository into the temporary directory
REPO_URL="https://github.com/sinanonur/clhelper-system.git"
git clone "$REPO_URL" "$TEMP_DIR"

# Step 2: Check for Ollama installation
if ! command -v ollama &> /dev/null; then
    echo "Ollama is not installed."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        read -p "Do you want to install Ollama? (y/n): " install_ollama
        if [[ "$install_ollama" == "y" ]]; then
            curl -fsSL https://ollama.com/install.sh | sh
        else
            echo "Ollama installation aborted. Exiting."
            exit 1
        fi
    else
        echo "Please install Ollama manually for your operating system. Exiting."
        exit 1
    fi
else
    echo "Ollama is already installed."
fi

# Step 3: Set up the model using the modelfile from the temporary directory
ollama create clhelper -f "$TEMP_DIR/modelfile"

# Step 4: Determine shell type and suggest configuration file
SHELL_TYPE=$(basename "$SHELL")
DEFAULT_CONFIG_FILE=""

case "$SHELL_TYPE" in
    bash)
        DEFAULT_CONFIG_FILE="$HOME/.bashrc"
        ;;
    zsh)
        DEFAULT_CONFIG_FILE="$HOME/.zshrc"
        ;;
    *)
        echo "Unknown shell type. Please specify your shell configuration file."
        ;;
esac

# Ask the user for the configuration file, with a default suggestion
read -p "Enter the path to your shell configuration file [default: $DEFAULT_CONFIG_FILE]: " CONFIG_FILE
CONFIG_FILE=${CONFIG_FILE:-$DEFAULT_CONFIG_FILE}

# Step 5: Add the bash function
NL_CMD_FUNCTION=$(cat << 'EOF'
function nlcmd() {
    if [ $# -eq 0 ]; then
        echo "Usage: nlcmd 'your natural language command here'"
        return 1
    fi

    local nl_command="$*"
    local bash_command

    # Run the natural language command through clhelper
    bash_command=$(ollama run clhelper "$nl_command")

    if [ -z "$bash_command" ]; then
        echo "Error: clhelper didn't return a valid bash command."
        return 1
    fi

    echo "Generated bash command:"
    echo "$bash_command"
    echo

    # Ask for confirmation before executing
    echo -n "Do you want to execute this command? (y/n): "
    read confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        echo "Executing command..."
        eval "$bash_command"
    else
        echo "Command execution cancelled."
    fi
}
EOF
)

if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
    if ! grep -q "function nlcmd" "$CONFIG_FILE"; then
        echo "$NL_CMD_FUNCTION" >> "$CONFIG_FILE"
        echo "Added nlcmd function to $CONFIG_FILE"
    else
        echo "nlcmd function already exists in $CONFIG_FILE"
    fi
else
    echo "Configuration file not found or not specified. Please check the path and try again."
    exit 1
fi

# Step 6: Remind the user to source the configuration file
echo "Setup complete. Please restart your terminal or run the following command to apply changes:"
echo "source $CONFIG_FILE"