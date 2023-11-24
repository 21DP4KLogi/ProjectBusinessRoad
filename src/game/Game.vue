<script setup>
  function goToMainPage() {
    window.location.href = "/"
  }
</script>

<template>
  <h1>Business Road game page</h1>
  <button v-on:click="goToMainPage()">Go back</button>
</template>

<style>
</style>
