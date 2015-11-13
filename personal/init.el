;;;;;;;;;;;;;;;;;;;; tramp ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (setq tramp-default-method "pscp")
;; (add-to-list 'tramp-default-user-alist
;;              '("pscp" "<host>.*" "<user>"))

;;;;;;;;;;;;;;;;;;;; cider ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ~/.lein/profiles.clj
;; {:user {:plugins [[cider/cider-nrepl "0.10.0-SNAPSHOT"]
;;                   [refactor-nrepl "2.0.0-SNAPSHOT"]]}}

;; move backward up 1 sexp recursively until we hit top or a comment block
;; then eval
(defun sindu--move-backward-up-and-eval (eval-fn)
  (let* ((prev-pos (point)))
    (sp-backward-up-sexp)
    (if (or (equal prev-pos (point))        ;; we hit top or the comment block
            (looking-at-p "(comment"))
        (progn
          (goto-char prev-pos)
          (sp-forward-sexp)
          (funcall eval-fn))
      (sindu--move-backward-up-and-eval eval-fn))))

;; like (cider-eval-defun-at-point) but can evaluate top-level sexp inside a top-level comment
(defun sindu-eval-defun-at-point ()
  (interactive)
  (save-excursion
    (sindu--move-backward-up-and-eval 'cider-eval-last-sexp)))

;; like (cider-pprint-eval-defun-at-point) but can evaluate top-level sexp inside a top-level comment

(defun sindu-pprint-eval-defun-at-point ()
  (interactive)
  (save-excursion
    (sindu--move-backward-up-and-eval 'cider-pprint-eval-last-sexp)))


(add-hook 'cider-mode-hook
          (lambda ()
            (define-key cider-mode-map (kbd "<f5>") 'cider-load-buffer)     ;; C-c C-k
            (define-key cider-mode-map (kbd "M-n") 'prelude-cleanup-buffer-or-region)  ;; C-c n
            (define-key cider-mode-map (kbd "M-]") 'cider-find-and-clear-repl-buffer)  ;; C-c M-o
	    (define-key cider-mode-map (kbd "<C-return>") 'sindu-pprint-eval-defun-at-point)
            (define-key cider-mode-map (kbd "<M-RET>") 'sindu-eval-defun-at-point)))

(add-hook 'cider-repl-mode-hook
          (lambda ()
            (define-key cider-repl-mode-map (kbd "M-]") 'cider-find-and-clear-repl-buffer)  ;; C-c M-o
            ))

;;(add-hook 'cider-repl-clear-buffer-hook
;;          (lambda ()
;;            (goto-char (point-max))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; clj-refactor ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(prelude-require-package 'clj-refactor)

(defun my-clojure-mode-hook ()
 (clj-refactor-mode 1)
 (yas-minor-mode 1) ; for adding require/use/import
 (cljr-add-keybindings-with-prefix "C-c C-m"))

(add-hook 'clojure-mode-hook #'my-clojure-mode-hook)

;;;;;;;;;;;;;;;;;;;; align-cljlet ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(prelude-require-package 'align-cljlet)

;;;;;;;;;;;;;;;;;; yasnippet & clojure-snippets ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(prelude-require-package 'yasnippet)
(yas-global-mode 1)
(prelude-require-package 'clojure-snippets)

;;;;;;;;;;;;;;;;;;;; ido ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq ido-use-virtual-buffers t)   ;; remember recent files even though it's closed

;;;;;;;;;;;;;;;;;;;; window ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun sindu-kill-buffer-and-close ()
  (interactive)
  (ido-kill-buffer)   ;; C-x k
  (delete-window))    ;; C-x 0

;; (global-set-key (kbd "<C-tab>") 'ace-jump-buffer)   ;; s->, C-c J
(global-set-key (kbd "<C-tab>") 'helm-buffers-list)        ;; C-x C-b

(global-set-key (kbd "<C-f4>") 'sindu-kill-buffer-and-close)
(global-set-key (kbd "C-s") 'helm-occur)    ;; original: isearch-forward

;;;;;;;;;;;;;;;;;;;;;;;; pretty print xml/html ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; https://sinewalker.wordpress.com/2008/06/26/pretty-printing-xml-with-emacs-nxml-mode/
(defun sindu-pretty-print-xml-region (begin end)
  "Pretty format XML markup in region. You need to have nxml-mode
http://www.emacswiki.org/cgi-bin/wiki/NxmlMode installed to do
this.  The function inserts linebreaks to separate tags that have
nothing but whitespace between them.  It then indents the markup
by using nxml's indentation rules."
  (interactive "r")
  (save-excursion
    (nxml-mode)
    (goto-char begin)
    (while (search-forward-regexp "\>[ \\t]*\<" nil t)
      (backward-char) (insert "\n"))
    (indent-region begin end))
  (message "Ah, much better!"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;; nxml ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; add hs folding
(add-to-list 'hs-special-modes-alist
             '(nxml-mode
               "<!--\\|<[^/>]*[^/]>"
               "-->\\|</[^/>]*[^/]>"
               "<!--"
               sgml-skip-tag-forward
               nil))

(add-hook 'nxml-mode-hook 'hs-minor-mode)

;; move one block
(setq nxml-sexp-element-flag t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;; iedit ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(prelude-require-package 'iedit)

;;;;;;;;;;;;;;;;;;;;;;;;;;;; python ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;(prelude-require-package 'ein)
;;(prelude-require-package 'ein-mumamo)


;;;;;;;;;;;;;;;;;;;;;;;;;;;; ggtags ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (prelude-require-package 'ggtags)

;; (add-hook 'c-mode-common-hook
;;           (lambda ()
;;             (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
;;               (ggtags-mode 1))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;; cider-eval-sexp-fu ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(prelude-require-package 'cider-eval-sexp-fu)
(require 'cider-eval-sexp-fu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;; neotree ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(prelude-require-package 'neotree)

;;;;;;;;;;;;;;;;;;;;;;;;;;;; multiple cursors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(prelude-require-package 'multiple-cursors)
(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)

;;;;;;;;;;;;;;;;;;;;;;;;;;;; c++ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; company-clang
(defun my-c++-mode-hook ()
  ;; (setq company-backends (delete 'company-semantic company-backends))  ;; use company-clang instead
  ;;(setq gdb-many-windows t)
  (setq flycheck-clang-language-standard "c++11")
  (setq gdb-show-main t))

(add-hook 'c++-mode-hook 'my-c++-mode-hook)
(add-hook 'c-mode-hook 'my-c++-mode-hook)

;; g++ -E -x c++ - -v
;; .dir-locals.el
;; ((nil . ((company-clang-arguments . ("-Ic:/programdata/mingw/lib/gcc/x86_64-w64-mingw32/4.8.1/include/c++/"
;;                                      "-Ic:/programdata/mingw/lib/gcc/x86_64-w64-mingw32/4.8.1/include/c++/x86_64-w64-mingw32/"
;;                                      "-Ic:/programdata/mingw/lib/gcc/x86_64-w64-mingw32/4.8.1/include/c++/backward/"
;;                                      "-Ic:/programdata/mingw/lib/gcc/x86_64-w64-mingw32/4.8.1/include/"
;;                                      "-Ic:/programdata/mingw/lib/gcc/x86_64-w64-mingw32/4.8.1/include-fixed/"
;;                                      "-Ic:/programdata/mingw/lib/gcc/x86_64-w64-mingw32/4.8.1/../../../../x86_64-w64-mingw32/include/"
;;                                      )))))


;; irony-mode
;; (prelude-require-package 'irony)

;; (add-hook 'c++-mode-hook 'irony-mode)
;; (add-hook 'c-mode-hook 'irony-mode)
;; (add-hook 'objc-mode-hook 'irony-mode)

;; replace the `completion-at-point' and `complete-symbol' bindings in
;; irony-mode's buffers by irony-mode's function
;; (defun my-irony-mode-hook ()
;;   (define-key irony-mode-map [remap completion-at-point]
;;     'irony-completion-at-point-async)
;;   (define-key irony-mode-map [remap complete-symbol]
;;     'irony-completion-at-point-async))
;; (add-hook 'irony-mode-hook 'my-irony-mode-hook)
;; (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)

;; (setq w32-pipe-read-delay 0)   ;; windows


;;;;;;;;;;;;;;;;;;;;;;;;;;;; fsharp ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (prelude-require-package 'fsharp-mode)
;; (setq inferior-fsharp-program "\"C:\\Program Files (x86)\\Microsoft SDKs\\F#\\3.1\\Framework\\v4.0\\fsi.exe\"")
;; (setq fsharp-compiler "\"C:\\Program Files (x86)\\Microsoft SDKs\\F#\\3.1\\Framework\\v4.0\\fsc.exe\"")
;; (add-hook 'fsharp-mode-hook
;;           (lambda ()
;;             (define-key fsharp-mode-map (kbd "M-RET") 'fsharp-eval-region)
;;             ;; (define-key fsharp-mode-map (kbd "C-SPC") 'fsharp-ac/complete-at-point)
;;             (define-key fsharp-mode-map (kbd "<f5>") 'fsharp-load-buffer-file)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;; windows keys mapping ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (setq w32-pass-lwindow-to-system nil)
;; (setq w32-lwindow-modifier 'super) ; Left Windows key

;; (setq w32-pass-rwindow-to-system nil)
;; (setq w32-rwindow-modifier 'super) ; Right Windows key

;; (setq w32-pass-apps-to-system nil)
;; (setq w32-apps-modifier 'hyper) ; Menu/App key


;;;;;;;;;;;;;;;;;;;;;;;;;;;; global settings ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-prettify-symbols-mode 1)
(desktop-save-mode 1)


;;;;;;;;;;;;;;;;;;;;;;;;;;;; malabar ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;; eclim ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (prelude-require-package 'emacs-eclim)
;; ;; (global-eclim-mode)
;; (custom-set-variables
;;  '(eclim-eclipse-dirs '("c:/Dev/Tools/Eclipse/eclipse-luna-SR1"))
;;  '(eclim-executable "c:/Dev/Tools/Eclipse/eclipse-luna-SR1/eclim"))





;;;;;;;;;;;;;;;;;;;;;;;;;;; melpa stable ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (add-to-list 'package-archives
;;              '("melpa-stable" . "http://stable.melpa.org/packages/") t)
;; (add-to-list 'package-pinned-packages '(cider . "melpa-stable") t)
;; (add-to-list 'package-pinned-packages '(clj-refactor . "melpa-stable") t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;; proxy ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (setq url-proxy-services '(("no_proxy" . "domain\\.com")
;;                            ("http" . "proxy:8080")
;;                            ("https" . "proxy:8080")))


;; (setq url-http-proxy-basic-auth-storage
;;       (list (list "proxy:8080"
;;                   (cons "userid"
;;                         (base64-encode-string "userid:pwd")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;; misc ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (url-get-authentication "http://proxy:8080" nil 'any nil)
;; (setq url-debug t)
;; (url-retrieve "http://news.ycombinator.com" (lambda (status) (switch-to-buffer (current-buffer))))

;; (url-retrieve "http://www.bbc.co.uk" (lambda (status) (switch-to-buffer (current-buffer))))

;; (url-retrieve "https://news.ycombinator.com" (lambda (status) (switch-to-buffer (current-buffer))))

;; (add-to-list 'exec-path "c:/somepath/bin")

;; (getenv "PATH")
;; (setenv "PATH" (concat "C:/somepath/bin" ";" (getenv "PATH")))

;; (setq sindu-temp (getenv "PATH"))
;; (setenv "PATH" "C:\\somepath\\bin;c:\\somepath2\\bin")
