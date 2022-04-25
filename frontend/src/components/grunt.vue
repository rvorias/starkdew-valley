<script setup lang="ts">
    import { ref } from 'vue'
    
</script>

<template>
    <div class="grunt" :style="styles">
    </div>
</template>

<style>
.grunt {
  position: absolute;
  height: 50px;
  width: 50px;
  background: url('https://res.cloudinary.com/picturesbase/image/upload/v1465832954/sprite_f5cw4a.png') -314px -8px;
}
</style>


<script lang="ts">
import { gruntState } from '@/datastore';

export default {
	data () {
		return {
			transitionTime: 0
		}
	},

	computed: {
		styles () {
			return {
				transform:  `translate3d(${gruntState.x - 25}px, ${gruntState.y - 25}px, 0)`,
				transition: `all ${this.transitionTime}s linear`,
				animation:  `${gruntState	.animationName} .8s steps(4) infinite`,
			}
		}
	},

	methods: {
		move (x, y) {
			this.x = x;
			this.y = y;

			var currentCoords = {
				x: Math.floor(this.$el.getBoundingClientRect().left + 25),
				y: Math.floor(this.$el.getBoundingClientRect().top  + 25)
			}

			var yDist     = this.y - currentCoords.y;
			var xDist     = this.x - currentCoords.x;
			var direction = this.getCardinal(Math.atan2(yDist, xDist) * 180 / Math.PI);

			this.animationName  = `walk-${direction}`;
			this.transitionTime = Math.sqrt(xDist * xDist + yDist * yDist) / 75;
		}
	},
}
</script>
