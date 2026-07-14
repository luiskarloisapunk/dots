{config, pkgs, ...}:

{
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
