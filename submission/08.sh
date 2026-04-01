# What is the receiver's address in this partially signed transaction?
# transaction=cHNidP8BAHsCAAAAAhuVpgVRdOxkuC7wW2rvw4800OVxl+QCgezYKHtCYN7GAQAAAAD/////HPTH9wFgyf4iQ2xw4DIDP8t9IjCePWDjhqgs8fXvSIcAAAAAAP////8BigIAAAAAAAAWABTHctb5VULhHvEejvx8emmDCtOKBQAAAAAAAAAA

#!/bin/bash

PSBT="cHNidP8BAHsCAAAAAhuVpgVRdOxkuC7wW2rvw4800OVxl+QCgezYKHtCYN7GAQAAAAD/////HPTH9wFgyf4iQ2xw4DIDP8t9IjCePWDjhqgs8fXvSIcAAAAAAP////8BigIAAAAAAAAWABTHctb5VULhHvEejvx8emmDCtOKBQAAAAAAAAAA"

python3 << 'PYEOF'
import base64, struct

CHARSET = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l'

def bech32_polymod(values):
    GEN = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]
    chk = 1
    for v in values:
        b = chk >> 25
        chk = ((chk & 0x1ffffff) << 5) ^ v
        for i in range(5):
            chk ^= GEN[i] if ((b >> i) & 1) else 0
    return chk

def bech32_hrp_expand(hrp):
    return [ord(x) >> 5 for x in hrp] + [0] + [ord(x) & 31 for x in hrp]

def bech32_create_checksum(hrp, data):
    values = bech32_hrp_expand(hrp) + data
    polymod = bech32_polymod(values + [0,0,0,0,0,0]) ^ 1
    return [(polymod >> 5 * (5 - i)) & 31 for i in range(6)]

def convertbits(data, frombits, tobits, pad=True):
    acc, bits, ret = 0, 0, []
    for value in data:
        acc = (acc << frombits) | value
        bits += frombits
        while bits >= tobits:
            bits -= tobits
            ret.append((acc >> bits) & ((1 << tobits) - 1))
    if pad and bits:
        ret.append((acc << (tobits - bits)) & ((1 << tobits) - 1))
    return ret

psbt = base64.b64decode("cHNidP8BAHsCAAAAAhuVpgVRdOxkuC7wW2rvw4800OVxl+QCgezYKHtCYN7GAQAAAAD/////HPTH9wFgyf4iQ2xw4DIDP8t9IjCePWDjhqgs8fXvSIcAAAAAAP////8BigIAAAAAAAAWABTHctb5VULhHvEejvx8emmDCtOKBQAAAAAAAAAA")

#extract the unsigned transaction from the PSBT
tx = psbt[8:8+psbt[7]]

#skip version 4
off = 4
num_in = tx[off]; off += 1
for _ in range(num_in):
    off += 36; sl = tx[off]; off += 1 + sl + 4

#parse outputs and find the one that is a v0 segwit output, then convert to bech32 address
num_out = tx[off]; off += 1
for _ in range(num_out):
    value = struct.unpack('<Q', tx[off:off+8])[0]; off += 8
    spk_len = tx[off]; off += 1
    spk = tx[off:off+spk_len]; off += spk_len
    if value > 0 and spk[0] == 0x00 and spk[1] == 0x14:
        data = [0] + convertbits(spk[2:], 8, 5)
        checksum = bech32_create_checksum('bcrt', data)
        print('bcrt' + '1' + ''.join(CHARSET[d] for d in data + checksum))
        break
PYEOF