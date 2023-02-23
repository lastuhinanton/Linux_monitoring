#!/bin/bash

. ../module.sh
. ./module_05.sh

setCodes
selectOption

isCorrect=$(validateOption 1 4 $option)

[[ $isCorrect -eq $RIGHT ]] && preOutputProcess $option
[[ $isCorrect -eq $RIGHT ]] && outputProcess $option


# 200: OK - The request was successful.
# 201: Created - The request was successful, and a resource was created.
# 400: Bad Request - The request could not be understood or was missing required parameters.
# 401: Unauthorized - Authentication failed or user does not have permissions for the requested operation.
# 403: Forbidden - Authentication succeeded, but the authenticated user does not have access to the requested resource.
# 404: Not Found - The requested resource could not be found.
# 500: Internal Server Error - An unexpected condition was encountered by the server.
# 501: Not Implemented - The server does not support the requested functionality.
# 502: Bad Gateway - The server received an invalid response from an upstream server.
# 503: Service Unavailable - The server is currently unable to handle the request due to a temporary overload or maintenance of the server.
