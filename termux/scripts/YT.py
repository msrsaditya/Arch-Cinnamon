import json
import subprocess
import re
import sys
url = sys.argv[1]
video_id = re.search(r'(?:v=|/)([a-zA-Z0-9_-]{11})', url).group(1)
result = subprocess.run(['youtube_transcript_api', video_id, '--format', 'json', '--languages',
                        'en', 'en-US', 'hi', 'es', 'pt', 'fr', 'de', 'ja', 'ko', 'ar', 'zh', 'ru', 'it'],
                       capture_output=True, text=True)
data = json.loads(result.stdout)
text_parts = []
for segment in data[0]:
    text_parts.append(segment['text'].strip())
paragraph = ' '.join(text_parts)
paragraph = ' '.join(paragraph.split())
with open('/storage/emulated/0/Download/Transcript.txt', 'w', encoding='utf-8') as f:
    f.write(paragraph)
print("Done")
