"BASIC SETUP:
" Use solarized colorscheme
colorscheme evening
set t_Co=256 " использовать больше цветов в терминале
set number
set nowrap
set autochdir
set autoindent
"Размер табуляции по умолчанию
set shiftwidth=4
set softtabstop=4
set tabstop=4
set smarttab
set expandtab "преобразование таба в пробелы
set textwidth=110
"Включаем "умные" отступы ( например, автоотступ после {)
set smartindent
"При вставке фрагмента сохраняет отступы
set pastetoggle=on
syn on " включить подсветку синтаксиса
set showmatch " показывать первую парную скобку после ввода второй
set matchpairs+=<:> " показывать совпадающие скобки для HTML-тегов
set autoread " перечитывать изменённые файлы автоматически
set backspace=indent,eol,start " backspace обрабатывает отступы, концы строк
" Do not add eol at the end of file.
set noeol
set whichwrap=b,<,>,[,],l,h " перемещать курсор на следующую строку при 
"нажатии на клавиши вправо-влево и пр.
"автодополнение фигурной скобки (так, как я люблю :)
imap {<CR> {<CR>}<Esc>O<Tab>
set pastetoggle=<F2>
set termencoding=utf-8
set fileencodings=utf8
if &modifiable
    set fileformat=unix
endif
set encoding=utf8
" Autocmpletion hotkey
set wildcharm=<TAB>
" Не использовать короткие теги PHP для поиска PHP блоков
let php_noShortTags = 1
" Подстветка SQL внутри PHP строк
let php_sql_query=1
" Подстветка HTML внутри PHP строк
let php_htmlInStrings=1
" Подстветка базовых функций PHP
let php_baselib = 1
"" Применять типы файлов
filetype on
filetype indent on
set showmatch " проверка скобок
"-----------------СПЕЦИАЛЬНЫЙ РАЗДЕЛ-------------
" F12 - обозреватель файлов
map <F12> :Ex<cr>
vmap <F12> <esc>:Ex<cr>i
imap <F12> <esc>:Ex<cr>i
"---------------Cyrillic symbol compatible:-------
set keymap=russian-jcukenwin
set iminsert=0
set imsearch=0
highlight lCursor guifg=NONE guibg=Cyan
"------------------------------------------------

set nocompatible

"enable syntax and plugins:
syntax enable
filetype plugin on
filetype plugin indent on

"fuzzy serach in subdir :
set path+=**
"display all mathing files when we tab complete
set wildmenu

"TAG JUMPING
command! MakeTags !ctags -R .

" FILE BROWSING:
""tweaks:
let g:netrw_banner=0       "idable annoing banner
"let g:netrw_browse_split=4 "open in prior window
"let g:netrw_altv=1         "open splits to the right
"let g:netrw_liststyle=3    "tree view
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'

"HTML snippets:
nnoremap ,html :-1read $HOME/.vim/skeleton.html<CR>11jwf>a
"-------------------
