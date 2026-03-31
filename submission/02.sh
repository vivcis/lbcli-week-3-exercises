# Create a native segwit address and get the public key from the address.
#!bin/bash

bitcoin-cli -named getaddressinfo address=$(bitcoin-cli -named getnewaddress address_type=bech32 | jq -r .result) | jq -r .result.pubkey    