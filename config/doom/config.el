;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;; -----------------------------------------------------------------------
;;; 1. AJUSTES BÁSICOS
;;; -----------------------------------------------------------------------
(setq display-line-numbers-type t)
(setq confirm-kill-emacs nil)

;;; -----------------------------------------------------------------------
;;; 2. TEMA: Caelestia / Matugen
;;; -----------------------------------------------------------------------
;;(add-to-list 'custom-theme-load-path "/home/lk/.local/state/caelestia/theme/")
;;(setq doom-theme 'matugen)
;;
;;(defun my/reload-caelestia-theme ()
;;  (interactive)
;;  (load-theme 'matugen t)
;;  (message "¡Tema dinámico de Matugen recargado!"))
;;
;;(require 'filenotify)
;;(defvar my/caelestia-theme-watcher nil)
;;
;;(defun my/watch-caelestia-theme-changes ()
;;  (let ((theme-dir "/home/lk/.local/state/caelestia/theme/"))
;;    (when my/caelestia-theme-watcher
;;      (ignore-errors (file-notify-rm-watch my/caelestia-theme-watcher)))
;;    (when (file-directory-p theme-dir)
;;      (setq my/caelestia-theme-watcher
;;            (file-notify-add-watch theme-dir '(change)
;;                                   (lambda (event)
;;                                     (let ((action (nth 1 event)) (file (nth 2 event)))
;;                                       (when (and (string= (file-name-nondirectory file) "matugen-theme.el")
;;                                                  (memq action '(changed created renamed)))
;;                                         (run-with-timer 0.2 nil #'my/reload-caelestia-theme)))))))))
;;
;;(add-hook 'window-setup-hook #'my/watch-caelestia-theme-changes)

(add-to-list 'custom-theme-load-path "/home/lk/.local/state/caelestia/theme/")
(setq doom-theme 'matugen)
(require 'filenotify)
(defvar my/matugen-watcher nil)
(defvar my/matugen-timer nil)

(defun my/watch-matugen-theme ()
  "Vigila la carpeta y recarga el tema sin importar cómo guarde Matugen."
  (interactive)
  ;; Limpiar watcher previo si existe
  (when my/matugen-watcher
    (ignore-errors (file-notify-rm-watch my/matugen-watcher)))

  (let ((dir (file-truename "/home/lk/.local/state/caelestia/theme/")))
    (if (not (file-directory-p dir))
        (message "ERROR DE VIGILANCIA: No se encuentra la carpeta %s" dir)
      (setq my/matugen-watcher
            (file-notify-add-watch
             dir '(change)
             (lambda (event)
               ;; Convertimos TODO el evento en texto para evitar fallos de índice
               (let ((event-str (format "%S" event)))
                 ;; Si el evento menciona "matugen" en cualquier parte:
                 (when (string-match-p "matugen" event-str)
                   ;; Cancelamos el temporizador anterior si hay ráfagas de escrituras
                   (when (timerp my/matugen-timer)
                     (cancel-timer my/matugen-timer))
                   ;; Programamos la recarga 0.5 segundos después del último evento
                   (setq my/matugen-timer
                         (run-with-timer 0.0 nil (lambda ()
                                                   (message "¡Recargando tema Matugen!")
                                                   (doom/reload-theme)))))))))
      (message "Vigilando cambios en: %s" dir))))

;; Activar al terminar de iniciar Doom Emacs
(add-hook 'doom-after-init-hook #'my/watch-matugen-theme)



;;; -----------------------------------------------------------------------
;;; 3. ORG / ORG-ROAM: directorios y configuración base
;;; -----------------------------------------------------------------------
(setq org-roam-directory "~/coco/")
(setq org-roam-dailies-directory "journal/")

(after! org
  (setq org-preview-latex-default-process 'dvisvgm)
  (plist-put org-format-latex-options :scale 1.3)
  (setq org-startup-with-latex-preview t))

(after! org-appear
  (setq org-appear-autoorg-latex t)
  (setq org-appear-trigger 'manual)
  (add-hook 'org-mode-hook 'org-appear-mode))

;;; -----------------------------------------------------------------------
;;; 4. ORG-ROAM: funciones auxiliares y plantillas (Dentro de after! org-roam)
;;; -----------------------------------------------------------------------
(after! org-roam

  ;; --- Utilidades de saneamiento ---
  (defvar my/spanish-day-abbrevs ["dom" "lun" "mar" "mié" "jue" "vie" "sáb"])

  (defun my/org-fecha-inactiva ()
    (let* ((now (decode-time))
           (dow (nth 6 now))
           (dia (aref my/spanish-day-abbrevs dow)))
      (format-time-string (format "[%%Y-%%m-%%d %s %%H:%%M]" dia))))

  (defun my/org-tag-sanitize (str)
    (replace-regexp-in-string "[^[:alnum:]_@#]" "" (replace-regexp-in-string "[[:space:]]+" "" str)))

  (defun my/read-template-file (path)
    (with-temp-buffer (insert-file-contents (expand-file-name path)) (buffer-string)))

  (defun my/org-dir-sanitize (str)
    (let ((clean (replace-regexp-in-string "[^[:alnum:]]" "_" str)))
      (replace-regexp-in-string "_+" "_" clean)))

  (defun my/parse-prof-sub-string (raw-str)
    (let ((items (split-string raw-str "," t "[ \t]+")))
      (mapcar (lambda (item)
                (let* ((parts (split-string item ":" t "[ \t]+"))
                       (prof (string-trim (car parts)))
                       (sub (if (> (length parts) 1) (string-trim (cadr parts)) nil)))
                  (cons prof sub)))
              items)))

  (defun my/org-roam-node-property (node prop-name)
    (cdr (assoc-string prop-name (org-roam-node-properties node) t)))

  ;; --- Flujo de Materia (Hub) ---
  (defvar my/org-roam-materia--cache nil)

  (defun my/org-roam-materia-init ()
    (let* ((semestre (completing-read "Semestre: " '("S1" "S2" "S3" "S4" "S5" "S6" "S7" "S8") nil t))
           (nombre (read-string "Nombre completo de la materia: "))
           (prof-sub-raw (read-string "Profesor(es)[Juancho: Matemáticas, ...]: "))
           (prof-sub-list (my/parse-prof-sub-string prof-sub-raw))
           (profesores-list (delete-dups (mapcar #'car prof-sub-list)))
           (submaterias-list (delete-dups (delq nil (mapcar #'cdr prof-sub-list))))
           (periodos (string-to-number (completing-read "Número de periodos: " '("1" "2" "3") nil t)))
           (es-reto (and submaterias-list t))
           (codigo (if (boundp 'org-roam-capture--node) (org-roam-node-title org-roam-capture--node) (read-string "Código: ")))
           (codigo-clean (replace-regexp-in-string "[[:space:]]+" "_" codigo)))
      (setq my/org-roam-materia--cache
            (list :semestre semestre :nombre nombre :prof-sub-raw prof-sub-raw :prof-sub-list prof-sub-list
                  :profesores profesores-list :submaterias submaterias-list :periodos periodos
                  :es-reto es-reto :codigo codigo-clean))
      (my/create-materia-directories semestre codigo-clean periodos submaterias-list)
      ""))

  (defun my/create-materia-directories (semestre codigo periodos submaterias)
    (let* ((base-dir (expand-file-name (format "~/academic/un/%s/%s/" semestre codigo))))
      (make-directory (concat base-dir "Material") t)
      (make-directory (concat base-dir "Trabajos") t)
      (dolist (sub submaterias) (make-directory (format "%sMaterial/%s" base-dir (my/org-dir-sanitize sub)) t))
      (dotimes (i periodos) (make-directory (format "%sTrabajos/P%d" base-dir (1+ i)) t))))

  (defun my/org-roam-materia-get (key) (plist-get my/org-roam-materia--cache key))

  (defun my/org-roam-materia-filetags ()
    "Genera etiquetas: :Materia:S1:Reto:Juan_Perez:Ana_Lopez:
Ya NO se agregan tags de submateria; esa relación vive únicamente en la
propiedad SUBMATERIAS del drawer."
    (let* ((sem (my/org-roam-materia-get :semestre))
           (profs (my/org-roam-materia-get :profesores))
           (reto-tag (if (my/org-roam-materia-get :es-reto) "Reto:" ""))
           (prof-tags (mapconcat (lambda (p) (format "%s:" (my/org-dir-sanitize p))) profs "")))
      (format ":Materia:%s:%s%s" sem reto-tag prof-tags)))

  (defun my/org-roam-materia-property-submaterias ()
    "String crudo 'Amelia: Matematicas, Edgar: Fisica' para :SUBMATERIAS:.
Vacío si la materia no tiene ninguna submateria."
    (if (my/org-roam-materia-get :submaterias)
        (or (my/org-roam-materia-get :prof-sub-raw) "")
      ""))

  (defun my/org-roam-materia-property-profesores ()
    "Profesores separados por coma para :PROFESOR: (ej. 'Amelia, Edgar')."
    (mapconcat #'identity (or (my/org-roam-materia-get :profesores) '()) ", "))

  ;; --- Flujo de Clase (Sesión) ---
  (defvar my/org-roam-clase--cache nil)

  (defun my/org-roam-clase-get (key) (plist-get my/org-roam-clase--cache key))

  (defun my/org-roam-clase-filter (node) (member "Materia" (org-roam-node-tags node)))

  (defun my/org-roam-clase-count (materia-title &optional submateria)
    "Cuenta las Clases ya creadas para MATERIA-TITLE. Si SUBMATERIA no es
nil, cuenta solo las de esa submateria, para que la Sesión se numere por
separado por submateria (Matemáticas Sesión 1, 2... y Física Sesión
1, 2... aunque sean de la misma Materia)."
    (let ((count 0)
          (re-materia (regexp-quote materia-title))
          (re-submateria (and submateria (regexp-quote submateria))))
      (dolist (file (org-roam-list-files))
        (when (file-readable-p file)
          (with-temp-buffer
            (insert-file-contents file)
            (goto-char (point-min))
            (when (and (re-search-forward "^#\\+filetags:.*:Clase:" nil t)
                       (progn (goto-char (point-min))
                              (re-search-forward (format "^:MATERIA:.*%s" re-materia) nil t))
                       (or (not re-submateria)
                           (progn (goto-char (point-min))
                                  (re-search-forward
                                   (format "^:SUBMATERIA:[ \t]*%s[ \t]*$" re-submateria) nil t))))
              (setq count (1+ count))))))
      count))

  (defun my/org-roam-clase-init ()
    (let* ((materia (org-roam-node-read nil #'my/org-roam-clase-filter nil t "Materia: "))
           (materia-title (org-roam-node-title materia))
           (materia-id (org-roam-node-id materia))
           (materia-tags (org-roam-node-tags materia))
           (codigo (my/org-tag-sanitize materia-title))
           (semestre (or (seq-find (lambda (tag) (string-match-p "\\`S[0-9]+\\'" tag)) materia-tags) "SX"))
           (prof-sub-raw (my/org-roam-node-property materia "SUBMATERIAS"))
           (pairs (and prof-sub-raw (not (string-empty-p prof-sub-raw)) (my/parse-prof-sub-string prof-sub-raw)))
           (pairs-con-sub (seq-filter #'cdr pairs))
           (profesores (and pairs (delete-dups (mapcar #'car pairs))))
           prof-hoy submateria)
      (cond ((and pairs-con-sub (> (length profesores) 1))
             (let* ((opciones (mapcar #'cdr pairs-con-sub))
                    (seleccion (completing-read "Submateria de hoy: " opciones nil t))
                    (elegido (nth (or (seq-position opciones seleccion #'string=) 0) pairs-con-sub)))
               (setq prof-hoy (car elegido) submateria (cdr elegido))))
            (pairs (setq prof-hoy (caar pairs) submateria (cdar pairs)))
            (t (let ((prof-tags (seq-filter (lambda (tag) (not (member tag (list "Materia" "Reto" semestre)))) materia-tags)))
                 (setq prof-hoy (cond ((> (length prof-tags) 1) (completing-read "¿Qué profesor impartió hoy?: " prof-tags nil t))
                                      ((= (length prof-tags) 1) (car prof-tags)) (t nil))
                       submateria nil))))
      (let* ((semana (read-number "Semana actual de clases (1-15): "))
             (periodo (format "P%d" (1+ (/ (1- semana) 5))))
             (sesion (1+ (my/org-roam-clase-count materia-title submateria))))
        (setq my/org-roam-clase--cache (list :codigo codigo :semestre semestre :semana semana :periodo periodo
                                             :sesion sesion :materia-title materia-title :materia-id materia-id
                                             :profesor prof-hoy :submateria submateria)))
      ""))

  (defun my/org-roam-clase-filetags ()
    (let ((prof-tag (if (my/org-roam-clase-get :profesor)
                        (format "%s:" (my/org-dir-sanitize (my/org-roam-clase-get :profesor)))
                      ""))
          (sub-tag (if (my/org-roam-clase-get :submateria)
                       (format "%s:" (my/org-dir-sanitize (my/org-roam-clase-get :submateria)))
                     "")))
      (format ":Clase:%s:%s:%s%sSemana%d:%s:"
              (my/org-roam-clase-get :codigo)
              (my/org-roam-clase-get :semestre)
              prof-tag
              sub-tag
              (my/org-roam-clase-get :semana)
              (my/org-roam-clase-get :periodo))))

  (defun my/org-roam-clase-materia-link ()
    "Enlace [[id:...][Título]] a la Materia (no se rompe si la renombras)."
    (format "[[id:%s][%s]]" (my/org-roam-clase-get :materia-id) (my/org-roam-clase-get :materia-title)))

  (defun my/org-roam-clase-sesion () (number-to-string (my/org-roam-clase-get :sesion)))

  (defun my/org-roam-clase-profesor () (or (my/org-roam-clase-get :profesor) ""))

  (defun my/org-roam-clase-submateria () (or (my/org-roam-clase-get :submateria) ""))

  ;; --- Configuración de Captura ---
  (setq org-roam-capture-templates
        `(("u" "Universidad")
          ("um" "Materia (Hub)" plain "%?" :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" ,(my/read-template-file "~/coco/templates/materiaTemplate.org")) :unnarrowed t)
          ("uc" "Clase" plain "%?" :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" ,(my/read-template-file "~/coco/templates/claseTemplate.org")) :unnarrowed t)
          ("p" "Problemas (ICPC/OMUM)" plain (file "~/coco/templates/problemTemplate.org") :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: :Competitiva:\n") :unnarrowed t)
          ("e" "Escritura" plain "* %?\n\n#+begin_verse\n\n#+end_verse" :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: :Escritura:\n") :unnarrowed t)
          ("b" "book notes" plain (file "~/coco/templates/bookTemplate.org") :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n") :unnarrowed t)))

  (setq org-roam-dailies-capture-templates '(("d" "default" entry "* %<%I:%M %p>: \n%?" :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n")))))

;;; -----------------------------------------------------------------------
;;; 5. ORG-ROAM: funciones personalizadas de captura
;;; -----------------------------------------------------------------------

;;; --- Auto-indexar Clases a Materia (Hub) ---
(defun my/org-roam-link-clase-to-materia ()
  "Vincula la nota de Clase recién creada al archivo de su Materia Hub.
Se ejecuta en `org-capture-after-finalize-hook' si se usó la plantilla de Clase."
  (interactive)
  (when (and (boundp 'org-capture-plist)
             (string= (plist-get org-capture-plist :key) "uc")
             (not org-note-abort))
    (let* ((cap-buffer (org-capture-get :buffer))
           (new-file (and cap-buffer (buffer-file-name cap-buffer)))
           (materia-title (my/org-roam-clase-get :materia-title))
           (semana (my/org-roam-clase-get :semana))
           (sesion (my/org-roam-clase-get :sesion))
           (submateria (my/org-roam-clase-get :submateria))
           (sub-label (if submateria (format " [%s]" submateria) ""))
           real-title
           node-id
           link-str)

      ;; 1. Extraemos el Título Real y garantizamos que exista un :ID:
      ;; (goto-char point-min ANTES de org-id-get-create: si no, y el cursor
      ;; queda bajo un heading del cuerpo al terminar la captura, Org le crea
      ;; un :ID: nuevo a ESE heading en vez de reusar el del archivo, dejando
      ;; un segundo :PROPERTIES: duplicado y un link apuntando al ID
      ;; equivocado.)
      (when (and new-file (file-exists-p new-file))
        (with-current-buffer (find-file-noselect new-file)
          (save-excursion
            (goto-char (point-min))
            (when (re-search-forward "^#\\+title:[ \t]*\\(.*\\)$" nil t)
              (setq real-title (string-trim (match-string 1)))))
          (goto-char (point-min))
          (setq node-id (org-id-get-create))
          (save-buffer))
        (org-id-add-location node-id new-file)
        (org-roam-db-update-file new-file))

      (unless real-title
        (setq real-title (plist-get org-capture-plist :description)))

      ;; 2. Construimos el enlace (con [Submateria] si aplica)
      (setq link-str
            (if node-id
                (format "- Semana %s, Sesión %s%s: [[id:%s][%s]]\n" semana sesion sub-label node-id real-title)
              (format "- Semana %s, Sesión %s%s: [[roam:%s]]\n" semana sesion sub-label real-title)))

      ;; 3. Insertamos el enlace en la Materia Hub, bajo el heading de
      ;; Clases/Sesiones/Bitácora si existe, o creándolo si no
      (let* ((materia-node (org-roam-node-from-title-or-alias materia-title))
             (materia-file (when materia-node (org-roam-node-file materia-node))))
        (if (and materia-file (file-exists-p materia-file))
            (with-current-buffer (find-file-noselect materia-file)
              (save-excursion
                (goto-char (point-min))
                (if (re-search-forward "^\\*+ \\(Clases\\|Sesiones\\|Bitácora\\)" nil t)
                    (progn
                      (org-end-of-subtree t t)
                      (unless (bolp) (insert "\n")))
                  (goto-char (point-max))
                  (unless (bolp) (insert "\n"))
                  (insert "* Clases\n"))
                (insert link-str)
                (save-buffer)))
          (message "No se pudo autoindexar: No se encontró el archivo de la materia '%s'" materia-title))))))

(add-hook 'org-capture-after-finalize-hook #'my/org-roam-link-clase-to-materia)

;;; --- Captura rápida de tareas de Proyecto ---
(defun my/org-roam-capture-task ()
  (interactive)
  ;; Agrega el archivo del proyecto a la agenda cuando termine la captura
  (add-hook 'org-capture-after-finalize-hook #'my/org-roam-project-finalize-hook)
  ;; Captura la tarea, creando el archivo del proyecto si hace falta
  (org-roam-capture- :node (org-roam-node-read
                            nil
                            (my/org-roam-filter-by-tag "Project"))
                     :templates '(("p" "project" plain "** TODO %?"
                                   :if-new (file+head+olp "%<%Y%m%d%H%M%S>-${slug}.org"
                                                          "#+title: ${title}\n#+category: ${title}\n#+filetags: Project"
                                                          ("Tasks"))))))

(global-set-key (kbd "C-c n t") #'my/org-roam-capture-task)

;;; --- Captura rápida al Inbox ---
(defun my/org-roam-capture-inbox ()
  (interactive)
  (org-roam-capture- :node (org-roam-node-create)
                     :templates '(("i" "inbox" plain "* %?"
                                   :if-new (file+head "Inbox.org" "#+title: Inbox\n")))))

(global-set-key (kbd "C-c n b") #'my/org-roam-capture-inbox)

;;; --- Insertar nodo sin abrirlo (finaliza la captura de inmediato) ---
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
;;; 8. APARIENCIA DE ORG / MARKDOWN (estilo Obsidian para tomar notas)
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
;; variables una sola vez al arrancar, en `doom-init-fonts-h'.
(setq doom-font (font-spec :family "JetBrains Mono" :size 15))
(setq doom-variable-pitch-font (font-spec :family "Noto Serif" :size 16))

(after! org
  (add-hook 'org-mode-hook #'hl-todo-mode)

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

  (setq org-hide-emphasis-markers t)
  (setq org-pretty-entities t)
  (setq org-startup-indented t)
  (setq org-startup-with-inline-images t)
  (setq org-image-actual-width '(400))
  (setq org-ellipsis " ▾")

  (add-hook 'org-mode-hook #'org-indent-mode)
  (add-hook 'org-mode-hook #'visual-line-mode)
  (add-hook 'org-mode-hook (lambda () (display-line-numbers-mode -1))))

(use-package! mixed-pitch
  :hook (org-mode . mixed-pitch-mode)
  :config
  (setq mixed-pitch-set-height t)
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

(use-package! visual-fill-column
  :hook (org-mode . visual-fill-column-mode)
  :init
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t))

(use-package! org-modern
  :hook (org-mode . org-modern-mode)
  :config
  (setq
   org-modern-checkbox '((?X . "☑") (?- . "◐") (?\s . "☐"))
   org-modern-table t
   org-modern-block-fringe nil
   org-modern-hide-stars t))

;;; -----------------------------------------------------------------------
;;; 9. KEYBINDINGS: org-roam
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
        ))
