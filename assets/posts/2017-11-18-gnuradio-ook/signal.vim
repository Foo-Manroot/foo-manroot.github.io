" File: signal.vim
" Author: Foo-Mamroot
" Description: syntax file for *.signal files
" Last Modified: 2018-06-12

if exists ("b:current_syntax")
	finish
endif

" Case sensitive
syntax keyword header channel command bits
syntax keyword on ON
syntax keyword off OFF

" Regexp for channel names (string before a tab)
syntax match chan_name /^\([^ \t]\+\)/

" Comments
syntax match comment "#.*$"

" Regexp for bits
syntax match zero /0\+/
syntax match one /1\+/


"""
" Results
"
" Format (case insensitive and tabs - key are string of bits):
"
" PACKET_FIELD:
"	key = value
"""
"syntax match	res_key contained /^\([^ =]\+\)/
syntax match	res_val contained /[=]\@<=.*/
syntax match	field	contained /^.*:$/

syntax region result start=/^\([^#]\+\):$/ end=/^[ \t]*$/
	\ fold transparent contains=comment,zero,one,on,off,res_key,res_val,field

let b:current_syntax = "signal"


" Colouring rules
highlight def link	header		Constant
highlight def link	chan_name	Identifier
highlight def link	comment		Comment

highlight		on		ctermfg=DarkRed
highlight		off		ctermfg=DarkGreen

highlight		zero		ctermfg=red	guifg=#ff0000
highlight		one		ctermfg=green	guifg=#00ff00

" Result
"highlight		res_key		ctermfg=yellow
highlight		res_val		ctermfg=yellow
highlight		field		ctermfg=brown

