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
  height: 32px;
  width: 32px;
  background: url(../assets/Atlas/weed_0.png);
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
                0: `url(${sprouts})`,
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

            var mappedStage = 0;
            const scalingFactor = 500;

            if (this.stage < scalingFactor) {
                mappedStage = 0;
            }
            else if (this.stage < scalingFactor*2) {
                mappedStage = 1;
            }
            else if (this.stage < scalingFactor*3) {
                mappedStage = 2;
            }
            else {
                mappedStage = 3;
            }

			return {
				transform:  `translate3d(${this.x_coord - 8}px, ${this.y_coord - 8}px, 0)`,
                background: this.plantStateImageMap[mappedStage]
			} 
		}
	}
}
</script>
