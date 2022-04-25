import pytest
import asyncio
import json
from openzeppelin.tests.utils import Signer, uint, str_to_felt, from_uint, felt_to_str
import time
from tests.conftest import set_block_timestamp

NUM_SIGNING_ACCOUNTS = 2
STAKE_TIME = 180
DAY_LENGTH = 30
CLAIM_AMOUNT = 10
signer = Signer(123456789987654321)

@pytest.mark.asyncio
@pytest.mark.parametrize('account_factory', [dict(num_signers=NUM_SIGNING_ACCOUNTS)], indirect=True)
async def test_farm(farm_factory):
    admin_account, admin_key, starkvile, starknet = farm_factory

    await signer.send_transaction(
        account=admin_account, to=starkvile.contract_address, selector_name='claim_worker', calldata=[]
    )

    # print(starkvile.contract_address)

    players_workers = await starkvile.get_workers(admin_account.contract_address).call()

    assert players_workers.result.workers == 1

    await signer.send_transaction(
        account=admin_account, to=starkvile.contract_address, selector_name='build_farm', calldata=[0,0]
    )

    set_block_timestamp(starknet.state, round(time.time()) + STAKE_TIME)

    await signer.send_transaction(
        account=admin_account, to=starkvile.contract_address, selector_name='claim_resources', calldata=[0,0,0]
    )

    await signer.send_transaction(
        account=admin_account, to=starkvile.contract_address, selector_name='build_farm', calldata=[1,0]
    )

    players_wheat = await starkvile.get_wheat(admin_account.contract_address).call()

    print(players_wheat.result.wheat)