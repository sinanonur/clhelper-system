# CLHelper System

This repository contains instructions and files for setting up and using the CLHelper system, a command-line helper based on the Ollama AI model.

## Usage

Use the `nlcmd` function followed by your natural language command in quotes:

```bash
nlcmd "create a new directory called test_folder"
```

The system will generate a bash command, show it to you, and ask for confirmation before executing it.


## Prerequisites

- [Ollama](https://ollama.ai/) installed on your system

## Setup

### Method 1: Automated Setup with `curl-setup.sh`

We have provided a dedicated script that downloads and executes the main setup script in a more controlled environment. To set up the CLHelper system automatically, run the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/sinanonur/clhelper-system/refs/heads/main/curl-setup.sh | bash
```

This script will:
- Download the main setup script to a temporary location.
- Run the main setup script in an interactive shell, ensuring proper handling of inputs and environment variables.
- Clean up any temporary files after execution.

### Method 2: Manual Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/sinanonur/clhelper-system.git
   cd clhelper-system
   ```

2. Create the CLHelper Ollama model:
   ```bash
   ollama create clhelper -f modelfile
   ```

3. Add the following function to your `~/.bashrc` or `~/.bash_profile`:

   ```bash
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
   ```

4. Reload your shell configuration:
   ```bash
   source ~/.bashrc  # or source ~/.bash_profile
   ```


## Note

Always review the generated command before confirming its execution to ensure it matches your intentions.
*DISCLAIMER*: I accept no responsibility for the commands it generates. Do it where you think it is safe and again always check the commands.

Let me know if you need further adjustments or additions!