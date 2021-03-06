(require 'cl)

; Startup
(setq inhibit-startup-screen t)
(setq initial-scratch-message "")
(when (display-graphic-p)
  (menu-bar-mode -1)
  (tool-bar-mode -1))


; Language
(set-language-environment "Japanese")
(set-locale-environment nil)

; Encoding
(prefer-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)

; Key
(define-key isearch-mode-map (kbd "C-h") 'isearch-delete-char)
(global-set-key (kbd "C-h") 'delete-backward-char)
(global-set-key (kbd "C-m") 'newline-and-indent)
(global-set-key (kbd "C-t") 'other-window)
(global-set-key (kbd "C-S-t")
                (lambda ()
                  (interactive)
                  (other-window -1)))
(global-set-key (kbd "C-x 2")
                (lambda ()
                  (interactive)
                  (split-window-vertically)
                  (other-window 1)))
(global-set-key (kbd "C-x 3")
                (lambda ()
                  (interactive)
                  (split-window-horizontally)
                  (other-window 1)))

; Backup
(setq auto-save-default nil)
(setq delete-auto-save-files t)
(setq make-backup-files nil)

; Parenthesis
(show-paren-mode t)
(setq show-paren-style 'parenthesis)

; cua-mode
(cua-mode t)
(setq cua-enable-cua-keys nil)

; iswitchb-mode
(iswitchb-mode t)

; Hooks
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil)))

; Misc
(column-number-mode t)
(fset 'yes-or-no-p 'y-or-n-p)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(setq confirm-kill-emacs 'y-or-n-p)
(setq scroll-margin 0
      scroll-step 1)
(setq kill-whole-line t)
(setq vc-follow-symlinks t)
(setq-default cursor-type 'bar)
(setq-default truncate-lines t)

; System Specific Settings
(when (eq window-system 'ns)
  (global-set-key [ns-drag-file] 'ns-find-file)
  (setq ns-pop-up-frames nil))

; package
(when (require 'package nil 'noerror)
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
  (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
  (package-initialize)
  (add-to-list 'load-path "~/.emacs.d/site-lisp"))

(defvar my-packages
  '(
    all
    auto-complete
    color-theme-solarized
    csv-mode
    fill-column-indicator
    markdown-mode
    org
    popwin
    undo-tree
    zlc))

(defun my-install-packages ()
  (interactive)
  (let ((packages (loop for package in my-packages
                        when (not (package-installed-p package))
                        collect package)))
    (when packages
      (package-refresh-contents)
      (dolist (package packages)
        (package-install package)))))

; auto-complete
(when (require 'auto-complete nil 'noerror)
  (global-auto-complete-mode t)
  (require 'auto-complete-config)
  (ac-config-default)
  (define-key ac-menu-map (kbd "C-n") 'ac-next)
  (define-key ac-menu-map (kbd "C-p") 'ac-previous)
  (setcdr (assq 'auto-complete-mode minor-mode-alist) '(""))
  (setq ac-use-menu-map t))

; fill-column-indicator
(when (require 'fill-column-indicator nil 'noerror)
  (setq-default fci-rule-column 80))


; linum
(when (require 'linum nil 'noerror)
  (global-linum-mode t)
  (setq linum-format "%4d"))

; org
(when (require 'org nil 'noerror)
  (add-to-list 'auto-mode-alist '("\\.org$" . org-mode)))

; popwin
(when (require 'popwin nil 'noerror)
  (setq display-buffer-function 'popwin:display-buffer)
  (setq popwin:popup-window-position 'bottom)
  (push '("*All*") popwin:special-display-config))

; undo-tree
(when (require 'undo-tree nil 'noerror)
  (global-undo-tree-mode t)
  (global-set-key (kbd "M-/") 'undo-tree-redo)
  (global-set-key (kbd "M-_") 'undo-tree-redo)
  (setq undo-tree-mode-lighter ""))

; whitespace
(when (require 'whitespace nil 'noerror)
  (global-whitespace-mode t)
  (setq whitespace-display-mappings
        '((tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t])))
  (setq whitespace-style
        '(tabs tab-mark)))

; zlc
(when (require 'zlc nil 'noerror)
  (zlc-mode t)
  (define-key minibuffer-local-map (kbd "C-n") 'zlc-select-next)
  (define-key minibuffer-local-map (kbd "C-p") 'zlc-select-previous))

; Gui
(when (display-graphic-p)
  ; Theme
  (ignore-errors
    (load-theme 'solarized-dark t))

  ; Font
  (cond ((eq window-system 'w32)
         (set-face-attribute 'default nil
                             :family "BDF UM+ OUTLINE"
                             :height 100)
         (set-fontset-font nil 'japanese-jisx0208
                           (font-spec :family "BDF UM+ OUTLINE")))
        ((eq window-system 'ns)
         (set-face-attribute 'default nil
                             :family "Ricty"
                             :height 135)
         (set-fontset-font nil 'japanese-jisx0208
                           (font-spec :family "Ricty"))))

  ; Misc
  (global-hl-line-mode t)
  (set-face-attribute 'mode-line nil :box nil))

; Local Settings
(if (file-exists-p "~/.emacs.d/.emacs_local")
    (load-file "~/.emacs.d/.emacs_local"))
