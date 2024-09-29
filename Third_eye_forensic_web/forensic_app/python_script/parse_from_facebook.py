import json
from datetime import datetime
from django.utils import timezone

def parse_facebook_chat(file_path):
    """
    Parses a Facebook Messenger chat export JSON file and returns conversations, participants, and messages.

    Args:
        file_path (str): Path to the Facebook Messenger JSON file.

    Returns:
        conversations (list of dict): List containing conversation details.
        participants (set): Set of unique participants.
    """
    with open(file_path, 'r', encoding='utf-8') as file:
        data = json.load(file)

    conversations = []
    participants = set()

    for convo in data.get('conversations', []):
        convo_title = convo.get('title', '')
        convo_participants = {participant['name'] for participant in convo.get('participants', [])}
        participants.update(convo_participants)
        convo_messages = convo.get('messages', [])

        messages = []
        for msg in convo_messages:
            sender = msg.get('sender_name', 'Unknown')
            timestamp_ms = msg.get('timestamp_ms')
            content = msg.get('content', '')
            msg_type = msg.get('type', 'Generic')

            # Convert timestamp to datetime
            if timestamp_ms:
                message_datetime = datetime.fromtimestamp(timestamp_ms / 1000, tz=timezone.utc)
            else:
                message_datetime = timezone.now()

            messages.append({
                'conversation_title': convo_title,
                'sender': sender,
                'datetime': message_datetime,
                'content': content,
                'type': msg_type
            })

        conversations.append({
            'title': convo_title,
            'participants': convo_participants,
            'messages': messages
        })
        
class Command(BaseCommand):
    help = 'Parses a Facebook Messenger chat export JSON file and stores the data in the database.'

    def add_arguments(self, parser):
        parser.add_argument('file_path', type=str, help='Path to the Facebook Messenger JSON export file.')

    def handle(self, *args, **kwargs):
        file_path = kwargs['file_path']

        if not os.path.isfile(file_path):
            raise CommandError(f"File '{file_path}' does not exist.")

        self.stdout.write(f"Parsing Facebook Messenger chat from '{file_path}'...")

        conversations_data, participants = parse_facebook_chat(file_path)

        self.stdout.write(f"Found {len(participants)} participants and {len(conversations_data)} conversations.")

        # Create Participant instances
        participant_objects = {}
        for name in participants:
            participant, created = Participant.objects.get_or_create(name=name)
            participant_objects[name] = participant
            if created:
                self.stdout.write(f"Created participant: {name}")

        # Create Conversation and Message instances
        conversation_count = 0
        message_count = 0
        for convo in conversations_data:
            title = convo['title'] if convo['title'] else f"Conversation {conversation_count + 1}"
            conversation, created = Conversation.objects.get_or_create(title=title)
            if created:
                self.stdout.write(f"Created conversation: {title}")
            # Add participants to conversation
            for participant_name in convo['participants']:
                participant = participant_objects.get(participant_name)
                if participant:
                    conversation.participants.add(participant)
            conversation_count += 1

            # Add messages to conversation
            for msg in convo['messages']:
                sender = participant_objects.get(msg['sender'])
                if not sender:
                    # If sender not found, create a new Participant
                    sender, _ = Participant.objects.get_or_create(name=msg['sender'])
                    participant_objects[msg['sender']] = sender
                    self.stdout.write(f"Created participant: {msg['sender']}")

                message_obj = Message(
                    conversation=conversation,
                    sender=sender,
                    datetime=msg['datetime'],
                    content=msg['content'],
                    type=msg['type']
                )
                message_obj.save()
                message_count += 1

        self.stdout.write(self.style.SUCCESS(
            f"Successfully imported {conversation_count} conversations and {message_count} messages."
        ))

        return conversations, participants
