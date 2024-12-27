" Check if Fugitive is installed
if !exists(':Git')
  echoerr "Convict requires fugitive.vim. Please install it first."
  finish
endif

nmap <Plug>(convict-commit) i<C-r>=convict#Commit()<CR>
