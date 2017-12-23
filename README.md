<h1 align="center">Enonic Development Assistant</h1>

<p align="center">
Helps build, deploy and run Enonic projects.
</p>

[![Travis Build Status][travis-image]][travis-url]
[![AppVeyor Build Status][appveyor-image]][appveyor-url]
[![Coverage Status][coveralls-image]][coveralls-url]
[![devDependency Status][devdep-image]][devdep-url]
[![Dependency Status][dep-image]][dep-url]

[![Enonic XP version][xp-image]][xp-url]

## Documentation

Please review the [API documentation](http://edloidas.com/enonic-dev-assistant/).

## Install

```
npm install -g enonic-dev-assistant
```

## Usage

Use the module from the command line:

```
Usage:
  eda [<args>]

Commands and options:
  --help                      # Print the module options and usage

  config:
    config -l | --list        # List all variables set in config file, along
                                with their values.
    config --set NAME VALUE   # Set a new value to the option by a key.
    config --get NAME         # Get the value for a given key.
    config --unset NAME       # Remove an option, which will result in using the
                                default value.

  build [-x | --exclude TASK] [-s | --silent] [-r | --rerun]:
    build                     # Run development build from local repos without
                                tests and linting.
    build -x | --exclude TASK # Exclude task from the build cycle.
    build -s | --silent       # Run the build in silent mode, without system
                                notification after it's finished.
    build -r | --rerun        # Rerun all cached tasks.

  clean                       # Clean builded files.

  lint                        # Lint the code.

  test                        # Test the code.

  run [-d | --debug]:
    run                       # Run the server in simple mode.
    run -d | --debug          # Run the server in the debug mode.

Examples:
  eda --help
  eda clean build -x test
  eda lint
```

## License

[MIT](LICENSE) © [Mikita Taukachou](https://edloidas.com)

<!-- Links -->
[travis-url]: https://travis-ci.org/edloidas/enonic-dev-assistant
[travis-image]: https://img.shields.io/travis/edloidas/enonic-dev-assistant.svg?label=linux%20build

[appveyor-url]: https://ci.appveyor.com/project/edloidas/enonic-dev-assistant
[appveyor-image]: https://img.shields.io/appveyor/ci/edloidas/enonic-dev-assistant.svg?label=windows%20build

[coveralls-url]: https://coveralls.io/github/edloidas/enonic-dev-assistant?branch=master
[coveralls-image]: https://coveralls.io/repos/github/edloidas/enonic-dev-assistant/badge.svg?branch=master

[dep-url]: https://david-dm.org/edloidas/enonic-dev-assistant
[dep-image]: https://david-dm.org/edloidas/enonic-dev-assistant.svg

[devdep-url]: https://david-dm.org/edloidas/enonic-dev-assistant#info=devDependencies
[devdep-image]: https://david-dm.org/edloidas/enonic-dev-assistant/dev-status.svg

[xp-url]: https://enonic.com
[xp-image]: https://img.shields.io/badge/enonic%20xp-≥%206.13.0-green.svg
