<script setup lang="ts">
    import { ref } from 'vue'
    import plot from './atlas/plot.vue'
</script>

<template>
    <div class="farm">
        <plot v-for="plot in plot_coords" :x_coord="plot.x" :y_coord="plot.y"></plot>
    </div>
</template>

<style>
.farm {
  display: absolute;
}
</style>


<script lang="ts">

export default {
  data() {
    const OFFSET_X = 700;
    const OFFSET_Y = 300;
    const N_ROWS = 5;
    const N_COLS = 10;
    const ROW_SPACING = 32;

    var myList = new Array();

    for (var r = 0; r < N_ROWS; r ++ ){
        for (var c = 0; c < N_COLS; c ++ ){
            myList.push({ x: OFFSET_X+(64*c), y: OFFSET_Y+((ROW_SPACING+32)*r) })
        }
    }

    return {
      plot_coords: myList
    }
  }
}
</script>