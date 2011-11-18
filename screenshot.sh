#!/bin/bash
. ./settings.sh

# Output a fatal error message and exit
# Parameters: Error message to show, and error code to return
# Side-effects: Exits the application with error code
fatalError()
{
	echo -e "\e[00;31mERROR: $1\e[00m"
	exit $2
}

subDir="$(date +$subDirFormat)"
dir="$baseDir$subDir"
fileName="$(date +$filenameFormat)"
filePath="$dir$fileName"
mkdir -p $dir || fatalError "Could not create directory $dir" 1

# Take screenshot via scrot
scrot -s "$filePath" || fatalError "Could not create screenshot" 2

# Upload with FTP
ftp -invp -z secure $ftpHost << EOF
user $ftpUser $ftpPass
mkdir /$subDir
cd /$subDir
put $filePath $fileName
bye
EOF

url="$baseUrl$subDir$fileName"

# Copy to clipboard and display URL
echo "$url" | xclip -selection clipboard
echo $url
notify-send "Uploaded screenshot: $url"
