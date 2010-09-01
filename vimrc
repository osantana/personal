" Color (light bg)
set background=light
colorscheme delek

" Color (dark bg)
" set background=dark
" colorscheme elflord

" General settings
set laststatus=2
set nocompatible
set nojoinspaces
set ruler
set hidden
set incsearch
set autowrite
set showcmd
set showmatch
set nohlsearch
set noignorecase
set nojoinspaces
set nobackup
set textwidth=0 nowrap
set completeopt=menu,preview

" Tab/Indent config
" 4 soft-space tabs for all kind of documents
set expandtab
set smarttab
set autoindent
set smartindent
set shiftwidth=4 tabstop=4 softtabstop=4

" No beeps
set visualbell

" Doh... you know what this does... ;-)
syntax on

" Some useful abbreviations to common mistyped commands
cab W w | cab Q q | cab Wq wq | cab wQ wq | cab WQ wq

" Comment/Uncomment for different languages
au FileType haskell,vhdl,ada            let comment = '-- '
au FileType sh,make,python              let comment = '# '
au FileType c,cpp,java,javascript       let comment = '// '
au FileType tex                         let comment = '% '
au FileType vim                         let comment = '" '

" Comment Blocks
" ,c -> comment selected
" ,u -> uncomment selected
noremap <silent> ,c :s,^,<C-R>=comment<CR>,<CR>:noh<CR>
noremap <silent> ,u :s,^\V<C-R>=comment<CR>,,e<CR>:noh<CR>

" Highlight trailing whitespaces
highlight WhitespaceEOL ctermbg=red guibg=red
match WhitespaceEOL /\s\+$/

" ,a -> clean all trailing spaces
noremap <silent> ,a :%s,\s\+$,,<CR>

" Python
let python_highlight_all = 1
au BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class,with

" Highlight TODO's with red color
highlight Todo       ctermfg=White   ctermbg=Red cterm=Bold
highlight Todo       guifg=#ffffff guibg=#96a6c8 cterm=Bold

" Terminal.app keyboard settings
map <Esc>[H <Home>
imap <Esc>[H <Home>
map <Esc>[F <End>
imap <Esc>[F <End>
map <Esc>[5~ <PageUp>
imap <Esc>[5~ <PageUp>
map <Esc>[6~ <PageDown>
imap <Esc>[6~ <PageDown>
