if exists('g:loaded_iced_function_list')
  finish
endif
let g:loaded_iced_function_list = 1

let s:save_cpo = &cpo
set cpo&vim

command! IcedBrowseFunction call iced#functions#list()

let &cpo = s:save_cpo
unlet s:save_cpo

