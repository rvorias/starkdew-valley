<script setup lang="ts">
// This starter template is using Vue 3 <script setup> SFCs
// Check out https://vuejs.org/api/sfc-script-setup.html#script-setup
import HelloWorld from './components/HelloWorld.vue'
import grunt from './components/grunt.vue'

</script>

<template>
  <div id="app">
  <grunt></grunt>
  </div>
</template>

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

.grunt {
  position: absolute;
  height: 50px;
  width: 50px;
  background: url('https://res.cloudinary.com/picturesbase/image/upload/v1465832954/sprite_f5cw4a.png') -314px -8px;
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
