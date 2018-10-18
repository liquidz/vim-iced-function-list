let s:save_cpo = &cpo
set cpo&vim

function! s:open(mode, resp) abort
  if !has_key(a:resp, 'file') || empty(a:resp['file'])
    return iced#message#error('not_found')
  endif

  let path = substitute(a:resp['file'], '^file:', '', '')
  if !filereadable(path)
    return iced#message#error('not_found')
  endif

  let cmd = ':edit'
  if a:mode ==# 'v'
    let cmd = ':split'
  elseif a:mode ==# 't'
    let cmd = ':tabedit'
  endif
  exe printf('%s %s', cmd, path)

  call cursor(a:resp['line'], a:resp['column'])
  normal! zz
endfunction

function! s:resolve(mode, func_name) abort
  call iced#nrepl#op#cider#info(a:func_name, {resp -> s:open(a:mode, resp)})
endfunction

function! s:select(resp) abort
  if !has_key(a:resp, 'value') | return iced#message#error('not_found') | endif
  call iced#selector({'candidates': a:resp['value'], 'accept': funcref('s:resolve')})
endfunction

function! iced#functions#list() abort
  call iced#message#info('fetching')

  let ns = iced#nrepl#ns#name()
  let code = printf('(map (comp #(subs %% 2) str second) (ns-publics ''%s))', ns)
  call iced#eval_and_read(code, funcref('s:select'))
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
