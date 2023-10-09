import requests
import json

url = '<insert function container app url here>'

payload = {
    "data": {
        "value": {
            "orderId": "1446"
        }
    }
}

headers = {
    'Content-Type': 'application/json'
}

response = requests.post(url, headers=headers, data=json.dumps(payload))

print(response.status_code)
print(response.text)
