<script setup>
    import { createApp, ref } from 'vue'
    const msg = ref('World of hello!')
    function onButtonClick() {
        window.location = '/';
    }
</script>

<template>
    <h1>{{msg}}</h1>
    <button v-on:click="onButtonClick()">Go back to the previous page</button>
</template>

<style>
</style>