<script setup lang="ts">
    import { ref } from 'vue'
    
</script>

<template>
    <div class="flower" :style="styles">
    </div>
</template>

<style>
.flower {
  position: absolute;
  height: 16px;
  width: 16px;
  background: url(../assets/big.png);
}
</style>

<script lang="ts">
import { plantState } from '@/datastore';
import sprouts from "../assets/Atlas/weed_0.png?url"
import smol from "../assets/Atlas/weed_1.png?url"
import medium from "../assets/Atlas/weed_2.png?url"
import big from "../assets/Atlas/weed_3.png?url"

export default {
    data () {
		return {
			plantStateImageMap: {
                0: `url(${smol})`,
                1: `url(${smol})`,
                2: `url(${medium})`,
                3: `url(${big})`,
            }
		}
	},
    props: {
        x_coord: Number, 
        y_coord: Number,
        stage: Number,
    },
    computed: {
		styles () {
			return {
				transform:  `translate3d(${this.x_coord - 8}px, ${this.y_coord - 8}px, 0)`,
                background: this.plantStateImageMap[plantState.stage]
			} 
		}
	}
}
</script>
