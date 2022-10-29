;;; .emacs -- Minimal emacs configs
;;;
;;; Commentary:
;;;   See https://github.com/klknn/dotfiles
;;; Code:

;; ==== package ===
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(package-initialize)

;;; do this for the first time
;; (package-refresh-contents)
;; (package-install use-package)

;;; General builtins
(defalias 'yes-or-no-p 'y-or-n-p)
(prefer-coding-system 'utf-8-unix)
(setq coding-system-for-read 'utf-8-unix)
(setq coding-system-for-write 'utf-8-unix)
(column-number-mode)
(show-paren-mode)
(recentf-mode)
(setq ring-bell-function 'ignore)
(setq-default indent-tabs-mode nil)
(setq-default linum-format "%5d  ")
(global-linum-mode)
(menu-bar-mode 0)
(windmove-default-keybindings)
(global-set-key (kbd "M-<left>")  'windmove-left)
(global-set-key (kbd "C-c <down>")  'windmove-down)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(setq scroll-step            1
      scroll-conservatively  10000)

(use-package whitespace
  :init (global-whitespace-mode 1)
  :config
  (setq whitespace-style '(face
                           trailing
                           tabs
                           spaces
                           empty
                           space-mark
                           tab-mark
                           lines-tail))
  (setq whitespace-display-mappings
        '((space-mark ?\u3000 [?\u25a1])
          (tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t])))
  (setq whitespace-space-regexp "\\(\u3000+\\)")
  (setq whitespace-action '(auto-cleanup))
  ;; lint 80 col
  (setq whitespace-line-column 80))


;;; Global third party
(use-package helm
  :ensure t
  :init (helm-mode t)
  :config
  ;; (global-set-key (kbd "C-f") 'helm-recentf)
  (global-set-key (kbd "C-x b") 'helm-mini)
  (global-set-key (kbd "M-x") 'helm-M-x))

(use-package company
  :ensure t
  :init (global-company-mode t)
  :config
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 2)
  (setq company-selection-wrap-around t))


(use-package flycheck
  :ensure t
  ;; :load-path "~/repos/flycheck"
  :init (global-flycheck-mode))

(flycheck-define-checker d-dscanner
  "A D style checker using D-Scanner.

See URL `https://github.com/dlang-community/D-Scanner'"
  :command ("dscanner" "--styleCheck" (source-inplace ".d"))
  :error-patterns
  ((error line-start
          (file-name) "(" line ":" column ")[error]: " (message)
          line-end)
   (warning line-start
            (file-name) "(" line ":" column ")[warn]: " (message)
            line-end))
  :modes d-mode)

(flycheck-add-mode 'd-dscanner 'd-mode)

;;; C++

(use-package google-c-style :ensure t)
(defun my/c++-mode-init ()
  "Initialize my C/C++ mode."
  (subword-mode)
  (google-set-c-style)
  (google-make-newline-indent)
  (c-set-offset 'arglist-close 0)
  (c-set-offset 'innamespace 0))
(add-hook 'c-mode-hook 'my/c++-mode-init)
(add-hook 'c++-mode-hook 'my/c++-mode-init)


;; D

(use-package flycheck-dmd-dub :ensure t)
(use-package company-dcd
  :load-path "~/repos/company-dcd")
(use-package d-mode
  :ensure t
  :config
  (add-hook 'd-mode-hook 'flycheck-dmd-dub-set-variables)
  (add-hook 'd-mode-hook 'company-dcd-mode)
  (add-hook 'd-mode-hook 'my/c++-mode-init))

;;; Gauche

(use-package scheme
  :config
  (setq scheme-program-name "gosh -i")
  (autoload 'scheme-mode "cmuscheme" "Major mode for Scheme." t)
  (autoload 'run-scheme "cmuscheme" "Run an inferior Scheme process." t)
  (defun scheme-other-window ()
    "Run Gauche on other window"
    (interactive)
    (split-window-horizontally (/ (frame-width) 2))
    (let ((buf-name (buffer-name (current-buffer))))
      (scheme-mode)
      (switch-to-buffer-other-window
       (get-buffer-create "*scheme*"))
      (run-scheme scheme-program-name)
      (switch-to-buffer-other-window
       (get-buffer-create buf-name))))
  (define-key global-map "\C-cG" 'scheme-other-window))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(flycheck-checkers
   '(ada-gnat asciidoctor asciidoc awk-gawk bazel-build-buildifier bazel-module-buildifier bazel-starlark-buildifier bazel-workspace-buildifier c/c++-clang c/c++-gcc c/c++-cppcheck cfengine chef-foodcritic coffee coffee-coffeelint coq css-csslint css-stylelint cuda-nvcc cwl d-dmd dockerfile-hadolint elixir-credo emacs-lisp emacs-lisp-checkdoc ember-template erlang-rebar3 erlang eruby-erubis eruby-ruumba fortran-gfortran go-gofmt go-golint go-vet go-build go-test go-errcheck go-unconvert go-staticcheck groovy haml handlebars haskell-stack-ghc haskell-ghc haskell-hlint html-tidy javascript-eslint javascript-jshint javascript-standard json-jsonlint json-python-json json-jq jsonnet less less-stylelint llvm-llc lua-luacheck lua markdown-markdownlint-cli markdown-mdl nix nix-linter opam perl perl-perlcritic php php-phpmd php-phpcs processing proselint protobuf-protoc protobuf-prototool pug puppet-parser puppet-lint python-flake8 python-pylint python-pycompile python-pyright python-mypy r-lintr racket rpm-rpmlint rst-sphinx rst ruby-rubocop ruby-standard ruby-reek ruby-rubylint ruby ruby-jruby rust-cargo rust rust-clippy scala scala-scalastyle scheme-chicken scss-lint scss-stylelint sass/scss-sass-lint sass scss sh-bash sh-posix-dash sh-posix-bash sh-zsh sh-shellcheck slim slim-lint sql-sqlint systemd-analyze tcl-nagelfar terraform terraform-tflint tex-chktex tex-lacheck texinfo textlint typescript-tslint verilog-verilator vhdl-ghdl xml-xmlstarlet xml-xmllint yaml-jsyaml yaml-ruby yaml-yamllint d-dscanner))
 '(package-selected-packages
   '(google-c-style company-dcd flycheck-dmd-dub company helm flycheck flycheck-mode use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
