import os
import requests
from tqdm import tqdm
from .config import CONFIG


BCDA_HOST = f'https://{CONFIG.BCDA_ENV}.bcda.cms.gov'

class BCDADownloader:
    def __init__(self):
        self.access_token = None

    def authenticate(self):
        r = requests.post(f'{BCDA_HOST}/auth/token', 
                        auth=(CONFIG.CLIENT_ID, CONFIG.CLIENT_SECRET), 
                        headers={'accept': 'application/json'})
        if r.status_code != 200:
            raise Exception(f'Could not get access token: {r.status_code} {r.text}')
        response = r.json()
        self.access_token = response['access_token']

    def patient_export(self):
        r = requests.get(f'{BCDA_HOST}/api/v1/Patient/$export', 
                        headers={'accept': 'application/fhir+json',
                                'Prefer': 'respond-async',
                                'Authorization': f'Bearer {self.access_token}'})
        assert(r.status_code==202)
        if r.status_code != 202:
            raise Exception(f'Could not initiate export: {r.status_code} {r.text}')
        self.content_location = r.headers['Content-Location']
        
    def try_download_files(self):
        r = requests.get(self.content_location, 
            headers={'accept': 'application/fhir+json',
                'Authorization': f'Bearer {self.access_token}'})
        if r.status_code == 200:
            print('Export Done!')
            # Download files
            response = r.json()['output']
            for download in tqdm(response): 
                r = requests.get(download['url'], 
                    headers={
                        'Accept-Encoding': 'gzip',
                        'Authorization': f'Bearer {self.access_token}'
                    })
                object_type=download['type']
                os.makedirs(f'data/{CONFIG.DATASET_NAME}/fihr', exist_ok=True)
                filename=f'data/{CONFIG.DATASET_NAME}/fihr/{object_type}.ndjson'
                with open(filename, 'wb') as f:
                    f.write(r.content)
            return { "status": "Done" }
        elif r.status_code == 202:
            return { "status": r.headers['X-Progress'] }
        else:
            raise Exception(f'Export error: {r.status_code} {r.text}')
