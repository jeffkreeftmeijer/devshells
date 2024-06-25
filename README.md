
# Managing development environments with Nix

[Nix's develop program](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-develop) starts a shell with the results of a derivation. For example, to start a bash shell with Cargo on a machine that doesn't have it installed:

```shell
nix develop nixpkgs#cargo
```

```
bash-5.2$
```

The real use case of *develop* is building development environments, which allow setting up a shell with multiple dependencies.

Nix's [template directory](https://github.com/NixOS/templates/tree/master) has some useful and community-maintained examples to get started building development environments. For example, the [Rust template](https://github.com/NixOS/templates/blob/c57ac1ea60ef97bdce2f13e12b849f0ca5eaffe9/rust/flake.nix ) has a *flake* that sets up everything needed in a Rust project:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/92d295f588631b0db2da509f381b4fb1e74173c5";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
	pkgs = import nixpkgs { inherit system; };
      in
      {
	devShell = with pkgs; mkShell {
	  buildInputs = [
	    darwin.apple_sdk.frameworks.CoreServices
	    darwin.apple_sdk.frameworks.Security
	    libiconv
	    gcc
	    cargo
	    rustc
	    rustfmt
	    rustPackages.clippy
	    rust-analyzer
	  ];
	  RUST_SRC_PATH = rustPlatform.rustLibSrc;
	};
      }
    );
}
```

After saving it as `flake.nix` in a project's directory<sup><a id="fnr.1" class="footref" href="#fn.1" role="doc-backlink">1</a></sup>, running `nix develop` starts the shell with everything available. To skip the shell and run a one-off command, use the `--command` flag:

```shell
nix develop --command cargo --version
```

    cargo 1.77.1

Even easier; to automatically load the environment when entering the project's directory, use [direnv](https://direnv.net). Create a file named `.envrc` containing the `use flake` directive:

```envrc
use flake .
```

Then, run `direnv allow` in the project directory, and all dependencies are added to the current shell. When switching to another directory, the dependencies are unloaded until you return.

After checking in the flake, the `.envrc` file, and the generated `flake.lock`, the project's dependencies are automatically installed and version locked, resulting in a reproducable setup for the project.


## On-demand development environments

Managing environments with Nix is powerful, but a downside of this approach is that the flake file needs to be checked into version control. That's not a problem for projects that use Nix to manage their dependencies, but, when working on a project you don't own, adding another way to handle dependencies might not be appreciated by the other maintainers. Aside from that, it might be useful to share development environments between similar projects without having to duplicate the flake.

Luckily, both Nix and direnv allow dependencies to be loaded from other paths than the current directory. To start a development shell from a flake in the `~/devshells/rust` directory, pass the directory path to the call to `nix develop` command:

```shell
nix develop ~/devshells/rust --command cargo --version
```

    cargo 1.77.1

To use a flake from outside the current directory with direnv, add a path to the directory containing the flake in the `.envrc` file:

```envrc
use flake ~/devshells/rust
```

This means that just having an `.envrc` file that points to a flake located elsewhere is enough to handle dependencies. This still requires a single file to be added to the project directory, but it allows for moving the flake and lock file to a seperate, version-controlled, location.


## A repository of development environments

For projects I can't add flakes to, I use my own [repository of development environments](https://github.com/jeffkreeftmeijer/devshells)<sup><a id="fnr.2" class="footref" href="#fn.2" role="doc-backlink">2</a></sup>, which includes flakes for to set up the following languages and utilities:

-   **[Rust](https://github.com/jeffkreeftmeijer/devshells/blob/main/rust/flake.nix):** version 1.77.1, with Cargo, rustfmt, Clippy, and rust-analyzer

-   **[Rustup](https://github.com/jeffkreeftmeijer/devshells/blob/main/rustup/flake.nix):** version 1.26.0, a copy of the Rust flake, with with Rustup instead of separate utilities for projects that depend on it

-   **[Elixir](https://github.com/jeffkreeftmeijer/devshells/blob/main/elixir/flake.nix):** version 1.16.2 on Erlang 25.3.2.11, with elixir-ls

-   **[Node.js](https://github.com/jeffkreeftmeijer/devshells/blob/main/nodejs/flake.nix):** version 22.0.0, with Prettier 3.2.5

-   **[PostgreSQL](https://github.com/jeffkreeftmeijer/devshells/blob/main/postgresql/flake.nix):** version 15.6, with `PGDATA` configured to be directory-local

-   **[Ruby](https://github.com/jeffkreeftmeijer/devshells/blob/main/ruby/flake.nix):** version 3.3.1

This means adding a single-line `.envrc` is enough to add a develoment environment for Rust projects:

```envrc
use flake ~/devshells/rust
```

This takes the flake file from the rust directory in my local checkout<sup><a id="fnr.3" class="footref" href="#fn.3" role="doc-backlink">3</a></sup> of my development environment repository.

Because environments can be [environments can be layered](https://determinate.systems/posts/nix-direnv/#layering-environments), a Phoenix project requiring Elixir, Node.js and PostgresQL simply stacks three flakes:

```envrc
use flake ~/devshells/elixir
use flake ~/devshells/nodejs
use flake ~/devshells/postgresql
```

## Footnotes

<sup><a id="fn.1" class="footnum" href="#fnr.1">1</a></sup> After adding the flake, ensure it's checked into version control. If not, Nix can't find it and will throw an error message that doesn't *quite* explain what's wrong:

```
error: getting status of '/nix/store/0ccnxa25whszw7mgbgyzdm4nqc0zwnm8-source/flake.nix': No such file or directory
```

<sup><a id="fn.2" class="footnum" href="#fnr.2">2</a></sup> Other repositories with development environment exist, like the aforementioned [NixOS/templates](https://github.com/NixOS/templates) and [the-nix-way/dev-templates](https://github.com/the-nix-way/dev-templates). One could point a project's `.envrc` file directly to one of these and get a working environment. I've done that in the past, and will certainly continue doing so.

However, if I have to return to a project frequently, I prefer setting up my own development shell and running from that. Preparing one myself ensures the shell doesn't include anything that's not needed for my projects, and makes any issues that arise easier to debug.

Still, these repositories are a great starting point for writing your own development shells. My Rust shell, for example, is based on the [the Rust flake from NixOS/templates](https://github.com/NixOS/templates/blob/c57ac1ea60ef97bdce2f13e12b849f0ca5eaffe9/rust/flake.nix).

<sup><a id="fn.3" class="footnum" href="#fnr.3">3</a></sup> Instead of using a local checkout, you could also point the `.envrc` file directly to a file on GitHub, for example:

```envrc
use flake github:jeffkreeftmeijer/devenv?dir=rust
```

This makes the setup more portable, but removes the ability to use and update lock files. Since I prefer my development environments to be version-locked and infrequently updated, that's a dealbreaker for me.