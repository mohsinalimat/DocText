var aws = require('aws-sdk');
var ddb = new aws.DynamoDB(
    {
        endpoint: 'https://dynamodb.us-west-2.amazonaws.com/',
        params: {TableName: 'User'}
    });
    
var docClient = new aws.DynamoDB.DocumentClient();    
exports.handler = (event, context, callback) => {
    
    //parameter validation
    if(event.emailId === null || event.emailId === '' || typeof event.emailId === 'undefined'){
        callback('Email Id cannot be empty');
    }
    var emailID = event.emailId;
    var prms = {
			Key: {
				userName: { S:  emailID}
			}
		}
	ddb.getItem(prms, function(err, data) {
        if (err) {
            console.error("Unable to read item. Error JSON:", JSON.stringify(err, null, 2));
            callback(null, 'failed');
        } else {
            console.log("GetItem succeeded:", data);
            if(data.Item && data.Item.RecoveryCode && data.Item.RecoveryCode.S.toString().trim() == event.code.toString().trim()) {
                callback(null, "success");
            } else {
                callback(null, 'failed');
            }
            
        }
    });
};