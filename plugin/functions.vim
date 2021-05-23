" functions.vim : arimasou16's favorite functions
"
" Name Of File: functions.vim
" Maintainer:   arimasou16 <arimasou16@gmail.com>
" URL:          https://arimasou16.com
" Script URL:   https://github.com/arimasou16/functions.vim
" Last Change:  2017/03/14
" Version:      1.0
"
command! -nargs=0 GetAmazon call s:GetTitleFromAmazon()
function! s:GetTitleFromAmazon()
  execute '%s/^\s*//ge'
  let flg = 0
  for i in range(1, line("$"))
    " 現在の行を取得
    let strline = getline(i)
    " 再生の文字位置を取得
    let found = match(strline, '^再生: ', 0)
    " 0で再生が始まる場合
    if found >= 0
      let flg = 1
      break
    endif
  endfor
  if flg == 0
    execute '%s/^\s\+\d\{1,\}:\d\{1,\}\s\+$\n//ge'
    execute '%s/^購入:.*$\n//ge'
    execute '%s/^\d\{1,\}\n//ge'
  else
    " 最初の行から最後の行まで
    for i in range(1, line("$"))
      " 現在の行を取得
      let strline = getline(i)
      " 再生の文字位置を取得
      let found = match(strline, '^再生: ', 0)
      " 0で再生が始まる場合
      if found == 0
        " '再生: 'の文字を切り捨て
        let strline = strline[8:]
        " 現在の行の文字列の中間位置を取得
        let num = ((strlen(strline)) / 2) + 2
        " 中間位置から以前の文字を切り捨て
        let strline = strline[num:]
      endif
      " 現在の行をstrlineで置換
      call setline(i, strline)
    endfor
  endif
  execute '%s/　/ /ge'
  execute '%s/～\|〜/\~/ge'
  execute '%s/“/"/ge'
  execute '%s/’/''/ge'
  execute '%!nkf -Z0'
  execute '%s/^\s*$\n//ge'
  execute '%s/\s\+$//ge'
  execute '%s/^\s\+//ge'
endfunction

command! -nargs=0 GetTHMV call s:GetTitleFromHMV()
function! s:GetTitleFromHMV()
  execute '%s/^\s\+//ge'
  execute '%s/^\s\+\n//ge'
  execute '%s/^\d\d．\n//ge'
  execute '%s/^\n//ge'
  execute '%!nkf -Z0'
  execute '%s/～/~/ge'
  execute '%s/“/"/ge'
  execute '%s/’/''/ge'
  execute '%s/`/''/ge'
  execute '%s/\(\S\)\([(\-\[].\+[)\-\]]\)\@=/\1 /ge'
  execute '%s/\s\+$//ge'
endfunction

command! -nargs=0 ArrageKindle call s:ArragePurchaseHistoryOfKindle()
function! s:ArragePurchaseHistoryOfKindle()
  execute '%s/^\(注文日\|合計\|受取人\|工藤秋生\|注文番号.*\|\s*注文の詳細.*\|Kindle 版\|販売:.*\|コンテンツと.*\|商品レビューを書く\|注文を非表示にする\)\n//ge'
  execute '%s/^\s*\n//ge'
  execute '%s/\n^￥ /\t/ge'
  execute '%s/\(\d\{4\}年\)\@<=\(\d月\)/0\2/ge'
  execute '%s/\(\d\{4\}年\d\d月\)\@<=\(\d日\)/0\2/ge'
  execute '%s/^\(\d\{4\}年\d\d月\d\d日\t[0-9,]\+$\)\n/\1\t/ge'
  execute '%s/^\(\d\{4\}年\d\d月\d\d日\t[0-9,]\+\t.\+$\)\n/\1\t/ge'
  execute '%s/^\(\d\{4\}\)年\(\d\d\)月\(\d\d\)日/\1\/\2\/\3/ge'
  sort u
  execute "normal G\"_dd"
endfunction

command! -nargs=0 ArrageGift call s:ArragePaymentHistoryOfGift()
function! s:ArragePaymentHistoryOfGift()
  execute 'g/利用　(注文番号/d'
  execute '%s/^\n//ge'
  "execute '%s/登録 (ギフト券番号: //ge'
  "execute '%s/ギフト券 オートチャージ (#//ge'
  "execute '%s/) //ge'
  execute '%s/￥//ge'
  execute '%s/\(\d\{4\}\/\)\@<=\(\d\/\)/0\2/ge'
  execute '%s/\(\d\{4\}\/\d\d\/\)\@<=\(\d\s\)/0\2/ge'
  sort
endfunction

