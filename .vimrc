"   __  __ _ _____ _________
"   \ \ | |_|     V  __/  __|
"    \ \| | | | | | |  | [__
" [_] \___|_|_|_|_|_|  \____|


" Execute the following command to bring the full power:
"
" 	:call VimrcSetUp()


" Encoding {{{
set encoding=utf-8
scriptencoding utf-8
" }}}


" Environment {{{
function! VimrcEnvironment()
	let env = {}
	let env.is_win = has('win32') || has('win64')

	let user_dir = env.is_win
				\ ? expand('$VIM/vimfiles')
				\ : expand('~/.vim')
	let env.path = {
				\ 	'user':          user_dir,
				\ 	'bundle':        user_dir . '/bundle',
				\ 	'bundle_preset': user_dir . '/bundle-preset.vim',
				\ 	'data':          user_dir . '/data',
				\ 	'local_vimrc':   user_dir . '/.vimrc_local',
				\ 	'neobundle':     user_dir . '/neobundle.vim',
				\ 	'tmp':           user_dir . '/tmp',
				\ 	'undo':          user_dir . '/data/undo',
				\ }

	return env
endfunction

function! VimrcSupports()
	let supports = {}

	let supports.neocomplete = has('lua')
				\ && (v:version > 703 || (v:version == 703 && has('patch885')))

	return supports
endfunction

let s:env = VimrcEnvironment()
let s:supports = VimrcSupports()
" }}}


" Required Plugins {{{
let s:plugins = [
			\ 	'AndrewRadev/linediff.vim',
			\ 	'Shougo/neomru.vim',
			\ 	'Shougo/unite-outline',
			\ 	'Shougo/unite.vim',
			\ 	'Shougo/vimfiler',
			\ 	'Shougo/vimproc',
			\ 	'Shougo/vimshell',
			\ 	'Shougo/vinarise',
			\ 	'cocopon/colorswatch.vim',
			\ 	'cocopon/iceberg.vim',
			\ 	'cocopon/shadeline.vim',
			\ 	'cocopon/svss.vim',
			\ 	'groenewege/vim-less',
			\ 	'hynek/vim-python-pep8-indent',
			\ 	'itchyny/thumbnail.vim',
			\ 	'kana/vim-textobj-indent',
			\ 	'kana/vim-textobj-user',
			\ 	'kannokanno/previm',
			\ 	'kchmck/vim-coffee-script',
			\ 	'leafgarland/typescript-vim',
			\ 	'mattn/emmet-vim',
			\ 	'mxw/vim-jsx',
			\ 	'nanotech/jellybeans.vim',
			\ 	'osyo-manga/unite-quickfix',
			\ 	'pangloss/vim-javascript',
			\ 	'rking/ag.vim',
			\ 	'scrooloose/syntastic',
			\ 	'sophacles/vim-processing',
			\ 	'stephpy/vim-yaml',
			\ 	'thinca/vim-qfreplace',
			\ 	'thinca/vim-quickrun',
			\ 	'thinca/vim-ref',
			\ 	'tikhomirov/vim-glsl',
			\ 	'tomtom/tcomment_vim',
			\ 	'toyamarinyon/vim-swift',
			\ 	'tpope/vim-fugitive',
			\ 	'tpope/vim-markdown',
			\ 	'tpope/vim-surround',
			\ 	'tyru/open-browser.vim',
			\ 	'ujihisa/camelcasemotion',
			\ 	'ujihisa/unite-colorscheme',
			\ 	'vim-jp/vital.vim',
			\ 	'vim-scripts/matchit.zip',
			\ 	'w0ng/vim-hybrid',
			\ 	s:supports.neocomplete
			\ 		? 'Shougo/neocomplete.vim'
			\ 		: 'Shougo/neocomplcache.vim',
			\ ]
let s:colorscheme = 'iceberg'
" }}}


" Setup {{{
function! VimrcSetUp()
	call s:install_plugin_manager()
endfunction
" }}}


" Installing {{{
function! s:mkdir_if_needed(dir)
	if isdirectory(a:dir)
		return 0
	endif

	call mkdir(a:dir, 'p')
	return 1
endfunction

function! s:install_plugins()
	call s:mkdir_if_needed(s:env.path.bundle)

	if exists(':Unite')
		Unite neobundle/install:!
		return 1
	endif

	if exists(':NeoBundleUpdate')
		NeoBundleUpdate
		return 1
	endif

	return 0
endfunction

