# SparkyCI DSL

This document defines SparkyCI DSL design, which is not _fully_
implemented yet. This is WIP.

## Configuration file

Create `.sparkyci.yaml` in project root directory

## Stages

CI process consists of following stages:

* `init`

Initialization stage, used to installed dependencies required for `main` stage


* `main`

Main CI logic, used to define parameters for CI process, enable / disable some 
features, so on. 

* `finish`

Finish stage is used for some clean up jobs, etc. 

The section is reserved for the future use. As SparkyCI jobs run on
ephemeral docker containers that are destroyed at the end of every build
there is no need for clean up steps so far.

## Init stage

Initialization stage allows to configure dependencies ( services, packages, etc ):

### Services

```yaml
init:
  services:
    mysql: {}
```

Supported services:

* mysql

* postgresql

Every service is implemented as a Sparrow plugin.
One can refer to a plugin documentation,
to see supported parameters.

For example - [sparkyci-service-mysql](http://sparrowhub.io/plugin/sparkyci-service-mysql/0.000012)

### Scripts

Allows execute arbitrary bash code:

```yaml
init:
  script: |
    cp t/.my.cnf ~
```

### Packages 

Installs packages of software

```yaml
init:
  packages:
     xml: {}
     ssl: {}
```

Every package is implemented as a Sparrow plugin.
One can refer to a plugin documentation,
to see supported parameters.

For example - [sparkyci-package-mysql](http://sparrowhub.io/plugin/sparkyci-package-mysql/0.000002)


### Variables

Sets environment variables, visible for main CI process:

```yaml
init:
  variables:
    DB_USE: sparky
    DB_PASS: sparky123
```

One can reference variables anywhere 
across CI scenario:

```yaml
init:
  script: |
    echo $DB_USER
```

## Main stage

Main stage configures main CI logic:

```yaml
main:
  with-code-coverage: true
  with-license-check: true
```

Stage parameters:

* `with-code-coverage`

Enable code coverage

* `with-zef-deps`

Enable zef dependencies report using [zef-deps](https://github.com/coke/raku-zef-deps)

* `with-license-check`

Enable license check ( not implemented yet )

* `verbose`

Enable verbose output ( mostly will affect `zef` commands )

### Build hooks

Build hooks allow customize standard build flow.

For example, to precede main build command with some custom bash script:

```yaml
main:
  build:
    pre: |
      set -x
      ake test-setup deploy-runner
```

# Complete example

```yaml
init:

  services:
    mysql:
      db_name: $MYSQL_DATABASE
      db_user: $MYSQL_USER
      db_pass: $MYSQL_PASSWORD

  packages:
    mysql: {}

  script: |
    env | grep MYSQL

  variables:
    MYSQL_DATABASE: dbdishtest
    MYSQL_HOST: localhost
    MYSQL_USER: testuser
    MYSQL_PASSWORD: testpass
    MYSQL_ROOT_PASSWORD: ''

main:

  build:
    pre: |
      set -x
      echo "hello from build.pre hook!"

  with-code-coverage: true
  verbose: true
```

# SparkyCI plugins

Services and packages - are reusable plugins that extend basic functionality.

SparkyCI plugins are _implemented_ as sparrow plugins.

## Services

To use sparkyci package one need to reference it as:

```yaml
  services: 
    name: {} # or specific parameters
```

To lookup for service parameters one need to refer a `sparkyci-service-$name`  plugin documentation.

For example:

Service - `mysql` , sparrow plugin - `sparkyci-service-mysql`

## Packages

The same logic applies to sparkyci packages:

For example:

Package - `build-essential` , sparrow plugin - `sparkyci-package-build-essential`

SparkyCI code:

```yaml
  packages: 
    name: {} # or specific parameters
```

Available sparkyci plugins are listed here:

http://sparrowhub.io/search?q=sparkyci
