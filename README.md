# semver criteria

Given same method call signatures, behavior should not change.

Upstream changes in the API call signature itself should be treated as bugfixes.
The intended API call was broken "upstream" / "for reasons not originating
from this gem", therefore from this gem's perspective, the same intended
behavior can be restored by updating ("fixing") the API call, i.e. a "bugfix".
Bump a patch.

# safe-t-rest

A ruby gem for Safe-T Box REST API

Basic usage:
================

* Install the gem
```
gem install safe-t-rest
```

* Require the gem
```ruby
require 'safe-t-rest'
```

* Initialize a new instance (can be empty or set via parameters)
empty:
```ruby
client = SafeTRest.new
```
set using hash:
```ruby
client = SafeTRest.new(url: 'https://Safe-T/ui_api/login.aspx', user_name: 'test', password: '123', extension_id: '1', role_id: '0')
```

* Configure the client (if you initialized empty)
```ruby
client.url = 'https://Safe-T_Box_Site.com/ui_api/login.aspx'
client.username = 'test'
client.password = '12345'
client.extension_id = '435-34534-24-234-6'
client.role_id = '00006'
```

* Send requests
```ruby
puts client.get_apps_process_state('my_packge_GUID.123123')

puts client.get_package_file_list('my_packge_GUID.123123')
```

* Safe Share
```ruby
args = {
	:files => 'file.txt', # name of file to share
	:recipients => 'alexander.dan@safe-t.com', # Email address of the one you want to share with
	:sender_name => 'Bar Hofesh',
	:sender_address => 'bar.hofesh@safe-t.com',
	:subject => 'Testing Ruby API', # Email Subject
	:message => 'This is a Test message, just checking the Ruby API using REST', # Email body message
	:message_encryption_level => '0', # 0 = high, 1 = normal, 2 = low
	:delivery_method => '0',
	:mobile_recipient => '',
	:return_receipt => true, # get back a notification when the file was downloaded
	:safe_reply => true, # send an safe reply invitation
	:max_downloads => '3', # maximum number of allowed downloads
	:package_expiry => '1440', # in minutes
	:folder_path => '', # empty means root folder
	:root_folder_id => '417' # My Storage ID
}

client.safe_share_file(args)
```

* File Upload
```ruby
args = {
	:file_base64 => 'V29ya2luZyA6KQo=', # the file as a base64 string Base64.encode64(File.read(file))
	:file_name => 'file.txt', # the name of the file
	:folder_path => '', # empty means root folder
	:root_folder_id => 417 # My Storage ID
}

client.file_upload(args)
```

* File Download
```ruby
args = {
	:file_name => 'file.txt', # The name of the file to download
	:folder_path => '', # The path of the file
	:root_folder_id => 417 # My Storage ID
}

file = client.file_download(args) # Get back the file as a base64 string
file = Base64.decode64(file) # decode the string
File.write('file.txt', file) # write decoded file
```
* New API
# RegisterSession - return json flow

## Overview

```
StatusCode=OK&StatusData=Base64Json
```
Base64Json:
```json
{
	"flow": [
	"username_password",
	"sms"
         ]
        "token": [
        "3434",
        "7676"
      ]
}
if there is no token element, SDA need to generate token.
```

## Scenarios

### Scenario 1

- Login to portal: (https://securemft/Safe-T/login.aspx)
 - SDA will send a rest call with URL and add sType :
    `https://securemft/Safe-T/login.aspx&sType=login`
    ```json
      {"RoleID": "00006", "ExtensionID": "226602f2-4960-4542-a489-8250a551b804", "Username":"", "Password":"", "Method": "RegisterSession","Arguments": ["https://securemft/Safe-T/login.aspx&sType=login"]}
    ```

  - Return value:
    `StatusCode=OK&StatusData=`
    ```json
    {
      "flow": [
        "username_password",
        "sms"
      ]
    }
    ```
- Handle return value
    - on submit , call iVerifyUserAccount add the submitted user name and password in base64 arguments:
      first step : username_password -  call iVerifyUserAccount (no need to call mobile - all against the same SDE Authentication app):

```json
{
  "RoleID": "00006",
   "ExtensionID": "226602f2-4960-4542-a489-8250a551b804",
   "Username":"",
   "Password":"",
   "Method": "iVerifyUserAccount",
   "Arguments": ["base64username","base64pass",true]
}
```
	  Return value:
         OK:Q2xpZW50TW93NyI=
         base64 string is  "05977777777"

    - If its ok + number :
       go to second step
       else handle retries and captcha
    - if there is no number ? we need to ask alex\eithan.

    - second step : sms - send sms to the ClientMobileNumber and validate it
       else handle retries and captcha

### Scenario 2
Any other case : https://securemft/Safe-T/login.aspx?folderType=x&(query_string_params) (packages related url's ,safe reply,package view, registration)

1.	SDA will call RegisterSession with URL param:

```json
{
  "RoleID": "00006",
   "ExtensionID": "226602f2-4960-4542-a489-8250a551b804",
   "Username":"",
   "Password":"",
   "Method": "iVerifyUserAccount",
   "Arguments": ["base64username","base64pass",true]
}
```

Return value:

in case of registers users:
`StatusCode=OK&StatusData=`
```json
    {
      "flow": [
        "username_password",
        "sms"
      ]
      "token": [
        "3434",
        "7676"
      ]
    }
```

2. Handle return :
```ruby
	if flow is :
	"username_password",
        "sms"
```
- Handle return value
    - on submit , call iVerifyUserAccount add the submitted user name and password in base64 arguments:
      first step : username_password -  call iVerifyUserAccount (no need to call mobile - all against the same SDE Authentication app):
	```json
{
  "RoleID": "00006",
   "ExtensionID": "226602f2-4960-4542-a489-8250a551b804",
   "Username":"",
   "Password":"",
   "Method": "iVerifyUserAccount",
   "Arguments": ["base64username","base64pass",true]
}

 Return value:
        OK:Q2xpZW50TW93NyI=
        base64 string is  "05977777777"

    - If its ok + number :
       go to second step
       else handle retries and captcha
    - if there is no number ? we need to ask alex\eithan.

    - second step : sms - send sms to the ClientMobileNumber and validate it
       else handle retries and captcha

# RubyDoc

http://www.rubydoc.info/github/bararchy/safe-t-rest/SafeTRest

* Added example client under /bin
