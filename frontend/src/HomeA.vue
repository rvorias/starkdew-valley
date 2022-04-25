<script setup lang="ts">
import homeA from '@/assets/homeA.png?url';
</script>

<template>
    <div :style="{ backgroundImage: `url(${homeA})` }" class="w-[1000px] h-[710px] bg-contain bg-no-repeat relative">
        <p class="w-full text-center relative top-[55%] ">
            <button @click="$router.push({ path: '/homeB' })" class="text-center bg-gradient-to-b from-gray-100 via-yellow-200 to-orange-400 px-2 py-1 rounded-lg">
                Start the game!
            </button>
        </p>
    </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue';
export default defineComponent({
})
</script>