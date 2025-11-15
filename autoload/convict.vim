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

function! s:SelectionIsValidNumber(choice, options) abort
  return a:choice =~ '^\d\+$' && a:choice >= 1 && a:choice <= len(a:options)
endfunction


function! s:SelectType(type_options) abort
  let commit_type = ''
  " Get the user's choice from the type confirm dialog
  let menu = "Choose commit type\n"
  for type_option in a:type_options
    let menu .= printf("%s\n", type_option)
  endfor
  let full_prompt = menu . "Type number and <Enter> (empty cancels): "
  let type_choice = input(full_prompt)
  execute 'redraw'
  " Check if a valid choice was made (non-zero index)
  if s:SelectionIsValidNumber(type_choice, a:type_options)
    " Return the selected commit type
    let commit_type = a:type_options[type_choice - 1]
    let commit_type = substitute(commit_type, '\d\+\.\s\(\w\+\):.*', '\1', "")
  endif
  return commit_type
endfunction


function! s:GetPathChangesListFromGit() abort
  let numstat = systemlist('git diff --staged --numstat')
  let file_changes = {}
  let dir_changes = {}
  for line in numstat
    let [added, deleted, filepath] = split(line, '\s\+', 1)
    let changes = str2nr(added) + str2nr(deleted)

    " Handle file renames (e.g., 'path1 => path2')
    if match(filepath, '=>') != -1
      let filepath = substitute(filepath, '.* => \(.*\)', '\1', 'g')
    endif

    " Add changes to the file
    let file_changes[filepath] = get(file_changes, filepath, 0) + changes

    " Aggregate changes for directories
    let dir = fnamemodify(filepath, ':h')
    if dir != ""
      let dir_changes[dir] = get(dir_changes, dir, 0) + changes
    endif
  endfor

  " Combine files and directories into a single list
  let combined_changes = []
  for [name, changes] in items(file_changes)
    call add(combined_changes, {'filename': name, 'total': changes})
  endfor
  for [name, changes] in items(dir_changes)
    call add(combined_changes, {'filename': name, 'total': changes})
  endfor

  " Sort by total changes in descending order
  call sort(combined_changes, {a, b -> b['total'] - a['total']})
  return combined_changes
endfunction


function! s:GetScopeOptions(combined_changes) abort
  let scope_options = []
  let counter = 1
  for item in a:combined_changes
    let filename = item['filename']
    let filename = fnamemodify(item['filename'], ':t')
    let filename = substitute(filename, '^\.', '', '')
    let filename = substitute(filename, '\..\+$', '', '')
    if filename == ""
      continue
    endif
    let numbered_filename = printf("%d. %s", counter, filename)
    call add(scope_options, numbered_filename)
    let counter += 1
    if counter > 9
      break
    endif
  endfor
  return scope_options
endfunction


function! s:SelectScope(scope_options) abort
  let menu = "Select scope\n"
  for scope_option in a:scope_options
    let menu .= printf("%s\n", scope_option)
  endfor
  let full_prompt = menu . "Type number or custom value and <Enter> (empty omits scope): "
  let scope = input(full_prompt)
  execute 'redraw'
  if s:SelectionIsValidNumber(scope, a:scope_options)
    let scope = strpart(a:scope_options[scope - 1], 3)
  endif
  return scope
endfunction


function! convict#Commit() abort
  if !exists(':Git')
    finish
  endif

  if !(line('.') ==# 1 && col('.') ==# 1)
    return ''
  endif

  let commit_msg = ''
  try
    let commit_type = s:SelectType(s:type_options)
    if commit_type == ''
      return ''
    end
    let commit_msg = commit_msg . commit_type

    let path_changes = s:GetPathChangesListFromGit()
    let scope_options = s:GetScopeOptions(path_changes)
    let scope = s:SelectScope(scope_options)
    if scope != ""
      let commit_msg = commit_msg . '(' . scope . ')'
    endif

    let break_options = ["&Yes", "&No"]
    let break_choice = confirm('Breaking change? (<Enter> for No)', join(break_options, "\n"), &ic ? 0 : 4)
    if break_choice == 1
      let commit_msg = commit_msg . '!'
    endif

    let commit_msg = commit_msg . ': '
  catch /Vim\%((\a\+)\)\=:E/
    echo "An error occurred: " . v:exception
    echo "Occurred at: " . v:throwpoint
  endtry
  return commit_msg
endfunction
