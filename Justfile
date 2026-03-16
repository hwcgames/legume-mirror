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

macos-zip: macos
    cd build/macos; zip -r9 ../macos.zip .

linux: licenses
    mkdir -p build/linux
    cp -r build/licenses/* build/linux
    godot4.6-mono --headless --verbose --export-release "linux"

windows: licenses
    mkdir -p build/windows
    cp -r build/licenses/* build/windows
    godot4.6-mono --headless --verbose --export-release "windows"

macos: licenses
    mkdir -p build/macos
    cp -r build/licenses/* build/macos
    godot4.6-mono --headless --verbose --export-release "macos"

[script]
licenses: 
    mkdir -p build/licenses/lib-licenses
    touch build/.gdignore
    cp LICENSE build/licenses/LICENSE.txt
    for addon in `ls addons`
    do
        cp addons/$addon/LICENSE* build/licenses/lib-licenses/$addon.txt || true
    done
