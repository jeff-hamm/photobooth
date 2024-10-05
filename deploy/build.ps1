$P = Resolve-Path "$PSScriptRoot\.."
pushd $p/protobooth
. "./build.ps1" -EnvFile "$p\protobooth/config.offline.env"
cp -Recurse  "$P/protobooth/build/web/*" "$P\ButtsBlazor\ButtsBlazor\wwwroot\booth\" -Force
popd