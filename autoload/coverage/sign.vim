let s:first_sign_id = 3000
let s:next_sign_id  = s:first_sign_id
let s:dummy_sign_id  = s:first_sign_id - 1

function! coverage#sign#clear_signs() abort
  let bufnr = coverage#utility#bufnr()
  call coverage#sign#find_current_signs()

  let sign_ids = map(values(getbufvar(bufnr, 'coverage_signs')), 'v:val.id')
  call coverage#sign#remove_signs(sign_ids)
  call setbufvar(bufnr, 'coverage_signs', {})
endfunction

" modified_lines: list of [<line_number (number),...]
function! coverage#sign#update_signs(modified_lines) abort
  call coverage#sign#find_current_signs()

  let bufnr = coverage#utility#bufnr()
  let old_coverage_signs = map(values(getbufvar(bufnr, 'coverage_signs')), 'v:val.id')
  let other_signs         = getbufvar(bufnr, 'coverage_other_signs')

  if !empty(old_coverage_signs)
    call coverage#sign#add_dummy_sign()
  endif

  " TODO: should not remove all signs at one time
  call coverage#sign#remove_signs(old_coverage_signs)

  for line_number in a:modified_lines
    if index(other_signs, line_number) == -1  " don't clobber others' signs
      let name = 'CoverageCovered'
      let id = coverage#sign#next_sign_id()
      execute "sign place" id "line=" . line_number "name=" . name "buffer=" . bufnr
    endif
  endfor

  if !empty(old_coverage_signs)
    call coverage#sign#remove_dummy_sign(0)
  endif

endfunction

function! coverage#sign#add_dummy_sign() abort
  let bufnr = coverage#utility#bufnr()
  if !getbufvar(bufnr, 'coverage_dummy_sign')
    execute "sign place" s:dummy_sign_id "line=" . 9999 "name=CoverageDummy buffer=" . bufnr
    call setbufvar(bufnr, 'coverage_dummy_sign', 1)
  endif
endfunction

function! coverage#sign#remove_dummy_sign(force) abort
  let bufnr = coverage#utility#bufnr()
  if getbufvar(bufnr, 'coverage_dummy_sign') && (a:force || !g:coverage_sign_column_always)
    execute "sign unplace" s:dummy_sign_id "buffer=" . bufnr
    call setbufvar(bufnr, 'coverage_dummy_sign', 0)
  endif
endfunction

function! coverage#sign#find_current_signs() abort
  let bufnr = coverage#utility#bufnr()
  let coverage_signs = {}   " <line_number (string)>: {'id': <id (number)>, 'name': <name (string)>}
  let gitgutter_signs = []
  let other_signs = []      " [<line_number (number),...]
  let dummy_sign_placed = 0

  redir => signs
    silent execute "sign place buffer=" . bufnr
  redir END

  for sign_line in filter(split(signs, '\n')[2:], 'v:val =~# "="')
    " Typical sign line:  line=88 id=1234 name=CoverageCovered
    " We assume splitting is faster than a regexp.
    let components  = split(sign_line)
    let name        = split(components[2], '=')[1]
    let line_number = str2nr(split(components[0], '=')[1])

    if name =~# 'CoverageDummy'
      let dummy_sign_placed = 1
    else
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
    endif
  endfor

  call setbufvar(bufnr, 'coverage_dummy_sign', dummy_sign_placed)
  call setbufvar(bufnr, 'coverage_signs', coverage_signs)
  call setbufvar(bufnr, 'coverage_gitgutter_signs', gitgutter_signs)
  call setbufvar(bufnr, 'coverage_other_signs', other_signs)
endfunction

function! coverage#sign#remove_signs(sign_ids) abort
  for id in a:sign_ids
    execute "sign unplace" id
  endfor
endfunction

function! coverage#sign#next_sign_id() abort
  let next_id = s:next_sign_id
  let s:next_sign_id += 1
  return next_id
endfunction
