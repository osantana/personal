" Reference:
"  http://sontek.net/turning-vim-into-a-modern-python-ide

filetype off

" Override some plugin settings
map <leader>v <Plug>TaskList
map <leader>g <Plug>MakeGreen
map <leader>U :GundoToggle<CR>
map <leader>dt :set makeprg=nosetests\|:call MakeGreen()<CR>

let g:pyflakes_use_quickfix = 0
let g:pep8_map='<leader>8'

set statusline=%<%f\ %h%m%r%y%=%-15.{fugitive#statusline()}\ %-14.(%l,%c%V%)\ %P

" Load and configure pathogen
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" Color (light bg)
set background=light
colorscheme delek

" General settings
set modeline 				" use vim settings in beginning/end of files
set modelines=5 			" number of lines to look for modeline
set laststatus=2
set nocompatible                        " disable compatible mode
set ruler                               " show line,col in status bar
set hidden                              " hide buffers with closed files
set incsearch                           " use incremental search
set autowrite                           " auto save file before some commands
set showcmd                             " show command/mode in at bottom
set showmatch                           " show match (), [] and {}
set nohlsearch                          " no highlight search results
set noignorecase                        " case sensitive search
set nojoinspaces                        " don't add space when joining line
set nobackup                            " no backups
set textwidth=0 nowrap                  " infinite lines with no wrap
set completeopt=menu,preview            " configure drop-down menu when completing with ctrl-n
set wildmode=list:longest               " bash like command line tab completion
set wildignore=*.o,*.obj,*~,*.swp,*.pyc " ignore when tab completing:
set writeany                            " Allow writing readonly files
set visualbell 				" Set visual bell
set foldmethod=indent 			" Folding method: indent
set foldlevel=99 			" Initial Fold Level

let mapleader="," 			" <Leader> == ,

" CTRL+[hjkl] navigation between buffers
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h

" Doh... you know what this does... ;-)
syntax on

" Restore filetype system
filetype on
filetype plugin indent on               " indent files, ftplugins

" Some useful abbreviations to common mistyped commands
cab W w | cab Q q | cab Wq wq | cab wQ wq | cab WQ wq | cab X x


" Comment/Uncomment for different languages
au FileType haskell,vhdl,ada            let comment = '-- '
au FileType sh,make,python,ruby         let comment = '# '
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
au ColorScheme * highlight WhitespaceEOL ctermbg=red guibg=red
match WhitespaceEOL /\s\+$/

" ,a -> clean all trailing spaces
noremap <silent> ,a :%s,\s\+$,,<CR>

" Language specifics
let python_highlight_all = 1

au FileType python set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class,with
au FileType python set omnifunc=pythoncomplete#Complete
au FileType python set expandtab smarttab autoindent smartindent shiftwidth=4 tabstop=4 softtabstop=4

" Terminal.app keyboard settings
map <Esc>[H <Home>
imap <Esc>[H <Home>
map <Esc>[F <End>
imap <Esc>[F <End>
map <Esc>[5~ <PageUp>
imap <Esc>[5~ <PageUp>
map <Esc>[6~ <PageDown>
imap <Esc>[6~ <PageDown>

" Moving .swp files away
set backupdir=~/.vim
set directory=~/.vim

" MacVim
if has("gui_macvim")
    let macvim_hig_shift_movement = 1
    set guioptions-=T
    colorscheme macvim
    set bg=light
    set guifont=Consolas:h18
    set guicursor=a:blinkoff0-blinkwait0
endif
