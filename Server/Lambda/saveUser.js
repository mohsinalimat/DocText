console.log("Loading function..");
var aws = require('aws-sdk');
var ddb = new aws.DynamoDB(
    {
        endpoint: 'https://dynamodb.us-west-2.amazonaws.com/',
        params: {TableName: 'User'}
    });
exports.handler = (event, context, callback) => {
    console.log(event.request.userAttributes);
    // console.log("custom attributes..." + event.request.userAttributes["custom:UserRole"]);
    
    var itemParams = {Item: {userName: {S: event.request.userAttributes.email},
                             FirstName: {S: event.request.userAttributes["custom:FirstName"]},
                             LastName: {S: event.request.userAttributes["custom:LastName"]},
                             UserRole: {S: event.request.userAttributes["custom:UserRole"]},
                             DoctorTitle: {S: event.request.userAttributes["custom:doctorTitle"]},
                             DoctorType: {S: event.request.userAttributes["custom:doctorType"]},
                             DoctorCharge: {S: event.request.userAttributes["custom:doctor_charge"]},
                             Doctor_Addr_City: {S: event.request.userAttributes["custom:doctor_addr_city"]},
                             Doctor_Addr_State: {S: event.request.userAttributes["custom:doctor_addr_state"]},
                             Doctor_Addr_Street: {S: event.request.userAttributes["custom:doctor_addr_street"]},
                             Doctor_Addr_Unit: {S: event.request.userAttributes["custom:doctor_addr_unit"]},
                             Doctor_Addr_Zip: {S: event.request.userAttributes["custom:doctor_addr_zip"]},
                             Doctor_Office_PhNo: {S: event.request.userAttributes["custom:doctor_office_phno"]},
                             ProfilePicUrl: {S: event.request.userAttributes["custom:profilePictureUrl"]},
                             Email: {S: event.request.userAttributes.email},
                             RecoveryCode: {S: "nil"},
                             dob: {S: event.request.userAttributes.birthdate},
                             PhoneNo: {S: event.request.userAttributes.phone_number},
                             PhNo_Country_Code: {S: event.request.userAttributes["custom:Ph_Country_code"]},
                             Active: {S: "true"},
                             Price: {S: "50"},
                             CreatedTime: {S: Date.now().toString()},
                             UpdatedTime: {S: Date.now().toString()}
    }};
    
    console.log(itemParams);
    ddb.putItem(itemParams, function(err, data) {
        if (err) {
            context.done(err, 'putting user item into dynamodb failed: ');
        }
        else {
            context.done(null, event);
        }
    });
};