#!/usr/bin/env python3
import os
import sys
import asyncio
import logging
import re
from getpass import getpass
from telethon import TelegramClient, events
from telethon.tl.functions.messages import GetHistoryRequest

logging.basicConfig(level=logging.ERROR, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

API_ID = 20880525
API_HASH = '61044cd7bcfc324253d4a3ed0b45b4be'
BOT_USERNAME = '@TrueCaller1Bot'

SESSION_FILE = '.truecallercli'

RESPONSE_TIMEOUT = 3.0
EDIT_WAIT_TIME = 1.5

GREEN = '\033[92m'
RED = '\033[91m'
RESET = '\033[0m'

def process_bot_response(text):
    if not text or text.strip() == "":
        return f" \n{RED}User hasn't joined the group{RESET}\n "

    if "exceeded your daily search limit" in text.lower():
        return f" \n{RED}Daily search limit exceeded{RESET}\n "

    if "invalid number" in text.lower():
        return f" \n{RED}Invalid phone number{RESET}\n "

    try:
        tc_name_match = re.search(r"\*\*Name:\*\* `([^`]+)`", text)
        tc_name = tc_name_match.group(1) if tc_name_match else ""

        unknown_name_match = re.search(r"\*\*🔍 Unknown Says:\*\*\s+\*\*Name:\*\* `([^`]+)`", text)
        unknown_name = unknown_name_match.group(1) if unknown_name_match else ""

        name = tc_name
        if unknown_name and tc_name != unknown_name:
            name = f"'{tc_name}' or '{unknown_name}'"
        elif name:
            name = f"'{name}'"

        carrier_match = re.search(r"\*\*Carrier:\*\* `([^`]+)`", text)
        carrier = carrier_match.group(1) if carrier_match else ""

        country_match = re.search(r"\*\*Country: ([^*]+)\*\*", text)
        country = country_match.group(1).strip() if country_match else ""
        country = re.sub(r'🇮🇳|🇺🇸|🇬🇧|🇨🇦|🇦🇺|🇳🇿|🇪🇺|🇯🇵|🇰🇷|🇨🇳|🇷🇺|🇧🇷|🇲🇽|🇿🇦|🇸🇦|🇦🇪|🇮🇳|🇵🇰|🇧🇩|🇱🇰|🇳🇵|🇸🇬|🇲🇾|🇮🇩|🇵🇭|🇹🇭|🇻🇳|🇰🇭|🇱🇦|🇲🇲|', '', country).strip()

        location_match = re.search(r"\*\*Location:\*\* `([^`]+)`", text)
        location = location_match.group(1) if location_match else ""

        whatsapp_match = re.search(r"\[WhatsApp\]\(([^)]+)\)", text)
        whatsapp_link = whatsapp_match.group(1) if whatsapp_match else ""

        telegram_match = re.search(r"\[Telegram\]\(([^)]+)\)", text)
        telegram_link = telegram_match.group(1) if telegram_match else ""

        formatted_output = " \n"  # Start with space

        if name:
            formatted_output += f"{GREEN}Name:{RESET} {name}\n"
        if carrier:
            formatted_output += f"{GREEN}Carrier:{RESET} {carrier}\n"

        location_info = []
        if country:
            location_info.append(country)
        if location:
            location_info.append(location)

        if location_info:
            formatted_output += f"{GREEN}Location:{RESET} {', '.join(location_info)}\n"

        links = []
        if whatsapp_link:
            links.append(f"{GREEN}WhatsApp:{RESET} \"{whatsapp_link}\"")
        if telegram_link:
            links.append(f"{GREEN}Telegram:{RESET} \"{telegram_link}\"")

        if links:
            formatted_output += " | ".join(links) + "\n"

        formatted_output += " "

        return formatted_output

    except Exception as e:
        logger.error(f"Error formatting response: {e}")
        return f" \n{RED}Could not parse response: {e}{RESET}\n "

async def lookup_number(phone_number):
    """Look up a single phone number and return the formatted result"""
    client = TelegramClient(SESSION_FILE, API_ID, API_HASH, system_version="4.16.30-vxCUSTOM")

    try:
        await client.start()

        if not await client.is_user_authorized():
            return f" \n{RED}You need to log in first. Run the script without arguments once to set up authentication.{RESET}\n "

        try:
            bot_entity = await client.get_entity(BOT_USERNAME)
        except Exception as e:
            return f" \n{RED}Finding bot: {e}{RESET}\n "

        latest_message_text = None
        message_updated = asyncio.Event()

        @client.on(events.NewMessage(from_users=bot_entity.id))
        async def bot_message_handler(event):
            nonlocal latest_message_text
            latest_message_text = event.message.text
            message_updated.set()

        @client.on(events.MessageEdited(from_users=bot_entity.id))
        async def bot_edit_handler(event):
            nonlocal latest_message_text
            latest_message_text = event.message.text
            message_updated.set()

        async def get_last_bot_message():
            history = await client(GetHistoryRequest(
                peer=bot_entity,
                limit=1,
                offset_date=None,
                offset_id=0,
                max_id=0,
                min_id=0,
                add_offset=0,
                hash=0
            ))
            if history.messages:
                return history.messages[0]
            return None

        message_updated.clear()

        await client.send_message(bot_entity, phone_number)

        try:
            await asyncio.wait_for(message_updated.wait(), timeout=RESPONSE_TIMEOUT)
        except asyncio.TimeoutError:
            last_message = await get_last_bot_message()
            if last_message and last_message.text:
                latest_message_text = last_message.text
            else:
                return f" \n{RED}No response received from TrueCaller bot{RESET}\n "

        if latest_message_text and ("searching" in latest_message_text.lower() or
                                  "working" in latest_message_text.lower() or
                                  "processing" in latest_message_text.lower()):
            message_updated.clear()
            try:
                await asyncio.wait_for(message_updated.wait(), timeout=EDIT_WAIT_TIME)
            except asyncio.TimeoutError:
                last_message = await get_last_bot_message()
                if last_message and last_message.text != latest_message_text:
                    latest_message_text = last_message.text

        if latest_message_text:
            if latest_message_text.strip():
                return process_bot_response(latest_message_text)
            else:
                return f" \n{RED}User hasn't joined the group{RESET}\n "
        else:
            return f" \n{RED}No response received from TrueCaller bot{RESET}\n "

    except Exception as e:
        return f" \n{RED}{str(e)}{RESET}\n "
    finally:
        await client.disconnect()

async def main():
    if len(sys.argv) != 2:
        print(" ")
        print(f"{RED}Usage: python3 truecaller.py PHONE_NUMBER{RESET}")
        print(" ")
        sys.exit(1)

    phone_number = sys.argv[1]

    if not phone_number.startswith('+'):
        phone_number = '+91' + phone_number

    result = await lookup_number(phone_number)

    print(result)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except Exception as e:
        print(" ")
        print(f"{RED}{str(e)}{RESET}")
        print(" ")
        sys.exit(1)
