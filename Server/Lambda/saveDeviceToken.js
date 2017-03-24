exports.handler = (event, context, callback) => {
    // TODO implement
    
    
var AWS = require("aws-sdk");
var result;

AWS.config.update({
  region: "us-east-1",
  endpoint: "https://dynamodb.us-west-2.amazonaws.com/"
});

var docClient = new AWS.DynamoDB.DocumentClient();

// parameter validation
    if(!event.roomId){
        callback("roomId cannot be empty");
    }
    
console.log(event.roomId);
var params = {
    TableName: "lambdachat",
    // IndexName: "doctorId-patientId-index",
    // ProjectionExpression: "doctorId, patientId",
    FilterExpression: "room_id = :roomId",
    ExpressionAttributeValues:{
        ":roomId": event.roomId
    }
};
console.log(params);
console.log("Scanning Rooms table.");
docClient.scan(params, onScan);

function onScan(err, data) {
    if (err) {
        console.error("Unable to scan the table. Error JSON:", JSON.stringify(err, null, 2));
    } else {
         global.result = data;
         console.log("Response : ", data);
        console.log("Scan succeeded.");
        global.result.Items.sort(function(a,b) {
            aSent_time = Date.parse(a.lastMessageTime);
            bSent_time = Date.parse(b.lastMessageTime)
            console.log(aSent_time);
            console.log(bSent_time);
            if (aSent_time > bSent_time) return 1;
            if (aSent_time < bSent_time) return -1;
            return 0;
        });
        return callback(null, global.result);
    }
}
};