var aws = require("aws-sdk");
var ddb = new aws.DynamoDB(
    {endpoint: 'https://dynamodb.us-west-2.amazonaws.com/',
     params: {TableName: 'User'}
    });
var docClient = new aws.DynamoDB.DocumentClient();    
exports.handler = (event, context, callback) => {
    
    // parameter validation
    if(!isNotEmpty(event.userName)){
        callback('UserName cannot be empty.');
    }
    console.log('Lambda execution : ', event);
    var params = {
        TableName:'User',
        Key:{
            "userName": event.userName
        },
        UpdateExpression: "set FirstName = :firstName, LastName = :lastName, ProfilePicUrl = :profilePicUrl, dob = :dateOfBirth, DoctorTitle = :doctorTitle, DoctorType = :doctorType, DoctorCharge = :doctorCharge, Doctor_Addr_Street = :doctor_addr_street, Doctor_Addr_Unit = :doctor_addr_unit, Doctor_Addr_City = :doctor_addr_city, Doctor_Addr_State = :doctor_addr_state, Doctor_Addr_Zip = :doctor_addr_zip",
        ExpressionAttributeValues:{
            ":firstName" : event.firstName,
            ":lastName" : event.lastName,
            ":profilePicUrl" : event.profilePicUrl,
            ":dateOfBirth" : event.dateOfBirth,
            ":doctorTitle" : event.doctorTitle,
            ":doctorType" : event.doctorType,
            ":doctorCharge" : event.doctorCharge,
            ":doctor_addr_street" : event.doctor_addr_street,
            ":doctor_addr_unit" : event.doctor_addr_unit,
            ":doctor_addr_city" : event.doctor_addr_city,
            ":doctor_addr_state" : event.doctor_addr_state,
            ":doctor_addr_zip" : event.doctor_addr_zip
        },
        ReturnValues:"UPDATED_NEW"
    };
    docClient.update(params, function(err, data) {
        if (err) {
            context.done(err, 'failed');
        }
        else {
            console.log("updated params: ", params);
            console.log("updated data: ", data);
            callback(null, 'success');   
        }
    });
    
    function isNotEmpty(str){
        return str !== null && str !== '' && typeof str !== 'undefined';
    }
};