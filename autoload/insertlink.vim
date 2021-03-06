function! s:GetVisualSelection(only_on_line) " {{{1
    let l:start_line = line("'<")
    let l:start_col = col("'<")
    let l:end_line = line("'>")
    let l:end_col = col("'>")
    if a:only_on_line && (l:start_line != l:end_line)
        echom "FileFromSelected: Start and end must be same line number"
        return
    end
    return getline(".")[l:start_col-1:l:end_col-1]
endfunction

function! s:GetBeforeAndAfterVisualSelection() " {{{1
    let start_line = line("'<")
    let start_col = col("'<")
    let end_line = line("'>")
    let end_col = col("'>")
    let before=getline(start_line)[:start_col-2]
    if start_col == 1
        let before = ""
    end
    let after=getline(start_line)[end_col:]
    return [before, after]
endfunction

function! s:make_markdown_link(text, url) " {{{1
    return "[" . a:text . "](" . a:url . ")"
endfunction " 

function! insertlink#file_from_selection(is_visual) " {{{1
    let text= a:is_visual ? <sid>GetVisualSelection(1) : expand('<cword>')
    let l:start_line = line(".")
    let l:start_col = col(".")
    let nospace = substitute(l:text, " ", "-", "g")
    let lower = tolower(nospace)
    let sanitised = substitute(lower, "[^a-zA-Z0-9\-]", "", "g")
    let linktext="./" . sanitised . ".md"
    let replacetext=s:make_markdown_link(l:text, linktext)
    if a:is_visual
        let around_visual = <sid>GetBeforeAndAfterVisualSelection()
        let l:line=around_visual[0] . replacetext . around_visual[1]
        call setline(l:start_line, l:line)
    else
        execute "normal ciw" . l:replacetext
    end
    call cursor(l:start_line, l:start_col+1)
    return linktext
endfunction " 

function! insertlink#file_from_selection_and_edit(is_visual) " {{{1
    exec "w|edit " . insertlink#file_from_selection(a:is_visual)
endfunction " 

function! s:first_line_from_file(filename)
    if !filereadable(a:filename)
        echom a:filename . " doesn't exist"
    endif
    let title=trim(system('head -n1 ' . a:filename))
    let matches = matchlist(title, '#\+ \(.*\)')
    if len(l:matches) > 1
        let l:title = l:matches[1]
    endif
    return l:title
endfunction

function! insertlink#FirstLineFromFileAsLink(filename) "{{{1
    let filename=resolve(fnamemodify(expand(a:filename), ":."))
    if l:filename[0] != '.'
        let filename = './' . l:filename
    endif
    let title=<sid>first_line_from_file(a:filename)
    let link="[" . title . "](" . l:filename . ")"
    let lfo=&formatoptions
    set fo-=a
    call append(line("."), l:link)
    let &fo=lfo
endfunction

function! insertlink#FirstLineFromFileAsListLinkBelow(filename) "{{{1
    let title=<sid>first_line_from_file(a:filename)
    let filename=resolve(fnamemodify(expand(a:filename), ":."))
    if l:filename[0] != '.'
        let filename = './' . l:filename
    endif
    let link="-   [" . title . "](" . l:filename . ")"
    let lfo=&formatoptions
    set fo-=a
    call append(line("."), l:link)
    let &fo=lfo
endfunction
