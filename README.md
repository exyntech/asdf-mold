<div align="center">

# asdf-mold [![Build](https://github.com/exyntech/asdf-mold/actions/workflows/build.yml/badge.svg)](https://github.com/exyntech/asdf-mold/actions/workflows/build.yml) [![Lint](https://github.com/exyntech/asdf-mold/actions/workflows/lint.yml/badge.svg)](https://github.com/exyntech/asdf-mold/actions/workflows/lint.yml)


[mold](https://github.com/exyntech/mold) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add mold
# or
asdf plugin add mold https://github.com/exyntech/asdf-mold.git
```

mold:

```shell
# Show all installable versions
asdf list-all mold

# Install specific version
asdf install mold latest

# Set a version globally (on your ~/.tool-versions file)
asdf global mold latest

# Now mold commands are available
mold --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/exyntech/asdf-mold/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Andy Mroczkowski](https://github.com/exyntech/)
