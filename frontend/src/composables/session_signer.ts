import { Provider, Account, getStarknet, toBN } from '@/starknet_wrapper'
import { getKeyPair } from 'starknet/utils/ellipticCurve';

export const ACCOUNT_CONTRACT = "0x07ea456d5af6c8b5f7499c79e48260dd37148be27f37ed4f314e5166d5c7480e"
export const ACCOUNT_PRIVATE_KEY = 123456
export const SESSION_CONTRACT = "0x007fc4ee71dcd9e993e673315b7f5afd84bde6a945e8023769b802191e4783d5"
export const SESSION_PRIVATE_KEY = 0xcafefade

export function getSessionSigner() {
    let prov = new Provider({
        baseUrl:"https://hackathon-3.starknet.io",
    });
    let signer = new Account(prov, ACCOUNT_CONTRACT, getKeyPair(SESSION_PRIVATE_KEY));
    return signer;
}