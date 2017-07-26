" ==============================================================================
" File:            join.vim
" Maintainer:      Joshua Potter <jrpotter2112@gmail.com>
"
" ==============================================================================

if exists('g:loaded_smart_join')
  finish
endif
let g:loaded_smart_join = 1


" GLOBAL VARIABLES: {{{1
" ==============================================================================

" g:smart_join_strip_whitespace_before :: Boolean {{{2
" ------------------------------------------------------------------------------
" Indicates that before joining, we strip any trailing whitespace on the current
" line.

if !exists('g:smart_join_strip_whitespace_before')
  let g:smart_join_strip_whitespace_before = 1
endif


" g:smart_join_strip_whitespace_after :: Boolean {{{2
" ------------------------------------------------------------------------------
" Indicates that after joining, we strip any trailing whitespace on the current
" line.

if !exists('g:smart_join_strip_whitespace_after')
  let g:smart_join_strip_whitespace_after = 1
endif


" FUNCTION: StripTrailing() {{{1
" ==============================================================================

function! s:StripTrailing(line)
  return substitute(a:line, '\(.\{-}\)\s*$', '\1', '')
endfunction


" FUNCTION: SmartJoinLine() {{{1
" ==============================================================================
" Primary functionality of smart joining. It tests the position of the textwidth
" and the various possibilities of line continuation at this point, deciding if
" it is necessary to introduce a line break or not. Returns true if a line break
" occurred.

function! s:SmartJoinLine()
  if g:smart_join_strip_whitespace_before
    call setline('.', s:StripTrailing(getline('.')))
  endif
  join
  " Have a 0 default value (indicting textwidth disabled) or already fits line.
  " As a special precaution, if only one word on the line, do nothing.
  let l:line = getline('.')
  if &textwidth == 0 || len(l:line) <= &textwidth ||
        \ len(split(l:line, '\W\+')) <= 1
    return
  endif
  " Move to textwidth position if possible. If not, joined line was shorter and
  " we are finished. Otherwise we can then determine whether or not we must
  " insert a line break.
  call cursor('.', &textwidth)
  if getcurpos()[2] < &textwidth
    return
  endif
  " If the character at textwidth is a whitespace character, we should simply
  " place a line break at textwidth.
  if match(l:line[&textwidth - 1], '\s\+') != -1
    exe "normal! r\<CR>"
    return 1
  " If the character following textwidth is a whitespace character, we simply
  " create a line break at this point. Note that :join will already clear out
  " any trailing whitespace between the two lines.
  elseif match(l:line[&textwidth], '\s\+') != -1
    exe "normal! lr\<CR>"
    return 1
  " The last possibility includes whether or not the current word runs through
  " textwidth.
  else
    " Move to the start of the word and check if we need to break before this.
    " In this case, we first check if we are at the beginning of the word
    " already (by verifying whether or not there exists a whitespace character
    " at the position left of the textwidth).
    if match(l:line[&textwidth - 2], '\s\+') == -1
      exe "normal! B"
    endif
    " Check if WORD goes past textwidth and break at this point if it does.
    if getcurpos()[2] + len(expand('<cWORD>')) - 1 > &textwidth
      exe "normal! hr\<CR>"
      return 1
    endif
  endif
  return 0
endfunction


" FUNCTION: SmartJoin(count) {{{1
" ==============================================================================
" A wrapper around SmartJoinLine() to incorporate post whitespace-stripping and
" potential recursive functionality.

function! s:SmartJoin(count)
  if a:count > 0
    let l:linebreak = s:SmartJoinLine()
    if l:linebreak
      exe "normal! j"
      " If the line we joined was also greater than textwidth, we should apply a
      " smart join to the line before continuing.
      if &textwidth != 0 && strlen(getline('.')) > &textwidth
        call s:SmartJoin(1)
      endif
    endif
    if g:smart_join_strip_whitespace_after
      call setline('.', s:StripTrailing(getline('.')))
    endif
    call s:SmartJoin(a:count - 1)
  endif
endfunction


" FUNCTION: SaveCursorSmartJoin(count) {{{1
" ==============================================================================
" A wrapper around SmartJoin(count) used to save the cursor position.

function! g:SaveCursorSmartJoin(count)
  let l:curpos = getcurpos()
  call s:SmartJoin(a:count)
  call setpos('.', l:curpos)
endfunction


" FUNCTION: SaveCursorVisualSmartJoin(count) {{{1
" ==============================================================================
" A wrapper around SmartJoin(count) used to save the cursor position.

function! g:SaveCursorVisualSmartJoin()
  call setpos('.', getpos("'<"))
  call s:SmartJoin(getpos("'>")[1] - getpos('.')[1])
  exe "normal! `<"
endfunction


" MAPPINGS: {{{1
" ==============================================================================

nmap <Plug>SmartJoin :<C-U> call g:SaveCursorSmartJoin(v:count1)<CR>
vmap <Plug>VisualSmartJoin :<C-U> call g:SaveCursorVisualSmartJoin()<CR>

nmap <silent> J <Plug>SmartJoin
vmap <silent> J <Plug>VisualSmartJoin

