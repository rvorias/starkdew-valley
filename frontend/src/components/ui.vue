<script setup lang="ts">
    import { ref } from 'vue'
    import { weedStats } from '@/datastore';
</script>

<template>
    <div class="ui-frame">
        <p>Total Yield: {{ weedStats.total_yield }}</p>
        <p>Harvests: {{ weedStats.number_of_harvests }}</p>
        <p>Nº Transactions: {{ tx_store.nb_tx }}</p>
        <p>Last Tx Status: {{ lastStatus }}</p>
    </div>
</template>

<style>
.ui-frame {
    float: right;
    width: 230px;
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
import { getSessionSigner, tx_store } from '@/composables/session_signer';

export default {
  data() {
    return {
      lastStatus: "",
    }
  },
  mounted() {
    setInterval(this.updateLastTx, 10000);
  },
  methods: {
    async updateLastTx() {
      if (!tx_store.last_tx_hash)
      {
        this.lastStatus = "";
        return;
      }
      this.lastStatus = (await getSessionSigner().getTransactionStatus(tx_store.last_tx_hash)).tx_status;
    }
  },
  computed: {
    tx_store() {
      return tx_store;
    }
  }
}
</script>