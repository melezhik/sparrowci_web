# SparkyCI DSL

This document defines SparkyCI DSL design, which is not
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

For example - [sparkyci-package-xml](http://sparrowhub.io/plugin/sparkyci-package-xml/0.000001)


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

* `with-license-check`

Enable license check


# Complete example

```yaml
init:
  services:
    mysql: {}

  script: |
    cp t/.my.cnf ~

  variables:
    DB_USER: sparky
    DB_PASS: sparky123

main:
  with-code-coverage: false
```
