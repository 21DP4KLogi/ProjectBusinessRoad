<script setup>
    import { createApp, ref } from 'vue'
    const msg = ref('Hello World!')
    function onButtonClick() {
        window.location = '/';
    }
</script>

<template>
    <h1>{{msg}}</h1>
    <button v-on:click="onButtonClick()">Go back to the homepage</button>
</template>

<style>
</style>