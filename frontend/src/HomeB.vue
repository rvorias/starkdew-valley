<script setup lang="ts">
import homeB from '@/assets/homeB.png?url';
</script>

<template>
    <div :style="{ backgroundImage: `url(${homeB})` }" class="w-[1000px] h-[710px] bg-contain bg-no-repeat relative flex flex-row justify-around items-center text-center">
        <div class="flex flex-col justify-center items-center text-center flex-1 p-20">
            <h3 class="text-2xl font-bold">Use your regular wallet</h3>
            <p class="my-8">This gives you full control, but will lead to more annoyance.</p><br>
            <button @click="slowMode" class="bg-yellow-500 px-2 py-1 rounded-lg disabled:bg-gray-300 disabled:text-gray-500" :disabled="status !== 'noclick'">
                🐢 Use your regular wallet
            </button>
        </div>
        <div class="flex flex-col justify-center items-center text-center flex-1 p-20">
            <h3 class="text-2xl font-bold">Use session key</h3>
            <p class="my-8">This will allow your browser to sign transactions automatically on your behalf.</p>
            <button @click="generateKeyAndGo" class="bg-yellow-500 px-2 py-1 rounded-lg disabled:bg-gray-300 disabled:text-gray-500" :disabled="status !== 'noclick'">
                🚀 Create a session key
            </button>
        </div>
        <p class="absolute top-[70%]" v-if="status === 'generating'">...Loading...</p>
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
