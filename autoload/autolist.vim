"autoload/autolist.vim

"variable (constant) for matching an empty list item
let s:empty_item = 'emptylistitem'

"variables (constants) for defining check directions, their values allow them to
"be added to the current line number to check for a possible previous list item
let s:dir_down = -1
let s:dir_up = 1

"= interface functions =========================================================

"for creating a new line with the `o` key
function! autolist#NewLineBelow() abort
    execute 'normal! o'
    call <SID>ContinueList(s:dir_down)
    startinsert!
endfunction

"for creating a new line with the return key
function! autolist#Return() abort
    "if cursor is at the end of the line or the line is empty
    if (col('.') == col('$') - 1 || getline('.') ==? '')
        "enter a newline call function
        execute "normal! a\<CR>"
        call <SID>ContinueList(s:dir_down)
        startinsert!
    elseif (col('.') == 1) "if cursor is at the start
        "short deletes are saved in the "- register
        let l:tmp = @-
        execute "normal! Di\<CR>"
        call <SID>ContinueList(s:dir_down)
        execute 'normal! $"-pg;'
        let @- = l:tmp
        startinsert
    else "else cursor is somewhere in the middle of the line
        "short deletes are saved in the "- register
        let l:tmp = @-
        execute "normal! lDa\<CR>"
        call <SID>ContinueList(s:dir_down)
        execute 'normal! "-pg;'
        let @- = l:tmp
        startinsert
    endif
endfunction

"for creating a new line with the `O` key
function! autolist#NewLineAbove() abort
    execute 'normal! O'
    normal! jmt}mb't
    .,'bnormal!
    normal! 'tk
    call <SID>ContinueList(s:dir_up)
    startinsert!
endfunction

"= internal functions ==========================================================

"continue a list in the given direction 'dir'
function! s:ContinueList(dir) abort
    let l:marker = <SID>DetectListMarker(a:dir)

    if (l:marker !=? '')
        if (l:marker == s:empty_item)
            call setline(line('.') + a:dir, '')
        else
            call setline(line('.'), l:marker)
            normal! $
        endif
    endif
endfunction

"detect the list type and return the appropriate list marker
"param: dir - the direction to search in, the value of this parameter should
"only be s:dir_down or s:dir_up
function! s:DetectListMarker(dir) abort
    "error check parameter
    if a:dir != s:dir_up && a:dir != s:dir_down
        echoerr 'autolist: DetectListMarker: dir: invalid value: ' . a:dir
    endif

    "set l:check_line based on direction of search
    let l:check_line = getline(line('.') + a:dir)

    let l:list_indent = matchstr(l:check_line, '\v^\s*')

    if exists('b:autolist_numbered_markers')
        if g:autolist_override_global_markers ||
                    \ exists('b:autolist_override_global_markers')
                    \ && b:autolist_override_global_markers
            let l:numbered_markers = b:autolist_numbered_markers
        else
            let l:numbered_markers = b:autolist_numbered_markers + g:autolist_numbered_markers
        endif
    else
        let l:numbered_markers = g:autolist_numbered_markers
    endif

    if exists('b:autolist_unordered_markers')
        if g:autolist_override_global_markers ||
                    \ exists('b:autolist_override_global_markers')
                    \ && b:autolist_override_global_markers
            let l:unordered_markers = b:autolist_unordered_markers
        else
            let l:unordered_markers = b:autolist_unordered_markers + g:autolist_unordered_markers
        endif
    else
        let l:unordered_markers = g:autolist_unordered_markers
    endif

    "check for numbered markers
    for l:marker in l:numbered_markers
        let l:orig_marker = l:marker
        "substitute the '#' character for an optional '-' and one or more
        "digits, this matches numbers (optionally negative)
        let l:marker = substitute(l:marker, '#', '-\\=\\d\\+', '')

        if l:check_line =~ '\v^\s*\V' . l:marker . '\v\s+\S+'
            "matched a non-empty list item
            let l:list_sep = matchstr(l:check_line, '\v^\s*\V' . l:marker . '\v\zs\s+')

            let l:marker = l:orig_marker
            let l:marker = substitute(l:marker, '#.*', '\\zs-\\=\\d\\*', '')

            let l:list_index = matchstr(l:check_line, '\v\s*\V' . l:marker)

            "calculate new index based on direction of search
            if a:dir == s:dir_down
                let l:list_index = l:list_index + 1
            else
                let l:list_index = l:list_index - 1
            endif

            let l:marker = l:orig_marker
            let l:marker = substitute(l:marker, '#', l:list_index, '')
            let l:marker = substitute(l:marker, '\\\\', '\', '')
            return l:list_indent . l:marker . l:list_sep
        elseif l:check_line =~ '\v^\s*\V' . l:marker . '\v\s*$'
            "matched an empty list item
            return s:empty_item
        endif
    endfor

    "check for unordered markers
    for l:marker in l:unordered_markers
        if l:check_line =~ '\v^\s*\V' . l:marker . '\v\s+\S+'
            "matched a non-empty list item
            let l:list_sep = matchstr(l:check_line, '\v^\s*\V' . l:marker . '\v\zs\s+')

            let l:marker = substitute(l:marker, '\\\\', '\', '')
            return l:list_indent . l:marker . l:list_sep
        elseif l:check_line =~ '\v^\s*\V' . l:marker . '\v\s*$'
            "matched an empty list item
            return s:empty_item
        endif
    endfor

    return ''
endfunction
