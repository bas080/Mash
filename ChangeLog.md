# Changelog for mash

## Unreleased changes

### Enhancements

- Cleaup code using hindent default configuration
- Remove unused functions
- Use arg parser to get the cli files/url

### Feature

- `require-run` feature which substitutes require statement with the stdout of
  the defined shell command

## 0.2.0

### Feature

- Support giving a HTTP url to the require statement

### Enhancements

- Better argument parsing
- Shows a help message containing option descriptions and instructions


## 0.1.0.1

### Fix

- Fix the once option which was causing an error when used as an option in the
  CLI
