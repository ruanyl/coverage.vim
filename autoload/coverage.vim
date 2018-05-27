let s:last_modified = {} 
let s:json_file_content = {} 

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

    if g:coverage_show_covered
      call coverage#sign#update_signs(get(modified_lines, 'covered', []), 'covered')
    endif
    if g:coverage_show_uncovered
      call coverage#sign#update_signs(get(modified_lines, 'uncovered', []), 'uncovered')
    endif
  endif
endfunction

function! coverage#get_coverage_lines(file_name) abort
  let coverage_json_full_pathes = coverage#find_coverage_json()
  let lines = {}
  let lines_map = {}

  for path in coverage_json_full_pathes
    if !filereadable(path)
      " echoerr '"' . path . '" is not found'
      continue
    endif

    let current_last_modified = getftime(path)

    " Only read file when file has changed
    if current_last_modified > get(s:last_modified, path)
      let s:json_file_content[path] = readfile(path)
      let s:last_modified[path] = current_last_modified
    endif

    try
      let json = json_decode(join(get(s:json_file_content, path)))
      if has_key(json, a:file_name)
        let current_file_json = get(json, a:file_name)

        if has_key(current_file_json, 'l')
          let lines_map = extend(lines_map, get(current_file_json, 'l'))
        else
          let lines_map = extend(lines_map, coverage#calc_line_from_statementsMap(current_file_json))
        endif
      endif
    catch
      echoerr v:exception
    endtry
  endfor
  let lines['covered'] = coverage#get_covered_lines(lines_map)
  let lines['uncovered'] = coverage#get_uncovered_lines(lines_map)
  return lines
endfunction

function! coverage#get_covered_lines(lines_map) abort
  let lines = filter(keys(a:lines_map), 'v:val != "0" && get(a:lines_map, v:val) != "0"')
  let lines = map(lines, 'str2nr(v:val)')
  return lines
endfunction

function! coverage#get_uncovered_lines(lines_map) abort
  let lines = filter(keys(a:lines_map), 'v:val != "0" && get(a:lines_map, v:val) == "0"')
  let lines = map(lines, 'str2nr(v:val)')
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
  if !exists('g:coverage_json_project_path')
    let cwd = fnamemodify('.', ':p')
  else
    let cwd = fnamemodify(g:coverage_json_project_path, ':p')
  endif
  let json_pathes = []
  if exists('g:coverage_json_report_pathes')
    for currpath in g:coverage_json_report_pathes
      let json_path = simplify(cwd . '/' . currpath)
      call add(json_pathes, json_path)
    endfor
  elseif exists('g:coverage_json_report_path')
    let json_path = simplify(cwd . '/' . g:coverage_json_report_path)
    call add(json_pathes, json_path)
  endif
  return json_pathes
endfunction
