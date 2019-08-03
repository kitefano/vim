" Test for displaying stuff
if !has('gui_running') && has('unix')
  set term=ansi
endif

source view_util.vim
source check.vim
source screendump.vim

func Test_display_foldcolumn()
  CheckFeature folding

  new
  vnew
  vert resize 25
  call assert_equal(25, winwidth(winnr()))
  set isprint=@

  1put='e more noise blah blah more stuff here'

  let expect = [
        \ "e more noise blah blah<82",
        \ "> more stuff here        "
        \ ]

  call cursor(2, 1)
  norm! zt
  let lines = ScreenLines([1,2], winwidth(0))
  call assert_equal(expect, lines)
  set fdc=2
  let lines = ScreenLines([1,2], winwidth(0))
  let expect = [
        \ "  e more noise blah blah<",
        \ "  82> more stuff here    "
        \ ]
  call assert_equal(expect, lines)

  quit!
  quit!
endfunc

func Test_display_foldtext_mbyte()
  CheckFeature folding

  call NewWindow(10, 40)
  call append(0, range(1,20))
  exe "set foldmethod=manual foldtext=foldtext() fillchars=fold:\u2500,vert:\u2502 fdc=2"
  call cursor(2, 1)
  norm! zf13G
  let lines=ScreenLines([1,3], winwidth(0)+1)
  let expect=[
        \ "  1                                     \u2502",
        \ "+ +-- 12 lines: 2". repeat("\u2500", 23). "\u2502",
        \ "  14                                    \u2502",
        \ ]
  call assert_equal(expect, lines)

  set fillchars=fold:-,vert:\|
  let lines=ScreenLines([1,3], winwidth(0)+1)
  let expect=[
        \ "  1                                     |",
        \ "+ +-- 12 lines: 2". repeat("-", 23). "|",
        \ "  14                                    |",
        \ ]
  call assert_equal(expect, lines)

  set foldtext& fillchars& foldmethod& fdc&
  bw!
endfunc

" check that win_ins_lines() and win_del_lines() work when t_cs is empty.
func Test_scroll_without_region()
  CheckScreendump

  let lines =<< trim END
    call setline(1, range(1, 20))
    set t_cs=
    set laststatus=2
  END
  call writefile(lines, 'Xtestscroll')
  let buf = RunVimInTerminal('-S Xtestscroll', #{rows: 10})

  call VerifyScreenDump(buf, 'Test_scroll_no_region_1', {})

  call term_sendkeys(buf, ":3delete\<cr>")
  call VerifyScreenDump(buf, 'Test_scroll_no_region_2', {})

  call term_sendkeys(buf, ":4put\<cr>")
  call VerifyScreenDump(buf, 'Test_scroll_no_region_3', {})

  " clean up
  call StopVimInTerminal(buf)
  call delete('Xtestscroll')
endfunc