function! s:clone_repository(url, local_path)
	if isdirectory(a:local_path)
		return
	endif

	execute printf('!git clone %s %s', a:url, a:local_path)
endfunction

function! s:install_plugin_manager()
	call s:mkdir_if_needed(s:env.path.user)
	call s:mkdir_if_needed(s:env.path.data)

	call s:clone_repository(
				\ 'https://github.com/Shougo/neobundle.vim',
				\ s:env.path.neobundle)
	call s:clone_repository(
				\ 'https://github.com/cocopon/bundle-preset.vim',
				\ s:env.path.bundle_preset)

	if !s:activate_plugin_manager()
		return 0
	endif

	if !s:install_plugins()
		return 0
	endif

	echo 'Restart vim to finish the installation.'
	return 1
endfunction
" }}}


" Activating {{{
function! s:load_plugin(path)
	try
		execute 'set runtimepath+=' . a:path

		return 1
	catch /:E117:/
		" E117: Unknown function
		return 0
	endtry
endfunction

function! s:activate_plugins()
	if !exists(':NeoBundle')
		" Plugin manager not installed yet
		return 0
	endif

	let command = exists(':PresetBundle')
				\ ? 'PresetBundle'
				\ : 'NeoBundle'

	for plugin in s:plugins
		execute printf("%s 'https://github.com/%s'", command, plugin)
	endfor

	return 1
endfunction

function! s:activate_plugin_manager_internal()
	" Activate NeoBundle
	if !exists(':NeoBundle')
		execute 'set runtimepath+=' . s:env.path.neobundle
	endif
	call neobundle#begin(s:env.path.bundle)

	try
		" Activate PresetBundle
		if !exists(':PresetBundle')
			execute 'set runtimepath+=' . s:env.path.bundle_preset
		endif
		call bundle_preset#rc()

		" Activate plugins
		return s:activate_plugins()
	finally
		call neobundle#end()
		filetype indent on
		filetype plugin on
	endtry
endfunction

function! s:activate_plugin_manager()
	try
		return s:activate_plugin_manager_internal()
	catch /:E117:/
		" E117: Unknown function
		" Plugin manager not installed yet
		return 0
	endtry
endfunction
" }}}


" Initializing {{{
call s:mkdir_if_needed(s:env.path.tmp)
call s:mkdir_if_needed(s:env.path.undo)
let s:bundle_activated = s:activate_plugin_manager()
" }}}


" Mapping {{{
" Turn off the IME when escaping from Insert mode
inoremap <silent> <ESC> <ESC>:<C-u>set iminsert=0<CR>

" Intuitive cursor movement in wrapped line
noremap j gj
noremap k gk

" Switch active window
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Emacs-like keybind
cnoremap <C-a> <Home>
cnoremap <C-b> <Left>
cnoremap <C-d> <Del>
cnoremap <C-e> <End>
cnoremap <C-f> <Right>
cnoremap <C-h> <Backspace>
cnoremap <C-k> <C-\>e getcmdpos() == 1 ? '' : getcmdline()[:getcmdpos() - 2]<CR>
inoremap <C-a> <Home>
inoremap <C-b> <Left>
inoremap <C-d> <Del>
inoremap <C-e> <End>
inoremap <C-f> <Right>
inoremap <C-h> <Backspace>
inoremap <C-k> <C-o>D
inoremap <C-n> <Down>
inoremap <C-p> <Up>

" Refer to history in Command-line mode
cnoremap <C-p> <Up>
cnoremap <Up> <C-p>
cnoremap <C-n> <Down>
cnoremap <Down> <C-n>

" Open the parent directory, or the current directory if not saved yet
nnoremap <silent> <C-u> :execute 'e ' . ((strlen(bufname('')) == 0) ? '.' : '%:h')<CR>

" Insert escaped '/' while inputting a search pattern
cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'

" For JIS keyboard
inoremap <C-@> <Nop>

" For US keyboard
noremap ; :

" Misc
nnoremap Y y$
nnoremap K <Nop>
" }}}


