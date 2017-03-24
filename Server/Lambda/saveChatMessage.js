console.log('Loading function');
var aws = require('aws-sdk');
//aws.config.update({accessKeyId: config.AWSAccessKeyId, secretAccessKey: config.AWSSecretKey}, {region: config.AWSRegion});
var sns = new aws.SNS();
var ddb = new aws.DynamoDB(
    {endpoint: 'https://dynamodb.us-west-2.amazonaws.com/',
     params: {TableName: 'Lambdachat'}});

var docClient = new aws.DynamoDB.DocumentClient();
exports.handler = function(event, context) {
    console.log(event.Records[0].Sns);
    var message_id = event.Records[0].Sns.MessageId;
    
    
    // For now you can use these hardcoded values... tomorrow i will implement it in iOS code....
    //var applicationARN = "arn:aws:sns:us-east-1:717363038630:app/APNS_SANDBOX/Dr.Text";
    var token = "";
    
    
    console.log("Lambda function is loading and its printing");
    console.log(event.Records[0].Sns);
    console.log(event.Records[0].Sns.Message);
    
    var payload = JSON.parse(event.Records[0].Sns.Message);
    console.log("payload objec is:"+ payload);
    console.log("message objec is:"+ payload.message);
    console.log("sender ID objec is:"+ payload.senderID);
    console.log("sender ID objec is:"+ payload.firstName);
    console.log("sender ID objec is:"+ payload.lastName);
    console.log("room ID objec is:"+ payload.roomID);
    console.log("sent_time objec is:"+ payload.sent_time);
    console.log("media_url objec is:"+ payload.media_url);
    console.log("message_status objec is:"+ payload.message_status);
    console.log("chargeId objec is:"+ payload.chargeId);
    
    var chargeId = payload.chargeId;
    var message = payload.message;
    var senderID = payload.senderID;
    var roomID = payload.roomID;
    var messageType = payload.messageType;
    var sentTime = payload.sent_time;
    var serverTime = new Date().getTime().toString();
    var receiverId = payload.receiverId;
    var firstName = payload.firstName;
    var lastName = payload.lastName;
    var mediaUrl = payload.media_url;
    var message_status = payload.message_status;
    var messageObj;
    var itemParams = {Item: {message_id: {S: message_id},
                             sent_time: {S: sentTime},
                             server_time: {S: serverTime},
                             message_type: {S: messageType},
                             room_id: {S: roomID},
                             sender_id: {S: senderID},
                             media_url: {S: mediaUrl},
                             receiver_Id: {S: receiverId},
                             message_status: {S: message_status},
                             message: {S: message}}};
    ddb.putItem(itemParams, function(err, data) {
        if(err){
            context.done(err,'');
        }else{
            messageObj = data;
            console.log("MessageObj: ", messageObj);
            console.log("MessageObj: ", data);
            var params = {
                TableName:'Room_Table',
                Key:{
                    "room_id": roomID
                },
                UpdateExpression: "set lastMessage = :r, lastMessageTime=:p",
                ExpressionAttributeValues:{
                    ":r":message,
                    ":p":serverTime
                },
                ReturnValues:"UPDATED_NEW"
            };
            docClient.update(params, function(err, d) {
                console.log("updated data: ", params);
                console.log("update doc client: ", d);
                // context.done(err,'');
                var params = {
                    TableName: "DeviceToken",
                    FilterExpression:"userId = :userId",
                    ExpressionAttributeValues:{
                        ':userId' : receiverId
                    }
                };
                
                console.log("scan before param data: ", params);
                docClient.scan(params, function(e, v){
                    if(e){
                        console.log(e);
                    }else{
                        console.log("scan doc client: ", v);
                        v.Items.forEach(function(row) {
                            console.log(row.deviceToken);
                            sendPushNotification(row.deviceToken, messageObj);
                        });
                    }
                });
            });
        }
            
    });
    
    function sendPushNotification(token){
        console.log("sendPushNotification calling...");
        var endPointParams = {
            PlatformApplicationArn : "arn:aws:sns:us-east-1:717363038630:app/APNS_SANDBOX/Dr.Text",
            Token : token//"FF4E886A20E8F7EBB856377F6BD71E829BBB51AA40D48CD5B533C426804FA122"
        };
        sns.createPlatformEndpoint(endPointParams,function(err,data){
            if(err){
                console.log("Error: " + err);
            }
            else{
                console.log("endPointArn: " + data.EndpointArn);
                var payload = {
                default: firstName + " " + lastName + " : " + message,
                APNS_SANDBOX: {
                    aps: {
                        alert: firstName + " " + lastName + " : " + message,
                        "sound": 'default',
                        "content-available": '1',
                        roomId: roomID,
                        message_id: message_id,
                        sentTime: sentTime,
                        messageType: messageType,
                        senderID: senderID,
                        mediaUrl: mediaUrl,
                        receiverId: receiverId,
                        message_status: message_status,
                        message: message
                        }
                    }
                };
                
                    // var itemParams = {Item: {message_id: {S: message_id},
                    //          sent_time: {S: sentTime},
                    //          server_time: {S: serverTime},
                    //          message_type: {S: messageType},
                    //          room_id: {S: roomID},
                    //          sender_id: {S: senderID},
                    //          media_url: {S: mediaUrl},
                    //          receiver_Id: {S: receiverId},
                    //          message_status: {S: message_status},
                    //          message: {S: message}}};
                
                payload.APNS_SANDBOX = JSON.stringify(payload.APNS_SANDBOX);
                payload = JSON.stringify(payload);
 
                console.log("Platform end point created",data);
                var params = {
                    Message: payload, 
                    Subject: "Test SNS From Lambda",
                    MessageStructure: 'json',
                    TargetArn: data.EndpointArn
                };
                
                sns.publish(params, function(e,d){
                if(err) {
                    console.log("Error: " + err);
                }else {
                    console.log('published to ', d);
                    var params = {
                        TableName:'Transaction',
                        Key:{
                            "ChargeId": chargeId
                        },
                        UpdateExpression: "set MessageId = :messageId",
                        ExpressionAttributeValues:{
                            ":messageId": message_id
                        },
                        ReturnValues:"UPDATED_NEW"
                    };
                    docClient.update(params, function(err, data) {
                        if(err) {
                            console.log('failed to update message id in transaction table ', err);    
                        }else {
                            console.log('success to update message id in transaction table', data);    
                        }
                    });
                }
                });
            }
        });    
    }
    
};