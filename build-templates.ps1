Import-Dotenv $PSScriptRoot\config.env -AllowClobber
ls -Recurse -Filter *.template | % { 
    $OutPath=Join-Path (Resolve-Path -RelativeBasePath . $_.Directory) (Split-Path -LeafBase  $_.FullName);
    ~/.bin/envsubst -o "$OutPath" -i "$_"
}
$GradioImport="@gradio\client\dist"
$GradioPath="$PSScriptRoot\web\js\$GradioImport"
mkdir $GradioPath -ErrorAction SilentlyContinue
cp "$PSScriptRoot\node_modules\$GradioImport\index.js*" "$GradioPath" -Force