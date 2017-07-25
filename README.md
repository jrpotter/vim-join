Smart Join
==========

[VERSION: 0.1]

Overview
--------

Allows for line joining that respects textwidth and optionally clears
whitespace.

Refer to ```doc/``` for complete instructions on use.

Installation
------------

I prefer using [vim-plug](https://github.com/junegunn/vim-plug) for plugin
management as follows:

```vim
Plug 'jrpotter/vim-join'
```

Follow use according to plugin manager you use or optionally copy
plugin/join.vim from this repo into ```$VIM_DIR/plugin```.

Usage
-----

Create a mapping to <Plug>SmartJoin to use the new joining functionality.
For instance,

noremap J <Plug>SmartJoin

