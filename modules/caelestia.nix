{config, pkgs, ...}:

{
xdg.configFile."caelestia/templates/matugen-theme.el".text = ''
;;; matugen-theme.el --- Theme usando variables de Caelestia Shell

(deftheme matugen "Tema dinámico generado por Caelestia Shell.")

(let* ((bg "#{{ surface.hex }}")
       (on-background "#{{ onSurface.hex }}")
       (primary "#{{ primary.hex }}")
       (primary-container "#{{ primaryContainer.hex }}")
       (on-primary-container "#{{ onPrimaryContainer.hex }}")
       (secondary "#{{ secondary.hex }}")
       (secondary-container "#{{ secondaryContainer.hex }}")
       (on-secondary-container "#{{ onSecondaryContainer.hex }}")
       (tertiary "#{{ tertiary.hex }}")
       (tertiary-container "#{{ tertiaryContainer.hex }}")
       (on-tertiary-container "#{{ onTertiaryContainer.hex }}")
       (err "#{{ error.hex }}")
       (err-container "#{{ errorContainer.hex }}")
       (on-err-container "#{{ onErrorContainer.hex }}")
       (surface "#{{ surface.hex }}")
       (surface-variant "#{{ surfaceVariant.hex }}")
       (surface-container "#{{ surfaceContainer.hex }}")
       (surface-container-low "#{{ surfaceContainerLow.hex }}")
       (surface-container-high "#{{ surfaceContainerHigh.hex }}")
       (surface-container-highest "#{{ surfaceContainerHighest.hex }}")
       (outline-color "#{{ outline.hex }}")
       (outline-variant "#{{ outlineVariant.hex }}")
       (on-surface "#{{ onSurface.hex }}")
       (on-surface-variant "#{{ onSurfaceVariant.hex }}")
       (primary-fixed "#{{ primaryFixed.hex }}")
       (primary-fixed-dim "#{{ primaryFixedDim.hex }}")
       (secondary-fixed "#{{ secondaryFixed.hex }}")
       (secondary-fixed-dim "#{{ secondaryFixedDim.hex }}")
       (tertiary-fixed "#{{ tertiaryFixed.hex }}")
       (tertiary-fixed-dim "#{{ tertiaryFixedDim.hex }}"))

  (custom-theme-set-faces
   'matugen
   ;; Basic faces
   `(default ((t (:background ,bg :foreground ,on-background))))
   `(cursor ((t (:background ,secondary))))
   `(highlight ((t (:background ,primary-container :foreground ,on-primary-container))))
   `(region ((t (:background ,surface-container-highest :foreground nil :extend t))))
   `(secondary-selection ((t (:background ,secondary-container :foreground ,on-secondary-container :extend t))))
   `(isearch ((t (:background ,tertiary-container :foreground ,on-tertiary-container :weight bold))))
   `(lazy-highlight ((t (:background ,secondary-container :foreground ,on-secondary-container))))
   `(vertical-border ((t (:foreground ,surface-container))))
   `(border ((t (:background ,surface-container :foreground ,surface-container))))
   `(fringe ((t (:background ,bg :foreground ,outline-variant))))
   `(shadow ((t (:foreground ,outline-variant))))
   `(link ((t (:foreground ,primary :underline t))))
   `(link-visited ((t (:foreground ,tertiary :underline t))))
   `(success ((t (:foreground ,tertiary))))
   `(warning ((t (:foreground ,secondary))))
   `(error ((t (:foreground ,err))))
   `(match ((t (:background ,secondary-container :foreground ,on-secondary-container))))
   
   ;; Font-lock (Sintaxis)
   `(font-lock-builtin-face ((t (:foreground ,primary))))
   `(font-lock-comment-face ((t (:foreground ,outline-color :slant italic))))
   `(font-lock-comment-delimiter-face ((t (:foreground ,outline-variant))))
   `(font-lock-constant-face ((t (:foreground ,tertiary :weight bold))))
   `(font-lock-doc-face ((t (:foreground ,on-surface-variant :slant italic))))
   `(font-lock-function-name-face ((t (:foreground ,primary-fixed :weight bold))))
   `(font-lock-keyword-face ((t (:foreground ,secondary :weight bold))))
   `(font-lock-string-face ((t (:foreground ,tertiary-fixed-dim))))
   `(font-lock-type-face ((t (:foreground ,primary-fixed-dim))))
   `(font-lock-variable-name-face ((t (:foreground ,on-surface))))
   `(font-lock-warning-face ((t (:foreground ,err :weight bold))))
   `(font-lock-preprocessor-face ((t (:foreground ,secondary-fixed-dim))))
   `(font-lock-negation-char-face ((t (:foreground ,tertiary-fixed))))

   ;; Modeline (Barra de estado)
   `(mode-line ((t (:background ,surface-container-low :foreground ,on-surface :box nil))))
   `(mode-line-inactive ((t (:background ,bg :foreground ,on-surface-variant :box nil))))
   `(mode-line-buffer-id ((t (:foreground ,primary :weight bold))))
   
   ;; Solaire-mode (Para compatibilidad completa con la interfaz de Doom)
   `(solaire-default-face ((t (:background ,bg :foreground ,on-background))))
   `(solaire-fringe-face ((t (:background ,bg :foreground ,outline-variant))))
   `(solaire-hl-line-face ((t (:background ,surface-container))))

   ;; Line numbers
   `(line-number ((t (:foreground ,outline-variant :inherit fixed-pitch))))
   `(line-number-current-line ((t (:foreground ,primary :weight bold :inherit fixed-pitch))))

   ;; Org-mode
   `(org-block ((t (:background ,surface-container-low :extend t :inherit fixed-pitch))))
   `(org-block-begin-line ((t (:background ,surface-container-low :foreground ,primary-fixed-dim :extend t :slant italic :inherit fixed-pitch))))
   `(org-block-end-line ((t (:background ,surface-container-low :foreground ,primary-fixed-dim :extend t :slant italic :inherit fixed-pitch))))
   `(org-code ((t (:background ,surface-container-low :foreground ,tertiary-fixed :inherit fixed-pitch))))
   `(org-hide ((t (:foreground ,bg))))

   ;; Rainbow delimiters
   `(rainbow-delimiters-depth-1-face ((t (:foreground ,primary))))
   `(rainbow-delimiters-depth-2-face ((t (:foreground ,secondary))))
   `(rainbow-delimiters-depth-3-face ((t (:foreground ,tertiary))))
   `(rainbow-delimiters-depth-4-face ((t (:foreground ,primary-fixed))))
   `(rainbow-delimiters-depth-5-face ((t (:foreground ,secondary-fixed))))
   `(rainbow-delimiters-depth-6-face ((t (:foreground ,tertiary-fixed))))
   `(rainbow-delimiters-depth-7-face ((t (:foreground ,primary-fixed-dim))))
   ))

(provide-theme 'matugen)
'';
xdg.configFile."caelestia/templates/kitty.conf".text = ''
  foreground            #{{ onSurface.hex }}
  background            #{{ surface.hex }}
  cursor                #{{ secondary.hex }}
  selection_background  #{{ secondary.hex }}

  # Normal Colors
  color0  #{{ term0.hex }}
  color1  #{{ term1.hex }}
  color2  #{{ term2.hex }}
  color3  #{{ term3.hex }}
  color4  #{{ term4.hex }}
  color5  #{{ term5.hex }}
  color6  #{{ term6.hex }}
  color7  #{{ term7.hex }}

  # Bright Colors
  color8  #{{ term8.hex }}
  color9  #{{ term9.hex }}
  color10 #{{ term10.hex }}
  color11 #{{ term11.hex }}
  color12 #{{ term12.hex }}
  color13 #{{ term13.hex }}
  color14 #{{ term14.hex }}
  color15 #{{ term15.hex }}
'';
  programs.caelestia = {
    enable = true;
    systemd = {
      enable = false; # if you prefer starting from your compositor
      target = "graphical-session.target";
      environment = [];
    };

    settings = {
      appearance ={
        padding.scale=.7;
        font = {
          scale = .93;
          clock = "Bitcount Grid Double";
        };
        anim.durations.scale = .8;
      };
      
      general = {
        apps= {
          terminal = ["foot"];
          explorer = ["yazi"];
        };
        idle= {
          lockBeforeSleep = false;
          timeouts = [];
        };

      };


      bar = {
        scrollActions = {
          workspaces = false;
          volume = false ;
          brightness = false;
        };
        workspaces = {
          occupiedBg= true;
          showWindows= false;


        };
        activeWindow.compact = true;
        tray.compact = true;
        status = {
          showBattery = false;
          showBluetooth = false;
        };
        clock = {
          showDate = true;
          showIcon = false;
        };
        
      };
      
      border.thickness = 4;

      lock.enabled = false;

      dashboard = {
        showPerformance = false;
        showWeather = false;
        resourceUpdateInterval = 100;
        dragThreshold = 20;
      };

      launcher = {
        showOnHover = true ;
        enableDangerousActions = true;
        dragThreshold = 10;
        useFuzzy= {
          apps = true;
          actions =  true;
          schemes = true;
          variants = true;
          wallpapers = true;
        };

      };

      notifs.groupPreviewNum = 1;
      
      osd.enableBrightness = false;

      services = {
        weatherLocation= "Culiacán";
        useFahrenheit = false;
        useTwelveHourClock = true;
      };

      utilities = {
        maxToasts=2;
        toasts.configLoaded= false;
        toasts.capsLockChanged= true;
        quickToggles = [
                     {
                id= "wifi";
                enabled= true;
            }
            {
                id= "bluetooth";
                enabled= true;
            }
            {
                id= "mic";
                enabled= true;
            }
            {
                id= "settings";
                enabled= false;
            }
            {
                id= "gameMode";
                enabled= true;
            }
            {
                id= "dnd";
                enabled= true;
            }
            {
                id= "vpn";
                enabled= false;
            }

        ];
      };

    
      paths.wallpaperDir = "${config.home.homeDirectory}/.dots/config/walls/";
      paths.mediaGif = "";
      paths.sessionGif = "${config.home.homeDirectory}/.dots/config/session.gif";
     }; 


    cli = {
        enable = true; # Also add caelestia-cli to path
        settings = {
        theme = {
          enableHypr = true;
          enableGtk = true;
          enableDiscord = false;
          enableSpicetify = true;

        };
      };
    };

  };





}
