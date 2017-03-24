console.log("Loading function");
var aws = require("aws-sdk");

exports.handler = (event, context, callback) => {
    var ddb = new aws.DynamoDB({endpoint: 'https://dynamodb.us-west-2.amazonaws.com/',
     params: {TableName: 'User'}});

    var docClient = new aws.DynamoDB.DocumentClient();
    console.log(event);
    var emailID = event.emailId;
    var profilePic = event.profilePicUrl;
    var code = randomStringFn();

            var params = {
                TableName:'User',
                Key:{
                    "userName": emailID
                },
                UpdateExpression: "set ProfilePicUrl = :r",
                ExpressionAttributeValues:{
                    ":r":profilePic
                },
                ReturnValues:"UPDATED_NEW"
            };
            
            docClient.update(params, function(err, data) {
                if (err) {
                    context.done(err, 'failed');
                }
                else {
                    console.log("updated data: ", params);
                    console.log(data);
                    callback(null, 'success');   
                }
            });


        function randomStringFn() {
    	var chars = "0123456789";
    	var string_length = 6;
    	var randomstring = '';
    	for (var i=0; i<string_length; i++) {
    		var rnum = Math.floor(Math.random() * chars.length);
    		randomstring += chars.substring(rnum,rnum+1);
    	}
    	return randomstring;
    }
    
};