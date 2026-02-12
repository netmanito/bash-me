
# Bash Me

Bash Me (bashme.sh) is a set of powerful aliases and functions for Bash, designed to boost your daily productivity. It includes Docker helpers, network tools, system utilities, and more, all easily managed from a single script.

## Installation

You can install Bash Me in three simple steps:

```
git clone https://github.com/netmanito/bash-me.git
cd bash-me
./bashme.sh install
```

### bashme.sh Options

* **install | i** — Install or update Bash Me aliases and functions in `~/.bash-me` and add sourcing to your `~/.bashrc` if not present.
* **bash | b** — Install or overwrite your `~/.bashrc` with the unified template (`bashrc_template.bash`). Backs up your old `.bashrc` as `.bashrc.orig`.
* **uninstall | u** — Remove `~/.bash-me` and its reference from your `.bashrc`.
* **help | h** — Show help and usage information.


## How it works

* A new file `~/.bash-me` will be created in your home directory containing all aliases and functions.
* Your `.bashrc` will be modified to include `.bash-me` at the end of the file:

    ```bash
    if [ -f ~/.bash-me ]; then
        source ~/.bash-me
    fi
    ```
* You can also use the `bash` option to install a unified, feature-rich `.bashrc` for any user (including root), based on `bashrc_template.bash`.

## TODO

* Add more aliases and functions.
* Improve documentation and examples.
* Create a more interactive installation process.
* Add support for other shells (e.g., Zsh, Fish).