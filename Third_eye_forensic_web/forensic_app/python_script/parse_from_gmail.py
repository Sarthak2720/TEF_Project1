import os.path
import base64
import json
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient.discovery import build
from django.utils import timezone
from .models import Email

# If modifying these SCOPES, delete the file token.json.
SCOPES = ['https://www.googleapis.com/auth/gmail.readonly']

def gmail_authenticate():
    """Authenticate and return a Gmail API service instance."""
    creds = None
    # The file token.json stores the user's access and refresh tokens.
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            token.write(creds.to_json())

    return build('gmail', 'v1', credentials=creds)

def fetch_emails(service):
    """Fetch emails from the user's Gmail inbox."""
    results = service.users().messages().list(userId='me', maxResults=10).execute()
    messages = results.get('messages', [])

    email_data = []
    if not messages:
        print('No messages found.')
    else:
        for msg in messages:
            msg_data = service.users().messages().get(userId='me', id=msg['id']).execute()
            email_id = msg_data['id']
            snippet = msg_data['snippet']
            payload = msg_data['payload']
            headers = payload['headers']

            # Extracting sender, receiver, and subject
            sender = next(header['value'] for header in headers if header['name'] == 'From')
            receiver = next(header['value'] for header in headers if header['name'] == 'To')
            subject = next(header['value'] for header in headers if header['name'] == 'Subject')
            date_sent = next(header['value'] for header in headers if header['name'] == 'Date')

            # Decoding email body
            body = ''
            if 'parts' in payload:
                for part in payload['parts']:
                    if part['mimeType'] == 'text/plain':
                        data = part['body']['data']
                        body = base64.urlsafe_b64decode(data).decode('utf-8')
            else:
                data = payload['body']['data']
                body = base64.urlsafe_b64decode(data).decode('utf-8')

            email_data.append({
                'email_id': email_id,
                'sender': sender,
                'receiver': receiver,
                'subject': subject,
                'date_sent': timezone.datetime.fromisoformat(date_sent[:-1]),
                'snippet': snippet,
                'body': body
            })

    return email_data
