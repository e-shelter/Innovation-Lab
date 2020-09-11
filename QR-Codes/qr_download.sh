#!/bin/bash

# Author: Matteo Lugaresi
# Date: 14.08.2020
# Purpose: Given a URL, generate and download the corresponding QR-Codes via an on-line service 

generate_post_data()
{
  cat <<EOF
{
"data":"$url",
"config": {
	"body":"square",
	"eye":"frame0",
	"eyeBall":"ball0",
	"erf1":[],
	"erf2":[],
	"erf3":[],
	"brf1":[],
	"brf2":[],
	"brf3":[],
	"bodyColor":"#000000",
	"bgColor":"#FFFFFF",
	"eye1Color":"#000000",
	"eye2Color":"#000000",
	"eye3Color":"#000000",
	"eyeBall1Color":"#000000",
	"eyeBall2Color":"#000000",
	"eyeBall3Color":"#000000",
	"gradientColor1":"",
	"gradientColor2":"",
	"gradientType":"linear",
	"gradientOnEyes":"true",
	"logo":"$logo",
	"logoMode":"default"
	},
"size":1000,
"download":"imageUrl",
"file":"png"
}
EOF
}


# Upload an image that will be used as a logo for the QR code

logo=$(curl -v -F 'file=@logo.jpg' -H 'Content-Type: multipart/form-data' https://qr-generator.qrcode.studio/qr/uploadimage)
logo=$(echo "$logo" | cut -f 4 -d "\"")
echo "Result: $logo"

# Read the input text file with QR names and URLs to be embedded

while IFS= read -r line
do
	name=$(echo "$line" | cut -f 1 -d " ")
	url=$(echo "$line" | cut -f 2 -d " ")
	
	qr=$(curl --header "Content-Type: application/json" \
	--request POST \
	--data "$(generate_post_data)" \
	https://qr-generator.qrcode.studio/qr/custom)
	
	echo "Logo: $logo"
	echo "QR response: $qr"
	
	qr=$(echo "$qr" | cut -f 2 -d ":" | tr -d "{}\"\\")
	
	echo "QR URL: http:$qr"
	
	curl "https:$qr" -o images/${name}.png
	
	sleep 2
	
done < input.txt

