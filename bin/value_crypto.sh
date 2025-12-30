#!/bin/sh

API="https://api.kraken.com/0/public/Ticker"

quote=$(curl -sf $API?pair=BTCEUR | jq -r ".result.XXBTZEUR.c[0]")
quote=$(LANG=C printf "%.2f" "$quote")

echo "#1 $quote €" | awk '{printf "BTC %'\''0.2f€", $2}' | sed 's/\,/./;:a;s/\B[0-9]\{3\}\>/.&/;ta'