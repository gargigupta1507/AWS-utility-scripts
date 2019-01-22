#!/bin/bash

#Change working directory to script's directory

#Remove previous input/output files if any
rm -rf Bucket_Names.txt TagList.csv

#Extract a list of all bucket names
aws s3api list-buckets --output text --query "Buckets[].[Name]" > Bucket_Names.txt

chmod u+x Bucket_Names.txt

#Read bucket names from file
names="Bucket_Names.txt"

#Prevent script from exiting in case tag is not found
set +e

while IFS= read -r name
do
	printf "\n$name  -------------> "
	
	#Attempt to extract Client Data Classification tag
	classification="$(aws s3api get-bucket-tagging --bucket $name --output text --query 'TagSet[?Key==`Client.DataClassification`].Value[]')"
		
	#Print tag information to console
	printf $classification"\n"
	
	#Check if tag was not found and set NoSuchTagSet in value when writing to output file
	if [ -z "$classification" ]
	then
		echo "$name,NoSuchTagSet" >> TagList.csv
	else
		echo $name,$classification >> TagList.csv
	fi

done < "$names"

rm -rf Bucket_Names.txt

printf "\n"
echo "Output stored in TagList.csv"