command! -nargs=0 ArrageRoute call s:ArrageRouteSearch()
function! s:ArrageRouteSearch()
  execute '%s/^\s\+\(.*\[train\]\|.*\d\d:\d\d着\|.*\d\d:\d\d発\)\@!.*$//ge'
  execute '%s/^\[train\]\n//ge'
  execute '%s/^\n//ge'
endfunction

command! -nargs=0 MarkSplit call s:MarkSplit()
function! s:MarkSplit()
  execute '%s/^/\[Mark\]\rPos=0/g'
endfunction

command! -nargs=0 Todo call s:OpenTodoTxt()
function! s:OpenTodoTxt()
  if filereadable(expand(g:todoTaskFile))
    execute 'tabe '. g:todoTaskFile
  endif
endfunction

command! -nargs=0 Done call s:OpenDoneTxt()
function! s:OpenDoneTxt()
  if filereadable(expand(g:todoTaskFile))
    execute 'tabe '. g:doneTaskFile
  endif
endfunction

command! -nargs=0 OpenHugo call s:OpenBrowserOnHugo()
function! s:OpenBrowserOnHugo()
  let l:filename = expand("%:r")
  if filename != ''
    let l:url = 'http://localhost:1313/blog/' . substitute(filename, '-', "/", "g") . '/'
    if has('win32') || has('win64')
      execute '!start ' . url
    elseif executable('firefox')
      execute '!firefox ' . url
    endif
  endif
endfunction

command! -nargs=1 ConvertWithPandoc call s:ConvertWithPandoc(<f-args>)
function! s:ConvertWithPandoc(type)
  let l:type = a:type
  if type == 'html' && filereadable(expand(g:pandoc_css))
    let l:cssfile = expand(g:pandoc_css)
    call execute("!pandoc -s --self-contained --metadata title=\"". expand("%:r") ."\" -f markdown -t ". type ." -c \"". cssfile ."\" -o \"". expand("%:r") .".". type ."\" \"". expand("%") ."\"")
  else
    call execute("!pandoc -f markdown -t ". type ." -o \"". expand("%:r") .".". type ."\" \"". expand("%") ."\"")
    echo "!pandoc -f markdown -t ". type ." -o \"%:r.". type ."\" \"%\""
  endif
  call execute("!start \"". expand("%:r.") .".". type ."\"")
endfunction


command! -range=% -nargs=0 RenameMethodCamelCase :<line1>,<line2>call s:RenameMethodCamelCase()
function! s:RenameMethodCamelCase() range abort
  let first = a:firstline
  let end   = a:lastline
  if first == 0
    let first = 1
  endif
  if end == 0
    let end = line("$")
  endif
  execute first . ',' . end . 's/\(^\|_\|\.\)\@<=\(.\)/\U&/ge'
  execute first . ',' . end . 's/_\|\.//ge'
  execute first . ',' . end . 's/^/get/ge'
endfunction

command! -range=% -nargs=0 MakeAudacityImportLabelTxtFile :<line1>,<line2>call s:MakeAudacityImportLabelTxtFile()
function! s:MakeAudacityImportLabelTxtFile() range abort
  let lastTrackTime = '0.000000'
  let first = a:firstline
  let end   = a:lastline
  if first == 0
    let first = 1
  endif
  if end == 0
    let end = line("$")
  endif
  let idx = 1
  for i in range(first, end)
    let strline = getline(i)
    let timeIn = matchlist(strline, '\(\d\):\(\d\{2\}\):\(\d\{2\}\)\.\(\d\{3\}\)', 0, 1)
    if len(timeIn) > 0
      let nextTrackTime = printf("%s", timeIn[1]*3600 + timeIn[2]*60 + timeIn[3]) . '.' . timeIn[4] . '000'
      call setline(i, lastTrackTime . "\t" . nextTrackTime . "\tラベル" . printf("%02s", idx))
      let lastTrackTime = nextTrackTime
    endif
    let idx = idx + 1
  endfor
endfunction

command! -nargs=0 HugoNewPost call s:HugoNewPost()
function! s:HugoNewPost()
  if isdirectory(expand(g:hugo_directory))
    let huguBaseDir = expand(g:hugo_directory)
    execute 'lcd ' . huguBaseDir
    if has('win32') || has('win64')
      let l:count = system('dir /b ' . huguBaseDir . '\content\post | find /c /v ""')
    else
      let l:count = system('ls ' . huguBaseDir . '/content/post | wc -l')
    endif
    let newfilename = strftime("%Y-%m-%d-") . printf("%05d", l:count + 1)
    call system('hugo new post/' . newfilename . '.md')
    execute 'tabe content/post/' . newfilename . '.md'
  endif
endfunction
finish
