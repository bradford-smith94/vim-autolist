"autolist.vim

if exists('g:loaded_autolist') || &cp
    finish
endif
let g:loaded_autolist = 1

"= script functions ============================================================

" credit: https://gist.github.com/sedm0784/dffda43bcfb4728f8e90
function! s:autolist_down()
    let l:preceding_line = getline(line(".") - 1)
    if l:preceding_line =~ '\v^\s*\d+\.\s\S+'
        " The previous line matches any number of digits followed by a full-stop
        " followed by one character of whitespace followed by one more character
        " i.e. it is an ordered list item

        " Continue the list
        let l:list_index = matchstr(l:preceding_line, '\v^\s*\zs\d*')
        let l:list_index = l:list_index + 1
        let l:list_indent = matchstr(l:preceding_line, '\v^\s*')
        call setline(".", l:list_indent. l:list_index. ". ")
    elseif l:preceding_line =~ '\v^\s*\d+\.\s$'
        " The previous line matches any number of digits followed by a full-stop
        " followed by one character of whitespace followed by nothing
        " i.e. it is an empty ordered list item

        " End the list and clear the empty item
        call setline(line(".") - 1, "")
    elseif l:preceding_line =~ '\v^\s*\-\s\S+'
        " The previous line is an unordered list item
        let l:list_indent = matchstr(l:preceding_line, '\v^\s*')
        call setline(".", l:list_indent. "- ")
    elseif l:preceding_line =~ '\v^\s*\-\s$'
        call setline(line(".") - 1, "")
    endif
endfunction

function! s:autolist_up()
    call <SID>autolist_down()
    if getline(".") =~ '\v\s*'
        " Fell into a case where we are inserting a new line above the rest of
        " the list, we need to check the line below this one
        let l:next_line = getline(line(".") + 1)
        if l:next_line =~ '\v^\s*\d+\.\s\S+'
            let l:list_index = matchstr(l:next_line, '\v^\s*\zs\d*')
            let l:list_index = l:list_index - 1
            let l:list_indent = matchstr(l:next_line, '\v^\s*')
            call setline(".", l:list_indent. l:list_index. ". ")
        elseif l:next_line =~ '\v^\s*\-\s\S+'
            let l:list_indent = matchstr(l:next_line, '\v^\s*')
            call setline(".", l:list_indent. "- ")
        endif
    endif
    " Renumber the list below this item (if it's a numbered list)
endfunction

"===============================================================================


"= helper functions ============================================================

"for creating a new line with the `o` key
function! s:AutolistNewLineBelow()
    execute "normal! o"
    call <SID>autolist_down()
    startinsert!
endfunction

"for creating a new line with the return key
function! s:AutolistReturn()
    execute "normal! a\<CR>"
    call <SID>autolist_down()
    startinsert
endfunction

"for creating a new line with the `O` key
function! s:AutolistNewLineAbove()
    execute "normal! O"
    call <SID>autolist_up()
    startinsert!
endfunction

"for hitting tab (if in a list and positioned at the start indent one level)
"NOTE: <Esc>>>a
function! s:AutolistIndent()
    execute "normal! a\<Tab>"
endfunction

"for hitting backspace (if in a list and positioned at the start unindent)
"NOTE: <Esc><<a
function! s:AutolistBackspace()
    execute "normal! a\<BS>"
endfunction

"===============================================================================


"= command mappings ============================================================

command! AutolistNewLineBelow call <SID>AutolistNewLineBelow()
command! AutolistReturn call <SID>AutolistReturn()
command! AutolistNewLineAbove call <SID>AutolistNewLineAbove()
command! AutolistIndent call <SID>AutolistIndent()
command! AutolistBackspace call <SID>AutolistBackspace()

"===============================================================================
