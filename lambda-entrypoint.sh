#!/bin/sh

# Vérifie si le Runtime Interface Emulator (RIE) existe
if [ -x "/aws-lambda-rie" ]; then
  echo "Starting AWS Lambda Runtime Interface Emulator (RIE)..."
  exec /aws-lambda-rie python3 -m awslambdaric "$_HANDLER"
else
  echo "Running Lambda directly without RIE..."
  exec python3 -m awslambdaric "$_HANDLER"
fi
