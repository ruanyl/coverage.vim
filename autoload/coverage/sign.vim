let s:first_sign_id = 3000
let s:next_sign_id  = s:first_sign_id

function! coverage#sign#clear_signs() abort
  let bufnr = coverage#utility#bufnr()
  call coverage#sign#find_current_signs()

  let sign_ids = map(values(getbufvar(bufnr, 'coverage_signs')), 'v:val.id')
  call coverage#sign#remove_signs(sign_ids, 1)
  call setbufvar(bufnr, 'coverage_signs', {})
endfunction

" modified_lines: list of [<line_number (number),...]
function! coverage#sign#update_signs(modified_lines) abort
  call coverage#sign#find_current_signs()

  let bufnr = coverage#utility#bufnr()
  let old_coverage_signs = map(values(getbufvar(bufnr, 'coverage_signs')), 'v:val.id')
  let other_signs         = getbufvar(bufnr, 'coverage_other_signs')

  call coverage#sign#remove_signs(old_coverage_signs, 1)

  for line_number in a:modified_lines
    if index(other_signs, line_number) == -1  " don't clobber others' signs
      let name = 'CoverageCovered'
      let id = coverage#sign#next_sign_id()
      execute "sign place" id "line=" . line_number "name=" . name "buffer=" . bufnr
    endif
  endfor

endfunction

function! coverage#sign#find_current_signs() abort
  let bufnr = coverage#utility#bufnr()
  let coverage_signs = {}   " <line_number (string)>: {'id': <id (number)>, 'name': <name (string)>}
  let gitgutter_signs = []
  let other_signs = []      " [<line_number (number),...]

  redir => signs
    silent execute "sign place buffer=" . bufnr
  redir END

  for sign_line in filter(split(signs, '\n')[2:], 'v:val =~# "="')
    " Typical sign line:  line=88 id=1234 name=CoverageCovered
    " We assume splitting is faster than a regexp.
    let components  = split(sign_line)
    let name        = split(components[2], '=')[1]
    let line_number = str2nr(split(components[0], '=')[1])

    if name =~# 'Coverage'
      let id = str2nr(split(components[1], '=')[1])
      " Remove orphaned signs (signs placed on lines which have been deleted).
      " (When a line is deleted its sign lingers.  Subsequent lines' signs'
      " line numbers are decremented appropriately.)
      if has_key(coverage_signs, line_number)
        execute "sign unplace" coverage_signs[line_number].id
      endif
      let coverage_signs[line_number] = {'id': id, 'name': name}
    else
      if name =~# 'GitGutter'
        call add(gitgutter_signs, line_number)
      else
        call add(other_signs, line_number)
      endif
    end
  endfor

  call setbufvar(bufnr, 'coverage_signs', coverage_signs)
  call setbufvar(bufnr, 'coverage_gitgutter_signs', gitgutter_signs)
  call setbufvar(bufnr, 'coverage_other_signs', other_signs)
endfunction

function! coverage#sign#remove_signs(sign_ids, all_signs) abort
  let bufnr = coverage#utility#bufnr()
  if a:all_signs && empty(getbufvar(bufnr, 'coverage_other_signs'))
    execute "sign unplace * buffer=" . bufnr
  else
    for id in a:sign_ids
      execute "sign unplace" id
    endfor
  endif
endfunction

function! coverage#sign#next_sign_id() abort
  let next_id = s:next_sign_id
  let s:next_sign_id += 1
  return next_id
endfunction