" File Types {{{
augroup vimrc_filetype
	autocmd!
	autocmd BufNewFile,BufRead *.as      setlocal filetype=javascript
	autocmd BufNewFile,BufRead *.gradle  setlocal filetype=groovy
	autocmd BufNewFile,BufRead *.pde     setlocal filetype=processing
	autocmd BufNewFile,BufRead *.podspec setlocal filetype=ruby
	autocmd BufNewFile,BufRead Podfile   setlocal filetype=ruby
	autocmd FileType apache     setlocal shiftwidth=2 tabstop=2
	autocmd FileType coffee     setlocal shiftwidth=2 tabstop=2 expandtab
	autocmd FileType css        setlocal shiftwidth=4 tabstop=4
	autocmd FileType eruby      setlocal shiftwidth=2 tabstop=2
	autocmd FileType gitcommit  setlocal nocursorline spell
	autocmd FileType html       setlocal shiftwidth=2 tabstop=2 indentexpr&
	autocmd FileType javascript setlocal shiftwidth=2 tabstop=2
	autocmd FileType php        setlocal shiftwidth=4 tabstop=4
	autocmd FileType python     setlocal shiftwidth=4 tabstop=4 expandtab
	autocmd FileType rst        setlocal indentexpr&
	autocmd FileType ruby       setlocal shiftwidth=2 tabstop=2 expandtab
	autocmd FileType scss       setlocal shiftwidth=4 tabstop=4
	autocmd FileType text       setlocal textwidth=0
	autocmd FileType vim        setlocal shiftwidth=2 tabstop=2 fdm=marker
	autocmd FileType xhtml      setlocal shiftwidth=2 tabstop=2 indentexpr&
	autocmd FileType xml        setlocal shiftwidth=2 tabstop=2
	autocmd FileType yaml       setlocal shiftwidth=2 tabstop=2
augroup END
" }}}


" Misc {{{
set completeopt=menu,menuone
set cursorline
set display=lastline
set grepprg=grep\ -nH
set laststatus=2
set nrformats-=octal
set number
set numberwidth=5
set shortmess=aTI
set virtualedit=block

" Backup
set nobackup
set noswapfile
execute 'set undodir=' . s:env.path.undo
set undofile

" IME
set iminsert=0
set imsearch=-1
set noimcmdline
set noimdisable

" Indent
set autoindent
set list
set listchars=eol:¬,tab:▸\ 
set noexpandtab
set nosmartindent
set shiftround
set shiftwidth=4
set tabstop=4

" Scroll
set scrolloff=8
set sidescroll=1
set sidescrolloff=16

" Search
set hlsearch
set ignorecase
set incsearch
set smartcase
" }}}


" Plugins {{{
" netrw {{{
let g:netrw_altv = 1
let g:netrw_preview = 1
" }}}

