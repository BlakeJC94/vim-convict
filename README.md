# convict.vim
Conventional commits for [`fugitive.vim`]()

## Usage
When opening the commit editor in `fugitive.vim`, Use `<CR>` in normal mode at the beginning of the
buffer to start a menu to select the commit type, scope (ranked in order of number of changes), and
indicate if a breaking change has occurred:
```
Choose commit type:
1. fix: A bug fix. Correlates with PATCH in SemVer
2. feat: A new feature. Correlates with MINOR in SemVer
3. docs: Documentation only changes
4. style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
5. refactor: A code change that neither fixes a bug nor adds a feature
6. perf: A code change that improves performance
7. test: Adding missing or correcting existing tests
8. build: Changes that affect the build system or external dependencies (example scopes: pip, docker, npm)
9. ci: Changes to CI configuration files and scripts (example scopes: GitLabCI)
Type number and <Enter> or click with the mouse (q or empty cancels): 1

Add scope (<Enter> for custom or skip):
1. foo
2. bar
3. baz
Type number and <Enter> or click with the mouse (q or empty cancels): 0

Add custom scope (<Enter> to skip): floob

Breaking change? (<Enter> for No)
(Y)es, (N)o: Y
```

This will then pre-fill the commit buffer with
```
fix(floob)!:
# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
#
# On branch main
# Your branch is up to date with 'origin/main'.
#
# Changes to be committed:
#   modified:   floob.txt
#
...
```

## Installation
Use vim's built-in package support or your favourite package manager.

My suggested method is [`vim-plug`]()
```
Plug 'tpope/vim-fugitive'
Plug 'BlakeJC94/vim-convict'
```

The default commit menu mapping is `<CR>`, which is only active at the start of buffers with the
`gitcommit` filetype. If you would like to customize this mapping, set
```
let g:convict_disable_default_map = 1
```
in your `vimrc`, and add this mapping to `~/.vim/ftplugin/gitcommit.vim`:
```
nmap <silent> <buffer> <your-map-here> <Plug>(convict-commit)
```

## Issues
If any errors are encountered (or you would like to make a feature request), raise an issue on the
repository so we can discuss. Pull requests are also welcomed

## Development
The `main` branch is reserved for releases and should be considered stable. Changes should occur in
the `dev` branch, which will periodically be merged into `main`.

### TODO
- [x] Readme v1
- [x] Establish plugin structure
- [x] Add code
- [x] Aggregate changes over directories
- [x] Refactor
- [x] Customizable mappings
- [ ] Version bumping with template support

## Licence
Distributed under the same terms as Vim itself. See `:help license`.
