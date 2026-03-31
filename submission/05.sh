# Create a partially signed transaction from the details below

# Amount of 20,000,000 satoshis to this address: 2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP 
# Use the UTXOs from the transaction below
# transaction="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

#!/bin/bash

rawtx="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba₀8d3e3edee9172f₀c97f₀46266fb₀2473₀44₀22₀5fee5796₀883f6d69acf283192785f1147a3e11b97cf₀1a21₀cf7e99165₀c₀4₀22₀483de1c5₁af5₀2744₀565caead6c₁₀64bac92cb477b536e₀6₀f₀₀4c733c45₁28₀1₂₁₀₂d₁₂b6b9₀7c5a₁ef０₂5d０9２4a₂9e35４f６d７b１b１１b５a７ddff９４７１０d６f００４２f３da８０００００００"

output_address="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
amount_sats=20000000

decoded=$(bitcoin-cli -regtest decoderawtransaction "$rawtx")
txId=$(echo "$decoded" | jq -r '.txid')
vout=0

#convert sats to btc for createpsbt
amount_btc=$(echo "scale=8; $amount_sats / 100000000" | bc)

#create the PSBT
psbt=$(bitcoin-cli -regtest createpsbt \
  "[{\"txid\":\"$txId\",\"vout\":$vout}]" \
  "{\"$output_address\":$amount_btc}")

echo "$psbt"