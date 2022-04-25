<template>
    <div class="tree">
        <img src="../../assets/Atlas/tree.png" :style="styles">
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
                    left: `${this.x_coord - 25}px`,
                    top: `${this.y_coord - 25}px`,
                }
            }
        }
    }
</script>
    
<style lang="css">
.tree {
    width: 96px;
}
</style> 