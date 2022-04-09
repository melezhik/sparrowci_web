# SparkyCI DSL

This document defines SparkyCI DSL design, which is not
implemented yet. WIP.

## Configuration file

Create `.sparkyci.yaml` in project root directory

## Stages

CI process consists of following stage:

* `init`

Initialization stage, used to installed dependencies required for `main` stage


* `main`

Main CI logic, used to defined parameters for CI process, enable / disable some 
features, so on.


* `finish`

Finish stage is used for some clean up jobs, etc. 

The section is reserved for the future use. As SparkyCI jobs run on
ephemeral docker containers that are destroyed at the end of every build
there is no need for clean up steps so far.


## Init stage

Pre stage allows to configure dependencies ( f.e. services ):

```yaml
init:
  services:
    mysql:
```

Supported services:

* mysql

* postgresql

Other parameters:

* `script`

Arbitrary bash code:

```yaml
init:
  script: |
    cp t/.my.cnf ~
```

* variables

Sets environment variables, visible for main CI process:

```yaml
init:
  variables:
    DB_USER=sparky
    DB_PASS=sparky123
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
    mysql:

  script: |
    cp t/.my.cnf ~

  variables:
    DB_USER=sparky
    DB_PASS=sparky123

main:
  with-code-coverage: false
```
