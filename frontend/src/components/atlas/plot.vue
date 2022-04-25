<template>
    <div id="tree" :style="styles">
        <img src="../../assets/Atlas/plot.png">
    </div>
</template>
    
<script>
    export default {
        props: {
            x_coord: Number, 
            y_coord: Number
        },
        computed: {
            styles () {
                return {
                    position: 'absolute',
                    transform:  `translate3d(${this.x_coord - 32}px, ${this.y_coord - 16}px, 0)`,
                }
            }
        }
    }
</script>
    
<style lang="css">
</style> 