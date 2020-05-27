(defun my--tangle-byte-compile-org ()
 "tangles emacs.org and byte compiles ~/.emacs.d/"
   (interactive)
   (when (equal (buffer-name)
                (concat "init.org"))
     (org-babel-tangle)
     (byte-recompile-directory (expand-file-name user-emacs-directory) 0)))

(defun my--tangle-org ()
 "tangles emacs.org and byte compiles ~/.emacs.d/"
   (interactive)
   (when (equal (buffer-name)
                (concat "init.org"))
     (org-babel-tangle)))
(add-hook 'after-save-hook #'my--tangle-org)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(straight-use-package 'org-plus-contrib)

(setq
 default-frame-alist '((font . "CaskaydiaCove NF-10"))
 tool-bar-mode nil
 menu-bar-mode nil)

(modify-syntax-entry ?_ "w")
(setq org-src-window-setup 'split-window-below)
(setq w32-pass-apps-to-system nil)
(setq w32-apps-modifier 'hyper) ; menu/app key
(ido-mode nil)
(use-package gcmh
  :config
  (gcmh-mode 1))
(setq-default fringe-indicator-alist (assq-delete-all 'truncation fringe-indicator-alist))
(use-package better-defaults)
(global-hl-line-mode 1)
(setq-default cursor-type 'bar)
(setq make-backup-files nil) ; stop creating backup~ files
(setq auto-save-default nil) ; stop creating #autosave# files
(setq create-lockfiles nil)  ; stop creating .# files
(global-auto-revert-mode t)
(fset 'yes-or-no-p 'y-or-n-p)
(setq
 cursor-in-non-selected-windows t  ; hide the cursor in inactive windows
 inhibit-splash-screen t
 echo-keystrokes 0.1               ; show keystrokes right away, don't show the message in the scratch buffe
 initial-scratch-message nil       ; empty scratch buffer
 initial-major-mode 'org-mode      ; org mode by default
 custom-safe-themes t
 confirm-kill-emacs 'y-or-n-p      ; y and n instead of yes and no when quitting
 )
(ido-mode nil)
(add-hook 'org-mode-hook 'hl-line-mode)
(add-hook 'org-mode-hook 'visual-line-mode)
(setq line-spacing 0.15)
(lambda () (progn
  (setq left-margin-width 2)
  (setq right-margin-width 2)
  (set-window-buffer nil (current-buffer))))
(setq org-tags-column 100)
(defun my-org-confirm-babel-evaluate (lang body)
  (not (string= lang "scheme")))
(setq org-confirm-babel-evaluate #'my-org-confirm-babel-evaluate)
(defun my/disable-scroll-bars (frame)
  (modify-frame-parameters frame
                           '((vertical-scroll-bars . nil)
                             (horizontal-scroll-bars . nil))))
(add-hook 'after-make-frame-functions 'my/disable-scroll-bars)

;; check if system is microsoft windows
(defun my-system-type-is-windows ()
  "return true if system is windows-based (at least up to win7)"
  (string-equal system-type "windows-nt")
  )

;; check if system is gnu/linux
(defun my-system-type-is-gnu ()
  "return true if system is gnu/linux-based"
  (string-equal system-type "gnu/linux")
  )

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))

(use-package kaolin-themes
  :config
  (load-theme 'kaolin-ocean))

(use-package flatland-theme)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-lsp t
        doom-modeline-env-enable-python t
        doom-modeline-project-detection 'project))

(use-package rainbow-mode)

(use-package elfeed
  :config
  (setq elfeed-db-directory "~/Dropbox/.elfeed"))
(use-package elfeed-org)

(defun elfeed-play-with-mpv ()
  "Play entry link with mpv."
  (interactive)
  (let ((entry (if (eq major-mode 'elfeed-show-mode) elfeed-show-entry (elfeed-search-selected :single)))
        (quality-arg "")
        (quality-val (completing-read "Max height resolution (0 for unlimited): " '("0" "480" "720") nil nil)))
    (setq quality-val (string-to-number quality-val))
    (message "Opening %s with height≤%s with mpv..." (elfeed-entry-link entry) quality-val)
    (when (< 0 quality-val)
      (setq quality-arg (format "--ytdl-format=[height<=?%s]" quality-val)))
    (start-process "elfeed-mpv" nil "mpv" quality-arg (elfeed-entry-link entry))))

(defvar elfeed-mpv-patterns
  '("youtu\\.?be")
  "List of regexp to match against elfeed entry link to know
whether to use mpv to visit the link.")

(defun elfeed-visit-or-play-with-mpv ()
  "Play in mpv if entry link matches `elfeed-mpv-patterns', visit otherwise.
See `elfeed-play-with-mpv'."
  (interactive)
  (let ((entry (if (eq major-mode 'elfeed-show-mode) elfeed-show-entry (elfeed-search-selected :single)))
        (patterns elfeed-mpv-patterns))
    (while (and patterns (not (string-match (car elfeed-mpv-patterns) (elfeed-entry-link entry))))
      (setq patterns (cdr patterns)))
    (if patterns
        (elfeed-play-with-mpv)
      (if (eq major-mode 'elfeed-search-mode)
          (elfeed-search-browse-url)
        (elfeed-show-visit)))))

(use-package pdf-tools   
  :config   (pdf-tools-install)   
  (setq-default pdf-view-display-size 'fit-page))

(use-package org-noter
  :config
  (setq org-noter-notes-search-path '("~/Dropbox/brain/notes")))
(defun org-noter--insert-heading (level title &optional newlines-number location)
  "Insert a new heading at LEVEL with TITLE.
The point will be at the start of the contents, after any
properties, by a margin of NEWLINES-NUMBER."
  (setq newlines-number (or newlines-number 1))
  (org-insert-heading nil t)
  (let* ((initial-level (org-element-property :level (org-element-at-point)))
         (changer (if (> level initial-level) 'org-do-demote 'org-do-promote))
         (number-of-times (abs (- level initial-level))))
    (dotimes (_ number-of-times) (funcall changer))
    (insert (org-trim (replace-regexp-in-string "\n" " " title)))

    (org-end-of-subtree)
    (unless (bolp) (insert "\n"))
    (org-N-empty-lines-before-current (1- newlines-number))
    (org-entry-put nil "ANKI_DESK" "Default")
    (org-entry-put nil "ANKI_NOTE_TYPE" "Basic")
    (org-entry-put nil "ANKI_TAGS" "")
    (when location
      (org-entry-put nil org-noter-property-note-location (org-noter--pretty-print-location location))

      (when org-noter-doc-property-in-notes
        (org-noter--with-valid-session
         (org-entry-put nil org-noter-property-doc-file (org-noter--session-property-text session))
         (org-entry-put nil org-noter--property-auto-save-last-location "nil"))))

    (run-hooks 'org-noter-insert-heading-hook)))

(use-package anki-editor)
(setq request-log-level 'debug)

(use-package org-download)
(setq-default org-download-image-dir "~/Dropbox/brain/image")
(when (my-system-type-is-windows)
  (setq org-download-screenshot-method "magick convert clipboard: %s")
  )

(use-package org-roam
  :hook 
  (after-init . org-roam-mode)
  :custom
  (org-roam-directory "~/Dropbox/brain")
  :bind (:map org-roam-mode-map
              (("C-c n l" . org-roam)
               ("C-c n f" . org-roam-find-file)
               ("C-c n g" . org-roam-show-graph))
              :map org-mode-map
              (("C-c n i" . org-roam-insert)
               ("C-c n c" . org-roam-capture))))
(use-package company-org-roam
  :straight (:host github :repo "jethrokuan/company-org-roam")
  :config
  (push 'company-org-roam company-backends))
(when (my-system-type-is-gnu)
  (setq org-roam-graph-executable "/usr/bin/dot"))
(when (my-system-type-is-windows)
  (setq org-roam-graph-executable "c:/Program Files (x86)/Graphviz2.38/bin/dot"))
(setq org-roam-capture-templates
      '(("d" "default" plain (function org-roam--capture-get-point)
        "%?"
        :file-name "%<%Y%m%d%H%M%S>-${slug}"
        :head "#+TITLE: ${title}\n"
        :unnarrowed t)
       ("c" "from notes" plain (function org-roam--capture-get-point)
        "%i"
        :file-name "%<%Y%m%d%H%M%S>-${slug}"
        :head "#+TITLE: ${title}\n"
        :unnarrowed t))
      )
(require 'org-roam-protocol)

(defun my/org-roam--backlinks-list-with-content (file)
  (with-temp-buffer
    (if-let* ((backlinks (org-roam--get-backlinks file))
              (grouped-backlinks (--group-by (nth 0 it) backlinks)))
        (progn
          (insert (format "\n\n* %d Backlinks\n"
                          (length backlinks)))
          (dolist (group grouped-backlinks)
            (let ((file-from (car group))
                  (bls (cdr group)))
              (insert (format "** [[file:%s][%s]]\n"
                              file-from
                              (org-roam--get-title-or-slug file-from)))
              (dolist (backlink bls)
                (pcase-let ((`(,file-from _ ,props) backlink))
                  (insert (s-trim (s-replace "\n" " " (plist-get props :content))))
                  (insert "\n\n")))))))
    (buffer-string)))


(defun my/org-export-preprocessor (backend)
  (let ((links (my/org-roam--backlinks-list-with-content (buffer-file-name))))
    (unless (string= links "")
      (save-excursion
        (goto-char (point-max))
        (insert (concat "\n* Backlinks\n") links)))))

(add-hook 'org-export-before-processing-hook 'my/org-export-preprocessor)

(defadvice org-capture
    (after make-full-window-frame activate)
  "Advise capture to be the only window when used as a popup"
  (if (equal "emacs-capture" (frame-parameter nil 'name))
      (delete-other-windows)))

(defadvice org-capture-finalize
    (after delete-capture-frame activate)
  "Advise capture-finalize to close the frame"
  (if (equal "emacs-capture" (frame-parameter nil 'name))
      (delete-frame)))
(defun org-journal-find-location ()
  ;; Open today's journal, but specify a non-nil prefix argument in order to
  ;; inhibit inserting the heading; org-capture will insert the heading.
  (org-journal-new-entry t)
  ;; Position point on the journal's top-level heading so that org-capture
  ;; will add the new entry as a child entry.
  (goto-char (point-min)))

(setq org-capture-templates '(("j" "Journal entry" entry (function org-journal-find-location)
                               "* %(format-time-string org-journal-time-format)%^{Title}\n%i%?")))

(use-package org-journal)
(setq org-journal-dir "~/Dropbox/brain/journals")
(setq org-journal-date-format "%A, %d %B %Y")
(setq org-journal-file-type 'weekly)
(setq org-journal-file-format "%Y%m%d.org")

(use-package evil
  :init
  (setq evil-disable-insert-state-bindings t
        evil-want-C-i-jump t
        evil-want-C-u-scroll t
        evil-want-integration t
        evil-want-keybinding nil)
  :config
  (evil-set-initial-state 'elfeed-show-mode-map 'emacs)
  (evil-set-initial-state 'elfeed-search-mode-map 'emacs)
  (evil-set-initial-state 'magit-mode-map 'emacs)
  (evil-set-initial-state 'dired-mode-map 'emacs)
  (evil-set-initial-state 'info-mode-map 'emacs)
  (evil-mode t))

(use-package corral
  :config
  (global-set-key (kbd "M-9") 'corral-parentheses-backward)
  (global-set-key (kbd "M-0") 'corral-parentheses-forward)
  (global-set-key (kbd "M-[") 'corral-brackets-backward)
  (global-set-key (kbd "M-]") 'corral-brackets-forward)
  (global-set-key (kbd "M-{") 'corral-braces-backward)
  (global-set-key (kbd "M-}") 'corral-braces-forward)
  (global-set-key (kbd "M-\"") 'corral-double-quotes-backward))

(use-package lispy
  :config
  (add-hook 'emacs-lisp-mode-hook (lambda () (lispy-mode 1)))
  (add-hook 'scheme-mode-hook (lambda () (lispy-mode 1))))

(use-package ace-window
  :init
  (setq aw-background t)
  (setq aw-keys '(?a ?r ?s ?t ?d ?h ?n ?e ?i))
  (setq aw-dispatch-always t))
(defvar aw-dispatch-alist
  '((?x aw-delete-window "Delete Window")
        (?m aw-swap-window "Swap Windows")
        (?M aw-move-window "Move Window")
        (?c aw-copy-window "Copy Window")
        (?j aw-switch-buffer-in-window "Select Buffer")
        (?l aw-flip-window)
        (?u aw-switch-buffer-other-window "Switch Buffer Other Window")
        (?k aw-split-window-fair "Split Fair Window")
        (?v aw-split-window-vert "Split Vert Window")
        (?b aw-split-window-horz "Split Horz Window")
        (?o delete-other-windows "Delete Other Windows")
        (?? aw-show-dispatch-help))
  "List of actions for `aw-dispatch-default'.")
(global-set-key (kbd "M-o") 'ace-window)

(use-package winum
  :config
  (winum-mode)
  (winum-set-keymap-prefix (kbd "C-c")))

(use-package geiser
  :config
  (setq geiser-active-implementations '(guile))
  )

(use-package bookmark+)

(org-babel-do-load-languages
 'org-babel-load-languages
 '(
   (scheme . t)))

(use-package sicp)

(use-package hyperbole)

(use-package ivy
  :diminish ivy-mode
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  (setq ivy-initial-inputs-alist nil))
(use-package counsel
  :diminish counsel-mode
  :config
  (counsel-mode 1))
(use-package avy)

(use-package company
    :config
    (setq company-idle-delay 0.0
          company-minimum-prefix-length 1)
    (global-company-mode))

(use-package which-key
  :config
  (which-key-mode))

(use-package smartparens
  :config
  (smartparens-global-mode)
  (require 'smartparens-config))

(use-package org-bullets
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(use-package undo-fu)

(use-package deadgrep)

(require 'org-habit)
(setq spacemacs-theme-org-agenda-height nil
      org-agenda-start-day "-1d"
      org-agenda-skip-scheduled-if-done t
      org-agenda-skip-deadline-if-done t
      org-agenda-include-deadlines t
      org-agenda-include-diary t
      org-agenda-block-separator nil
      org-agenda-compact-blocks t
      org-agenda-start-with-log-mode t
      org-habit-following-days 7
      org-habit-preceding-days 10
      org-habit-show-habits-only-for-today t
      org-agenda-tags-column -102
      org-habit-graph-column 50
      org-clock-out-remove-zero-time-clocks t
      org-clock-out-when-done t
      org-clock-persist t)
(defun org-journal-find-location ()
  ;; Open today's journal, but specify a non-nil prefix argument in order to
  ;; inhibit inserting the heading; org-capture will insert the heading.
  (org-journal-new-entry t)
  ;; Position point on the journal's top-level heading so that org-capture
  ;; will add the new entry as a child entry.
  (goto-char (point-min)))

(use-package deft
  :init
  (setq deft-extensions '("org" "md")
        deft-recursive t
        deft-directory "~/dropbox/archives"
        deft-use-filename-as-title t
        deft-file-naming-rules '((noslash . "-")
                                 (nospace . "-")
                                 (case-fn . downcase))))
(use-package zetteldeft
  :after deft)

(use-package projectile
  :config
  (projectile-mode 1))

(use-package emmet-mode
  :config
  (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'css-mode-hook 'emmet-mode)
  (setq emmet-self-closing-tag-style " /"))

(use-package web-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (setq web-mode-engines-alist '(("django" . "\\.html\\'")))
  (setq web-mode-enable-auto-pairing nil))

(use-package magit)

(use-package elpy
  :if (my-system-type-is-windows)
  :config
  (elpy-enable))

(use-package blacken)

(use-package realgud)

(use-package lsp-mode
  :if (my-system-type-is-gnu)
  :commands lsp
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook
  (lsp-mode . lsp-enable-which-key-integration)
  (python-mode . lsp))

(use-package pyvenv)

(use-package company-irony
  :config
  (add-to-list 'company-backends 'company-irony))

(use-package irony
  :hook ((c++-mode-hook . irony-mode)
         (c-mode-hook . irony-mode)
         (irony-mode-hook . irony-cdb-autosetup-compile-options)))

(use-package vterm
  :if (my-system-type-is-gnu))
(use-package vterm-toggle
  :straight (vterm-toggle :type git :host github :repo "jixiuf/vterm-toggle")
  :if (my-system-type-is-gnu)
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (add-to-list 'display-buffer-alist
               '("^v?term.*"
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 (reusable-frames . visible)
                 (window-height . 0.3))))

(use-package rustic)

(use-package yaml-mode)

(defun copy-line (arg)
  "copy lines (as many as prefix argument) in the kill ring.
    ease of use features:
    - move to start of next line.
    - appends the copy on sequential calls.
    - use newline as last char even on the last line of the buffer.
    - if region is active, copy its lines."
  (interactive "p")
  (let ((beg (line-beginning-position))
        (end (line-end-position arg)))
    (when mark-active
      (if (> (point) (mark))
          (setq beg (save-excursion (goto-char (mark)) (line-beginning-position)))
        (setq end (save-excursion (goto-char (mark)) (line-end-position)))))
    (if (eq last-command 'copy-line)
        (kill-append (buffer-substring beg end) (< end beg))
      (kill-ring-save beg end)))
  (kill-append "\n" nil)
  (beginning-of-line (or (and arg (1+ arg)) 2))
  (if (and arg (not (= 1 arg))) (message "%d lines copied" arg)))

(defun my-counsel-p4 ()
  (interactive)
  (let ((counsel-fzf-cmd "find ~/Dropbox/Calibre | grep -e pdf | fzf -f \"%s\""))
    (counsel-fzf)))
(use-package general)
(general-evil-setup)
(general-define-key "<menu>" (general-simulate-key "C-c"))
(general-define-key
 "C-z" 'undo-fu-only-undo
 "C-s-z" 'undo-fu-only-redo)
(general-define-key
 "H-t" 'vterm-toggle)
(use-package key-chord :config (key-chord-mode t))
(general-define-key
 :keymap org-mode-map
 "H-c" 'org-pomodoro)
(defun def-rep-command (alist)
  "Return a lambda that calls the first function of ALIST. It sets the transient map to all functions of ALIST, allowing you to repeat those functions as needed."
  (lexical-let ((keymap (make-sparse-keymap))
                (func (cdar alist)))
    (mapc (lambda (x)
            (when x
              (define-key keymap (kbd (car x)) (cdr x))))
          alist)
    (lambda (arg)
      (interactive "p")
      (when func
        (funcall func arg))
      (set-transient-map keymap t))))
(key-chord-define-global "yy"   
      (def-rep-command
       '(nil
         ("n" . windmove-left)
         ("i" . windmove-right)
         ("e" . windmove-down)
         ("u" . windmove-up)
         ("y" . other-window)
         ("h" . ace-window)
         ("s" . (lambda () (interactive) (ace-window 4)))
         ("d" . (lambda () (interactive) (ace-window 16)))
         ("-" . text-scale-decrease)
         ("=" . text-scale-decrease)
         )))
(general-define-key
 :prefix "C-c"
 "c" 'avy-goto-char-timer
 "w" 'avy-goto-word-0
 "e" '(:ignore t :wk "elfeed")
 "eo" 'elfeed-visit-or-play-with-mpv
 "ee" 'elfeed
 "eu" 'elfeed-update
 "f" 'my-counsel-p4
 "a" '(:ignore t :wk "Org")
 "ac" 'org-capture 
 )


(general-define-key
 :keymaps 'lispy-mode-map
 "h" 'special-lispy-up
 "k" 'special-lispy-down
 "j" 'special-lispy-left)

(general-nmap "k" 'evil-next-line)
(general-nmap "h" 'evil-previous-line)
(general-nmap "j" 'evil-backward-char)
