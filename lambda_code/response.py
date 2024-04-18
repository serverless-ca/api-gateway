import json
import logging

message = {
  "status": "success",
  "data": {
    "usedBy": "API Gateway"
  },
  "message": "successful response from API Gateway lambda function"
}


def lambda_handler(event, context):  # pylint: disable=unused-argument
    """Reply to API request"""
    logging.info("Received event: %s", json.dumps(event, indent=2))

    headers = {"Content-Type": "application/json"}
    return {"statusCode": 200, "headers": headers, "body": message}
