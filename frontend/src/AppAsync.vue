<script lang="ts">
import { defineAsyncComponent } from 'vue';
export default defineAsyncComponent(async () => {
        return await import('./App.vue');
    }
)
</script>