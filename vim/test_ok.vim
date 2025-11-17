if !exists('g:test#ruby#test_ok#file_pattern')
  let g:test#ruby#test_ok#file_pattern = '\v_test\.rb$'
endif

function! test#ruby#test_ok#test_file(file) abort
  return a:file =~# g:test#ruby#test_ok#file_pattern
endfunction

function! test#ruby#test_ok#executable() abort
  if filereadable('Gemfile') && get(g:, 'test#ruby#bundle_exec', 1)
    return 'bundle exec ruby'
  else
    return 'ruby'
  endif
endfunction

function! test#ruby#test_ok#build_position(type, pos) abort
  if a:type ==# 'nearest'
    let name = s:nearest_test(a:pos)
    if !empty(name)
      return [a:pos['file'], '--name', name]
    else
      return [a:pos['file']]
    endif
  elseif a:type ==# 'file'
    return [a:pos['file']]
  else
    return []
  endif
endfunction

function! test#ruby#test_ok#build_args(args) abort
  for idx in range(0, len(a:args) - 1)
    if test#base#file_exists(a:args[idx])
      let path = remove(a:args, idx)
      break
    endif
  endfor

  return [path] + a:args
endfunction

function! s:nearest_test(pos) abort
  let name = test#base#nearest_test(a:pos, { 'test': ['\v^\s*def\s+(test_\w+)'], 'namespace': [] })
  return empty(name['test']) ? '' : name['test'][0]
endfunction
