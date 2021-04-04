if exists("g:loaded_simple_highlighting")
  finish
endif
let g:loaded_simple_highlighting = 1

" Basic Functions {{{
function NewArray(length, elemVal)
    let retVal = []
    for idx in range(a:length)
        let retVal += [deepcopy(a:elemVal)]
    endfor
    return retVal
endfunction

function Zeros(length)
    return NewArray(a:length, 0)
endfunction

function FlatternStrArr(strArr, seperator) "Flattern String Array into signal string
    if len(a:strArr) == 0
        return ''
    endif
    let ret = a:strArr[0]
    for str in a:strArr[1:]
        let ret .= a:seperator.str
    endfor
    return ret
endfunction

"function to add excape characters in a string to characters which are considered magic
function StringEscMagic(str)
	let str = a:str
	let str = substitute(str, '\\', '\\\\', 'g')
	let str = substitute(str, '\^', '\\^', 'g')
	let str = substitute(str, '\$', '\\$', 'g')
	let str = substitute(str, '\.', '\\.', 'g')
	let str = substitute(str, '\*', '\\*', 'g')
	let str = substitute(str, '\~', '\\~', 'g')
	let str = substitute(str, '\[', '\\[', 'g')
	let str = substitute(str, '\]', '\\]', 'g')
"	let str = substitute(str, '\&', '\\&', 'g')
	return str
endfunction

"function below taken form <http://vim.wikia.com/wiki/Windo_and_restore_current_window>
" Just like windo, but restore the current window when done.
function! WinDo(command)
  let currwin=winnr()
  execute 'windo ' . a:command
  execute currwin . 'wincmd w'
endfunction
com! -nargs=+ -complete=command Windo call WinDo(<q-args>)

"function modified from <https://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript>
function! VisualSelection()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end,   column_end  ] = getpos("'>")[1:2]

    if (line2byte(line_start)+column_start) > (line2byte(line_end)+column_end)
        let [line_start, column_start, line_end, column_end] =
        \   [line_end, column_end, line_start, column_start]
    end
    let lines = getline(line_start, line_end)
    if len(lines) == 0
            return ['']
    endif
	if &selection ==# "exclusive"
	    let column_end -= 1 "I needed to remove the last character to make it match the visual selctiona
	endif
    if visualmode() ==# "\<C-V>"
        for idx in range(len(lines))
            let lines[idx] = lines[idx][: column_end - 1]
            let lines[idx] = lines[idx][column_start - 1:]
        endfor
    else
        let lines[-1] = lines[-1][: column_end - 1]
        let lines[ 0] = lines[ 0][column_start - 1:]
    endif
    return lines  
    "return join(lines, "\n")
endfunction


" }}}

"Highlight words extension {{{
"
" useful web link: http://www.ibm.com/developerworks/linux/library/l-vim-script-1/index.html
" http:/:vs
" /vim.wikia.com/wiki/Highlight_multiple_words

highlight hlg1 ctermbg=DarkGreen   guibg=DarkGreen      ctermfg=white guifg=white
highlight hlg2 ctermbg=DarkCyan    guibg=DarkCyan       ctermfg=white guifg=white
highlight hlg3 ctermbg=Blue        guibg=Blue           ctermfg=white guifg=white
highlight hlg4 ctermbg=DarkMagenta guibg=DarkMagenta    ctermfg=white guifg=white
highlight hlg5 ctermbg=DarkRed     guibg=DarkRed        ctermfg=white guifg=white
highlight hlg6 ctermbg=DarkYellow  guibg=DarkYellow     ctermfg=white guifg=white
highlight hlg7 ctermbg=Brown       guibg=Brown          ctermfg=white guifg=white
highlight hlg8 ctermbg=DarkGrey    guibg=DarkGrey       ctermfg=white guifg=white
highlight hlg9 ctermbg=Black       guibg=Black          ctermfg=white guifg=white
let s:TOTAL_HL_NUMBERS = 10

