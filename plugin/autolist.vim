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

if !exists('g:autolist_override_global_markers')
    let g:autolist_override_global_markers = 0
endif

"= create mappings =============================================================

nnoremap <silent> <Plug>AutolistNewLineAbove :call autolist#NewLineAbove()<CR>
nnoremap <silent> <Plug>AutolistNewLineBelow :call autolist#NewLineBelow()<CR>
nnoremap <silent> <Plug>AutolistReturn :call autolist#Return()<CR>

"===============================================================================
