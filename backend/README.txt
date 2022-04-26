export STARKNET_GATEWAY_URL=https://hackathon-3.starknet.io/
export STARKNET_FEEDER_GATEWAY_URL=https://hackathon-3.starknet.io/
export STARKNET_CHAIN_ID=SN_GOERLI
export STARKNET_NETWORK_ID=hackathon-3

cd argent
nile compile contracts/SessionKey.cairo   
starknet deploy --contract artifacts/SessionKey.json 

# Contract address: 0x05445b794087a540c714788b29ce76b5ff9056a7cdb635effe4a6f5017492d30
# Here update argent default address

nile compile contracts/ArgentAccount.cairo --account_contract
starknet deploy --contract artifacts/ArgentAccount.json

# Address 0x0347ad5f0c88431ae90c66b064cce247a9bec8f13101c6a9e9c831db636f9e28

cd ../starkdew
nile compile
starknet deploy --contract artifacts/StarkVile.json 

# 0x0388396fe63011bd4fcaf0dfad90c73628395b0eaecb603d1e6030c58b3c62b6
