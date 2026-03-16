{
  stdenv,
  blender,
  godotPackages_4_6,
  zip,
  dotnetCorePackages,
}:
stdenv.mkDerivation {
  pname = "legume-traffick";
  version = "0.0.1-demo";
  src = ./.;

  nativeBuildInputs = [
    godotPackages_4_6.godot-mono
    blender
    zip
    dotnetCorePackages.dotnet_9.sdk
  ];

  buildPhase = ''
    mkdir ./home-for-now
    export HOME=`realpath home-for-now`
    mkdir -p ~/.local/share/godot/
    ln -s ${godotPackages_4_6.export-templates-mono-bin}/share/godot/export_templates ~/.local/share/godot/
    mkdir -p $out
    godot4.6-mono --headless --export-release "Windows Desktop" $out/lt.exe
    godot4.6-mono --headless --export-release Linux $out/lt.x86_64
    rm -r home-for-now
  '';
}
