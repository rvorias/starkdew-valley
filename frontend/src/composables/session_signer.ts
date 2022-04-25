import { Provider, Account, getStarknet, toBN } from '@/starknet_wrapper'
import { getKeyPair, getStarkKey } from 'starknet/utils/ellipticCurve';

import { GAME_CONTRACT, ACCOUNT_CONTRACT, ACCOUNT_PRIVATE_KEY, SESSION_CONTRACT, SESSION_PRIVATE_KEY } from './contract_addresses';
export { ACCOUNT_CONTRACT, ACCOUNT_PRIVATE_KEY, SESSION_CONTRACT, SESSION_PRIVATE_KEY } from './contract_addresses';

export const KEY_PAIR = getKeyPair(SESSION_PRIVATE_KEY);

export function getSessionSigner() {
    let prov = new Provider({
        baseUrl:"https://hackathon-3.starknet.io",
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

export async function setSessionKey() {
    let account = getSessionSigner();
    let nonce = parseInt((await account.callContract({
        contractAddress: ACCOUNT_CONTRACT,
        entrypoint: "get_nonce",
        calldata: [],
    })).result[0], 16);
    console.log(account);
    let tx = await account.invokeFunction(
        {
            contractAddress: ACCOUNT_CONTRACT,
            entrypoint: "set_session_key",
            calldata: [await account.signer.getPubKey(), 90, GAME_CONTRACT, 0, nonce],
        }
    );
    console.log(tx);
};