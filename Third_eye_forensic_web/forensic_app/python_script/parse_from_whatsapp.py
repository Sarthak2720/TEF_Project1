import re
from datetime import datetime

def parse_whatsapp_chat(file_path):
    """
    Parses a WhatsApp chat export file and returns a list of messages and a set of participants.

    Args:
        file_path (str): Path to the WhatsApp chat export text file.

    Returns:
        messages (list of dict): List containing message details.
        participants (set): Set of unique participants.
    """
    # Regular expression pattern to match WhatsApp messages
    # Example line: "12/31/20, 11:59 PM - John Doe: Happy New Year!"
    message_pattern = re.compile(
        r'^(?P<date>\d{1,2}/\d{1,2}/\d{2,4}),\s(?P<time>\d{1,2}:\d{2}\s(?:AM|PM))\s-\s(?P<sender>.*?):\s(?P<message>.*)'
    )
    
    messages = []
    participants = set()
    
    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            line = line.strip()
            match = message_pattern.match(line)
            if match:
                date_str = match.group('date')
                time_str = match.group('time')
                sender = match.group('sender')
                message = match.group('message')
                
                # Parse datetime
                datetime_str = f"{date_str} {time_str}"
                try:
                    message_datetime = datetime.strptime(datetime_str, '%m/%d/%y %I:%M %p')
                except ValueError:
                    try:
                        message_datetime = datetime.strptime(datetime_str, '%m/%d/%Y %I:%M %p')
                    except ValueError:
                        # Handle unexpected date formats
                        message_datetime = None
                
                messages.append({
                    'datetime': message_datetime,
                    'sender': sender,
                    'message': message
                })
                
                participants.add(sender)
            else:
                # Handle multiline messages or system messages if needed
                if messages:
                    # Append to the last message's content
                    messages[-1]['message'] += f'\n{line}'
class Command(BaseCommand):
    help = 'Parses a WhatsApp chat export file and stores the data in the database.'

    def add_arguments(self, parser):
        parser.add_argument('file_path', type=str, help='Path to the WhatsApp chat export text file.')

    def handle(self, *args, **kwargs):
        file_path = kwargs['file_path']

        if not os.path.isfile(file_path):
            raise CommandError(f"File '{file_path}' does not exist.")

        self.stdout.write(f"Parsing WhatsApp chat from '{file_path}'...")

        messages, participants = parse_whatsapp_chat(file_path)

        self.stdout.write(f"Found {len(participants)} participants and {len(messages)} messages.")

        # Create Participant instances
        participant_objects = {}
        for name in participants:
            participant, created = Participant.objects.get_or_create(name=name)
            participant_objects[name] = participant
            if created:
                self.stdout.write(f"Created participant: {name}")

        # Create Message instances
        message_count = 0
        for msg in messages:
            sender_name = msg['sender']
            sender = participant_objects.get(sender_name)
            if not sender:
                # This shouldn't happen, but just in case
                sender, _ = Participant.objects.get_or_create(name=sender_name)
                participant_objects[sender_name] = sender

            message_obj = Message(
                datetime=msg['datetime'] if msg['datetime'] else timezone.now(),
                sender=sender,
                message=msg['message']
            )
            message_obj.save()
            message_count += 1

        self.stdout.write(self.style.SUCCESS(f"Successfully imported {message_count} messages."))
        return messages, participants
