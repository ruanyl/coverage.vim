# Coverage.vim

Greatly inspired by [vim-gitgutter](https://github.com/airblade/vim-gitgutter)

A vim plugin which shows code coverage like [wallabyjs](https://wallabyjs.com/)

> requires vim8 or neovim

![coverage](https://cloud.githubusercontent.com/assets/486382/21000678/e4dc204a-bd24-11e6-9847-a4568511c1f3.png)


### Install

```
Plug 'ruanyl/coverage.vim'
```

### How it works

This plugin uses vim8 new feature `timer_start()` to read the `<coverage-*>.json` in an interval. Whenver the file changed, it will update the signs of current buffer.

The plugin awares of signs from other plugins, for example: `syntastic`, `ale` ... But it will overwrite the signs of `gitgutter`.

### Config

Specify the path to `coverage.json` file relative to your current working directory.

> Currently it supports [istanbul](https://github.com/gotwarlost/istanbul) `json reporter` nicely, and should also support `istanbul` based tools like [nyc](https://github.com/istanbuljs/nyc) and [karma-coverage](https://github.com/karma-runner/karma-coverage)

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

Do not display signs on covered lines

```
let g:coverage_show_covered = 0
```

Display signs on uncovered lines

```
let g:coverage_show_uncovered = 1
```

> If you found the project helpful, please give it a star :)

### MIT License
