#!/bin/bash
# Fetch latest YouTube videos and save to Hugo data file
# Run before build or via cron on Cloudflare Pages

CHANNEL_ID="UCKe7UoTutc3xEVBU3o8cDig"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"

mkdir -p "$DATA_DIR"

curl -s "https://www.youtube.com/feeds/videos.xml?channel_id=$CHANNEL_ID" | python3 -c "
import sys, xml.etree.ElementTree as ET, json
ns = {'atom': 'http://www.w3.org/2005/Atom', 'yt': 'http://www.youtube.com/xml/schemas/2015'}
tree = ET.parse(sys.stdin)
root = tree.getroot()
videos = []
for entry in root.findall('atom:entry', ns)[:4]:
    vid = entry.find('yt:videoId', ns).text
    title = entry.find('atom:title', ns).text
    published = entry.find('atom:published', ns).text[:10]
    videos.append({'id': vid, 'title': title, 'date': published})
json.dump(videos, open('$DATA_DIR/youtube.json', 'w'), ensure_ascii=False, indent=2)
print(f'Updated {len(videos)} videos')
"
