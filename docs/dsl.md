# SparkyCI DSL

This document defines SparkyCI DSL design, which is not
implemented yet. WHIP.

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

Finish stage is used for some clean up jobs, etc

## Int stage

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

```
init:
  script: |
    cp t/.my.cnf ~
```

* variables

Sets environment variables, visible for main CI process:

```
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

* `script`

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
