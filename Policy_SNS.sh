#!/bin/bash

#Change working directory to script's directory

#Remove previous input/output files if any
rm -rf SNS_Topics.txt policy.txt SNS.csv

#Extract a list of all SNS topics for the account
aws sns list-topics --region us-east-1 --output text --query 'Topics[]' > SNS_Topics.txt

chmod u+x SNS_Topics.txt

#Read ARNs of topics from file
topics="SNS_Topics.txt"

while IFS= read -r arn
do
	#Extract ARN policy
	aws sns get-topic-attributes --region us-east-1 --topic-arn "$arn" --query 'Attributes.Policy' > policy.txt
	printf "\n"
	cat policy.txt

	#Principal is set to wildcard - POTENTIALLY VULNERABLE
	if grep -q "AWS:\*" policy.txt
	then
		#Condition clause is used with wildcard - NOT VULNERABLE (WHITE)
		if grep -q 'Condition' policy.txt
		then
			echo -e "$arn:\033[1;37m NOT VULNERABLE \033[0m"
			echo "$arn,NOT VULNERABLE" >> SNS.csv
		else
			#Condition clause is not used with wildcard - VULNERABLE (RED)
			echo -e "$arn:\033[1;31m VULNERABLE \033[0m"
			echo "$arn,VULNERABLE" >> SNS.csv
		fi
	else
		#Wildcard not used in Principal - NOT VULNERABLE (WHITE)
		echo -e "$arn:\033[1;37m NOT VULNERABLE \033[0m"
		echo "$arn,NOT VULNERABLE" >> SNS.csv
	fi
done < "$topics"

rm -rf SNS_topics.txt policy.txt

printf "\n"
echo "Output stored in csv file SNS.csv"
