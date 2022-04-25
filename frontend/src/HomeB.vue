<script setup lang="ts">
import homeB from '@/assets/homeB.png?url';
</script>

<template>
    <div :style="{ backgroundImage: `url(${homeB})` }" class="w-[1000px] h-[710px] bg-contain bg-no-repeat relative flex flex-col justify-center items-center text-center">
        <div>
            <button @click="slowMode" class="bg-yellow-500 px-2 py-1 rounded-lg disabled:bg-gray-300 disabled:text-gray-500" :disabled="status !== 'noclick'">
                Use your regular wallet
            </button>
        </div>
        <p>I want to play StarkDew Valley for 2min</p>
        <p>This will allow your browser to sign transactions automatically on your behalf</p>
        <button @click="generateKeyAndGo" class="bg-gradient-to-b from-gray-100 via-yellow-200 to-orange-400 px-2 py-1 rounded-lg disabled:bg-gray-300 disabled:text-gray-500" :disabled="status !== 'noclick'">
            Create a 2-hour session key and start playing
        </button>
        <p v-if="status === 'generating'">...Loading...</p>
    </div>
</template>

<script lang="ts">
import { getStarknet } from 'get-starknet';

import { setSessionKey, setSlowMode } from '@/composables/session_signer';

import { defineComponent } from 'vue';
export default defineComponent({
    data() {
        return {
            status: "noclick" as 'noclick' | 'waiting' | 'generating',
        }
    },
    methods: {
        async slowMode() {
            let t = setSlowMode();
            let sn = await getStarknet();
            await sn.enable();
            this.status = 'waiting';
            try {
                await sn.account.execute({
                    contractAddress: "0xcafe",
                    entrypoint: "claim_worker",
                    calldata: [],
                })
            } catch(_) {}
            this.status = 'generating';
            await new Promise((resolve) => setTimeout(() => resolve(), 2500));
            await t;
            this.$router.push({ path: '/game' })
        },
        async generateKeyAndGo() {
            let settingKey = setSessionKey();
            let sn = await getStarknet();
            await sn.enable();
            this.status = 'waiting';
            try {
                await sn.account.execute({
                    contractAddress: "0xcafe",
                    entrypoint: "create_ephemereal_key",
                    calldata: [],
                })
            } catch(_) {}
            this.status = 'generating';
            await new Promise((resolve) => setTimeout(() => resolve(), 2500));
            await settingKey;
            this.$router.push({ path: '/game' })
        }
    }
})
</script>
