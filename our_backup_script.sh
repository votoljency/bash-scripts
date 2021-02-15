#! /bin/bash

DATE=$(date +%d-%m-%Y)
# Date in format DAY##-MONTH##-YEAR####

mkdir -p ~/archive/$DATE
# create a folder for today's date in the archive, if archive doesn't exist, make archive 
ls -al ~/Documents > ~/archive/$DATE/contents.txt
# create a text file listing the contents of the documents folder
cd ~/  && tar -cpzf $DATE.docs.backup.gz Documents/*
# change to parent directory to tar /Documents folder
cp ~/$DATE.docs.backup.gz ~/archive/$DATE/documents_archive.gz
# one .gz file is left in the home directory, a clone is sent to our archive under it's date