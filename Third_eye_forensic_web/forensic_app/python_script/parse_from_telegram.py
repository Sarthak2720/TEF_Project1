from telethon import TelegramClient, sync
from telethon.tl.functions.messages import GetHistoryRequest
from telethon.tl.types import PeerChannel
import csv

# Your Telegram API credentials (use your actual API ID and hash)
api_id = '452567267'  # Replace with your real API ID
api_hash = 'abcdef1234567890abcdef1234567890'  # Replace with your real API Hash
phone_number = '+916365567890'  # Replace with your phone number (international format)

# Initialize the Telegram client
client = TelegramClient('demo_session', api_id, api_hash)

# Define the output CSV file path
output_file = 'demo_telegram_chat_history.csv'

# Define the async function to fetch and parse the chat messages
async def main():
    # Start the client and connect to Telegram
    await client.start(phone_number)
    
    # Replace with an actual chat or channel username
    target_chat = 'example_channel'  # You can replace with an actual chat or channel username
    
    # Fetch the target chat/channel information
    chat = await client.get_entity(target_chat)

    # Get chat history (you can adjust limit or add date range)
    history = await client(GetHistoryRequest(
        peer=PeerChannel(chat.id),
        offset_id=0,
        offset_date=None,
        add_offset=0,
        limit=100,  # Fetch 100 messages for demo purposes
        max_id=0,
        min_id=0,
        hash=0
    ))

    # Prepare the list to store messages
    messages = []

    # Loop through the fetched messages
    for message in history.messages:
        if hasattr(message, 'message'):  # Check if it's a text message
            msg_text = message.message
        else:
            msg_text = None

        # Detect media type
        if message.media:
            if hasattr(message.media, 'photo'):
                media_type = 'photo'
            elif hasattr(message.media, 'document'):
                media_type = 'document'
            else:
                media_type = 'other'
        else:
            media_type = 'none'

        # Collect all relevant message data
        messages.append({
            'message_id': message.id,
            'sender_id': message.from_id.user_id if message.from_id else 'unknown',
            'date': message.date,
            'message_text': msg_text,
            'media_type': media_type
        })

    # Save the messages to a CSV file
    save_to_csv(messages)

    print(f"Chat history successfully saved to {output_file}")

# Function to save parsed messages into a CSV file
def save_to_csv(messages):
    # Define CSV column headers
    headers = ['message_id', 'sender_id', 'date', 'message_text', 'media_type']

    # Write messages to a CSV file
    with open(output_file, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=headers)
        writer.writeheader()  # Write the header row

        # Write each message row to the CSV file
        for message in messages:
            writer.writerow(message)

# Run the Telegram client session
with client:
    client.loop.run_until_complete(main())
