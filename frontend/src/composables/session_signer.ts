import { Provider, Account, getStarknet, toBN } from '@/starknet_wrapper'
import { getKeyPair, getStarkKey } from 'starknet/utils/ellipticCurve';

export const ACCOUNT_CONTRACT = "0x03eaf6c577e25244edd4d64b4341de947d6a3e2cc17ad9755f85dc6bf4383240"
export const ACCOUNT_PRIVATE_KEY = 123456
export const SESSION_CONTRACT = "0x0327ab3f2f94daf4f4b5eecf47130efc273b3f5a956f0442c7300a39d47ef02a"
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