import { Provider, Account, getStarknet, toBN } from '@/starknet_wrapper'
import { getKeyPair, getStarkKey } from 'starknet/utils/ellipticCurve';

import { GAME_CONTRACT, ACCOUNT_CONTRACT, ACCOUNT_PRIVATE_KEY, SESSION_CONTRACT, SESSION_PRIVATE_KEY } from './contract_addresses';
export { ACCOUNT_CONTRACT, ACCOUNT_PRIVATE_KEY, SESSION_CONTRACT, SESSION_PRIVATE_KEY } from './contract_addresses';

export const KEY_PAIR = getKeyPair(SESSION_PRIVATE_KEY);

var slowMode = false;

var sn: any;

export function getSessionSigner() {
    if (slowMode)
        return sn.account;

    let prov = new Provider({
        baseUrl: "https://hackathon-3.starknet.io",
    });
    let signer = new Account(prov, ACCOUNT_CONTRACT, KEY_PAIR);
    signer.estimateFee = async () => {
        return {
            amount: 0,
            unit: "wei"
        }
    };
    return signer;
}

export async function setSlowMode()
{
    sn = await getStarknet();
    slowMode = true;
}

import { reactive } from 'vue';
export var tx_store = reactive({
    last_tx_hash: undefined,
    nb_tx: 0,
});

export async function setSessionKey() {
    let account = getSessionSigner();
    let nonce = parseInt((await account.callContract({
        contractAddress: ACCOUNT_CONTRACT,
        entrypoint: "get_nonce",
        calldata: [],
    })).result[0], 16);
    let tx = await account.invokeFunction(
        {
            contractAddress: ACCOUNT_CONTRACT,
            entrypoint: "set_session_key",
            calldata: [await account.signer.getPubKey(), 900, GAME_CONTRACT, 0, nonce],
        }
    );
    tx_store.last_tx_hash = tx.transaction_hash;
};
