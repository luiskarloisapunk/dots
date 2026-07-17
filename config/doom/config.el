;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-roam-directory "~/coco/")
(setq org-roam-dailies-directory "journal/")


(after! org
  ;; 1. La función para copiar la tarea al diario de hoy
  (defun my/org-roam-copy-todo-to-today ()
    (interactive)
    (let ((org-refile-keep t) ;; Cambia a nil si prefieres MOVER en vez de COPIAR
          (org-roam-dailies-capture-templates
           '(("t" "tasks" entry "%?"
              :if-new (file+head+olp "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n" ("Tasks")))))
          (org-after-refile-insert-hook #'save-buffer)
          today-file
          pos)
      (save-window-excursion
        (org-roam-dailies--capture (current-time) t)
        (setq today-file (buffer-file-name))
        (setq pos (point)))

      ;; Solo archiva si el archivo destino es diferente al actual
      (unless (equal (file-truename today-file)
                     (file-truename (buffer-file-name)))
        (org-refile nil nil (list "Tasks" today-file nil pos)))))

  ;; 2. Función segura para el hook (evita bloqueos si algo falla)
  (defun my/org-roam-copy-todo-on-done-hook ()
    "Ejecuta la copia al diario solo si el estado cambia a DONE."
    (when (equal org-state "DONE")
      (ignore-errors
        (my/org-roam-copy-todo-to-today))))

  ;; 3. Añadir el hook usando el método seguro de Emacs
  (add-hook 'org-after-todo-state-change-hook #'my/org-roam-copy-todo-on-done-hook))
(after! org-roam
  (setq org-roam-capture-templates
        '(


          ("d" "default" plain "%?"
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+date: %U\n")
           :unnarrowed t)
          ("l" "programming language" plain
           "* Characteristics\n\n- Family: %?\n- Inspired by: \n\n* Reference:\n\n"
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
           :unnarrowed t)
          ("b" "book notes" plain
           (file "~/coco/templates/BookNoteTemplate.org")
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
           :unnarrowed t)
          ("p" "project" plain "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+category: ${title}\n#+filetags: Project")
           :unnarrowed t)
          )
        )
  (setq org-roam-dailies-capture-templates
        '(("d" "default" entry "* %<%I:%M %p>: %?"
           :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))

  )
