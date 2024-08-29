Import-Dotenv $PSScriptRoot\config.env -AllowClobber
ls -Recurse -Filter *.template | % { 
    $OutPath=Join-Path (Resolve-Path -RelativeBasePath . $_.Directory) (Split-Path -LeafBase  $_.FullName);
    ~/.bin/envsubst -o "$OutPath" -i "$_"
}