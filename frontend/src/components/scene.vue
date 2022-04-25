<template>
    <div class="scene">
        <tree :x_coord="50" :y_coord="50"></tree>
        <tree :x_coord="100" :y_coord="300"></tree>
        <tree :x_coord="500" :y_coord="50"></tree>
        <tree :x_coord="200" :y_coord="450"></tree>
        <tree :x_coord="900" :y_coord="50"></tree>
        <tree :x_coord="500" :y_coord="200"></tree>
        <rock :x_coord="400" :y_coord="50"></rock>
        <rock :x_coord="1100" :y_coord="200"></rock>
    </div>
</template>

<style>
.scene {
  position: absolute;
}
</style>


<script lang="ts">
import { ref } from 'vue'
import tree from './atlas/tree.vue'
import rock from './atlas/rock.vue'
import plot from './atlas/plot.vue'
export default {
    data () {
        return {}
    },
    components: {
        tree,
        rock,
        plot
    }
}
</script>
