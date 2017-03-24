console.log("Loading function");
var AWS = require("aws-sdk");

exports.handler = function(event, context) {
    // var eventText = JSON.stringify(event, null, 2);
    // console.log("Received event:", eventText);
    var sns = new AWS.SNS();
    
    var endPointParams = {
        PlatformApplicationArn : "arn:aws:sns:us-east-1:717363038630:app/APNS_SANDBOX/Dr.Text",
        Token : "FF4E886A20E8F7EBB856377F6BD71E829BBB51AA40D48CD5B533C426804FA122"
    };
    sns.createPlatformEndpoint(endPointParams,function(err,data){
        if(err){
            console.log(err);
        }
        else{
            console.log("Platform end point created",data);
            var params = {
                Message: "Sending from lambda function...", 
                Subject: "Test SNS From Lambda",
                TargetArn: data.EndpointArn
            };
            
            sns.publish(params, context.done);
        }
    });
};