<template>
  <div id="app">
    <Raptime />
  </div>
</template>

<script>
import Raptime from './components/Raptime.vue'

export default {
  name: 'RaptimeDog',
  components: {
    Raptime
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
