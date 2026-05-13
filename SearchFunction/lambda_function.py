import boto3
import requests
from requests_aws4auth import AWS4Auth
import json
import urllib.parse

region = 'us-east-1'
service = 'es'
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

host = 'https://vpc-search-engine-domain-vyfj5nw7n7ddvgfmdph7jyndbe.us-east-1.es.amazonaws.com'
index = 'mygoogle'
url = f"{host}/{index}/_search"

def get_from_Search(query):
    headers = {"Content-Type": "application/json"}
    r = requests.get(url, auth=awsauth, headers=headers, data=json.dumps(query))
    return r.json()

def lambda_handler(event, context):
    try:
        print("Event:", event)

        # 1. Handle JSON POST from API Gateway
        if "body" in event and event["body"]:
            try:
                body = json.loads(event["body"])
                term = body.get("query")
            except:
                # 2. Handle HTML form POST (searchTerm=xxx)
                form = urllib.parse.parse_qs(event["body"])
                term = form.get("searchTerm", [""])[0]
        else:
            term = ""

        print("Search term:", term)

        query = {
            "size": 25,
            "query": {
                "multi_match": {
                    "query": term,
                    "fields": ["Title", "Author", "Date", "Body"]
                }
            },
            "fields": ["Title", "Author", "Date", "Summary"]
        }

        print("Sending query to OpenSearch")
        response_json = get_from_Search(query)

        hits = response_json.get("hits", {}).get("hits", [])
        print("Hits:", hits)

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(hits)
        }

    except Exception as e:
        print("Exception:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"status": False, "message": str(e)})
        }