let g:hlPat   = NewArray(s:TOTAL_HL_NUMBERS,[])  "stores the patters
let s:REGEX_OR = '\|'

"press [<number>] <Leader> h -> to highligt the whole word under the cursor
"   highligted colour is determed by the number the number defined above
nnoremap <Plug>HighlightWordUnderCursor :<C-U> exe "call HighlightAdd(".v:count.",'\\<".expand('<cword>')."\\>')"<CR>
vnoremap <Plug>HighlightWordUnderCursor :<C-U> exe "call HighlightAddVisual(".v:count.")"<CR>
if !hasmapto('<Plug>HighlightWordUnderCursor', 'n') && (mapcheck("<Leader>h", "n") == "")
  nmap <silent> <Leader>h <Plug>HighlightWordUnderCursor
  vmap <silent> <Leader>h <Plug>HighlightWordUnderCursor
endif

"NOTE: above funtion can match on an empty pattern '\<\>' however this doesn't
"   seem to have any magor negetive effects so is not fixed

"Hc [0,2...] -> clears the highlighted patters listed or all if no arguments
"   are passed
command -nargs=* Hc call HighlightClear(<f-args>)

command -nargs=* Hs call HighlightSearch(<f-args>) | set hlsearch

command -nargs=+ Ha call HighlightAddMultiple(<f-args>)

command -nargs=+ Hw call HighlightWriteCommands(<f-args>)

command -nargs=1 Hd call HighlightSetDefaultSlot(<f-args>)

let g:hlDefaultNum = 1

function HighlightSetDefaultSlot(hlNum)
  let g:hlDefaultNum = a:hlNum
endfunction

function HighlightWriteCommands(...)
    let cmds = []
    if a:0 == 1
        for idx in range(s:TOTAL_HL_NUMBERS)
            let cmds+=HighlightPatternCommands(eval(idx))
        endfor
    else
        for idx in range(3, a:0)
            let cmds+=HighlightPatternCommands(eval('a:'.idx))
        endfor
    endif
    call writefile(cmds, a:1)
endfunction

function HighlightPatternCommands(hlNum)
    let cmds = []
    if s:HighlightCheckNum(a:hlNum) && w:hlIdArr[a:hlNum] > 0
        let str = 'Ha '.a:hlNum
        let idx = 0
        for pat in g:hlPat[a:hlNum]
            if idx == 10
                let cmds += [str]
                let str = 'Ha '.a:hlNum
                let idx = 0
            endif
            let idx = idx+1
            let str = str.' '.substitute(pat, ' ', "\\\\ ", 'g')
        endfor
        let cmds += [str]
    endif
    return cmds
endfunction

function HighlightAddVisual(hlNum)
    let patternLines = VisualSelection()
    for pattern in patternLines
        call HighlightAddEscMagic(a:hlNum, pattern)
    endfor
endfunction

function HighlightAddEscMagic(hlNum, pattern)
	let pattern = StringEscMagic(a:pattern)
	call HighlightAdd(a:hlNum, pattern)
endfunction

function HighlightAdd(hlNum, pattern)
    if a:hlNum == 0
      let hlNum = g:hlDefaultNum
    else
      let hlNum = a:hlNum
    endif
    if (s:HighlightCheckNum(hlNum) != 0) &&( a:pattern != '') && (a:pattern != '\<\>')
        let prevSlotAndIdx = HighlightPatternInSlot(a:pattern)
        let prevHlNum = prevSlotAndIdx[0]
        let prevIdx   = prevSlotAndIdx[1]
        if prevHlNum != -1
            call HighlightRemovePatternAt(prevHlNum,prevIdx)
            if prevHlNum == hlNum " was already at slot so do not add it back in
                return 
            endif
        endif
        let g:hlPat[hlNum] += [a:pattern]
        call WinDo('call s:HighlightUpdatePriv('.hlNum.')')
    endif
endfunction


if !exists("g:highlightPriority")
    let g:highlightPriority = 0  " 0 => override coc's CocActionAsync('highlight') 
                                      " but not normal serach highlight 
endif

