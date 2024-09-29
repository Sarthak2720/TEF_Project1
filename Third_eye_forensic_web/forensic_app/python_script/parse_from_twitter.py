import json
from datetime import datetime
from django.utils import timezone

def parse_twitter_tweets(file_path):
    """
    Parses a Twitter tweets JSON export file and returns tweets and participants.

    Args:
        file_path (str): Path to the Twitter tweets JSON export file.

    Returns:
        tweets (list of dict): List containing tweet details.
        participants (set): Set of unique participants.
    """
    with open(file_path, 'r', encoding='utf-8') as file:
        data = json.load(file)

    tweets = []
    participants = set()

    for tweet in data.get('tweets', []):
        tweet_id = tweet.get('id')
        created_at = tweet.get('created_at')  # Example format: "Wed Oct 10 20:19:24 +0000 2018"
        content = tweet.get('full_text') or tweet.get('text', '')
        tweet_type = 'Tweet'

        # Determine tweet type
        if 'retweeted_status' in tweet:
            tweet_type = 'Retweet'
            original_tweet = tweet['retweeted_status']
            content = original_tweet.get('full_text') or original_tweet.get('text', '')
            sender_name = original_tweet['user']['name']
        elif tweet.get('in_reply_to_status_id') is not None:
            tweet_type = 'Reply'
            sender_name = tweet['user']['name']
        elif 'quoted_status' in tweet:
            tweet_type = 'Quote'
            quoted_tweet = tweet['quoted_status']
            content = quoted_tweet.get('full_text') or quoted_tweet.get('text', '')
            sender_name = quoted_tweet['user']['name']
        else:
            sender_name = tweet['user']['name']

        # Parse datetime
        try:
            message_datetime = datetime.strptime(created_at, '%a %b %d %H:%M:%S %z %Y')
        except ValueError:
            message_datetime = timezone.now()

        tweets.append({
            'tweet_id': tweet_id,
            'sender': sender_name,
            'datetime': message_datetime,
            'content': content,
            'type': tweet_type
        })

        participants.add(sender_name)

    return tweets, participants

def parse_twitter_followers(file_path):
    """
    Parses a Twitter followers JSON export file and returns a list of followers.

    Args:
        file_path (str): Path to the Twitter followers JSON export file.

    Returns:
        followers (list of str): List containing follower usernames.
    """
    with open(file_path, 'r', encoding='utf-8') as file:
        data = json.load(file)

    followers = [follower['name'] for follower in data.get('users', [])]
    return followers

class Command(BaseCommand):
    help = 'Parses Twitter tweets and followers export JSON files and stores the data in the database.'

    def add_arguments(self, parser):
        parser.add_argument('tweets_file_path', type=str, help='Path to the Twitter tweets JSON export file.')
        parser.add_argument('followers_file_path', type=str, help='Path to the Twitter followers JSON export file.')

    def handle(self, *args, **kwargs):
        tweets_file_path = kwargs['tweets_file_path']
        followers_file_path = kwargs['followers_file_path']

        # Validate tweets file
        if not os.path.isfile(tweets_file_path):
            raise CommandError(f"Tweets file '{tweets_file_path}' does not exist.")

        # Validate followers file
        if not os.path.isfile(followers_file_path):
            raise CommandError(f"Followers file '{followers_file_path}' does not exist.")

        self.stdout.write(f"Parsing Twitter tweets from '{tweets_file_path}'...")
        tweets_data, tweet_participants = parse_twitter_tweets(tweets_file_path)
        self.stdout.write(f"Found {len(tweet_participants)} tweet participants and {len(tweets_data)} tweets.")

        self.stdout.write(f"Parsing Twitter followers from '{followers_file_path}'...")
        followers = parse_twitter_followers(followers_file_path)
        self.stdout.write(f"Found {len(followers)} followers.")

        # Create Participant instances for tweet participants
        tweet_participant_objects = {}
        for name in tweet_participants:
            participant, created = Participant.objects.get_or_create(name=name)
            tweet_participant_objects[name] = participant
            if created:
                self.stdout.write(f"Created participant: {name}")

        # Create Conversation instance (e.g., 'Twitter Activity')
        conversation, created = Conversation.objects.get_or_create(title='Twitter Activity')
        if created:
            self.stdout.write(f"Created conversation: {conversation.title}")

        # Add participants to conversation
        for participant in tweet_participant_objects.values():
            conversation.participants.add(participant)

        # Create Message instances
        message_count = 0
        for tweet in tweets_data:
            sender = tweet_participant_objects.get(tweet['sender'])
            if not sender:
                # If sender not found, create a new Participant
                sender, _ = Participant.objects.get_or_create(name=tweet['sender'])
                tweet_participant_objects[tweet['sender']] = sender
                self.stdout.write(f"Created participant: {tweet['sender']}")

            message_obj = Message(
                conversation=conversation,
                sender=sender,
                datetime=tweet['datetime'],
                content=tweet['content'],
                type=tweet['type']
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
            f"Successfully imported {message_count} tweets and {len(followers)} followers."
        ))