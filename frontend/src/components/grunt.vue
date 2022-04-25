<script setup lang="ts">
    import { ref } from 'vue'
    
</script>

<template>
    <div class="grunt" v-bind:style="styles">

    </div>
</template>

<script lang="ts">
export default {
	data () {
		return {
			x:              50,
			y:              50,
			animationName:  '',
			transitionTime: 0
		}
	},

	computed: {
		styles () {
			return {
				transform:  `translate3d(${this.x - 25}px, ${this.y - 25}px, 0)`,
				transition: `all ${this.transitionTime}s linear`,
				animation:  `${this.animationName} .8s steps(4) infinite`,
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

			this.speak();
		}
	},

	ready () {
		this.$el.addEventListener("transitionend", () => {
			this.animationName = '';
		}, false);

		// Private methods

		this.speak = function() {
			var audioElement = document.createElement('audio');
			var tracks       = [ 'https://res.cloudinary.com/picturesbase/video/upload/ac_mp3/v1465834936/grunt7_r4oygy.mp3',  'https://res.cloudinary.com/picturesbase/video/upload/ac_mp3/v1465834935/grunt3_lngkuu.mp3', 'https://res.cloudinary.com/picturesbase/video/upload/ac_mp3/v1465834936/grunt2_r3kqr7.mp3'];
			var track        = tracks[Math.floor(Math.random() * tracks.length)];

			audioElement.setAttribute('src', track);
			audioElement.play();
		};

		this.getCardinal = function(angle) {
			var directions = ["SE", "S", "SW", "W", "NW", "N", "NE", "E"];
			var index      = angle - 22.5;
			index < 0      && (index += 360);
			index          = parseInt(index / 45);

			return(directions[index]);
		};
	},

	events: {
		'mapClick': function(coords) {
			this.move(coords.x, coords.y);
		}
	}
}
</script>