if s:bundle_activated
	" camelcasemotion {{{
	map <silent> b <Plug>CamelCaseMotion_b
	map <silent> e <Plug>CamelCaseMotion_e
	map <silent> w <Plug>CamelCaseMotion_w
	" }}}

	" neocomplcache/neocomplete {{{
	if s:supports.neocomplete
		let g:neocomplete#enable_at_startup = 1
		let g:neocomplete#data_directory = s:env.path.data . '/neocomplete'

		let g:neocomplete#force_omni_input_patterns = {
					\ 	'python': '\h\w*\|[^. \t]\.\w*',
					\ }
	else
		let g:neocomplcache_enable_at_startup = 1
		let g:neocomplcache_temporary_dir = s:env.path.data . '/neocomplcache'

		let g:neocomplcache_force_omni_patterns = {
					\ 	'python': '\h\w*\|[^. \t]\.\w*',
					\ }
	endif
	" }}}

	" neomru {{{
	let g:neomru#file_mru_path = s:env.path.data . '/neomru/file'
	let g:neomru#directory_mru_path = s:env.path.data . '/neomru/directory'
	" }}}

	" open-browser {{{
	nmap gW <Plug>(openbrowser-open)
	" }}}

	" quickrun {{{
	let g:quickrun_config = {}
	let g:quickrun_config['_'] = {
				\ 	'runner': 'vimproc',
				\ 	'runner/vimproc/updatetime': 40,
				\ }
	let g:quickrun_config['rst'] = {
				\ 	'command': 'rst2html.py',
				\ 	'outputter': 'browser',
				\ 	'runner': 'system',
				\ }
	let g:quickrun_config['processing'] = {
				\ 	'command': 'processing-java',
				\ 	'exec': '%c --sketch=%s:p:h/ --output=' . s:env.path.tmp . '/processing --force --run',
				\ }
	" }}}

	" ref {{{
	let g:ref_cache_dir = s:env.path.data . '/ref'
	" }}}

	" shadeline {{{
	let g:shadeline = {}
	let g:shadeline.active = {
				\ 	'left': [
				\ 		'fname',
				\ 		'flags',
				\ 		'ShadelineItemGitBranch',
				\ 	],
				\ 	'right': [
				\ 		'<',
				\ 		['ff', 'fenc', 'ft'],
				\ 		'ruler',
				\ 	],
				\ }
	let g:shadeline.inactive = {
				\ 	'left': [
				\ 		'fname',
				\ 		'flags',
				\ 	],
				\ }

	function! ShadelineItemGitBranch()
		let name = exists('*fugitive#head')
					\ ? fugitive#head()
					\ : ''
		return empty(name) ? '' : printf('(%s)', name)
	endfunction
	" }}}

	" svss {{{
	let g:svss_auto_source = 1
	" }}}

	" syntastic {{{
	let g:syntastic_mode_map = {
				\ 	'mode': 'passive',
				\ 	'active_filetypes': [
				\ 		'coffee',
				\ 		'javascript',
				\ 		'python',
				\ 		'typescript',
				\ 		'vim',
				\ 	],
				\ 	'passive_filetypes': [],
				\ }
	let g:syntastic_auto_loc_list = 0

	" javascript
	let g:syntastic_javascript_checkers = ['eslint']

	" python
	" E501 ... line too long
	let g:syntastic_python_checkers = ['flake8']
	let g:syntastic_python_flake8_args = join([
				\ 	'--ignore=E501',
				\ ])

	" TypeScript
	let g:syntastic_typescript_checkers = ['tslint']
	" }}}

	" unite {{{
	let g:unite_data_directory = s:env.path.data . '/unite'
	nnoremap ,ub :Unite buffer<CR>
	nnoremap ,ul :Unite line<CR>
	nnoremap ,um :Unite neomru/file<CR>
	nnoremap ,uo :Unite outline<CR>
	nnoremap <C-g> :Unite neomru/file<CR>

	call unite#custom#profile('default', 'context', {
				\ 	'direction': 'botright',
				\ 	'enable_start_insert': 0,
				\ 	'prompt_direction': 'top',
				\ })

	function! s:change_unite_mapping()
		try
			unmap <buffer> <C-k>
		catch /:E31:/
			" E31: No such mapping
		endtry
	endfunction

	augroup vimrc_unite
		autocmd!
		autocmd FileType unite call s:change_unite_mapping()
	augroup END
	" }}}

	" vimfiler {{{
	let g:vimfiler_as_default_explorer = 1
	let g:vimfiler_enable_auto_cd = 1
	let g:vimfiler_safe_mode_by_default = 0
	let g:vimfiler_data_directory = s:env.path.data . '/vimfiler'

	function! s:change_vimfiler_mapping()
		unmap <buffer> <C-j>
		unmap <buffer> <C-l>
		map <buffer> D <Plug>(vimfiler_switch_to_drive)
		map <buffer> L <Plug>(vimfiler_redraw_screen)
	endfunction

	augroup vimrc_vimfiler
		autocmd!
		autocmd FileType vimfiler call s:change_vimfiler_mapping()
	augroup END
	" }}}

	" vimshell {{{
	let g:vimshell_temporary_directory = s:env.path.data . '/vimshell'

	function! s:change_vimshell_mapping()
		unmap <buffer> <C-l>
		map <buffer> L <Plug>(vimshell_clear)

		if !s:supports.neocomplete
			imap <buffer> <C-p> <Plug>(vimshell_history_unite)
			imap <buffer> <C-n> <Plug>(vimshell_history_unite)
		endif
	endfunction

	augroup vimrc_vimshell
		autocmd!
		autocmd FileType vimshell call s:change_vimshell_mapping()
	augroup END
	" }}}
endif

" Disable unused plugins
let g:loaded_gzip = 1
let g:loaded_tar = 1
let g:loaded_tarPlugin = 1
let g:loaded_zip = 1
let g:loaded_zipPlugin = 1

" Disable unused kaoriya plugins
let g:plugin_dicwin_disable = 1
" }}}


" Local Settings {{{
if filereadable(s:env.path.local_vimrc)
	execute 'source ' . s:env.path.local_vimrc
endif
" }}}


" Color Scheme {{{
if s:bundle_activated
	if !has('gui_running')
		syntax enable
		execute printf('colorscheme %s', s:colorscheme)
	else
		augroup vimrc_colorscheme
			autocmd!
			execute printf('autocmd GUIEnter * colorscheme %s', s:colorscheme)
		augroup END
	endif
endif
" }}}
