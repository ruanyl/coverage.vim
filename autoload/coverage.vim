let s:last_modified = 0
let s:json_file_content = []

function! coverage#start() abort
  if exists('s:timer')
    call timer_stop(s:timer)
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

  let current_last_modified = getftime(coverage_json_full_path)

  " Only read file when file has changed
  if current_last_modified > s:last_modified
    let s:json_file_content = readfile(coverage_json_full_path)
    let s:last_modified = current_last_modified
  endif

  try
    let json = json_decode(join(s:json_file_content))
    if has_key(json, a:file_name)
      let current_file_json = get(json, a:file_name)

      if has_key(current_file_json, 'l')
        let lines_map = get(current_file_json, 'l')
        let lines = filter(keys(lines_map), 'v:val != "0" && get(lines_map, v:val) != "0"')
        let lines = map(lines, 'str2nr(v:val)')
      else
        let lines_map = coverage#calc_line_from_statementsMap(current_file_json)
        let lines = filter(keys(lines_map), 'v:val != "0" && get(lines_map, v:val) != "0"')
        let lines = map(lines, 'str2nr(v:val)')
      endif
    endif
  catch
    echoerr v:exception
  endtry
  return lines
endfunction

function! coverage#calc_line_from_statementsMap(json) abort
  let statementMap = get(a:json, 'statementMap')
  let statements = get(a:json, 's')
  let lines = {}
  for key in keys(statements)
    if !has_key(statementMap, key)
      continue
    endif
    let line = statementMap[key].start.line
    let line_count = statements[key]
    let pre_line_count = get(lines, line, 'undefined')
    if line_count == 0 && get(statementMap[key], 'skip')
      let line_count = 1
    endif
    if pre_line_count == 'undefined' || pre_line_count < line_count
      let lines[line] = line_count
    endif
  endfor
  return lines
endfunction

function! coverage#find_coverage_json() abort
  let cwd = fnamemodify('.', ':p')
  let json_path = cwd . g:coverage_json_report_path
  return json_path
endfunction
