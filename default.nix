# { pkgs ? import <nixpkgs> { overlays = [ (import ./nix_files/overlay.nix) ]; } }:

#{ pkgs ? import <nixpkgs> {} }:
{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/tags/22.11.tar.gz" ) {} }:
let
  packages = rec {

    # python packages required for both docker and development
    commonPythonPackages = (p: with p; [
      requests
      pymc
      fastapi
      numpyro
      pydantic
      requests
      uvicorn
      gunicorn
    ]);

    # additional python packages requred for development
    devPythonPackages = (p:
      commonPythonPackages p
      ++ (with p; [
        httpx
        pytest
     ])
    );

    devShell = pkgs.mkShell {
      # fix missing locales
      LOCALE_ARCHIVE =
        "${pkgs.glibcLocales}/lib/locale/locale-archive";

      packages = [
        (pkgs.python3.withPackages devPythonPackages)
        pkgs.cmake # ... example of other package needed for development
      ];
    };

    # base python interpreter (for docker)
    dockerPythonEnv = pkgs.python3.withPackages commonPythonPackages;

    # lower layer of docker image (don't rebuild this for each source code change)
    baseDockerImage = pkgs.dockerTools.buildImage {
      name = "python-img";
      tag = "latest";
      #created = "now";
      copyToRoot = pkgs.buildEnv {
        name = "python-img";
        paths = [
          #pkgs.busybox # /bin/sh inside container
          #pkgs.bash # for interactive shell (make shell)
          pkgs.gcc # pymc/aesara requires g++
          #pkgs.mkl # mkl libraries are unfree
          dockerPythonEnv
          #pkgs.curl # test web request inside container
        ];
        pathsToLink = [ "/bin" ];
      };
    };

    #dockerImage = pkgs.dockerTools.streamLayeredImage {
    #dockerImage = pkgs.dockerTools.buildImage {
    dockerImage = pkgs.dockerTools.buildLayeredImage {
      name = "pyhello";
      tag = "latest";
      #created = "now";
      fromImage = baseDockerImage;
      #copyToRoot = pkgs.buildEnv {
      #  name = "image-root";
      #  paths = [ ./app ]; # gets copied to root of the image (without /app prefix)
        #pathsToLink = [ "/bin" ];
      #};
      contents = [ ./app ]; # gets copied to root of the image (without /app prefix)
      config = {
        #Env = [ "PYTHONPATH=${dockerPythonEnv}/${dockerPythonEnv.sitePackages}" ];
        Cmd = [ "/bin/gunicorn" "-k" "uvicorn.workers.UvicornWorker" "--workers=2" "--bind" "0.0.0.0:8000" "main:app" ];
        ExposedPorts = { "8000/tcp" = {}; };
      };

      #diskSize = 1024;
      #buildVMMemorySize = 512;
    };
  };
in
  packages

# > nix-store -q $(which sqlite3)
# to find location of executable

# nix-shell -A devShell
# nix-build -A dockerImage | docker load
