{config,pkgs,lib,...}:

{
  home.activation = {
    crearEsqueletoArchivos = let
      directorios = [
        "coco"               # Tu repositorio único de Org-roam
        "downloads"           # Zona de descarga temporal
        "academic"            # Almacén de archivos universitarios por año
        "projects"            # Proyectos de programación y desarrollo
        "library/books"       # PDFs, EPUBs y material de estudio ajeno
        "library/media"       # Películas, música, juegos
        "library/datasets"    # Datos brutos (data science, etc.)
        "personal/id"
        "personal/academic"
        "personal/finance"
        "personal/health"
        "personal/legal"
      ];
      
      comandosMkdir = builtins.concatStringsSep "\n" 
        (map (dir: "mkdir -p \$HOME/${dir}") directorios);
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        echo "Asegurando el esqueleto de directorios del usuario..."
        ${comandosMkdir}
      '';
  };







}
