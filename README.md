# Coverage.vim

Inspired by [vim-gitgutter](https://github.com/airblade/vim-gitgutter)

A vim plugin which shows code coverage like [wallabyjs](https://wallabyjs.com/)

> requires vim8

### Install

```
Plug 'ruanyl/coverage.vim'
```

### Config

Specify the path to `coverage.json` file relative to your current working directory

```
let g:coverage_json_report_path = 'coverage/coverage.json'
```

Define the symbol display for covered lines

```
let g:coverage_sign_covered = '⦿'
```

Define the interval time of updating the coverage lines

```
let g:coverage_interval = 5000
```
