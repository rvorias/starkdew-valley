<template>
    <div class="bg-white w-[1100px]">
        <h1>Async helper</h1>
        <p>
            <button @click.stop="setSessionKey" class="bg-gray-500 mx-1">Create a temp key</button>
            <button @click.stop="doSomething" class="bg-gray-500 mx-1">Claim Worker</button>
            <button @click.stop="resetState" class="bg-gray-500 mx-1">Reset State</button>
        </p>
        <p><input type="text" size="70" v-model="session_contract"/><button class="bg-black text-white rounded-md" @click="setSessionContract">Set Contract</button><br/> Test - {{ getSessionKey() && false || '' }} {{ sessionKeyData }}</p>
    </div>
</template>

<script lang="ts">

import {
    setSessionKey,
    getSessionSigner,
    ACCOUNT_CONTRACT,
    ACCOUNT_PRIVATE_KEY,
    SESSION_CONTRACT,
    SESSION_PRIVATE_KEY
} from '@/composables/session_signer';

import { GAME_CONTRACT } from '@/composables/contract_addresses';

import { makeSigner } from './Help';
import { Provider, Account, getStarknet, toBN } from '@/starknet_wrapper'

import { getKeyPair } from 'starknet/utils/ellipticCurve';

import { starkvile } from '@/composables/contract'

import { defineComponent } from 'vue';
export default defineComponent({
    data() {
        return {
            balance: 0,
            session_contract: SESSION_CONTRACT,
            sessionKeyData: "",
        }
    },
    methods: {
        getSigner() {
            let prov = new Provider({
                baseUrl:"https://hackathon-3.starknet.io",
            });
            let signer = new Account(prov, ACCOUNT_CONTRACT, getKeyPair(ACCOUNT_PRIVATE_KEY));
            return signer;
        },
        async setSessionContract() {
            let account = getSessionSigner();
            let nonce = parseInt((await account.callContract({
                contractAddress: ACCOUNT_CONTRACT,
                entrypoint: "get_nonce",
                calldata: [],
            })).result[0], 16);
            console.log("Calling set_session_key_contract")
            let tx = await account.invokeFunction(
                {
                    contractAddress: ACCOUNT_CONTRACT,
                    entrypoint: "set_session_key_contract",
                    calldata: [this.session_contract, nonce],
                },
                undefined,
                {
                    nonce: nonce,
                    maxFee: 0,
                }
            );
            console.log(tx);
        },
        async setSessionKey() {
            setSessionKey();
        },
        async getSessionKey() {
            let account = this.getSigner();
            const key_data = await account.callContract({
                contractAddress: SESSION_CONTRACT,
                entrypoint: "get_session_key",
                calldata: [toBN(ACCOUNT_CONTRACT).toString()],
            })
            this.sessionKeyData = key_data.result.join(' ') + ` Time left ${900 - Math.round(Date.now()/1000 - key_data.result[2].toString())}`;
        },
        async doSomething() {
            let account = getSessionSigner();
            let nonce = parseInt((await account.callContract({
                contractAddress: ACCOUNT_CONTRACT,
                entrypoint: "get_nonce",
                calldata: [],
            })).result[0], 16);
            /*
            let tx = await account.execute(
                [{
                    contractAddress: SESSION_CONTRACT,
                    entrypoint: "get_session_key",
                    calldata: [toBN(ACCOUNT_CONTRACT).toString()],
                }],
                undefined,
                {
                    nonce: nonce,
                    maxFee: 0,
                }
            );*/
            console.log(await starkvile.claim_worker());
        },
        async resetState() {
            let account = getSessionSigner();
            let nonce = parseInt((await account.callContract({
                contractAddress: ACCOUNT_CONTRACT,
                entrypoint: "get_nonce",
                calldata: [],
            })).result[0], 16);
            let tx = await account.execute(
                [{
                    contractAddress: GAME_CONTRACT,
                    entrypoint: "reset_state",
                    calldata: [],
                }],
                undefined,
                {
                    nonce: nonce,
                    maxFee: 0,
                }
            );
            console.log(tx);
        },
        async incrementNonce() {
            let account = getSessionSigner();
            let nonce = parseInt((await account.callContract({
                contractAddress: ACCOUNT_CONTRACT,
                entrypoint: "get_nonce",
                calldata: [],
            })).result[0], 16);
            let tx = await account.execute(
                [{
                    contractAddress: SESSION_CONTRACT,
                    entrypoint: "get_session_key",
                    calldata: [toBN(ACCOUNT_CONTRACT).toString()],
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