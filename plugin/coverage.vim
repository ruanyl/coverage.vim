if exists('g:loaded_coverage') || !has('signs') || &cp || !exists('*timer_start')
  finish
endif
let g:loaded_coverage = 1

function! s:set(var, default) abort
  if !exists(a:var)
    if type(a:default)
      execute 'let' a:var '=' string(a:default)
    else
      execute 'let' a:var '=' a:default
    endif
  endif
endfunction

call s:set('g:coverage_enabled', 1)
call s:set('g:coverage_sign_covered', '⦿')
call s:set('g:coverage_sign_uncovered', '⦿')
call s:set('g:coverage_signs', 1)
call s:set('g:coverage_show_covered', 0)
call s:set('g:coverage_show_uncovered', 1)
call s:set('g:coverage_override_sign_column_highlight', 1)
call s:set('g:coverage_json_report_path', 'coverage/coverage.json')
call s:set('g:coverage_auto_start', 1)
call s:set('g:coverage_interval', 5000)
call s:set('g:coverage_sign_column_always', 0)

call coverage#highlight#define_sign_column_highlight()
call coverage#highlight#define_highlights()
call coverage#highlight#define_signs()

command -bar Coverage    call coverage#start()
if g:coverage_auto_start
  call coverage#start()
endif

autocmd BufRead * call coverage#process_buffer()
