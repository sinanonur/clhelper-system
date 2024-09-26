# CLHelper System

This repository contains instructions and files for setting up and using the CLHelper system, a command-line helper based on the Ollama AI model.

## Prerequisites

- [Ollama](https://ollama.ai/) installed on your system
- [gh CLI](https://cli.github.com/) (GitHub Command Line Interface) installed and authenticated

## Setup

1. Clone this repository:
 ```bash
 git clone https://github.com/yourusername/clhelper-system.git
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

## Usage

Use the `nlcmd` function followed by your natural language command in quotes:

```bash
nlcmd "create a new directory called test_folder"
```

The system will generate a bash command, show it to you, and ask for confirmation before executing it.

## Note

Always review the generated command before confirming its execution to ensure it matches your intentions.

