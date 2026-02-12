# INFO.md

## Overview

This document explains the purpose and structure of the `bashme.sh` script, including a summary of its main logic and detailed documentation for each function.

---

## What the Script Does

The `bashme.sh` script is a Bash utility for managing custom Bash aliases and functions, as well as configuring the user's `.bashrc` file. It provides options to install, update, or uninstall a set of Bash aliases/functions (collectively called "BashMe"), and to set up a new `.bashrc` file. The script can also display help information.

The script supports the following main commands:
- `install` or `m`: Install or update BashMe aliases and functions.
- `rc` or `b`: Install a new `.bashrc` file (with backup and user confirmation).
- `uninstall` or `u`: Remove BashMe configuration and references.
- `help` or `h`: Display help information.

---

## Function Documentation

### `log()`
**Purpose:**
- Prints log messages with different levels (INFO, WARN, ERROR) and optional color formatting. Respects silent/error display flags.

**Parameters:**
- `$1`: Log level (INFO, WARN, ERROR)
- `$@`: Message to log

---

### `help()`
**Purpose:**
- Displays help information about the script's available options and their descriptions.

---

### `findBashMe()`
**Purpose:**
- Searches the user's home directory for any `.bash-me` file, indicating a previous BashMe installation.

---

### `bash_check()`
**Purpose:**
- Checks if BashMe is already referenced in the user's `.bashrc` file.
- Returns 0 if found, 1 otherwise.

---

### `downloadOrUseFile(FILE_NAME, DESCRIPTION)`
**Purpose:**
- Appends a local BashMe file to `~/.bash-me` if it exists, or downloads it from GitHub if not.
- Used for both aliases and functions files.

**Parameters:**
- `FILE_NAME`: Name of the file to use or download
- `DESCRIPTION`: Description for logging

---

### `bashMeUpdate()`
**Purpose:**
- Updates the BashMe aliases/functions by comparing the current and new versions, prompting the user before overwriting.
- Backs up the old `.bash-me` file if updating.
- Ensures BashMe is referenced in `.bashrc`.

---

### `deployBashMe()`
**Purpose:**
- Installs BashMe if not present, or offers to update if already installed.
- Prompts the user for confirmation before proceeding.
- Calls `downloadOrUseFile` for required files and adds BashMe to `.bashrc`.

---

### `addBashMe()`
**Purpose:**
- Appends a snippet to the user's `.bashrc` to source `~/.bash-me` if it exists.

---

### `destroyBashMe()`
**Purpose:**
- Removes the `.bash-me` file and its reference from `.bashrc`.
- Cleans up BashMe configuration from the user's environment.

---

### `setNewBashrc()`
**Purpose:**
- Sets up a new `.bashrc` file for the user, with backup and confirmation prompts.
- Chooses the appropriate template based on whether the user is root or not.
- Sources the new `.bashrc` after installation.

---

## Main Script Logic

- Exits on error (`set -e`).
- Checks for required arguments and prints usage if missing.
- Parses the first argument as the command and dispatches to the appropriate function:
    - `install`/`m` → `deployBashMe`
    - `rc`/`b` → `setNewBashrc`
    - `uninstall`/`u` → `destroyBashMe`
    - `help`/`h` → `help`
    - Any other value → error and usage message

---

## Notes
- The script uses a temporary file for intermediate operations and ensures cleanup with a `trap`.
- It supports both local and remote (GitHub) sources for BashMe files.
- User interaction is required for potentially destructive operations (overwriting files).

---

## Files Used
- `~/.bash-me`: Stores custom aliases and functions.
- `~/.bashrc`: User's Bash configuration file.
- `bash-files/`: Directory containing BashMe template files.

---

## Authors & License
- See the project README.md for authorship and licensing details.
