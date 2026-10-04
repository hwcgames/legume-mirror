#!/usr/bin/env nix-shell
#!nix-shell -p just -i 'just -f' -p godotPackages_4_7.godot-mono -p zip
set unstable

all: linux-zip windows-zip

push: linux-push windows-push

clean:
    rm -r build

channel := "devel"

linux-push: linux
    butler push build/linux handlewithcaregames/hwcrpg:linux-{{channel}}

windows-push: windows
    butler push build/windows handlewithcaregames/hwcrpg:windows-{{channel}}

linux-zip: linux
    cd build/linux; zip -r9 ../linux.zip .

windows-zip: windows
    cd build/windows; zip -r9 ../windows.zip .

linux: licenses
    mkdir -p build/linux
    cp -r build/licenses/* build/linux
    godot-mono --headless --verbose --export-release "linux"

windows: licenses
    mkdir -p build/windows
    cp -r build/licenses/* build/windows
    godot-mono --headless --verbose --export-release "windows"

macos: licenses
    mkdir -p build/macos
    cp -r build/licenses/* build/macos
    godot-mono --headless --verbose --export-release "macos"

linux-rust:
    #!/usr/bin/env bash
    cd rs
    cargo b --target x86_64-unknown-linux-gnu
    cargo b --release --target x86_64-unknown-linux-gnu

windows-rust:
    #!/usr/bin/env bash
    cd rs
    cargo b --target x86_64-pc-windows-gnu
    cargo b --release --target x86_64-pc-windows-gnu

[script]
licenses: 
    mkdir -p build/licenses/lib-licenses
    touch build/.gdignore
    cp LICENSE build/licenses/LICENSE.txt
    for addon in `ls addons`
    do
        cp addons/$addon/LICENSE* build/licenses/lib-licenses/$addon.txt || true
    done
