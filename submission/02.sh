# Create a native segwit address and get the public key from the address.
#!/bin/bash

ADDRESS=$(bitcoin-cli -regtest getnewaddress "" bech32)
bitcoin-cli -regtest getaddressinfo "$ADDRESS" | jq -r '.pubkey'