<script setup>
  function goToMainPage() {
    window.location.href = "/"
  }
</script>

<template>
  <div id="topbar">
    <div id="title">
      <h1>Project Business Road</h1>
    </div>
    <button v-on:click="goToMainPage()">Log out</button>
  </div>
  <div id="bottomhalf">
  </div>
</template>

<style src="public/game_style.css">
</style>
