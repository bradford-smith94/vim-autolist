#vim-autolist
A plugin that automatically continues lists.

When typing out a list, going to the next line will automatically insert your list marker.

##Installation
You can install with Vundle or similar plugin managers using:
```
    Plugin 'bradford-smith94/vim-autolist'
```

Or you can use the Pathogen method:
```
    cd ~/.vim/bundle
    git clone git://github.com/bradford-smith94/vim-autolist.git
```

Once installed and help tags have been generated you can read the help with `:help autolist`.

##Usage
This plugin exposes commands:
```
    :AutolistNewLineAbove
    :AutolistNewLineBelow
    :AutolistReturn
```

These functions need to be mapped to keys or called directly in order to be
used.

A default mapping example would be:
```
    "these are mapped for all filetypes all the time
    inoremap <CR> <Esc>:AutolistReturn<CR>
    nnoremap o :AutolistNewLineBelow<CR>
    nnoremap O :AutolistNewLineAbove<CR>
```

To use a command directly:
```
    "type something like this then hit enter
    :AutolistNewLineBelow
```

##Configuration

In order to enable this plugin for specific filetypes you can make your
mapping inside an autocmd; for example, the following makes a buffer local
mapping for the enter key only in markdown files:
```
    autocmd Filetype markdown inoremap <buffer> <CR> <Esc>:AutolistReturn<CR>
```

The other way to make filetype specific mappings would be to put the mapping in
an ftplugin file.
```
    "in ~/.vim/ftplugin/markdown.vim
    inoremap <buffer> <CR> <Esc>:AutolistReturn<CR>
```

##Issues

Needs support for more list markers, only two styles are valid right now:

'`1. `' for numbered, and '`- `' for unordered.


##Credits
I got the idea for this plugin from [sedm0784](https://www.github.com/sedm0784)'s gist [Vim Auto List Completion](https://gist.github.com/sedm0784/dffda43bcfb4728f8e90).
