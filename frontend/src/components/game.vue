<script setup lang="ts">
// This starter template is using Vue 3 <script setup> SFCs
// Check out https://vuejs.org/api/sfc-script-setup.html#script-setup
import grunt from './grunt.vue'
import flower from './flower.vue'
import scene from './scene.vue'
import farm from './farm.vue'
import ui from './ui.vue'
import tilemap from "../assets/Atlas/tilemap.png"
</script>

<template>
  <div id="game" @click="handleClick" :style="{ background: `url(${tilemap})` }">
      <scene></scene>
      <!-- <farm></farm> -->
      <grunt></grunt>
      <flower  v-for="flower in flower_coords" :x_coord="flower.x" :y_coord="flower.y" :stage="flower.stage"></flower>
      <ui></ui>

      <div  v-if="regenerateModalStep !== 'nok'"  class="w-full h-full flex justify-center items-center">
        <div class="p-4 bg-white rounded-lg" style="z-index:10000;">
          <h2 class="text-center my-4 font-bold text-xl">Regenerate your ephemereal key</h2>
          <p class="text-sm text-center">Your temp key will soon expire</p>
          <p class="text-center">
            <button v-if="regenerateModalStep!=='ok'" class="bg-yellow-500 my-4 px-2 py-1 rounded-lg disabled:bg-gray-300 disabled:text-gray-500" :disabled="regenerateModalStep !== 'waiting'"
              @click="regenerateKeyPrompt">
              Regenerate Key
            </button>
            <button v-if="regenerateModalStep==='ok'" class="bg-green-500 my-4 px-2 py-1 rounded-lg" :disabled="true">
              Key regenerated
            </button>
          </p>
          <p class="text-center" v-if="regenerateModalStep==='regenerating'">Regenerating</p>
          <p class="text-center" v-if="regenerateModalStep==='ok'">All Good!</p>
        </div>
      </div>
  </div>
</template>

<script lang="ts">
import { starkvile } from '@/composables/contract'
import { getStarknet } from 'get-starknet';
import { setSessionKey } from '@/composables/session_signer';
import { gruntState, controller, weedStats } from '@/datastore';

export default {
  data() {
    return {
      flower_coords: [],
      regenerateModalStep: "nok" as "nok" | "waiting" | "regenerating" | "ok",
    }
  },

  async mounted () {
    window.addEventListener('keydown', this.handleControlDown);
    window.addEventListener('keyup', this.handleControlUp);
    setInterval(this.moveGrunt, 1);
    setInterval(this.growWeed, 20);

    let raw_coords = await starkvile.getAllFarms()

    raw_coords[0].map((a, index) => {
      this.flower_coords.push({ x: parseInt(a.x_coord.toString()), y:  parseInt(a.y_coord.toString()), stage: 3000, idx: index })
    })

    setTimeout(() => this.regenerateModalStep = 'waiting', 45 * 1000)
  },
  methods: {
    async regenerateKeyPrompt() {
      this.regenerateModalStep = 'regenerating';
      let settingKey = setSessionKey();
      let sn = await getStarknet();
      await sn.enable();
      try {
          await sn.account.execute({
              contractAddress: "0xcafe",
              entrypoint: "create_ephemereal_key",
              calldata: [],
          })
      } catch(_) {}
      await new Promise((resolve) => setTimeout(() => resolve(), 2500));
      await settingKey;
      this.regenerateModalStep = 'ok';
      setTimeout(() => this.regenerateModalStep = 'nok', 3000)
    },
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
    growWeed() {
      this.flower_coords.forEach( flower => {
        flower.stage = flower.stage + 1
      })
    },
    async handleClick(event: MouseEvent) {
      var harvestable = this.getHarvestable()
      if (harvestable == null) {
        // let worker = await starkvile.claim_worker()
        // console.log(worker)
        let build_farm = await starkvile.build_farm(Math.round(gruntState.x), Math.round(gruntState.y))

        console.log(build_farm)
        console.log(gruntState.x, gruntState.y)
        // Plant flowers
        // Use gruntState.x, gruntState.y
        this.flower_coords.push({x: gruntState.x, y: gruntState.y, stage: 0})
      }
      else {
        this.flower_coords.forEach(async (flower, index) => {
          if (harvestable.x == flower.x && harvestable.y == flower.y) {
            // this is where you harvest flowers 
            // Use flower.x, flower.y
            var index = this.flower_coords.indexOf(flower);
              if (index !== -1) {
                console.log(flower.stage);
                weedStats.number_of_harvests += 1;
                let build_farm = await starkvile.claim_resources(0, Math.round(flower.x), Math.round(flower.y))

                console.log(build_farm)

                let stage = parseInt(flower.stage/350);
                if (stage > 4) {
                  stage = 0;
                }
                weedStats.total_yield += Math.pow(2, stage)-1;
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
      const gruntSpeed = 0.4;

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
      else if (controller.down) {
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
#game {
    width: 1184px;
    height: 640px;
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
