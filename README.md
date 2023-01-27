
# Sample Python + Docker Nix project

Demonstrates how to configure Nix with distinct development and deployment environments  
and how to build Docker container for deployment.

## Getting started

### Install Nix

On Linux run:
```sh
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```
or read the instructions at https://nix.dev/tutorials/install-nix

#### Validate Nix install

Open a **new terminal** and run:
```sh
$ nix --version
nix (Nix) 2.12.0
```

### Install direnv

```sh
sudo apt install direnv
```

Add the following line at the end of the `~/.bashrc` file:

```sh
eval "$(direnv hook bash)"
```

Make sure it appears even after `rvm`, `git-prompt` and other shell extensions that manipulate the prompt.  
Restart the shell.  
More info at: https://direnv.net/docs/hook.html

Then, when you cd into the project directory, direnv should automatically detect `.envrc` file and activate your Nix environment.

The first time you enter the directory, there will be a prompt saying that you need to approve contents of `.envrc` before it gets loaded.

Run:
```sh
direnv allow
```

Note: Direnv has lots of cool recipes available at https://github.com/direnv/direnv/wiki

### Install Docker

Find and follow the instructions to install Docker to your OS, e.g. `snap install docker`.

The Makefile is assuming that you've configured your Docker to be accessible as non-root user.  
See https://docs.docker.com/engine/install/linux-postinstall/ for instructions, or fix Makefile by adding `sudo` before `docker` commands.
If you're having problems with non-root Docker access even after following the above instructions, try running `sudo chown $USER /var/run/docker.sock`

## `Makefile` targets

Run:
- `make docker` - to build and run Docker image
- `make test` - to run Python tests without Docker
- `make watch` - to start web server locally (without Docker) and reload on edits

Read `Makefile` for info.