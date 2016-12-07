function! coverage#highlight#define_sign_column_highlight() abort
  if g:coverage_override_sign_column_highlight
    highlight! link SignColumn LineNr
  else
    highlight default link SignColumn LineNr
  endif
endfunction

function! coverage#highlight#define_highlights() abort
  let [guibg, ctermbg] = coverage#highlight#get_background_colors('SignColumn')

  " Highlights used by the signs.

  execute "highlight CoverageCoveredDefault    guifg=#009900 guibg=" . guibg . " ctermfg=2 ctermbg=" . ctermbg
  execute "highlight CoverageUncoveredDefault  guifg=#ff2222 guibg=" . guibg . " ctermfg=1 ctermbg=" . ctermbg

  execute "highlight CoverageCoveredInvisible    guifg=bg guibg=" . guibg . " ctermfg=" . ctermbg . " ctermbg=" . ctermbg
  execute "highlight CoverageUncoveredInvisible  guifg=bg guibg=" . guibg . " ctermfg=" . ctermbg . " ctermbg=" . ctermbg

  highlight default link CoverageCovered          CoverageCoveredDefault
  highlight default link CoverageUncovered        CoverageUncoveredDefault

endfunction

function! coverage#highlight#define_signs() abort
  sign define CoverageCovered
  sign define CoverageUncovered

  call coverage#highlight#define_sign_text()
  call coverage#highlight#define_sign_text_highlights()
endfunction

function! coverage#highlight#define_sign_text() abort
  execute "sign define CoverageCovered            text=" . g:coverage_sign_covered
  execute "sign define CoverageUncovered          text=" . g:coverage_sign_uncovered
endfunction

function! coverage#highlight#define_sign_text_highlights() abort
  " Once a sign's text attribute has been defined, it cannot be undefined or
  " set to an empty value.  So to make signs' text disappear (when toggling
  " off or disabling) we make them invisible by setting their foreground colours
  " to the background's.
  if g:coverage_signs
    sign define CoverageCovered            texthl=CoverageCovered
    sign define CoverageUncovered          texthl=CoverageUncovered
  else
    sign define CoverageCovered            texthl=CoverageCoveredInvisible
    sign define CoverageUncovered          texthl=CoverageUncoveredInvisible
  endif
endfunction

function! coverage#highlight#get_background_colors(group) abort
  redir => highlight
  silent execute 'silent highlight ' . a:group
  redir END

  let link_matches = matchlist(highlight, 'links to \(\S\+\)')
  if len(link_matches) > 0 " follow the link
    return coverage#highlight#get_background_colors(link_matches[1])
  endif

  let ctermbg = coverage#highlight#match_highlight(highlight, 'ctermbg=\([0-9A-Za-z]\+\)')
  let guibg   = coverage#highlight#match_highlight(highlight, 'guibg=\([#0-9A-Za-z]\+\)')
  return [guibg, ctermbg]
endfunction

function! coverage#highlight#match_highlight(highlight, pattern) abort
  let matches = matchlist(a:highlight, a:pattern)
  if len(matches) == 0
    return 'NONE'
  endif
  return matches[1]
endfunction
