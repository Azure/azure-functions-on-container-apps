import requests
import json

url = 'https://hf-4k56.mangobush-7790a409.northcentralus.azurecontainerapps.io/api/invoke'

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