;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;; -----------------------------------------------------------------------
;;; 1. AJUSTES BÁSICOS
;;; -----------------------------------------------------------------------
(setq display-line-numbers-type t)
(setq confirm-kill-emacs nil)

;;; -----------------------------------------------------------------------
;;; 2. TEMA: Caelestia / Matugen
;;; -----------------------------------------------------------------------
(add-to-list 'custom-theme-load-path "/home/lk/.local/state/caelestia/theme/")
(setq doom-theme 'matugen)

(defun my/reload-caelestia-theme ()
  (interactive)
  (load-theme 'matugen t)
  (message "¡Tema dinámico de Matugen recargado!"))

(require 'filenotify)
(defvar my/caelestia-theme-watcher nil)

(defun my/watch-caelestia-theme-changes ()
  (let ((theme-dir "/home/lk/.local/state/caelestia/theme/"))
    (when my/caelestia-theme-watcher
      (ignore-errors (file-notify-rm-watch my/caelestia-theme-watcher)))
    (when (file-directory-p theme-dir)
      (setq my/caelestia-theme-watcher
            (file-notify-add-watch theme-dir '(change)
                                   (lambda (event)
                                     (let ((action (nth 1 event)) (file (nth 2 event)))
                                       (when (and (string= (file-name-nondirectory file) "matugen-theme.el")
                                                  (memq action '(changed created renamed)))
                                         (run-with-timer 0.2 nil #'my/reload-caelestia-theme)))))))))

(add-hook 'window-setup-hook #'my/watch-caelestia-theme-changes)

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

  ;; --- Flujo de Clase (Sesión) ---
  (defvar my/org-roam-clase--cache nil)

  (defun my/org-roam-clase-filter (node) (member "Materia" (org-roam-node-tags node)))

  (defun my/org-roam-clase-count (materia-title)
    (let ((count 0) (re-materia (regexp-quote materia-title)))
      (dolist (file (org-roam-list-files))
        (when (file-readable-p file)
          (with-temp-buffer
            (insert-file-contents file)
            (when (and (re-search-forward "^#\\+filetags:.*:Clase:" nil t)
                       (progn (goto-char (point-min)) (re-search-forward (format "^:MATERIA:.*%s" re-materia) nil t)))
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
                 (setq prof-hoy (cond ((> (length prof-tags) 1) (completing-read "¿Profesor?: " prof-tags nil t))
                                      ((= (length prof-tags) 1) (car prof-tags)) (t nil))
                       submateria nil))))
      (let* ((semana (read-number "Semana (1-15): "))
             (periodo (format "P%d" (1+ (/ (1- semana) 5))))
             (sesion (1+ (my/org-roam-clase-count materia-title))))
        (setq my/org-roam-clase--cache (list :codigo codigo :semestre semestre :semana semana :periodo periodo
                                             :sesion sesion :materia-title materia-title :materia-id materia-id
                                             :profesor prof-hoy :submateria submateria)))
      ""))

  ;; --- Configuración de Captura ---
  (setq org-roam-capture-templates
        `(("u" "Universidad")
          ("um" "Materia (Hub)" plain "%?" :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" ,(my/read-template-file "~/coco/templates/materiaTemplate.org")) :unnarrowed t)
          ("uc" "Clase" plain "%?" :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" ,(my/read-template-file "~/coco/templates/claseTemplate.org")) :unnarrowed t)
          ("p" "Problemas (ICPC/OMUM)" plain (file "~/coco/templates/problemTemplate.org") :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: :Competitiva:\n") :unnarrowed t)
          ("e" "Escritura" plain "* %?\n\n#+begin_verse\n\n#+end_verse" :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: :Escritura:\n") :unnarrowed t)
          ("b" "book notes" plain (file "~/coco/templates/bookTemplate.org") :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n") :unnarrowed t)))

  (setq org-roam-dailies-capture-templates '(("d" "default" entry "* %<%I:%M %p>: \n%?" :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))

  ;; --- Auto-indexar Clases ---
  (defun my/org-roam-link-clase-to-materia ()
    (when (and (boundp 'org-capture-plist) (string= (plist-get org-capture-plist :key) "uc") (not org-note-abort))
      (let* ((cap-buffer (org-capture-get :buffer)) (new-file (and cap-buffer (buffer-file-name cap-buffer)))
             (materia-title (my/org-roam-clase-get :materia-title)) (semana (my/org-roam-clase-get :semana))
             (sesion (my/org-roam-clase-get :sesion)) real-title node-id link-str)
        (when (and new-file (file-exists-p new-file))
          (with-current-buffer (find-file-noselect new-file) (setq node-id (org-id-get-create)) (save-buffer))
          (org-roam-db-update-file new-file))
        (setq link-str (format "- Semana %s, Sesión %s: [[id:%s][%s]]\n" semana sesion node-id (plist-get org-capture-plist :description)))
        (let* ((materia-node (org-roam-node-from-title-or-alias materia-title)) (materia-file (when materia-node (org-roam-node-file materia-node))))
          (when materia-file (with-current-buffer (find-file-noselect materia-file)
                               (goto-char (point-max)) (insert link-str) (save-buffer)))))))

  (add-hook 'org-capture-after-finalize-hook #'my/org-roam-link-clase-to-materia))

;;; -----------------------------------------------------------------------
;;; 5. TAREAS Y AGENDA
;;; -----------------------------------------------------------------------
(after! org
  (defun my/org-roam-copy-todo-on-done-hook ()
    (when (equal org-state "DONE") (ignore-errors (my/org-roam-copy-todo-to-today))))
  (add-hook 'org-after-todo-state-change-hook #'my/org-roam-copy-todo-on-done-hook))

(after! org-roam
  (defun my/org-roam-filter-by-tag (tag-name) (lambda (node) (member tag-name (org-roam-node-tags node))))
  (defun my/org-roam-refresh-agenda-list () (setq org-agenda-files (mapcar #'org-roam-node-file (seq-filter (my/org-roam-filter-by-tag "Project") (org-roam-node-list)))))
  (my/org-roam-refresh-agenda-list))
