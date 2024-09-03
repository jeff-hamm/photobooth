param([string]$EnvFile="$PSScriptRoot\config.butts.env")
Import-Dotenv "$EnvFile" -AllowClobber
ls -Recurse -Filter *.template | % { 
    $OutPath=Join-Path (Resolve-Path -RelativeBasePath . $_.Directory) (Split-Path -LeafBase  $_.FullName);
    ~/.bin/envsubst -o "$OutPath" -i "$_"
}
$GradioImport="@gradio\client\dist"
$GradioPath="$PSScriptRoot\web\js\$GradioImport"
mkdir $GradioPath -ErrorAction SilentlyContinue
cp "$PSScriptRoot\node_modules\$GradioImport\index.js*" "$GradioPath" -Force
npm run tsc
flutter build web
mkdir "..\ButtsBlazor\ButtsBlazor\wwwroot\photobooth\" -Force
cp -Recurse  .\build\web\* "..\ButtsBlazor\ButtsBlazor\wwwroot\photobooth\" -Force
pushd "..\ButtsBlazor"
try {
    ./push.ps1
}
finally{
    popd
}