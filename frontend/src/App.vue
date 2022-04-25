<script setup lang="ts">
// This starter template is using Vue 3 <script setup> SFCs
// Check out https://vuejs.org/api/sfc-script-setup.html#script-setup
import grunt from './components/grunt.vue'
import flower from './components/flower.vue'
import scene from './components/scene.vue'
import farm from './components/farm.vue'

import HelpAsync from './components/session_key/HelpAsync.vue';
</script>

<template>
  <div id="app" @click="handleClick">
      <scene></scene>
      <farm></farm>
      <HelpAsync></HelpAsync>
      <grunt></grunt>
      <flower  v-for="flower in flower_coords" :x_coord="flower.x" :y_coord="flower.y"></flower>
  </div>
</template>

<script lang="ts">
import { gruntState, controller } from '@/datastore';

export default {
  data() {
    return {
      flower_coords: [{ x: 100, y: 100}, {x:500, y:500}]
    }
  },

  mounted () {
    window.addEventListener('keydown', this.handleControlDown);
    window.addEventListener('keyup', this.handleControlUp);
    setInterval(this.moveGrunt, 1);
  },
  methods: {
    distance(x1, y1, x2, y2) {
      var distance = Math.sqrt((Math.pow(x1-x2,2))+(Math.pow(y1-y2,2)))
      return distance
    },
    getHarvestable() {
      var harvestable_flower_coord = null

      this.flower_coords.forEach((flower, index) => {
        var curr_dist = this.distance(flower.x, flower.y, gruntState.x, gruntState.y)
        if (curr_dist < 50) {
          harvestable_flower_coord = flower
        }
      });
      return harvestable_flower_coord
    },

    handleClick(event: MouseEvent) {
      var harvestable = this.getHarvestable()
      if (harvestable == null) {
        // Plant flowers
        // Use gruntState.x, gruntState.y
        this.flower_coords.push({x: gruntState.x, y: gruntState.y})
      }
      else {
        this.flower_coords.forEach((flower, index) => {
          if (harvestable.x == flower.x && harvestable.y == flower.y) {
            // this is where you harvest flowers 
            // Use flower.x, flower.y
            var index = this.flower_coords.indexOf(flower);
              if (index !== -1) {
                this.flower_coords.splice(index, 1);
            }
          }
        });
      }
    },
    handleControlDown(event: KeyboardEvent) {
      if (event.key === 'w') {
        controller.up = true;
      }
      if (event.key === 'a') {
        controller.left = true;
      }
      if (event.key === 's') {
        controller.down = true;
      }
      if (event.key === 'd') {
        controller.right = true;
      }
    },
    handleControlUp(event: KeyboardEvent) {
      if (event.key === 'w') {
        controller.up = false;
      }
      if (event.key === 'a') {
        controller.left = false;
      }
      if (event.key === 's') {
        controller.down = false;
      }
      if (event.key === 'd') {
        controller.right = false;
      }
    },
    moveGrunt() {
      const gruntSpeed = 1;

      gruntState.x = gruntState.x + gruntSpeed*( controller.right - controller.left );
      gruntState.y = gruntState.y + gruntSpeed*( controller.down - controller.up );

      if (controller.right) {
        if (controller.up) {
          gruntState.animationName='walk-NE';
        }
        else if (controller.down) {
          gruntState.animationName='walk-SE';
        }
        else {
          gruntState.animationName='walk-E';
        }
      }
      else if (controller.left) {
        if (controller.up) {
          gruntState.animationName='walk-NW';
        }
        else if (controller.down) {
          gruntState.animationName='walk-SW';
        }
        else {
          gruntState.animationName='walk-W';
        }
      }
      else if (controller.up) {
        gruntState.animationName='walk-N';
      }
      else if (controller.up) {
        gruntState.animationName='walk-S';
      }
      else {
        gruntState.animationName='';
      }
    }
  }
};
</script>

<style>
#app, html, body {
  height: 100%;
  width: 100%;
  margin: 0;
  background: url('https://res.cloudinary.com/picturesbase/image/upload/v1465832953/tile_bd8hxf.png');
  cursor: url('https://res.cloudinary.com/picturesbase/image/upload/v1465832953/cursor_ubpicr.png'), pointer;
}

.field {
  position: relative;
  width: 100%;
  height: 100%;
}

.pointer {
  position: absolute;
  opacity: 0;
  z-index: -1;
  -webkit-user-select: none;
  user-select: none;
}

@keyframes walk-N {
   0%   { background-position: 592px -8px;   }
   100% { background-position: 592px -220px; }
}

@keyframes walk-NE {
   0%   { background-position: -89px -8px;   }
   100% { background-position: -89px -220px; }
}

@keyframes walk-E {
   0%   { background-position: -164px -8px;   }
   100% { background-position: -164px -220px; }
}

@keyframes walk-SE {
   0%   { background-position: -241px -8px;   }
   100% { background-position: -241px -220px; }
}

@keyframes walk-S {
   0%   { background-position: -314px -8px;   }
   100% { background-position: -314px -220px; }
}

@keyframes walk-SW {
  0%   { background-position: -386px -8px;   }
  100% { background-position: -386px -220px; }
}

@keyframes walk-W {
  0%   { background-position: -461px -8px;   }
  100% { background-position: -461px -220px; }
}

@keyframes walk-NW {
  0%   { background-position: 75px -8px;   }
  100% { background-position: 75px -220px; }
}

</style>
