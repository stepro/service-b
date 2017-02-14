#!/bin/bash
set -e

CONFIG=${1:-dev}
if [ "$CONFIG" == "dev" ]; then
  CONFIG=Debug
fi

echo Building...

dotnet restore
dotnet publish -c $CONFIG -o out

echo Build completed
