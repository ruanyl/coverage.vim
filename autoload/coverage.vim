function! coverage#start() abort
  if exists('s:timer')
    timer_stop(s:timer)
  endif
  let s:timer = timer_start(g:coverage_interval, 'coverage#process_buffer', {'repeat': -1})
endfunction

function! coverage#process_buffer(...) abort
  let l:bufnr = bufnr('')
  call coverage#utility#set_buffer(l:bufnr)
  let buffer_modified = coverage#utility#has_unsaved_changes()
  if !buffer_modified
    let file = expand('#' . l:bufnr . ':p')
    let modified_lines = coverage#get_coverage_lines(file)

    if g:coverage_signs
      call coverage#sign#update_signs(modified_lines)
    endif
  endif
endfunction

function! coverage#get_coverage_lines(file_name) abort
  let coverage_json_full_path = coverage#find_coverage_json()
  let lines = []

  if !filereadable(coverage_json_full_path)
    "echoerr '"' . coverage_json_full_path . '" is not found'
    return lines
  endif
  try
    let json = json_decode(join(readfile(coverage_json_full_path)))
    if has_key(json, a:file_name)
      let current_file_json = get(json, a:file_name)
      let lines_map = get(current_file_json, 'l')
      let lines = filter(keys(lines_map), 'v:val != "0" && get(lines_map, v:val) != 0')
    endif
  catch
    echoerr v:exception
  endtry
  return lines
endfunction

function! coverage#find_coverage_json() abort
  let cwd = fnamemodify('.', ':p')
  let json_path = cwd . g:coverage_json_report_path
  return json_path
endfunction
