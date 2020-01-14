# Barracuda WAF-as-a-Service REST API

Barracuda WAF-as-a-Service includes a full REST API that can be used to add and configure applications to be protected.

To use the API, you must first have a Barracuda user and a valid WAF-as-a-Service license.  To sign up for a Barracuda account and a free 30-day trial of WAF-as-a-Service, [click here](https://waas.barracudanetworks.com/).

## Logging In

To log in, send a POST request to `https://api.waas.barracudanetworks.com/v2/waasapi/api_login/`.  Send the following parameters:

* `email`: Your Barracuda user email.
* `password`: Your Barracuda user password.
* `account_id` (optional, rarely used): If your Barracuda user has access to multiple accounts, specify the ID of the account you wish to log in to.  If omitted, defaults to your user's default account.

If authentication is not successful, the server will return a 403 response code.  If authentication is successful, the server will return the following JSON:

`{"key": "5092be7f07e541d48b51d2a7f3688fdf_RHqaPgyM2j25vwB", "expiry": "2018-06-11T08:07:45.567Z"}`

You may now call other API methods.  Pass in the additional HTTP header `auth-api`, with a value equal to the `key` returned above.  You may use the `key` until the `expiry` time specified.

## Logging Out

You may invalidate the `key` before it expires by sending a POST request to `https://api.waas.barracudanetworks.com/v2/waasapi/api_logout/`.

## API Methods

See the following document for a full description of all API methods: [https://api.waas.barracudanetworks.com/swagger/](https://api.waas.barracudanetworks.com/swagger/).

## Sample Code

See the `waas_rest_api_example.py` file for an example script that logs in and prints the list of protected applications associated with the user account.
