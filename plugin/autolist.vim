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
    let g:autolist_unordered_markers = ['-', '*', '+']
endif

"variables (constants) for defining check directions for s:DetectListMarker
let s:dir_down = 1
let s:dir_up = 0

"variable (constant) for matching an empty list item
let s:empty_item = "emptylistitem"

"run a validation on markers, numbered must contain a '#' and neither can match
" s:empty_item
for s:marker in g:autolist_numbered_markers
    if s:marker !~ "#"
        echoerr "autolist, invalid marker: '" . s:marker . "' numbered markers must contain a '#'"
        unlet g:loaded_autolist
        finish
    elseif s:marker == s:empty_item
        echoerr "autolist, invalid marker: '" . s:marker . "' markers cannot match empty item marker"
        unlet g:loaded_autolist
        finish
    endif
endfor

for s:marker in g:autolist_unordered_markers
    if s:marker == s:empty_item
        echoerr "autolist, invalid marker: '" . s:marker . "' markers cannot match empty item marker"
        unlet g:loaded_autolist
        finish
    endif
endfor

"just to avoid any scoping issues
unlet s:marker

"= script functions ============================================================

"detect the list type and return the appropriate list marker
"param: dir - the direction to search in, the value of this parameter should
"only be s:dir_down or s:dir_up
function s:DetectListMarker(dir)
    "error check parameter
    if a:dir != s:dir_up && a:dir != s:dir_down
        echoerr "Autolist: DetectListMarker: dir: invalid value: " . a:dir
    endif

    "set l:check_line based on direction of search
    if a:dir == s:dir_down
        let l:check_line = getline(line(".") - 1)
    else
        let l:check_line = getline(line(".") + 1)
    endif

    let l:list_indent = matchstr(l:check_line, '\v^\s*')

    "check for numbered markers
    for l:marker in g:autolist_numbered_markers
        let l:orig_marker = l:marker
        "substitute the '#' character for regex one or more digits
        "for some reason two pairs of backslashes were needed
        "pattern is '-\=\d\+' for an optional '-' and one or more digits
        let l:marker = substitute(l:marker, "#", "-\\\\=\\\\d\\\\+", "")

        if l:check_line =~ '\v^\s*\V' . l:marker . '\v\s+\S+'
            "matched a non-empty list item
            let l:list_sep = matchstr(l:check_line, '\v^\s*\V' . l:marker . '\v\zs\s+')

            let l:marker = l:orig_marker
            "again substitute needed two pairs of backslashes
            let l:marker = substitute(l:marker, "#.*", "\\\\zs-\\\\=\\\\d\\\\*", "")

            let l:list_index = matchstr(l:check_line, '\v\s*\V' . l:marker)

            "calculate new index based on direction of search
            if a:dir == s:dir_down
                let l:list_index = l:list_index + 1
            else
                let l:list_index = l:list_index - 1
            endif

            let l:marker = l:orig_marker
            let l:marker = substitute(l:marker, "#", l:list_index, "")
            return l:list_indent . l:marker . l:list_sep
        elseif l:check_line =~ '\v^\s*\V' . l:marker . '\v\s*$'
            "matched an empty list item
            return s:empty_item
        endif
    endfor

    "check for unordered markers
    for l:marker in g:autolist_unordered_markers
        if l:check_line =~ '\v^\s*\V' . l:marker . '\v\s+\S+'
            "matched a non-empty list item
            let l:list_sep = matchstr(l:check_line, '\v^\s*\V' . l:marker . '\v\zs\s+')

            return l:list_indent . l:marker . l:list_sep
        elseif l:check_line =~ '\v^\s*\V' . l:marker . '\v\s*$'
            "matched an empty list item
            return s:empty_item
        endif
    endfor

    return ""
endfunction

"continue a list by checking the previous line (insert item below)
function! s:ContinueDown()
    let l:marker = <SID>DetectListMarker(s:dir_down)

    "don't do anything if we didn't match a list
    if (l:marker != "")
        if (l:marker == s:empty_item)
            "previous line was an empty item, clear it
            call setline(line(".") - 1, "")
        else
            "marker is next list item, continue the list
            call setline(".", l:marker)
        endif
    endif
endfunction

"continue a list by checking the next line (insert item above)
function! s:ContinueUp()
    let l:marker = <SID>DetectListMarker(s:dir_up)

    "don't do anything if we didn't match a list
    if (l:marker != "")
        if (l:marker == s:empty_item)
            "next line was an empty item, clear it
            call setline(line(".") + 1, "")
        else
            "marker is a list item, continue the list
            call setline(".", l:marker)
        endif
    endif
endfunction

"===============================================================================


"= helper functions ============================================================

"for creating a new line with the `o` key
function! s:NewLineBelow()
    execute "normal! o"
    call <SID>ContinueDown()
    startinsert!
endfunction

"for creating a new line with the return key
function! s:Return()
    "if cursor is at the end of the line or the line is empty
    if (col(".") == col("$") - 1 || getline(".") == "")
        "enter a newline call function
        execute "normal! a\<CR>"
        call <SID>ContinueDown()
        startinsert!
    elseif (col(".") == 1) "if cursor is at the start
        "short deletes are saved in the "- register
        let l:tmp = @-
        execute "normal! Di\<CR>"
        call <SID>ContinueDown()
        execute "normal! $\"-pa"
        let @- = l:tmp
        startinsert
    else "else cursor is somewhere in the middle of the line
        "short deletes are saved in the "- register
        let l:tmp = @-
        execute "normal! lDa\<CR>"
        call <SID>ContinueDown()
        execute "normal! $\"-pa"
        let @- = l:tmp
        startinsert
    endif
endfunction

"for creating a new line with the `O` key
function! s:NewLineAbove()
    execute "normal! O"
    call <SID>ContinueUp()
    startinsert!
endfunction

"===============================================================================


"= create mappings =============================================================

nnoremap <silent> <Plug>AutolistNewLineAbove :call <SID>NewLineAbove()<CR>
nnoremap <silent> <Plug>AutolistNewLineBelow :call <SID>NewLineBelow()<CR>
nnoremap <silent> <Plug>AutolistReturn :call <SID>Return()<CR>

"===============================================================================
