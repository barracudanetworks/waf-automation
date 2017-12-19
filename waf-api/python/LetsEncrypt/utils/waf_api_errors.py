class WAFAPIException(Exception):
    """MASTER CLASS FOR WAF/BAC API EXCEPTIONS"""

    def __init__(self, response, message):
        if not message:
            message = ""

        if response is not None:
            message += " - API JSON Message Response: {}".format(WAFAPIException._get_error_msg(response))

        self.response = response

        super(WAFAPIException, self).__init__(message)

    @staticmethod
    def _get_error_msg(response):
        if response.text:
            try:
                return response.json()  # might throw ValueError
            except ValueError:
                pass

        return {}


class WAFAPIValueException(WAFAPIException):
    def __init__(self, message):
        super().__init__(None, message)


class WAFAPILoginException(WAFAPIException):
    def __init__(self, response):
        message = '{code} Login Error, Reason: {reason}. URL: {url}'.format(code=response.status_code,
                                                                            reason=response.reason, url=response.url)
        super().__init__(response, message)


class WAFAPIHTTPServerError(WAFAPIException):
    # for 500...600 status code errors
    def __init__(self, response):
        message = '{code} Server Error, Reason: {reason}. URL: {url}'.format(code=response.status_code,
                                                                             reason=response.reason, url=response.url)
        super().__init__(response, message)


class WAFAPIHTTPClientError(WAFAPIException):
    # for 400...500 (no 401) status code errors
    def __init__(self, response):
        message = '{code} Client Error, Reason: {reason}. URL: {url}'.format(code=response.status_code,
                                                                             reason=response.reason, url=response.url)
        super().__init__(response, message)
