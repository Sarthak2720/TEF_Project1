import json
from datetime import datetime
from django.utils import timezone

def parse_instagram_chat(file_path):
    """
    Parses an Instagram Direct Messages JSON export file and returns conversations, participants, and messages.

    Args:
        file_path (str): Path to the Instagram Direct Messages JSON export file.

    Returns:
        conversations (list of dict): List containing conversation details.
        participants (set): Set of unique participants.
    """
    with open(file_path, 'r', encoding='utf-8') as file:
        data = json.load(file)

    conversations = []
    participants = set()

    for convo in data.get('inbox', {}).get('threads', []):
        convo_title = convo.get('thread_title', '')
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

    return conversations, participants

def parse_instagram_followers(file_path):
    """
    Parses an Instagram followers JSON export file and returns a list of followers.

    Args:
        file_path (str): Path to the Instagram followers JSON export file.

    Returns:
        followers (list of str): List containing follower usernames.
    """
    with open(file_path, 'r', encoding='utf-8') as file:
        data = json.load(file)

    followers = [follower['username'] for follower in data.get('followers', {}).get('followers', [])]
    return followers

import os
from django.core.management.base import BaseCommand, CommandError
from forensic_app.python_script.utils import parse_instagram_chat, parse_instagram_followers
from forensic_app.models import Participant, Conversation, Message
from django.utils import timezone

class Command(BaseCommand):
    help = 'Parses Instagram Direct Messages and followers export JSON files and stores the data in the database.'

    def add_arguments(self, parser):
        parser.add_argument('chat_file_path', type=str, help='Path to the Instagram Direct Messages JSON export file.')
        parser.add_argument('followers_file_path', type=str, help='Path to the Instagram followers JSON export file.')

    def handle(self, *args, **kwargs):
        chat_file_path = kwargs['chat_file_path']
        followers_file_path = kwargs['followers_file_path']

        # Validate chat file
        if not os.path.isfile(chat_file_path):
            raise CommandError(f"Chat file '{chat_file_path}' does not exist.")

        # Validate followers file
        if not os.path.isfile(followers_file_path):
            raise CommandError(f"Followers file '{followers_file_path}' does not exist.")

        self.stdout.write(f"Parsing Instagram chats from '{chat_file_path}'...")
        conversations_data, chat_participants = parse_instagram_chat(chat_file_path)
        self.stdout.write(f"Found {len(chat_participants)} chat participants and {len(conversations_data)} conversations.")

        self.stdout.write(f"Parsing Instagram followers from '{followers_file_path}'...")
        followers = parse_instagram_followers(followers_file_path)
        self.stdout.write(f"Found {len(followers)} followers.")

        # Create Participant instances for chat participants
        chat_participant_objects = {}
        for name in chat_participants:
            participant, created = Participant.objects.get_or_create(name=name)
            chat_participant_objects[name] = participant
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
                participant = chat_participant_objects.get(participant_name)
                if participant:
                    conversation.participants.add(participant)
            conversation_count += 1

            # Add messages to conversation
            for msg in convo['messages']:
                sender = chat_participant_objects.get(msg['sender'])
                if not sender:
                    # If sender not found, create a new Participant
                    sender, _ = Participant.objects.get_or_create(name=msg['sender'])
                    chat_participant_objects[msg['sender']] = sender
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

        # Create Participant instances for followers
        follower_objects = {}
        for username in followers:
            follower, created = Participant.objects.get_or_create(name=username)
            follower_objects[username] = follower
            if created:
                self.stdout.write(f"Added follower: {username}")

        self.stdout.write(self.style.SUCCESS(
            f"Successfully imported {conversation_count} conversations, {message_count} messages, and {len(followers)} followers."
        ))
