import pytest
import asyncio
from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.public.abi import get_selector_from_name
from utils.utilities import deploy, str_to_felt

user1 = 0x69221ff9023c4d7ba9123f0f9c32634c23fc5776d86657f464ecb51fd811445
user2 = 0x72648c3b1953572d2c4395a610f18b83cca14fa4d1ba10fc4484431fd463e5c

@pytest.fixture(scope='module')
def event_loop():
    return asyncio.new_event_loop()

@pytest.fixture(scope='module')
async def get_starknet():
    starknet = await Starknet.empty()
    return starknet

@pytest.mark.asyncio
async def test_multicall(get_starknet):
    starknet = get_starknet
    multicall = await deploy(starknet, "contracts/Multicall.cairo")
    erc20_1 = await deploy(starknet, "contracts/lib/ERC20.cairo", [str_to_felt('token1'), str_to_felt('T1'), user1])
    erc20_2 = await deploy(starknet, "contracts/lib/ERC20.cairo", [str_to_felt('token2'), str_to_felt('T2'), user2])

    response = await multicall.aggregate([
        erc20_1.contract_address, get_selector_from_name('decimals'), 0,
        erc20_1.contract_address, get_selector_from_name('balanceOf'), 1, user1,
        erc20_2.contract_address, get_selector_from_name('balanceOf'), 1, user2
    ]).call()

    assert response.result.result[0] == 18
    assert response.result.result[1] == 1000
    assert response.result.result[3] == 1000