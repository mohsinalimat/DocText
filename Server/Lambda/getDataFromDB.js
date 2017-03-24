exports.handler = (event, context, callback) => {
    // TODO implement
    
    
var AWS = require("aws-sdk");
var result;

AWS.config.update({
  region: "us-east-1",
  endpoint: "https://dynamodb.us-west-2.amazonaws.com/"
});

var docClient = new AWS.DynamoDB.DocumentClient();
console.log(JSON.stringify(event))
// parameter validation
    if(!event.RoomId){
        callback("roomId cannot be empty");
    }
    
console.log(event.RoomId);
var params = {
    TableName: "lambdachat",
    IndexName: "room_id-server_time-index",
    // ProjectionExpression: "doctorId, patientId",
    KeyConditionExpression: "room_id = :roomId",
    ExpressionAttributeValues:{
        ":roomId": event.RoomId
    },
    Limit : event.Limit,
    ScanIndexForward : false
};
if(!isEmpty(event.LastEvaluatedKey)) {
    params.ExclusiveStartKey = event.LastEvaluatedKey;
}
console.log(params);
console.log("Scanning Rooms table.");
docClient.query(params, onScan);

function onScan(err, data) {
    if (err) {
        console.error("Unable to scan the table. Error JSON:", JSON.stringify(err, null, 2));
    } else {
         global.result = data;
         console.log("Response : ", data);
        console.log("Scan succeeded.");
        global.result.Items.sort(function(a,b) {
            aSent_time = new Date(Number(a.server_time));//Date.parse(a.server_time);
            bSent_time = new Date(Number(b.server_time));//Date.parse(b.server_time)
            console.log(aSent_time);
            console.log(bSent_time);
            if (aSent_time > bSent_time) return 1;
            if (aSent_time < bSent_time) return -1;
            return 0;
        });
        return callback(null, global.result);
    }
}

function isEmpty(str){
    return str === null || str === '' || typeof str === 'undefined';
}
};