local fn = vim.fn
local cmd = vim.cmd
-- ============================================================================
-- ArrageKindle
-- ============================================================================
vim.api.nvim_create_user_command('ArrageKindle', function()
  cmd([[%s/^\(注文日\|合計\|受取人\|工藤秋生\|注文番号.*\|\s*注文の詳細.*\|Kindle 版\|販売:.*\|コンテンツと.*\|商品レビューを書く\|注文を非表示にする\)\n//ge]])
  cmd([[%s/^\s\+注文内容を表示 領収書等\s\+\n//ge]])
  cmd([[%s/^\s*\n//ge]])
  cmd([[%s/\n^￥\s*/\t/ge]])
  cmd([[%s/\(\d\{4\}年\)\@<=\(\d月\)/0\2/ge]])
  cmd([[%s/\(\d\{4\}年\d\d月\)\@<=\(\d日\)/0\2/ge]])
  cmd([[%s/^\(\d\{4\}年\d\d月\d\d日\t[0-9,]\+$\)\n/\1\t/ge]])
  cmd([[%s/^\(\d\{4\}年\d\d月\d\d日\t[0-9,]\+\t.\+$\)\n/\1\t/ge]])
  cmd([[%s/^\(\d\{4\}\)年\(\d\d\)月\(\d\d\)日/\1\/\2\/\3/ge]])
  cmd([[sort u]])
  cmd([[normal G"_dd]])
end, {})

-- ============================================================================
-- ArrageGift
-- ============================================================================
vim.api.nvim_create_user_command('ArrageGift', function()
  cmd([[g/利用　(注文番号/d]])
  cmd([[%s/^\n//ge]])
  -- cmd([[%s/登録 (ギフト券番号: //ge]])
  -- cmd([[%s/ギフト券 オートチャージ (#//ge]])
  -- cmd([[%s/) //ge]])
  cmd([[%s/￥//ge]])
  cmd([[%s/\(\d\{4\}\/\)\@<=\(\d\/\)/0\2/ge]])
  cmd([[%s/\(\d\{4\}\/\d\d\/\)\@<=\(\d\s\)/0\2/ge]])
  cmd([[sort]])
end, {})

-- ============================================================================
-- MakeAudacityImportLabelTxtFile
-- ============================================================================
vim.api.nvim_create_user_command('MakeAudacityImportLabelTxtFile', function(opts)
  local lastTrackTime = '0.000000'
  local first = opts.line1
  local end_line = opts.line2
  if first == 0 then first = 1 end
  if end_line == 0 then end_line = fn.line("$") end

  local idx = 1
  for i = first, end_line do
    local strline = fn.getline(i)
    local timeIn = fn.matchlist(strline, [[\(\d\):\(\d\{2\}\):\(\d\{2\}\)\.\(\d\{3\}\)]], 0, 1)
    
    -- LuaからVimscriptリストを受け取ると1-basedになるため timeIn[2] から参照
    if #timeIn > 0 and timeIn[2] ~= "" then
      local total_sec = tonumber(timeIn[2]) * 3600 + tonumber(timeIn[3]) * 60 + tonumber(timeIn[4])
      local nextTrackTime = string.format("%s.%s000", total_sec, timeIn[5])
      
      fn.setline(i, lastTrackTime .. "\t" .. nextTrackTime .. "\tラベル" .. string.format("%02d", idx))
      lastTrackTime = nextTrackTime
    end
    idx = idx + 1
  end
end, { range = "%" })

-- ============================================================================
-- HugoNewPost
-- ============================================================================
vim.api.nvim_create_user_command('HugoNewPost', function()
  if fn.isdirectory(fn.expand(vim.g.hugo_directory or "")) == 1 then
    local hugoBaseDir = fn.expand(vim.g.hugo_directory)
    cmd('lcd ' .. hugoBaseDir)
    
    local count_str
    if fn.has('win32') == 1 or fn.has('win64') == 1 then
      count_str = fn.system('dir /b ' .. hugoBaseDir .. '\\content\\post | find /c /v ""')
    else
      count_str = fn.system('ls ' .. hugoBaseDir .. '/content/post | wc -l')
    end
    
    local count = tonumber(vim.trim(count_str)) or 0
    local newfilename = fn.strftime("%Y-%m-%d-") .. string.format("%05d", count + 1)
    
    fn.system('hugo new post/' .. newfilename .. '.md')
    cmd('tabe content/post/' .. newfilename .. '.md')
  end
end, {})

-- ============================================================================
-- OpenHugo
-- ============================================================================
vim.api.nvim_create_user_command('OpenHugo', function()
  local filename = fn.expand("%:r")
  if filename ~= '' then
    local url = 'http://localhost:1313/blog/' .. fn.substitute(filename, '-', "/", "g") .. '/'
    if fn.has('win32') == 1 or fn.has('win64') == 1 then
      cmd('!start ' .. url)
    elseif fn.executable('firefox') == 1 then
      cmd('!firefox ' .. url)
    else
      cmd('OpenBrowser ' .. url)
    end
  end
end, {})

-- ============================================================================
-- GetLyrics
-- ============================================================================
vim.api.nvim_create_user_command('GetLyrics', function()
  -- 1. コマンドラインで曲のID（*******の部分）を入力させる
  local id = vim.fn.input("歌ネットの曲IDを入力してください (例: 12345): ")
  
  -- 空のままエンターを押した場合はキャンセル
  if id == "" then
    print("\nキャンセルしました。")
    return
  end
  
  -- 画面を更新して「取得中」メッセージを表示
  print("\n取得中...")
  vim.cmd('redraw')

  -- 2. curlを使ってバックグラウンドでHTMLを直接取得
  local url = "https://www.uta-net.com/song/" .. id .. "/"
  local html = vim.fn.system({"curl", "-s", url})
  
  if vim.v.shell_error ~= 0 or html == "" then
    print("取得に失敗しました。IDが間違っているか、ネットワークを確認してください。")
    return
  end

  -- 3. Extract: HTMLから必要な部分だけをくり貫く
  local title  = vim.fn.matchstr(html, [[<title>\zs\_.\{-}\ze</title>]])
  local credit = vim.fn.matchstr(html, [[歌詞ページです。\zs\_.\{-}\ze。]])
  local lyrics = vim.fn.matchstr(html, [[<div id="kashi_area" itemprop="text">\zs\_.\{-}\ze</div>]])
  local artist = vim.fn.matchstr(html, [[<span itemprop="byArtist name">\zs\_.\{-}\ze</span>]])

  local result_lines = {}
  
  if title ~= "" then table.insert(result_lines, title) end
  if credit ~= "" then table.insert(result_lines, credit) end
  if artist ~= "" then table.insert(result_lines, artist) end
  if lyrics ~= "" then
    for line in vim.gsplit(lyrics, "\n") do
      table.insert(result_lines, line)
    end
  end

  if #result_lines == 0 then
    print("指定されたパターンが見つかりませんでした。")
    return
  end

  -- 4. 現在のバッファを、くり貫いた結果で上書きする
  vim.api.nvim_buf_set_lines(0, 0, -1, false, result_lines)

  -- 5. Format: 不要なタグの削除と、指定文字列の自動置換
  local replacements = {
    [[1s/^\S\+\s\+\(.\{-}\)\s\+歌詞.*/\[ti:\1\]/e]],
    [[2s/作詞:/\[au:/ge]],
    [[2s/$/\]/ge]],
    [[2s/,作曲:/\//e]],
    [[3s/^/\[ar:/ge]],
    [[3s/$/\]/ge]],
    [[%s/<br \=\/\=>/\r/ge]],
    [[%s/<\/div>//ge]],
    [[%s/^\s\+<div.*>//ge]],
    [[%s/&amp;/\&/ge]],
    [[%s/GORO MATSUI/松井五郎/ige]],
    [[%s/KYOSUKE HIMURO/氷室京介/ige]],
    [[%s/\n\+\%$//e]],
  }
  
  for _, cmd in ipairs(replacements) do
    vim.cmd('silent! ' .. cmd)
  end
  print("歌詞の取得と整形が完了しました！")
end, {})
