export STARKNET_GATEWAY_URL=http://localhost:5000/
export STARKNET_FEEDER_GATEWAY_URL=http://localhost:5000/
export STARKNET_CHAIN_ID=SN_GOERLI
export STARKNET_NETWORK_ID=localhost

cd argent
nile compile contracts/SessionKey.cairo   
starknet deploy --contract artifacts/SessionKey.json 

# Contract address: 0x0067d37cbfbe55601dd24901427009d5495fec3e6120d43e99ac31c7125f062d
# Here update argent default address

nile compile contracts/ArgentAccount.cairo --account_contract
starknet deploy --contract artifacts/ArgentAccount.json

# Address 0x061d93e666009effec049a0ac5f79325d425251a7dfce9baf3f9db48dd1d3674

cd ../starkdew
nile compile
starknet deploy --contract artifacts/StarkVile.json 

# 0x0388396fe63011bd4fcaf0dfad90c73628395b0eaecb603d1e6030c58b3c62b6
