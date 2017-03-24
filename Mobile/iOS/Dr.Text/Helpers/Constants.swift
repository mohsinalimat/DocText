//
//  Constants.swift
//  Dr.Text
//
//  Created by SoftSuave on 13/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

//Base Url
let BASE_URL = "https://yecodbvvqh.execute-api.us-east-1.amazonaws.com/Chat"

// AWS Configurations
let COGNITO_USER_POOL_ID = "us-west-2_Qtn63SJPp"
let COGNITO_USER_POOL_APP_CLIENT_ID = "2jm3cqkd6bl2fhogc533cgaleh"
let COGNITO_USER_POOL_APP_CLIENT_SECRET = "svv6dcpcuk93nft6pgbbg37vrgjefpaj2oe8elsouc0bsufu0g5"
let COGNITO_IDENTITY_POOL_ID = "us-west-2:d870ea1c-bfeb-4a12-9731-da1bcbce7bc6"
let AWS_SNS_APPLICATION_ARN = "arn:aws:sns:us-east-1:717363038630:app/APNS_SANDBOX/Dr.Text"
let AWS_S3_BUCKETNAME = "mrtext/"
let AWS_S3_PROFILE_PIC_FOLDER = "ProfilePictures"
let AWS_S3_MEDIA_FILE_FOLDER = "Multi_Media_Files"

// Media Type Constants
let MEDIA_TYPE_TEXT = "text"
let MEDIA_TYPE_IMAGE = "image"
let MEDIA_TYPE_AUDIO = "audio"
let MEDIA_TYPE_VIDEO = "video"

// Message Status Constants
let MESSAGE_STATUS_NOT_SENT = "Sending..."
let MESSAGE_STATUS_SENT = "Sent"
let MESSAGE_STATUS_READ = "Read"
let MESSAGE_STATUS_DELIVERED = "Delivered"
let MESSAGE_STATUS_NOT_DELIVERED = "Not delivered"

// Message Amount in dollars
let AMOUNT_CURRENCY = "usd"

// Error message string constants
let ACCOUNT_EXIST = "An account exists for this email"

let DOCTOR_CHARGE_EMPTY = "Amount is required"
let EMPTY_FIRST_NAME = "First name is required"
let EMPTY_LAST_NAME = "Last name is required"
let NUMBERS_SYMBOLS_NOT_SUPPORTED = "Invalid name"

let VALID_EMAIL_ID = "Invalid email address"
let PASSWORD_EIGHT_CHAR = "Password must be more than 8 characters"

let EMPTY_EMAIL_ID = "Email address is required"
let EMPTY_PASSWORD = "Password is required"
let EMPTY_CONFIRM_PASSWORD = "Confirm password is required"
let PASSWORD_NOT_MATCH = "Password doesn't match"
let EMPTY_DOB = "Date of birth is required"
let DOB_18_YEARS = "You must be over 18 to use this service"

let EMPTY_DOCTOR_TYPE = "Select a Type..."
let EMPTY_DOCTOR_TITLE = "Select a Title..."

let EMPTY_STREET = "You must input a Street"
let EMPTY_CITY = "You must input a City"
let EMPTY_STATE = "You must input a State"
let EMPTY_PHONE_NO = "You must input a phone number"
let EMPTY_ZIP = "You must input a Zip"
let ZIP_NOT_VALID = "Invalid Zip"
let PHNO_10_CHAR = "Phone number must have 10 characters"
let CHECK_TICK_MARK = "Please accept terms & condition"

let EMPTY_CARD_NO = "You must input a Card number"
let EMPTY_EXP_DATE = "You must input a Expiry date"
let EMPTY_CVV = "You must input a CVV"
