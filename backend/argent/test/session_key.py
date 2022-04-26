import os
import pytest
import asyncio
from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.compiler.compile import compile_starknet_files, compile_starknet_codes

from starkware.starknet.core.os.transaction_hash.transaction_hash import calculate_transaction_hash_common, TransactionHashPrefix
from starkware.starknet.public.abi import get_selector_from_name
from starkware.starknet.definitions.general_config import StarknetChainId

from utils.Signer import Signer
from utils.TransactionSender import get_transaction_hash


@pytest.fixture(scope='module')
def event_loop():
    return asyncio.new_event_loop()

@pytest.fixture(scope='module')
async def get_starknet():
    starknet = await Starknet.empty()
    return starknet

def compile(path):
    return compile_starknet_files(
        files=[os.path.join("contracts/", path)],
        debug_info=True
    )

@pytest.fixture(scope="session")
def compiled_session_key():
    return compile("SessionKey.cairo")

def calc_hash(account: int, call_array, calldata, nonce):
    TRANSACTION_VERSION = 0
    max_fee = 0

    execute_calldata = [
        len(call_array),
        *[x for t in call_array for x in t],
        len(calldata),
        *calldata,
        nonce]

    return calculate_transaction_hash_common(
        TransactionHashPrefix.INVOKE,
        TRANSACTION_VERSION,
        account,
        get_selector_from_name('authenticate_maybe'),
        execute_calldata,
        max_fee,
        StarknetChainId.TESTNET.value,
        []
    )

signer = Signer(123456789987654321)

@pytest.mark.asyncio
async def test_check_call(get_starknet: Starknet, compiled_session_key):
    contract = await get_starknet.deploy(contract_def=compiled_session_key)
    print(contract.struct_manager._contract_structs)
    await contract.set_session_key(contract.struct_manager.get_contract_struct("KeyConf")(
        public_key=signer.public_key,
        time=30,
        contract=0,
        total_value=0
    )).invoke(caller_address=0xcafe)

    #hash = calc_hash(0xcafe, [], [], 0)
    #print(hash)
    #signature = list(signer.sign(hash))
    #print(signature)
    #await contract.authenticate_maybe([], [], 0).call(caller_address=0xcafe, signature=signature)

    await contract.test_function([], [], 0)
