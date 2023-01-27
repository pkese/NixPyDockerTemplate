# { pkgs ? import <nixpkgs> { overlays = [ (import ./nix_files/overlay.nix) ]; } }:
# { pkgs ? import <nixpkgs> {} }:
{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/tags/22.11.tar.gz") {} }:
let
  dockerImageName = "nixpysample";

  # python packages required for both docker and development
  commonPythonPkgs = (py: with py; [
    pymc
    fastapi
    uvicorn
    gunicorn
  ]);

  # additional python packages requred only for development
  devPythonPkgs = (py: with py; [
    httpx
    pytest
  ]);

  packages = rec {

    inherit dockerImageName;

    # development shell environment
    devShell = pkgs.mkShell {
      # fix missing locales
      LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
      packages = [
        (pkgs.python3.withPackages (py: (commonPythonPkgs py) ++ (devPythonPkgs py)))
        # other system packages needed for development
        pkgs.cmake # needed by Makefile
        # pkgs.git
      ];
    };

    #dockerImage = pkgs.dockerTools.streamLayeredImage {
    dockerImage = pkgs.dockerTools.buildLayeredImage {
      name = dockerImageName;
      tag = "latest";
      contents = [
        pkgs.bash # for interactive shell (make dockerShell)
        pkgs.gcc # pymc/aesara requires g++
        (pkgs.python3.withPackages commonPythonPkgs)
        ./app # source code (contents get copied to root of the image without /app prefix)
      ]; 
      config = {
        Cmd = [ "gunicorn" "-k" "uvicorn.workers.UvicornWorker" "--workers=2" "--bind" "0.0.0.0:8000" "main:app" ];
        ExposedPorts = { "8000/tcp" = {}; };
      };
      maxLayers = 6;
    };
  };
in
  packages
