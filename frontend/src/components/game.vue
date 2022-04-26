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
  <div id="game" @dblclick="handleClick" class="relative" :style="{ background: `url(${tilemap})` }">
      <scene></scene>
      <!-- <farm></farm> -->
      <grunt></grunt>
      <flower  v-for="flower in flower_coords" :x_coord="flower.x" :y_coord="flower.y" :stage="Math.floor(flower.stage / 1000 / 15)"></flower>
      <ui></ui>

      <div class="absolute bottom-0">
        <p v-for="mess of messages.mess.slice(-3)"> {{ mess }}</p>
      </div>

      <div  v-if="regenerateModalStep !== 'nok'"  class="w-full h-full flex justify-center items-center">
        <div class="p-4 bg-white rounded-lg relative" style="z-index:10000;">
          <button class="absolute top-2 right-2 text-xs" @click="pushBackModal">X</button>
          <h2 class="text-center my-4 font-bold text-xl">Regenerate your session key</h2>
          <p class="text-sm text-center">Your session key will expire soon</p>
          <p class="text-center">
            <button v-if="regenerateModalStep!=='ok'" class="bg-gradient-to-b from-yellow-100 via-yellow-200 to-yellow-600 my-4 px-2 py-1 rounded-lg disabled:bg-gray-300 disabled:text-gray-500" :disabled="regenerateModalStep !== 'waiting'"
              @click="regenerateKeyPrompt">
              🗝 Regenerate Key
            </button>
            <button v-if="regenerateModalStep==='ok'" class="bg-gradient-to-b from-lime-100 via-lime-200 to-lime-600 my-4 px-2 py-1 rounded-lg" :disabled="true">
              Key regenerated
            </button>
          </p>
          <p class="text-center" v-if="regenerateModalStep==='regenerating'">Regenerating</p>
          <p class="text-center" v-if="regenerateModalStep==='ok'">All Good!</p>
        </div>
      </div>
      <div v-if="!initialLoad" class="absolute top-0 left-0 w-full h-full bg-black bg-opacity-50 flex justify-center items-center">
        <h1 class="text-center text-white text-4xl">... Loading ...</h1>
      </div>
  </div>
</template>

<script lang="ts">
import { starkvile } from '@/composables/contract'
import { getStarknet } from 'get-starknet';
import { setSessionKey, tx_store, getSlowMode } from '@/composables/session_signer';
import { gruntState, controller, weedStats, messages } from '@/datastore';

export default {
  data() {
    return {
      flower_coords: [],
      flower_idx: 0,
      regenerateModalStep: "nok" as "nok" | "waiting" | "regenerating" | "ok",
      initialLoad: false,
    }
  },

  async mounted () {
    window.addEventListener('keydown', this.handleControlDown);
    window.addEventListener('keyup', this.handleControlUp);
    setInterval(this.moveGrunt, 1);
    setInterval(this.growWeed, 20);

    let weedSt = starkvile.get_wheat(0xcafe);
    let raw_coords = await starkvile.getAllFarms()
    raw_coords.farms.map((a, index) => {
      const age = Math.round(Date.now() / 1000 -  a.plant_time.toString());
      this.flower_coords.push({ x: parseInt(a.x_coord.toString()), y:  parseInt(a.y_coord.toString()), stage: age * 1000, idx: raw_coords[0].length - index - 1 })
    })
    weedStats.total_yield = +(await weedSt).wheat.toString();

    console.log(this.flower_coords);

    this.flower_idx = raw_coords[0].length

    this.initialLoad = true;

    setTimeout(() => this.regenerateModalStep = 'waiting', 60 * 1000)
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
      if (!getSlowMode())
        setTimeout(() => this.regenerateModalStep = 'nok', 3000)
    },
    async pushBackModal() {
      this.regenerateModalStep = 'nok';
      setTimeout(() => this.regenerateModalStep = 'waiting', 60000)
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
        flower.stage = flower.stage + 20;
      })
    },
    async handleClick(event: MouseEvent) {
      var harvestable = this.getHarvestable()
      if (harvestable == null) {
        messages.mess.push("Planting flower");
        let x = gruntState.x;
        let y = gruntState.y;

        let build_farm = await starkvile.build_farm(Math.round(gruntState.x), Math.round(gruntState.y));
        tx_store.last_tx_hash = build_farm.transaction_hash;
        tx_store.nb_tx += 1;

        // Plant flowers
        // Use gruntState.x, gruntState.y
        this.flower_coords.push({x, y, stage: 0, idx: this.flower_idx})

        this.flower_idx++;
        messages.mess.push("Flower planted");
      }
      else {
        this.flower_coords.forEach(async (flower, index) => {
          if (harvestable.x == flower.x && harvestable.y == flower.y) {
            // this is where you harvest flowers 
            // Use flower.x, flower.y
            var index = this.flower_coords.indexOf(flower);
              if (index !== -1) {
                weedStats.number_of_harvests += 1;
                console.log("CLAIM RES", flower);
                messages.mess.push("Harvesting flower");
                let build_farm = await starkvile.claim_resources(flower.idx, Math.round(flower.x), Math.round(flower.y))
                tx_store.last_tx_hash = build_farm.transaction_hash;
                tx_store.nb_tx += 1;

                let stage = parseInt(flower.stage / 1000 / 15);
                if (stage > 4) {
                  stage = 0;
                }
                weedStats.total_yield += Math.pow(2, stage)-1;
                //this.flower_coords.splice(index, 1);
                this.flower_coords[index].stage = 0;
                messages.mess.push("Flower harvested");
            }
          }
        });
      }
    },
    handleControlDown(event: KeyboardEvent) {
      if (event.key === 'w' || event.key === 'z' || event.key === 'ArrowUp') {
        controller.up = true;
      }
      if (event.key === 'a' || event.key === 'q' || event.key === 'ArrowLeft') {
        controller.left = true;
      }
      if (event.key === 's' || event.key === 'ArrowDown') {
        controller.down = true;
      }
      if (event.key === 'd' || event.key === 'ArrowRight') {
        controller.right = true;
      }
    },
    handleControlUp(event: KeyboardEvent) {
      if (event.key === 'w' || event.key === 'z' || event.key === 'ArrowUp') {
        controller.up = false;
      }
      if (event.key === 'a' || event.key === 'q' || event.key === 'ArrowLeft') {
        controller.left = false;
      }
      if (event.key === 's' || event.key === 'ArrowDown') {
        controller.down = false;
      }
      if (event.key === 'd' || event.key === 'ArrowRight') {
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
