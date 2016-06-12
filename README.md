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

A simple mapping example would be:
```
    "these are mapped for all filetypes all the time
    inoremap <CR> <Esc>:AutolistReturn<CR>
    nnoremap o :AutolistNewLineBelow<CR>
    nnoremap O :AutolistNewLineAbove<CR>
```

This example makes the `Enter` key in insert mode call autolist as well as the
`o` and `O` keys in normal mode, so that while you are normally typing out a
list autolist will work automatically.

Or to use a command directly:
```
    "just type something like this then hit enter
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
###Defining custom markers

The list markers that are detected by autolist can be configured. The
following variables will set the recognized markers for ordered and unordered
lists respectively, their default values are shown. Override these in your
vimrc or other configuration file to change what markers autolist will
recognize.
```
    g:autolist_numbered_markers = ['#.', '#)', '#-']
    g:autolist_unordered_markers = ['-', '*']
```

Numbered markers must contain a `#` character, this is where autolist will
insert the list item number.

Markers must not have the value `emptylistitem` (and why would they anyway?)
this is the value autolist uses to internally recognize when it matches an
empty item (line with just a marker and whitespace) so that it can delete it
automatically.


##Credits
I got the idea for this plugin from [sedm0784](https://www.github.com/sedm0784)'s gist [Vim Auto List Completion](https://gist.github.com/sedm0784/dffda43bcfb4728f8e90).
