<template>
    <div class="rock">
        <img src="../../assets/Atlas/rock_1.png" :style="styles">
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
                    transform:  `translate3d(${this.x_coord - 25}px, ${this.y_coord - 25}px, 0)`,
                }
            }
        }
    }
</script>
    
<style lang="css">
</style> 