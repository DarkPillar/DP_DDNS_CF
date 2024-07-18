#!/bin/bash

#Authored Salvador Aubert (DarkPillar.net) and licensed under Apache 2.0

# RECORD/ZONE IDs can be obtained
# through your account-wide audit log after having saved a change to your
# desired record.

# Generate an API token that is able to both Read and Edit DNS records.
# Zone Resources should include all zones from an account.
# Select the account associated with the zone you wish to edit.
# Generate the API token and copy the one-time token id to $API_TOKEN.
ZONE_ID="Your Zone ID" 
RECORD_ID="Your Record ID"
API_TOKEN="Your API Token"
DOMAIN="The subdomain you wish to associate with your IP"
IP_FILE="/tmp/current_ip.txt"

# Get the current public IP address
CURRENT_IP=$(curl -s http://ipv4.icanhazip.com)

# Check if the IP file exists and compare with the current IP
if [ -f $IP_FILE ]; then
    OLD_IP=$(cat $IP_FILE)
else
    OLD_IP=""
fi

# If the IP has changed or if this is the first run, update Cloudflare
if [ "$CURRENT_IP" != "$OLD_IP" ]; then
    echo "IP has changed to $CURRENT_IP. Updating Cloudflare record..."
    
    # Update the Cloudflare DNS record
    RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"$DOMAIN\",\"content\":\"$CURRENT_IP\",\"ttl\":120,\"proxied\":false}")

    # Check if the update was successful
    if echo $RESPONSE | grep -q '"success":true'; then
        echo "DNS record updated successfully."
        echo $CURRENT_IP > $IP_FILE
    else
        echo "Failed to update DNS record."
        echo "Response: $RESPONSE"
    fi
else
    echo "IP has not changed. No update needed."
fi
