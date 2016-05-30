"autolist.vim

if exists('g:loaded_autolist') || &cp
    finish
endif
let g:loaded_autolist = 1

"= variables ===================================================================

if !exists('g:autolist_numbered_markers')
    let g:autolist_numbered_markers = ['#.', '#)', '#-']
endif

if !exists('g:autolist_unordered_markers')
    let g:autolist_unordered_markers = ['-', '*']
endif

"= script functions ============================================================

" detect the list type and return the appropriate list marker
function s:autolist_detect()
    let l:preceding_line = getline(line(".") - 1)
    let l:list_indent = matchstr(l:preceding_line, '\v^\s*')

    "check for numbered markers
    for l:marker in g:autolist_numbered_markers
        "substitute the '#' character for regex one or more digits
        let l:marker = substitute(l:marker, "#", "\d+", "")

        if l:preceding_line =~ '\v^\s*' . l:marker . '\s+\S+'
            " matched a non-empty list item
            let l:list_index = matchstr(l:preceding_line, '\v\s*\zs\d*')
            let l:list_index = l:list_index + 1
            let l:marker = substitute(l:marker, "\d+", l:list_index, "")
            return l:list_indent . l:marker . " "
        elseif l:preceding_line =~ '\v^\s*' . l:marker . '\s*$'
            " matched an empty list item
        endif
    endfor

    "check for unordered markers
    for l:marker in g:autolist_unordered_markers
        if l:preceding_line =~ '\v^\s*' . l:marker . '\s+\S+'
            " matched a non-empty list item
            return l:list_indent . l:marker
        elseif l:preceding_line =~ '\v^\s*' . l:marker . '\s*$'
            " matched an empty list item
        endif
    endfor

    return ""
endfunction

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
    "if cursor is at the end of the line or the line is empty
    if (col(".") == col("$") - 1 || getline(".") == "")
        "enter a newline call function
        execute "normal! a\<CR>"
        call <SID>autolist_down()
        startinsert!
    elseif (col(".") == 1) "if cursor is at the start
        "short deletes are saved in the "- register
        execute "normal! Di\<CR>"
        call <SID>autolist_down()
        execute "normal! $\"-pa"
        startinsert
    else "else cursor is somewhere in the middle of the line
        "short deletes are saved in the "- register
        execute "normal! lDa\<CR>"
        call <SID>autolist_down()
        execute "normal! $\"-pa"
        startinsert
    endif
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
