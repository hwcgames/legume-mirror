{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    godot-overlay.url = "github:florianvazelle/godot-overlay";
    godot-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    godot-overlay,
    flake-utils,
  }: let
    systems = ["i686-linux" "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    outputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [godot-overlay.overlays.default];
      };
    in rec {
      # packages = import ./default.nix {inherit system pkgs;};
      # apps.default = flake-utils.lib.mkApp {drv = packages.default;};
      devShells.default = with pkgs;
      with xorg; let
        deps = [
          godotpkgs."4_5_1_stable"
          alsa-lib
          libGL
          vulkan-loader
          libX11
          libXcursor
          libXext
          libXfixes
          libXi
          libXinerama
          libxkbcommon
          libXrandr
          libXrender
          libdecor
          wayland
          dbus
          dbus.lib
          fontconfig
          fontconfig.lib
          libpulseaudio
          speechd-minimal
          udev
          cmake
          zig_0_13
          mesa
        ];
      in
        mkShell {
          nativeBuildInputs = deps;
          LD_LIBRARY_PATH = lib.makeLibraryPath deps;
        };
    });
  in
    outputs
    // {
    };
}
