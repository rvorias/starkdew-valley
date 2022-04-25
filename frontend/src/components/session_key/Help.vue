<template>
    <div class="bg-white">
        <h1>ToTo</h1>
        <button @click.stop="setSessionKey" class="bg-gray-500">Create a temp key</button>
        <button @click.stop="doSomething" class="bg-gray-500">Do Something</button>
    </div>
</template>

<script lang="ts">

const ACCOUNT_CONTRACT = "0x04b5f4857ebb588bfc964edb773791018cb7678bf55ca6e5fdcfadaf0e26114c"
const ACCOUNT_PRIVATE_KEY = 123456
const SESSION_PRIVATE_KEY = 0xcafefade

import { makeSigner } from './Help';
import { Provider, Account, getStarknet } from '@/starknet_wrapper'

import { getKeyPair } from 'starknet/utils/ellipticCurve';

export function getSessionSigner() {
    let prov = new Provider({
        baseUrl:"https://hackathon-3.starknet.io",
    });
    let signer = new Account(prov, ACCOUNT_CONTRACT, getKeyPair(SESSION_PRIVATE_KEY));
    return signer;
}

import { defineComponent } from 'vue';
export default defineComponent({
    data() {
        return {

        }
    },
    async mounted() {
        let starknet = await getStarknet();
        starknet.enable();
    },
    methods: {
        getSigner() {
            let prov = new Provider({
                baseUrl:"https://hackathon-3.starknet.io",
            });
            let signer = new Account(prov, ACCOUNT_CONTRACT, getKeyPair(ACCOUNT_PRIVATE_KEY));
            return signer;
        },
        async setSessionKey() {
            let account = this.getSigner();
            let nonce = parseInt((await account.callContract({
                contractAddress: ACCOUNT_CONTRACT,
                entrypoint: "get_nonce",
                calldata: [],
            })).result[0], 16);
            let tx = await account.execute(
                [{
                    contractAddress: "0x04f0875d1a67952a0ecedf9fa62c60ce6f3d29b70e6ad28199b0310bffe1ef0b",
                    entrypoint: "set_session_key",
                    calldata: [SESSION_PRIVATE_KEY],
                }],
                undefined,
                {
                    nonce: nonce,
                    maxFee: 0,
                }
            );
            console.log(tx);
        },
        async doSomething() {
            let account = this.getSigner();
            let nonce = parseInt((await account.callContract({
                contractAddress: ACCOUNT_CONTRACT,
                entrypoint: "get_nonce",
                calldata: [],
            })).result[0], 16);
            let session = getSessionSigner();
            let tx = await session.execute(
                [{
                    contractAddress: ACCOUNT_CONTRACT,
                    entrypoint: "get_signer",
                    calldata: [],
                }],
                undefined,
                {
                    nonce: nonce,
                    maxFee: 0,
                }
            );
            console.log(tx);
        }
    }
})
</script>