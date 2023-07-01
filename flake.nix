{
  description = "ffmpeg with mpp";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      packages = forAllSystems
        ({ pkgs }: rec {
          mpp =
            pkgs.stdenv.mkDerivation {

              name = "mpp";
              src = pkgs.fetchFromGitHub {
                owner = "rockchip-linux";
                repo = "mpp";
                rev = "ae444a6cb5cde1116ea523ed31b0e5cc13a0b536";
                hash = "sha256-v60tEf0mNnOF+nJvExbdI2tgxHqxznlqoHEqq/n97UM=";
              };
              buildInputs = [ pkgs.cmake ];

              cmakeFlags = [
                "-DCMAKE_BUILD_TYPE=Release"
                "-DHAVE_DRM=ON"
                "-DCMAKE_INSTALL_LIBDIR=lib"
                "-DCMAKE_INSTALL_INCLUDEDIR=include"
                "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
                "-DAVSD_TEST:BOOL=OFF"
                "-DCMAKE_BUILD_TYPE:STRING=None"
                "-DH264D_TEST:BOOL=OFF"
                "-DH265D_TEST:BOOL=OFF"
                "-DJPEGD_TEST:BOOL=OFF"
                "-DMPI_DEC_TEST:BOOL=OFF"
                "-DMPI_ENC_TEST:BOOL=OFF"
                "-DMPI_RC2_TEST:BOOL=OFF"
                "-DMPI_RC_TEST:BOOL=OFF"
                "-DMPI_TEST:BOOL=OFF"
                "-DMPP_BUFFER_TEST:BOOL=OFF"
                "-DMPP_ENV_TEST:BOOL=OFF"
                "-DMPP_INFO_TEST:BOOL=OFF"
                "-DMPP_LOG_TEST:BOOL=OFF"
                "-DMPP_MEM_TEST:BOOL=OFF"
                "-DMPP_PACKET_TEST:BOOL=OFF"
                "-DMPP_PLATFORM_TEST:BOOL=OFF"
                "-DMPP_TASK_TEST:BOOL=OFF"
                "-DMPP_THREAD_TEST:BOOL=OFF"
                "-DRKPLATFORM:BOOL=ON"
                "-DVP9D_TEST:BOOL=OFF"
                "-DVPU_API_TEST:BOOL=OFF"
                "-DHAVE_DRM:BOOL=ON"
                "-Wno-dev"
              ];
            };
          ffmpeg-mpp = pkgs.ffmpeg.overrideAttrs
            (oldAttrs: {
              buildInputs = oldAttrs.buildInputs ++ [ mpp ];
              configureFlags = oldAttrs.configureFlags ++ [ "--enable-rkmpp" ];
            });
          default = ffmpeg-mpp;
        });
    };
}
