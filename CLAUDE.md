# Dotfiles — CLAUDE.md

Repo de configuración NixOS para múltiples hosts usando flakes + home-manager.

## Estructura

```
.dots/
├── flake.nix                    # Entrypoint: inputs y outputs para todos los hosts
├── flake.lock
├── CLAUDE.md                    # Este archivo
│
├── hosts/                       # Configuración específica por máquina
│   ├── AM/                      # Desktop principal (x86_64-linux)
│   │   ├── configuration.nix    # NixOS: hostname, boot, stateVersion
│   │   ├── hardware-configuration.nix
│   │   └── home.nix             # Home-manager: importa módulos + fija username/stateVersion
│   ├── laptop/                  # Laptop (stub — agregar hardware-configuration.nix al configurar)
│   │   ├── configuration.nix
│   │   └── home.nix
│   └── phone/                   # Android via nix-on-droid (stub)
│       └── home.nix             # Solo módulos CLI, sin desktop
│
├── modules/
│   ├── nixos/                   # Módulos NixOS (nivel sistema)
│   │   ├── common.nix           # nix settings, GC, usuarios, neovim, firefox
│   │   ├── desktop.nix          # Hyprland, pipewire, ly, bluetooth, mango
│   │   └── syncthing.nix        # Servicio syncthing (todos los hosts lo importan)
│   └── home/                    # Módulos home-manager (nivel usuario)
│       ├── common.nix           # git, bash, aliases, xdg symlinks, dir skeleton
│       ├── desktop.nix          # kitty, cursor, yazi desktop entry, mimeApps
│       ├── packages.nix         # home.packages del desktop (neovim, emacs, etc.)
│       ├── caelestia.nix        # Caelestia shell + templates matugen
│       └── spicetify.nix        # Spicetify con extensiones
│
└── config/                      # Archivos de configuración de programas (simbólicos)
    ├── doom/                    # Doom Emacs
    ├── hypr/                    # Hyprland
    ├── mango/                   # MangoWM
    ├── nvim/                    # Neovim
    ├── quickshell/              # Quickshell
    ├── walls/                   # Wallpapers (caelestia los lee desde aquí)
    └── session.gif
```

## Convenciones

### ¿Qué va dónde?

| Tipo de config | Ubicación |
|---|---|
| Configuración del sistema operativo (boot, red, servicios) | `modules/nixos/` |
| Configuración de usuario/programas | `modules/home/` |
| Lo específico de una sola máquina (hostname, hardware, stateVersion) | `hosts/<nombre>/` |
| Archivos de config que los programas leen directamente | `config/<programa>/` |

### Regla de imports

- `hosts/<nombre>/configuration.nix` importa módulos de `modules/nixos/`
- `hosts/<nombre>/home.nix` importa módulos de `modules/home/`
- Los módulos NO se importan entre sí — lo hace siempre el host
- El flake pasa `spicetify-nix` vía `extraSpecialArgs`; caelestia llega por `sharedModules`

### Symlinks en `config/`

`modules/home/common.nix` usa `config.lib.file.mkOutOfStoreSymlink` para enlazar
`~/.dots/config/<programa>` → `~/.config/<programa>`. Así los cambios en `config/`
son efectivos sin hacer rebuild. Agregar un programa nuevo:

```nix
# en modules/home/common.nix, atributo configDirs:
miApp = "mi-app";  # enlaza .dots/config/mi-app → ~/.config/mi-app
```

## Comandos

```bash
# Rebuild del host actual
nr   # alias definido en modules/home/common.nix → usa $(hostname)

# Equivalente explícito
sudo nixos-rebuild switch --flake ~/.dots#AM

# Verificar que el flake evalúa sin errores
nix flake check ~/.dots

# Abrir los dotfiles en neovim
dots
```

## Agregar un host nuevo (laptop)

1. Instalar NixOS normalmente y copiar `hardware-configuration.nix` generado a `hosts/laptop/`
2. Ajustar `networking.hostName` en `hosts/laptop/configuration.nix`
3. Descomentar `laptop = mkNixosHost { hostname = "laptop"; };` en `flake.nix`
4. Desde el laptop: `sudo nixos-rebuild switch --flake ~/.dots#laptop`

## Agregar Android (nix-on-droid)

1. Instalar la app [Nix-on-Droid](https://github.com/nix-community/nix-on-droid) desde F-Droid
2. Descomentar el bloque `nixOnDroidConfigurations.phone` en `flake.nix`
3. Ajustar paquetes en `hosts/phone/home.nix` según lo que quieras en el teléfono
4. Desde el teléfono: `nix-on-droid switch --flake ~/.dots#phone`

## Syncthing

Todos los hosts NixOS importan `modules/nixos/syncthing.nix`. Para que dos máquinas
se sincronicen, agregar en el `configuration.nix` de cada host:

```nix
services.syncthing.settings = {
  devices."nombre-del-otro-host".id = "<device-id>";
  folders."/home/lk/coco" = {
    id = "coco";
    devices = [ "nombre-del-otro-host" ];
  };
};
```

Carpetas sugeridas para sincronizar: `coco/` (org-roam), `personal/`, `library/books/`.

## Inputs del flake

| Input | Para qué |
|---|---|
| `nixpkgs` | Paquetes y módulos base (release-26.05) |
| `home-manager` | Gestión de configuración de usuario |
| `mangowm` | MangoWM (window manager) |
| `spicetify-nix` | Spicetify para Spotify |
| `caelestia-shell` | Shell de escritorio Caelestia |
| `nix-on-droid` | Soporte Android (usa su propio nixpkgs) |
