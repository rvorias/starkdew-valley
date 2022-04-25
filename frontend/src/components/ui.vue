<script setup lang="ts">
    import { ref } from 'vue'
    import { weedStats } from '@/datastore';
</script>

<template>
    <div class="ui-frame">
        <p>Number of harvests: {{ weedStats.number_of_harvests }}</p>
        <p>Total yield: {{ weedStats.total_yield }}</p>
    </div>
</template>

<style>
.ui-frame {
    float: right;
    width: 200px;
    height: auto;
    background: rgb(133,244,246);
    background: linear-gradient(180deg, rgba(133,244,246,1) 0%, rgba(91,169,249,1) 37%, rgba(45,88,253,1) 100%);
    color: rgb(255, 255, 255);
    padding: 10px;
    font-size: 10px;
    border-style: solid;
    border-color: rgb(226, 226, 226);
    border-width: 4px;
    border-radius: 0px 0px 0px 10px;
}
p {
  font-size: 15px;
}
</style>


<script lang="ts">

export default {
  data() {
    return {}
  }
}
</script>