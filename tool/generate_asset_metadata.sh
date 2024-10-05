#!/bin/bash

# Script used to analyze bundled assets and generate a dart file which contains
# the relevant metadata needed at runtime without forcing the application to
# download the assets.
#
# Usage:
# ./tool/generate_asset_metadata.sh > lib/assets.g.dart

set -e

output_metadata () {
    width=$(identify -format "%w" "$1" | tail -n1 | cut -d" " -f4)
    height=$(identify -format "%h" "$1" | tail -n1 | cut -d" " -f4)
    filepath=$1
    name=$(basename "${filepath%.*}")

    echo "Asset(name: '$name', path: '$1', size: Size($width, $height));"
}

echo "// GENERATED CODE - DO NOT MODIFY BY HAND"
echo ""
echo "import 'package:flutter/widgets.dart';"
echo "import 'package:io_photobooth/common/widgets.dart';"
echo ""
echo "class Assets {"

# characters=("android.png" "dash.png" "dino.png" "sparky.png")

# for character in "${characters[@]}"
# do
#     path="assets/images/$character"
#     width=$(identify -format "%w" "$path" | tail -n1 | cut -d" " -f4)
#     height=$(identify -format "%h" "$path" | tail -n1 | cut -d" " -f4)    
#     name=$(basename "${path%.*}")
#     echo "  static const $name = Asset(name: '$name', path: '$path', size: Size($width, $height),);"
# done

echo "  static const characters = {"

for character in "${characters[@]}"
do
    path="assets/images/$character"
    width=$(identify -format "%w" "$path" | tail -n1 | cut -d" " -f4)
    height=$(identify -format "%h" "$path" | tail -n1 | cut -d" " -f4)    
    name=$(basename "${path%.*}")
    echo "  Asset(name: '$name', path: '$path', size: Size($width, $height),),"
done


echo "  };"

# googleProps=assets/props/google/*.png

# echo "  static const googleProps = {"
# for prop in $googleProps
# do    
#     width=$(identify -format "%w" "$prop" | tail -n1 | cut -d" " -f4)
#     height=$(identify -format "%h" "$prop" | tail -n1 | cut -d" " -f4)    
#     name=$(basename "${prop%.*}")
#     echo "    Asset(name: '$name', path: '$prop', size: Size($width, $height),),"
# done

# echo "  };"

customProps=assets/props/custom/*.png

echo "  static const customProps = {"
for prop in $customProps
do    
    width=$(identify -format "%w" "$prop" | tail -n1 | cut -d" " -f4)
    height=$(identify -format "%h" "$prop" | tail -n1 | cut -d" " -f4)    
    name=$(basename "${prop%.*}")
    echo "    Asset(name: '$name', path: '$prop', size: Size($width, $height),),"
done

echo "  };"

hatProps=assets/props/hats/*.png

echo "  static const hatProps = {"
for prop in $hatProps
do    
    width=$(identify -format "%w" "$prop" | tail -n1 | cut -d" " -f4)
    height=$(identify -format "%h" "$prop" | tail -n1 | cut -d" " -f4)    
    name=$(basename "${prop%.*}")
    echo "    Asset(name: '$name', path: '$prop', size: Size($width, $height),),"
done

echo "  };"

eyewearProps=assets/props/eyewear/*.png

echo "  static const eyewearProps = {"
for prop in $eyewearProps
do    
    width=$(identify -format "%w" "$prop" | tail -n1 | cut -d" " -f4)
    height=$(identify -format "%h" "$prop" | tail -n1 | cut -d" " -f4)    
    name=$(basename "${prop%.*}")
    echo "    Asset(name: '$name', path: '$prop', size: Size($width, $height),),"
done

echo "  };"

foodProps=assets/props/food/*.png

echo "  static const foodProps = {"
for prop in $foodProps
do    
    width=$(identify -format "%w" "$prop" | tail -n1 | cut -d" " -f4)
    height=$(identify -format "%h" "$prop" | tail -n1 | cut -d" " -f4)    
    name=$(basename "${prop%.*}")
    echo "    Asset(name: '$name', path: '$prop', size: Size($width, $height),),"
done

echo "  };"

shapeProps=assets/props/shapes/*.png

echo "  static const shapeProps = {"
for prop in $shapeProps
do    
    width=$(identify -format "%w" "$prop" | tail -n1 | cut -d" " -f4)
    height=$(identify -format "%h" "$prop" | tail -n1 | cut -d" " -f4)    
    name=$(basename "${prop%.*}")
    echo "    Asset(name: '$name', path: '$prop', size: Size($width, $height),),"
done

echo "  };"

echo "  static const props = {...customProps, ...eyewearProps, ...hatProps, ...foodProps, ...shapeProps};"
echo "  "
echo "  static const randomProps = {...customProps};"
echo "}"