(custom-set-faces!
  '(markdown-header-face :inherit font-lock-function-name-face :weight bold :family "variable-pitch")
  '(markdown-header-face-1 :inherit markdown-header-face :height 1.6)
  '(markdown-header-face-2 :inherit markdown-header-face :height 1.5)
  '(markdown-header-face-3 :inherit markdown-header-face :height 1.4)
  '(markdown-header-face-4 :inherit markdown-header-face :height 1.3)
  '(markdown-header-face-5 :inherit markdown-header-face :height 1.2)
  '(markdown-header-face-6 :inherit markdown-header-face :height 1.1))

(after! org
  (add-hook 'org-mode-hook #'hl-todo-mode)
(setq doom-font (font-spec :family "JetBrains Mono" :size 15))

(setq display-line-numbers-type t)    ;; Activar números de línea
(setq confirm-kill-emacs nil)         ;; Salir sin pedir confirmación
(setq initial-buffer-choice 'eshell)
  ;; Escalar los títulos de Org Mode dentro del tema doom-one de forma correcta
  (custom-theme-set-faces! 'doom-one
    '(org-level-1 :inherit outline-1 :height 1.6 :weight bold)
    '(org-level-2 :inherit outline-2 :height 1.5 :weight bold)
    '(org-level-3 :inherit outline-3 :height 1.4)
    '(org-level-4 :inherit outline-3 :height 1.3)
    '(org-level-5 :inherit outline-3 :height 1.2)
    '(org-level-6 :inherit outline-3 :height 1.1)
    '(org-level-7 :inherit outline-3 :height 1.0)
    '(org-level-8 :inherit outline-3 :height 1.0)
    '(org-document-title :height 1.8 :bold t :underline nil)))
(defun my/org-roam-capture-task ()
  (interactive)
  ;; Add the project file to the agenda after capture is finished
  (add-hook 'org-capture-after-finalize-hook #'my/org-roam-project-finalize-hook)

  ;; Capture the new task, creating the project file if necessary
  (org-roam-capture- :node (org-roam-node-read
                            nil
                            (my/org-roam-filter-by-tag "Project"))
                     :templates '(("p" "project" plain "** TODO %?"
                                   :if-new (file+head+olp "%<%Y%m%d%H%M%S>-${slug}.org"
                                                          "#+title: ${title}\n#+category: ${title}\n#+filetags: Project"
                                                          ("Tasks"))))))

(global-set-key (kbd "C-c n t") #'my/org-roam-capture-task)

(defun my/org-roam-capture-inbox ()
  (interactive)
  (org-roam-capture- :node (org-roam-node-create)
                     :templates '(("i" "inbox" plain "* %?"
                                  :if-new (file+head "Inbox.org" "#+title: Inbox\n")))))

(global-set-key (kbd "C-c n b") #'my/org-roam-capture-inbox)

(defun org-roam-node-insert-immediate (arg &rest args)
  (interactive "P")
  (let ((args (cons arg args))
        (org-roam-capture-templates (list (append (car org-roam-capture-templates)
                                                  '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))

(add-to-list 'custom-theme-load-path "/home/lk/.local/state/caelestia/theme/")
(setq doom-theme 'matugen)
;;;###autoload
(defun my/reload-caelestia-theme ()
  (interactive)
  (load-theme 'matugen t)
  (message "¡Tema dinámico de Matugen recargado!"))
(require 'filenotify)

(defvar my/caelestia-theme-watcher nil
  "Guarda el watcher que vigila el directorio del tema.")

(defun my/watch-caelestia-theme-changes ()
  "Vigila la carpeta de Caelestia y recarga el tema si matugen-theme.el cambia."
  (let ((theme-dir "/home/lk/.local/state/caelestia/theme/"))
    ;; Si ya había un watcher activo, lo limpiamos para evitar duplicados
    (when my/caelestia-theme-watcher
      (ignore-errors
        (file-notify-rm-watch my/caelestia-theme-watcher)))
    
    ;; Vigilamos la CARPETA completa
    (when (file-directory-p theme-dir)
      (setq my/caelestia-theme-watcher
            (file-notify-add-watch
             theme-dir
             '(change)
             (lambda (event)
               (let ((action (nth 1 event))
                     (file (nth 2 event)))
                 ;; Comprobamos si el archivo afectado es nuestro tema
                 (when (and (string= (file-name-nondirectory file) "matugen-theme.el")
                            (memq action '(changed created renamed)))
                   ;; Damos 0.2 segundos para que Caelestia termine de escribir el archivo
                   (run-with-timer 0.2 nil #'my/reload-caelestia-theme)))))))))

(add-hook 'window-setup-hook #'my/watch-caelestia-theme-changes)

(after! org-roam
  (map! :leader
        :desc "Org-roam buffer"     "c n l" #'org-roam-buffer-toggle
        :desc "Find node"           "c n f" #'org-roam-node-find
        :desc "Insert node"         "c n i" #'org-roam-node-insert
        :desc "Insert node (discreet)" "C-c n I" #'org-roam-node-insert-immediate
        )
  (map! :i "C-c n i" #'org-roam-node-insert-immediate)

  (map! :map org-rode-map
        "C-M-i" #'completion-at-point)

  (map! :prefix ("C-c n d" . "Dailies")
        "y" #'org-roam-dailies-capture-yesterday
        "t" #'org-roam-dailies-capture-tomorrow)

  )


(after! org-roam
  ;; 1. El código de tu tutorial (Filtrar archivos por tag "Project")
  (defun my/org-roam-filter-by-tag (tag-name)
    (lambda (node)
      (member tag-name (org-roam-node-tags node))))

  (defun my/org-roam-list-notes-by-tag (tag-name)
    (mapcar #'org-roam-node-file
            (seq-filter
             (my/org-roam-filter-by-tag tag-name)
             (org-roam-node-list))))

  (defun my/org-roam-refresh-agenda-list ()
    (interactive)
    (setq org-agenda-files (my/org-roam-list-notes-by-tag "Project")))

  ;; Ejecutarlo al cargar
  (my/org-roam-refresh-agenda-list)

  ;; =================================================================
  ;; LA SOLUCIÓN MÁGICA: Cambiar nombres de archivo por categorías reales
  ;; =================================================================
  (setq org-agenda-prefix-format
        '((agenda . " %i %-12:c%?-12t% s")
          (todo   . " %i %-12:c ")
          (tags   . " %i %-12:c ")
          (search . " %i %-12:c "))))


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
