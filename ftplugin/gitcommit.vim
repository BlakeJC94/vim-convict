if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

if !exists("g:convict_disable_default_map")
  nmap <silent> <buffer> <CR> <Plug>(convict-commit)
endif
