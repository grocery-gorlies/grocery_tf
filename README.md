# grocery_tf

## Immediate todo's:

1. ~~figure out lambda error handling~~  
* ~~setting retries for asynchronous~~  
* ~~cloudwatch logging for synchronous~~  
2. ~~create s3 bucket for layer sc~~  
3. ~~set up lambda layer~~   
4. set up dummy file  

## Next steps:

1) set up api gateway (lambda proxy vs normal?)
* test if makes it to cloudwatch to confirm
* one endpoint for adding data, one for pulling
2) s3 for saving user input data
* means adding bucket module and lambda permissions for write?
* test if request writes to s3
3) set up dynamodb (when to use rds vs dynamo db?)
* test if row inserted into dynamodb
* create lambdas - one for inserting to dynamo db, one for getting results 
4) figure out documentation at the end (open api)
5) refine cloudwatch monitoring to send alerts
6) SQS dlq needed for failures? or is cloudwatch enough