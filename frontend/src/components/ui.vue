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
    height: 100px;
    background: rgb(0, 0, 0);
    color: white;
    font-size: normal;
}
</style>


<script lang="ts">

export default {
  data() {
    return {}
  }
}
</script>