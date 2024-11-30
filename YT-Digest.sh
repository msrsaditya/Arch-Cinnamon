#!/bin/bash

# File Containing URLs
urls_file="$1"

# Activate the Virtual Environment
source ~/Documents/Projects/.venv/bin/activate

# Run Ollama Serve in the Background Suppressing All Output
ollama serve > /dev/null 2>&1 &

# Capture the PID of the Ollama Serve Process
ollama_pid=$!

# Disown the Process to Avoid Job Notifications
disown

# Initialize Video Counter
video_counter=1

# Create Daily Digest and Daily Reader Directories
mkdir -p "Daily Digest" "Daily Reader"

# Read URLs from the File and Process Each URL
while IFS= read -r url || [[ -n "$url" ]]; do

    # Extract the Title of the YouTube Video
    echo "Extracting Title of Video $video_counter..."
    title=$(yt-dlp --no-warnings --get-title "$url")

    # Get the Video ID from the URL
    video_id=$(echo "$url" | sed 's/.*v=\([^&]*\).*/\1/')

    # Get the YouTube Video's Transcript Using YouTube Transcript API
    echo "Extracting Transcript of Video $video_counter..."
    transcript=$(python -m youtube_transcript_api "$video_id" --languages en --format text)

    # Remove Line Breaks and Convert Transcript Into One Single Paragraph for Easy Reading by Model
    transcript=$(echo "$transcript" | tr '\n' ' ')

    # Define Output Files
    output_file="${title}"
    output_file_html="Daily Reader/$output_file.html"
    output_file_wav="Daily Digest/$output_file.wav"

    # Generate Temporary Markdown for HTML Conversion and Temporary TXT for Piper Use
    temp_md=$(mktemp).md
    temp_txt=$(mktemp).txt

    # Give the Formatted Transcript to the Llama3.2 Model for Summary
    echo "Generating Summary for Video $video_counter..."
    (echo "$transcript" | ollama run llama3.2 "Summarize this YouTube Video Transcript: $transcript") > "$temp_md"

    # Convert Markdown to HTML and TXT Using Pandoc for Easy Readability
    echo "Converting Video $video_counter into Readable Format..."
    pandoc "$temp_md" -s -o "$output_file_html" --css=style.css --metadata title="$title"
    pandoc "$temp_md" -t plain -o "$temp_txt"
    cp style.css "Daily Reader"

    # Create Audio Version Using Text from Markdown
    echo "Converting Video $video_counter into Audible Format..."
    cat "$temp_txt" | ~/.piper/piper --length_scale 1.5 --model ~/.piper/en_US-danny-low.onnx --output_file "$output_file_wav" > /dev/null 2>&1

    # Remove temporary markdown file
    rm "$temp_md" "$temp_txt"

    # Print Success Acknowledgment Message
    echo "Video $video_counter Successfully Processed!"
    echo "-------------------------------------------"

    # Increment the video counter
    ((video_counter++))
done < "$urls_file"

# Deactivate the Virtual Environment
deactivate

# Kill the Ollama Serve Process After Getting the Summary
kill $ollama_pid

# Open All HTML Files in the Browser
# open Daily\ Reader/*.html

# Copy Files to Mac after Completion
scp -r ~/Documents/Projects/YT-Digest/Daily\ Digest shashank@192.168.29.9:~/Downloads
scp -r ~/Documents/Projects/YT-Digest/Daily\ Reader shashank@192.168.29.9:~/Downloads
