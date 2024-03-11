filetype off

" Color (light bg)
set background=light

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
set clipboard=unnamed

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
au FileType vhdl set expandtab smarttab autoindent smartindent shiftwidth=4 tabstop=4 softtabstop=4

" Moving .swp files away
set backupdir=~/.vim
set directory=~/.vim
