if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

nnoremap <silent> <buffer> <CR>  i<C-r>=convict#Commit()<CR>
