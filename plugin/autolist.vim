"autolist.vim

"= script functions ============================================================

" credit: https://gist.github.com/sedm0784/dffda43bcfb4728f8e90
function! s:autolist_down()
    let l:preceding_line = getline(line(".") - 1)
    if l:preceding_line =~ '\v^\s*\d+\.\s'
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
    elseif l:preceding_line[0] == "-" && l:preceding_line[1] == " "
        " The previous line is an unordered list item
        if strlen(l:preceding_line) == 2
            " ...which is empty: end the list and clear the empty item
            call setline(line(".") - 1, "")
        else
            " ...which is not empty: continue the list
            call setline(".", "- ")
        endif
    endif
endfunction

"===============================================================================


"= global functions ============================================================

function! g:AutolistNewLineBelow()
    execute "normal! o"
    call <SID>autolist_down()
    startinsert!
endfunction

function! g:AutolistNewLineAbove()
    execute "normal! O"
endfunction

function! g:AutolistIndent()
    execute "normal! a<Tab>"
endfunction

function! g:AutolistBackspace()
    execute "normal! a<BS>"
endfunction

"===============================================================================
