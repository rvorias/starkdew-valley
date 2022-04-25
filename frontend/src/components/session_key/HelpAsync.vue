<script lang="ts">
import { defineAsyncComponent } from 'vue';
export default defineAsyncComponent(async () => {
        let res = await import('./Help.vue');
        return res;
    }
)
</script>