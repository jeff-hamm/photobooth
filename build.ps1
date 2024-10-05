param([string]$EnvFile,[switch]$Metadata,[switch]$Compile, [switch]$Push)
if(!$EnvFile){
    if($Push) {
        $EnvFile="$PSScriptRoot\config.butts.env"
    } else {
        $EnvFile="$PSScriptRoot\config.env"
    }
}
Import-Dotenv "$EnvFile" -AllowClobber -Verbose

if($Metadata) {
    bash "./tool/generate_asset_metadata.sh"
}

ls -Recurse -Filter *.template | % { 
    $OutPath=Join-Path (Resolve-Path -RelativeBasePath . $_.Directory) (Split-Path -LeafBase  $_.FullName);
    ~/.bin/envsubst -o "$OutPath" -i "$_"
}
$GradioImport="@gradio\client\dist"
$GradioPath="$PSScriptRoot\web\js\$GradioImport"
mkdir $GradioPath -ErrorAction SilentlyContinue
cp "$PSScriptRoot\node_modules\$GradioImport\index.js*" "$GradioPath" -Force
npm run tsc
dart run build_runner build --delete-conflicting-outputs

if ($Compile -or $Push) {   
    flutter build web --no-web-resources-cdn
    if ($Push) {
        mkdir "..\ButtsBlazor\ButtsBlazor\wwwroot\booth\" -Force
        cp -Recurse  .\build\web\* "..\ButtsBlazor\ButtsBlazor\wwwroot\booth\" -Force
        pushd "..\deploy"
        try {
            ./push.ps1
        }
        finally{
            popd
        }
    }
}