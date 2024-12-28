if exists('g:autoloaded_convict')
  finish
endif
let g:autoloaded_convict = 1

let s:type_options = [
      \'1. fix: A bug fix. Correlates with PATCH in SemVer',
      \'2. feat: A new feature. Correlates with MINOR in SemVer',
      \'3. docs: Documentation only changes',
      \'4. style: Changes that do not affect the meaning of the code',
      \'5. refactor: A code change that neither fixes a bug nor adds a feature',
      \'6. perf: A code change that improves performance',
      \'7. test: Adding missing or correcting existing tests',
      \'8. build: Changes that affect the build system or external dependencies',
      \'9. ci: Changes to CI configuration files and scripts',
      \]

function! convict#Commit() abort
  if !(line('.') ==# 1 && col('.') ==# 1)
    return ''
  endif

  let l:commit_msg = ''

  " Get the user's choice from the type confirm dialog

  let l:type_choice = inputlist(['Choose commit type (<Esc> to cancel):'] + l:type_options)
  " Check if a valid choice was made (non-zero index)
  if l:type_choice > 0
    " Return the selected commit type
    let l:commit_type = substitute(l:type_options[l:type_choice - 1], '\d\+\.\s\(\w\+\):.*', '\1', "")
    let l:commit_msg = l:commit_msg . l:commit_type
  else
    " Cancel if no commit type is selected
    return ''
  endif

  let l:numstat = systemlist('git diff --staged --numstat')
  let l:file_changes = {}
  let l:dir_changes = {}
  for line in l:numstat
    let [added, deleted, filepath] = split(line, '\s\+', 1)
    let changes = str2nr(added) + str2nr(deleted)

    " Handle file renames (e.g., 'path1 => path2')
    if match(filepath, '=>') != -1
      let filepath = substitute(filepath, '.* => \(.*\)', '\1', 'g')
    endif

    " Add changes to the file
    let l:file_changes[filepath] = get(l:file_changes, filepath, 0) + changes

    " Aggregate changes for directories
    let dir = fnamemodify(filepath, ':h')
    if dir != ""
      let l:dir_changes[dir] = get(l:dir_changes, dir, 0) + changes
    endif
  endfor

  " Combine files and directories into a single list
  let l:combined_changes = []
  for [name, changes] in items(l:file_changes)
    call add(l:combined_changes, {'filename': name, 'total': changes})
  endfor
  for [name, changes] in items(l:dir_changes)
    call add(l:combined_changes, {'filename': name, 'total': changes})
  endfor

  " Sort by total changes in descending order
  call sort(l:combined_changes, {a, b -> b['total'] - a['total']})

  let l:scope_options = []
  let l:counter = 1
  for item in l:combined_changes
    let l:filename = item['filename']
    let l:filename = fnamemodify(item['filename'], ':t')
    let l:filename = substitute(l:filename, '^\.', '', '')
    let l:filename = substitute(l:filename, '\..\+$', '', '')
    if l:filename == ""
      continue
    endif
    let l:numbered_filename = printf("%d. %s", l:counter, l:filename)
    call add(l:scope_options, l:numbered_filename)
    let l:counter += 1
    if l:counter > 9
      break
    endif
  endfor

  " Get the user's input from the scope dialog
  execute 'redraw'
  let l:scope_choice = inputlist(['Add scope (<Enter> for custom or skip):'] + l:scope_options)
  let l:scope = ""
  if l:scope_choice > 0
    let l:scope = strpart(l:scope_options[l:scope_choice - 1], 3)
  else
    let l:scope = input('Add custom scope (<Enter> to skip): ', "")
  endif

  " Check if a valid choice was made (non-zero index)
  if l:scope != ""
    let l:commit_msg = l:commit_msg . '(' . l:scope . ')'
  endif

  " Get the user's choice from the breaking change confirm dialog
  execute 'redraw'
  let l:break_options = ["&Yes", "&No"]
  let l:break_choice = confirm('Breaking change? (<Enter> for No)', join(l:break_options, "\n"), &ic ? 0 : 4)
  " Check if a valid choice was made (non-zero index)
  if l:break_choice == 1
    let l:commit_msg = l:commit_msg . '!'
  endif

  let l:commit_msg = l:commit_msg . ': '
  return l:commit_msg
endfunction
