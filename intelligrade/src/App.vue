<template>
  <div id="app">
    <router-view :key="$route.fullPath" />
  </div>
</template>

<script lang="ts">
export default {
  name: 'App',
}
</script>

<style>
/* Your styles here */
</style>
