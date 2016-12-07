function! coverage#utility#set_buffer(bufnr) abort
  let s:bufnr = a:bufnr
  let s:file = resolve(bufname(a:bufnr))
endfunction

function! coverage#utility#bufnr()
  return s:bufnr
endfunction

function! coverage#utility#is_active() abort
  return g:coverage_enabled &&
        \ coverage#utility#is_file_buffer() &&
        \ coverage#utility#exists_file() &&
endfunction

function! coverage#utility#is_file_buffer() abort
  return empty(getbufvar(s:bufnr, '&buftype'))
endfunction

function! coverage#utility#exists_file() abort
  return filereadable(s:file)
endfunction

function! coverage#utility#has_unsaved_changes() abort
  return getbufvar(s:bufnr, "&mod")
endfunction
