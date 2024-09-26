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

# Step 4: Determine shell type
SHELL_TYPE=$(basename "$SHELL")
CONFIG_FILE=""

case "$SHELL_TYPE" in
    bash)
        CONFIG_FILE="$HOME/.bashrc"
        ;;
    zsh)
        CONFIG_FILE="$HOME/.zshrc"
        ;;
    *)
        read -p "Enter the path to your shell configuration file: " CONFIG_FILE
        ;;
esac

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

if ! grep -q "function nlcmd" "$CONFIG_FILE"; then
    echo "$NL_CMD_FUNCTION" >> "$CONFIG_FILE"
    echo "Added nlcmd function to $CONFIG_FILE"
else
    echo "nlcmd function already exists in $CONFIG_FILE"
fi

# Step 6: Source the configuration file only if it's the correct shell
if [[ "$SHELL_TYPE" == "bash" ]]; then
    source "$HOME/.bashrc"
elif [[ "$SHELL_TYPE" == "zsh" ]]; then
    source "$HOME/.zshrc"
else
    echo "Please manually source your shell configuration file."
fi

echo "Configuration file sourced. Setup complete."