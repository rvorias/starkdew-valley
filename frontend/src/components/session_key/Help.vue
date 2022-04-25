<template>
    <div class="bg-white relative top-[1000px]">
        <h1>ToTo</h1>
        <p><button @click.stop="setSessionKey" class="bg-gray-500">Create a temp key</button></p>
        <p><button @click.stop="doSomething" class="bg-gray-500">Do Something</button></p>
        <p><input type="text" size="70" v-model="session_contract"/><button class="bg-black text-white rounded-md" @click="setSessionContract">Set Contract</button><br/> Test - {{ getSessionKey() }} {{ sessionKeyData }}</p>
    </div>
</template>

<script lang="ts">

const ACCOUNT_CONTRACT = "0x07ea456d5af6c8b5f7499c79e48260dd37148be27f37ed4f314e5166d5c7480e"
const ACCOUNT_PRIVATE_KEY = 123456
const SESSION_CONTRACT = "0x007fc4ee71dcd9e993e673315b7f5afd84bde6a945e8023769b802191e4783d5"
const SESSION_PRIVATE_KEY = 0xcafefade

import { makeSigner } from './Help';
import { Provider, Account, getStarknet, toBN } from '@/starknet_wrapper'

import { getKeyPair } from 'starknet/utils/ellipticCurve';

import { starkvile } from '@/composables/contract'


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
            balance: 0,
            session_contract: SESSION_CONTRACT,
            sessionKeyData: "",
        }
    },
    async mounted() {
        this.balance = await starkvile.get_wheat('0x015c618ef96e0df85832cb1dd514c4fa4bb5b38ecabfe0464808bc8645fbc6f4')
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
            let account = this.getSigner();
            let nonce = parseInt((await account.callContract({
                contractAddress: ACCOUNT_CONTRACT,
                entrypoint: "get_nonce",
                calldata: [],
            })).result[0], 16);
            console.log("Calling set_session_key_contract")
            let tx = await account.execute(
                [{
                    contractAddress: ACCOUNT_CONTRACT,
                    entrypoint: "set_session_key_contract",
                    calldata: [SESSION_CONTRACT],
                }],
                undefined,
                {
                    nonce: nonce,
                    maxFee: 0,
                }
            );
            console.log(tx);
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
                    contractAddress: ACCOUNT_CONTRACT,
                    entrypoint: "set_session_key",
                    calldata: [SESSION_PRIVATE_KEY, 0],
                }],
                undefined,
                {
                    nonce: nonce,
                    maxFee: 0,
                }
            );
            console.log(tx);
        },
        getSessionKey() {
            let account = this.getSigner();
            account.callContract({
                contractAddress: SESSION_CONTRACT,
                entrypoint: "get_session_key",
                calldata: [toBN(ACCOUNT_CONTRACT).toString()],
            }).then(x => { console.log(x.result); this.sessionKeyData = x.result.join(' ') });
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