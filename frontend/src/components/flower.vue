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
  height: 50px;
  width: 50px;
  background: url(../assets/big.png) -314px -8px;
}
</style>

<script lang="ts">

export default {
    props: {
        x_coord: Number, 
        y_coord: Number
    },
    computed: {
		styles () {
			return {
				transform:  `translate3d(${this.x_coord - 25}px, ${this.y_coord - 25}px, 0)`,

			}
		}
	}
}
</script>