function s:HighlightUpdatePriv(hlNum) "if patern is black will set w:hlIdArr[a:hlNum] to  -1
    if w:hlIdArr[a:hlNum] > 0
        call matchdelete(w:hlIdArr[a:hlNum])
    end
    let w:hlIdArr[a:hlNum] = matchadd('hlg'.a:hlNum, HighlightPattern(a:hlNum), g:highlightPriority)
endfunction

function HighlightWinEnter()
    if !exists("w:displayed")
        let w:displayed  = 1
        let w:hlIdArr = Zeros(s:TOTAL_HL_NUMBERS)
        for idx in range(s:TOTAL_HL_NUMBERS)
            if len(g:hlPat[idx]) > 0
                call s:HighlightUpdatePriv(idx)
            endif
        endfor
    endif
endfunction

if !exists("s:au_highlight_loaded") "guard
    let s:au_highlight_loaded = 1 "only run commands below once
    autocmd WinEnter    * call HighlightWinEnter()
    autocmd BufEnter    * call HighlightWinEnter()
    call  HighlightWinEnter()
endif

function HighlightAddMultiple(...)
    if a:0 < 2
        echoerr 'HighlightAddMultiple usage <slot number> [pattern ...]'
    else
        for idx in range(2, a:0)
            call HighlightAdd(a:1, eval('a:'.idx))
        endfor
    endif
endfunction

function HighlightClear(...)
    if a:0 == 0
        for idx in range(s:TOTAL_HL_NUMBERS) "range stops BEFORE
            call s:HighlightClearPriv(eval(idx))
        endfor
    else
        for idx in range(1, a:0) "range stops AFTER
            call s:HighlightClearPriv(eval('a:'.idx))
        endfor
    endif
endfunction

function s:HighlightClearPriv(hlNum)
    if s:HighlightCheckNum(a:hlNum) && w:hlIdArr[a:hlNum] > 0
        call WinDo('call s:HighlightClearBuffPriv('.a:hlNum.')')
        let g:hlPat[a:hlNum]   = []
    endif
endfunction

function s:HighlightClearBuffPriv(hlNum)
    call matchdelete(w:hlIdArr[a:hlNum])
    let w:hlIdArr[a:hlNum] = 0
endfunction

function s:HighlightCheckNum(hlNum)
    if a:hlNum >= s:TOTAL_HL_NUMBERS
        echoerr 'ERROR: Highlight number must be from 0 to 's:TOTAL_HL_NUMBERS-1'inclsive. Not'a:hlNum
        return 0
    endif
    return 1
endfunction

function HighlightSearch(...)
    let searchStr = call('HighlightPattern', a:000)
    call UserSerach(searchStr)
endfunction

function HighlightPatternInSlot(pattern)
    for hlNum in range(s:TOTAL_HL_NUMBERS)
        for patIdx in range(len(g:hlPat[hlNum]))
            if a:pattern == g:hlPat[hlNum][patIdx]
                return [hlNum, patIdx]
            endif
        endfor
    endfor
    return [-1, -1]
endfunction

function HighlightRemovePatternAt(hlNum, patIdx)
    call remove(g:hlPat[a:hlNum], a:patIdx)
    call WinDo('call s:HighlightUpdatePriv('.a:hlNum.')')
endfunction

function HighlightPattern(...)
    let idxs = []
    if a:0 == 0
        let idxs = range(s:TOTAL_HL_NUMBERS)
    else
        for aIdx in range(1, a:0) "range stops AFTER
            call add(idxs,eval('a:'.aIdx))
        endfor
    endif
    let pattern = ''
    for idx in idxs
        if len(g:hlPat[idx]) > 0
            let idxPattern = FlatternStrArr(g:hlPat[idx], s:REGEX_OR)
            if len(pattern) > 0 
                let pattern .= s:REGEX_OR
            endif
            let pattern .= idxPattern
        endif
    endfor
    return pattern
endfunction

function UserSerach(searchStr)
    let @/ = a:searchStr
endfunction

"}}}


