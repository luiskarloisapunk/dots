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


;;; -----------------------------------------------------------------------
;;; 1. AJUSTES BÁSICOS (UI, comportamiento general)
;;; -----------------------------------------------------------------------

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)
(setq confirm-kill-emacs nil)         ;; Salir sin pedir confirmación
;;; ----------------------------------------------------------------------- 2.
;;; TEMA: Caelestia / Matugen (tema dinámico con auto-recarga)
;;; -----------------------------------------------------------------------

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


;;; -----------------------------------------------------------------------
;;; 3. ORG / ORG-ROAM: directorios
;;; -----------------------------------------------------------------------

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-roam-directory "~/coco/")
(setq org-roam-dailies-directory "journal/")

(after! org
  (setq org-preview-latex-default-process 'dvisvgm)
  (plist-put org-format-latex-options :scale 1.3)
  (setq org-startup-with-latex-preview t))

(after! org-appear
  ;; Activa org-appear para fragmentos de LaTeX
  (setq org-appear-autoorg-latex t)
  ;; Hace que reaparezca el código al instante al poner el cursor encima
  (setq org-appear-trigger 'manual)
  (add-hook 'org-mode-hook 'org-appear-mode))

;;; -----------------------------------------------------------------------
;;; 4. ORG-ROAM: plantillas de captura (notas, diario)
;;; -----------------------------------------------------------------------

(after! org-roam
  ;;; 1. UTILIDADES GENERALES
  (defvar my/spanish-day-abbrevs ["dom" "lun" "mar" "mié" "jue" "vie" "sáb"]
    "Abreviaturas de días en español, indexadas 0=domingo .. 6=sábado.")

  (defun my/org-fecha-inactiva ()
    "Marca de tiempo inactiva con día en español: [2026-07-17 vie 00:45].
Genérica: la usan Clase, Ensayo, Poema y las plantillas de programación
competitiva."
    (let* ((now (decode-time))
           (dow (nth 6 now))
           (dia (aref my/spanish-day-abbrevs dow)))
      (format-time-string (format "[%%Y-%%m-%%d %s %%H:%%M]" dia))))

  (defun my/org-tag-sanitize (str)
    "Convierte STR en una etiqueta Org válida: sin espacios ni símbolos raros."
    (replace-regexp-in-string
     "[^[:alnum:]_@#]" ""
     (replace-regexp-in-string "[[:space:]]+" "" str)))

  (defun my/read-template-file (path)
    "Lee PATH (soporta ~) y devuelve su contenido como string.
Se usa para inyectar plantillas .org externas dentro de
`org-roam-capture-templates' con backquote/unquote, ya que
`org-roam-capture--fill-template' NO soporta la forma (file \"...\")
que sí entiende `org-capture' normal."
    (with-temp-buffer
      (insert-file-contents (expand-file-name path))
      (buffer-string)))
  ;;; 2. FLUJO PARA NOTAS DE MATERIA (Hub)
  ;; El TÍTULO de la nota (lo que escribes en el prompt "Node:") es el
  ;; CÓDIGO de la materia, ej. "F1009". Aquí solo se preguntan los datos
  ;; que faltan: semestre, nombre completo y profesor.

  (defvar my/org-roam-materia--cache nil)

  (defun my/org-roam-materia-init ()
    "Pregunta semestre, nombre completo y profesor de una Materia nueva."
    (let* ((semestre (completing-read
                      "Semestre: "
                      '("Sem1" "Sem2" "Sem3" "Sem4" "Sem5" "Sem6" "Sem7" "Sem8")
                      nil t))
           (nombre (read-string "Nombre completo de la materia: "))
           (profesor (read-string "Profesor: ")))
      (setq my/org-roam-materia--cache
            (list :semestre semestre :nombre nombre :profesor profesor))
      ""))

  (defun my/org-roam-materia-get (key)
    (plist-get my/org-roam-materia--cache key))

  (defun my/org-roam-materia-filetags ()
    (format ":Materia:%s:" (my/org-roam-materia-get :semestre)))
  ;;; 3. FLUJO PARA NOTAS DE CLASE (Sesión)
  (defvar my/org-roam-clase--cache nil
    "Datos ya resueltos de la última captura de Clase en curso.")

  (defun my/org-roam-clase-filter (node)
    "Filtro para `org-roam-node-read': solo notas con tag :Materia:."
    (member "Materia" (org-roam-node-tags node)))

  (defun my/org-roam-clase-count (materia-title)
    "Cuenta cuántas notas :Clase: en DISCO ya pertenecen a MATERIA-TITLE.
Lee `org-roam-list-files' directamente (no depende de que la DB de
org-roam ya esté sincronizada), así el contador nunca se queda en 1."
    (let ((count 0)
          (re-materia (regexp-quote materia-title)))
      (dolist (file (org-roam-list-files))
        (when (file-readable-p file)
          (with-temp-buffer
            (insert-file-contents file)
            (goto-char (point-min))
            (when (and (re-search-forward "^#\\+filetags:.*:Clase:" nil t)
                       (progn
                         (goto-char (point-min))
                         (re-search-forward
                          (format "^:MATERIA:.*%s" re-materia) nil t)))
              (setq count (1+ count))))))
      count))

  (defun my/org-roam-clase-init ()
    "Ejecuta el flujo interactivo completo (una sola vez) para una nota de Clase:
1) Busca la Materia (org-roam-node-read filtrado por :Materia:).
2) Usa el título de la Materia como código (el título ES el código).
3) Hereda el tag de semestre (SemN) desde la Materia.
4) Pregunta solo la semana actual (1-15) y calcula el Periodo (P1/P2/P3).
5) Cuenta las clases previas de esa materia leyendo disco -> SESION.
No inserta texto por sí misma: solo llena `my/org-roam-clase--cache'."
    (let* ((materia (org-roam-node-read nil #'my/org-roam-clase-filter nil t "Materia: "))
           (materia-title (org-roam-node-title materia))
           (materia-tags  (org-roam-node-tags materia))
           (codigo (my/org-tag-sanitize materia-title))
           (semestre (or (seq-find (lambda (tag) (string-match-p "\\`Sem[0-9]+\\'" tag))
                                   materia-tags)
                         "SemX"))
           (semana (read-number "Semana actual de clases (1-15): "))
           (periodo (format "P%d" (1+ (/ (1- semana) 5))))
           (sesion (1+ (my/org-roam-clase-count materia-title))))
      (setq my/org-roam-clase--cache
            (list :codigo codigo
                  :semestre semestre
                  :semana semana
                  :periodo periodo
                  :sesion sesion
                  :materia-title materia-title))
      ""))

  (defun my/org-roam-clase-get (key)
    (plist-get my/org-roam-clase--cache key))

  (defun my/org-roam-clase-filetags ()
    "Construye la línea de #+filetags: para la nota de Clase."
    (format ":Clase:%s:%s:Semanas%d:%s:"
            (my/org-roam-clase-get :codigo)
            (my/org-roam-clase-get :semestre)
            (my/org-roam-clase-get :semana)
            (my/org-roam-clase-get :periodo)))

  (defun my/org-roam-clase-materia-link ()
    (format "[[roam:%s]]" (my/org-roam-clase-get :materia-title)))

  (defun my/org-roam-clase-sesion ()
    (number-to-string (my/org-roam-clase-get :sesion)))
  ;;; 4. MENÚ DE CAPTURA — las cabeceras viven en ~/coco/templates/
  (setq org-roam-capture-templates
        `(
          ;; ================= UNIVERSIDAD =================
          ("u" "Universidad")

          ("um" "Materia (Hub)" plain "%?"
           :target (file+head
                    "%<%Y%m%d%H%M%S>-${slug}.org"
                    ,(my/read-template-file "~/coco/templates/materiaTemplate.org"))
           :unnarrowed t)

          ("uc" "Clase" plain "%?"
           :target (file+head
                    "%<%Y%m%d%H%M%S>-${slug}.org"
                    ,(my/read-template-file "~/coco/templates/claseTemplate.org"))
           :unnarrowed t)
          ("p" "Problemas (ICPC/OMUM)" plain
           (file "~/coco/templates/problemTemplate.org")
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :Competitiva:\n")
           :unnarrowed t)

          ("e" "Escritura" plain
           "* %?\n\n#+begin_verse\n\n#+end_verse"
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :Escritura:\n")
           :unnarrowed t)

          ("b" "book notes" plain
           (file "~/coco/templates/bookTemplate.org")
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n")
           :unnarrowed t)
          ))

  (setq org-roam-dailies-capture-templates
        '(("d" "default" entry "* %<%I:%M %p>: \n%?"
           :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))
  )
                                        ;----------------------------------------------
;;; 5. ORG-ROAM: funciones personalizadas de captura
;;; -----------------------------------------------------------------------

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


;;; -----------------------------------------------------------------------
;;; 6. ORG-ROAM: copiar tarea completada (DONE) al diario de hoy
;;; -----------------------------------------------------------------------

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


;;; -----------------------------------------------------------------------
;;; 7. ORG-ROAM: agenda filtrada por tag "Project"
;;; -----------------------------------------------------------------------

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

  (setq org-agenda-prefix-format
        '((agenda . " %i %-12:c%?-12t% s")
          (todo   . " %i %-12:c ")
          (tags   . " %i %-12:c ")
          (search . " %i %-12:c "))))


;;; -----------------------------------------------------------------------
;;; 8. KEYBINDINGS: org-roam
;;; -----------------------------------------------------------------------

(after! org-roam
  (map! :leader
        :desc "Org-roam buffer"     "c n l" #'org-roam-buffer-toggle
        :desc "Find node"           "c n f" #'org-roam-node-find
        :desc "Insert node"         "c n i" #'org-roam-node-insert
        :desc "Insert node (discreet)" "C-c n I" #'org-roam-node-insert-immediate
        (:prefix ("t" . "toggle")
         :desc "Toggle eshell split"            "e" #'+eshell/toggle
         :desc "Toggle line highlight in frame" "h" #'hl-line-mode
         :desc "Toggle line highlight globally" "H" #'global-hl-line-mode
         :desc "Toggle line numbers"            "l" #'doom/toggle-line-numbers
         :desc "Toggle markdown-view-mode"      "m" #'dt/toggle-markdown-view-mode
         :desc "Toggle truncate lines"          "t" #'toggle-truncate-lines
         :desc "Toggle treemacs"                "T" #'+treemacs/toggle
         :desc "Toggle ghostel split"             "g" #'+ghostel/toggle
         )
        )
  (map! :i "C-c n i" #'org-roam-node-insert-immediate)

  (map! :map org-mode-map
        "C-M-i" #'completion-at-point
        :localleader
        :desc "Toggle LaTeX Preview" "x" #'org-latex-preview)


  (map! :prefix ("C-c n d" . "Dailies")
        :desc "Capture in yesterday journal" "Y" #'org-roam-dailies-capture-yesterday
        :desc "Capture in tomorrow journal" "T" #'org-roam-dailies-capture-tomorrow
        :desc "Capture in today journal" "n" #'org-roam-dailies-capture-today
        :desc "Go to today journal" "d" #'org-roam-dailies-goto-today
        :desc "Go to yesterday journal" "y" #'org-roam-dailies-goto-yesterday
        :desc "Go to tomorrow journal" "t" #'org-roam-dailies-goto-tomorrow
        :desc "Capture in any day journal" "v" #'org-roam-dailies-capture-date
        :desc "Go to any day journal" "c" #'org-roam-dailies-goto-date
        :desc "Go to next journal" "b" #'org-roam-dailies-goto-next-note
        :desc "Go to previous journal" "f" #'org-roam-dailies-goto-previous-note
        )

  )


;;; -----------------------------------------------------------------------
;;; 9. APARIENCIA DE ORG / MARKDOWN (estilo Obsidian para tomar notas)
;;; -----------------------------------------------------------------------

;; Caras de encabezado de markdown-mode (para archivos .md)
(custom-set-faces!
  '(markdown-header-face :inherit font-lock-function-name-face :weight bold :family "variable-pitch")
  '(markdown-header-face-1 :inherit markdown-header-face :height 1.6)
  '(markdown-header-face-2 :inherit markdown-header-face :height 1.5)
  '(markdown-header-face-3 :inherit markdown-header-face :height 1.4)
  '(markdown-header-face-4 :inherit markdown-header-face :height 1.3)
  '(markdown-header-face-5 :inherit markdown-header-face :height 1.2)
  '(markdown-header-face-6 :inherit markdown-header-face :height 1.1))

;; IMPORTANTE: `doom-font' y `doom-variable-pitch-font' deben fijarse al nivel
;; superior del archivo (NUNCA dentro de un `after!'). Doom lee estas
;; variables una sola vez al arrancar, en `doom-init-fonts-h'; si las pones
;; dentro de `(after! org ...)' se fijan demasiado tarde (org solo carga
;; cuando abres el primer .org, ya después de que Doom inicializó las
;; fuentes) y por eso seguía viéndose JetBrains Mono en todos lados.
(setq doom-font (font-spec :family "JetBrains Mono" :size 15))
;; Fuente serif para el texto de lectura/prosa de tus notas.
;; Cambia "Noto Serif" por la serif que tengas instalada si prefieres otra
;; (p. ej. "Georgia", "EB Garamond", "Liberation Serif").
(setq doom-variable-pitch-font (font-spec :family "Noto Serif" :size 16))

(after! org
  (add-hook 'org-mode-hook #'hl-todo-mode)

  ;; OJO: antes esto estaba en `(custom-theme-set-faces! 'doom-one ...)', pero
  ;; tu tema activo es `matugen', no `doom-one' — por eso nunca se aplicaba.
  ;; `custom-set-faces!' (sin nombre de tema) se aplica encima de CUALQUIER
  ;; tema activo.
  ;;
  ;; Usamos alturas ABSOLUTAS (en décimas de punto: 200 = 20pt) para todos los
  ;; niveles, en vez de multiplicadores relativos (":height 1.6"). Los
  ;; multiplicadores se calculan sobre la fuente que hereda cada cara — como
  ;; `outline-N' hereda del `default' MONOESPACIADO (15pt), un heading
  ;; profundo con multiplicador 1.0 terminaba más chico que el texto normal,
  ;; que sí usa la serif de 20pt vía `mixed-pitch-mode'. Con números absolutos
  ;; los headings siempre son >= que el cuerpo del texto (20pt), como debe ser.
  (custom-set-faces!
    '(org-document-title :height 230 :bold t :underline nil :family "Noto Serif")
    '(org-level-1 :inherit outline-1 :height 170 :weight bold :family "Noto Serif")
    '(org-level-2 :inherit outline-2 :height 160 :weight bold :family "Noto Serif")
    '(org-level-3 :inherit outline-3 :height 150 :family "Noto Serif")
    '(org-level-4 :inherit outline-3 :height 140 :family "Noto Serif")
    '(org-level-5 :inherit outline-3 :height 130 :family "Noto Serif")
    '(org-level-6 :inherit outline-3 :height 120 :family "Noto Serif")
    '(org-level-7 :inherit outline-3 :height 120 :family "Noto Serif")
    '(org-level-8 :inherit outline-3 :height 120 :family "Noto Serif")
    '(org-list-dt :family "Noto Serif"))

  ;; --- Look "Obsidian / Markdown" para los .org --------------------------
  (setq org-hide-emphasis-markers t)      ; oculta *negrita*, /cursiva/, etc.
  (setq org-pretty-entities t)            ; renderiza símbolos LaTeX/UTF-8
  (setq org-startup-indented t)           ; indentación tipo outline limpia
  (setq org-startup-with-inline-images t) ; muestra imágenes al abrir el archivo
  (setq org-image-actual-width '(400))
  (setq org-ellipsis " ▾")

  (add-hook 'org-mode-hook #'org-indent-mode)
  (add-hook 'org-mode-hook #'visual-line-mode)

  ;; Quitar los números de línea SOLO en los .org (el resto de buffers, como
  ;; código, conservan `display-line-numbers-type' definido arriba)
  (add-hook 'org-mode-hook (lambda () (display-line-numbers-mode -1))))

;; mixed-pitch-mode aplica la fuente serif (`doom-variable-pitch-font') solo
;; al texto de prosa, y deja tablas, bloques de código, verbatim/código en
;; línea y drawers con la fuente monoespaciada. Esto es lo que corrige el
;; desalineado de las tablas: con una fuente proporcional en TODO el buffer
;; una tabla nunca puede alinearse, porque cada carácter tiene un ancho
;; distinto. Requiere añadir en $DOOMDIR/packages.el:
;;   (package! mixed-pitch)
(use-package! mixed-pitch
  :hook (org-mode . mixed-pitch-mode)
  :config
  (setq mixed-pitch-set-height t) ; usa el tamaño de doom-variable-pitch-font
  (dolist (face '(org-table
                  org-table-row
                  org-formula
                  org-code
                  org-verbatim
                  org-block
                  org-block-begin-line
                  org-block-end-line
                  org-meta-line
                  org-document-info-keyword
                  org-special-keyword
                  org-drawer
                  org-property-value
                  org-tag
                  line-number
                  line-number-current-line))
    (add-to-list 'mixed-pitch-fixed-pitch-faces face)))

;; visual-fill-column centra el texto y limita su ancho, igual que la vista
;; de lectura de Obsidian, en vez de estirarse de borde a borde de la
;; ventana. Requiere añadir en $DOOMDIR/packages.el:
;;   (package! visual-fill-column)
(use-package! visual-fill-column
  :hook (org-mode . visual-fill-column-mode)
  :init
  (setq visual-fill-column-width 100     ; ancho del "papel" en columnas
        visual-fill-column-center-text t))

;; org-modern le da a org-mode una apariencia moderna (encabezados limpios,
;; viñetas redondeadas, tablas con bordes suaves, checkboxes bonitos), muy
;; similar a Obsidian/Markdown. Si el paquete no está instalado, añade en
;; $DOOMDIR/packages.el la línea: (package! org-modern)
(use-package! org-modern
  :hook (org-mode . org-modern-mode)
  :config
  (setq
   org-modern-checkbox '((?X . "☑") (?- . "◐") (?\s . "☐"))
   org-modern-table t
   org-modern-block-fringe nil
   org-modern-hide-stars t))

(use-package! super-save
  :config
  ;; Enable super-save globally
  (super-save-mode +1)

  ;; Save when Emacs loses focus, switching windows, or switching buffers
  (setq super-save-auto-save-when-idle t
        super-save-idle-duration 5 ; Save after 5 seconds of idle time
        super-save-max-buffer-size 10000000) ; Limit to ~10MB files

  ;; Optional: Silence the "File saved" spam in the minibuffer
  (setq super-save-silent t)
  )
;;
;; wep
;;; -----------------------------------------------------------------------
;;; Notas finales de Doom (documentación original, sin modificar)
;;; -----------------------------------------------------------------------

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
