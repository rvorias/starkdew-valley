import { Provider, Account, getStarknet, toBN } from '@/starknet_wrapper'
import { getKeyPair, getStarkKey } from 'starknet/utils/ellipticCurve';

export const ACCOUNT_CONTRACT = "0x042d69746de5073a073ee738c4366b845462ebbdaae470113c71a8fc6f20e1fb"
export const ACCOUNT_PRIVATE_KEY = 123456
export const SESSION_CONTRACT = "0x0500631802ee5beaa484985feb7f071907c74416eb3ddf49b7cacf60bc4d867c"
export const SESSION_PRIVATE_KEY = 0xcafebabe

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
            calldata: [await account.signer.getPubKey(), 60, nonce],
        }
    );
    console.log(tx);
};