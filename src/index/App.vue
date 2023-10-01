<script setup>
    import { createApp, ref } from 'vue'
    const msg = ref('Hello World!')
    function onButtonClick() {
        window.location = '/test';
    }
</script>

<template>
    <h1>{{msg}}</h1>
    <button v-on:click="onButtonClick()">Go to another page</button>
</template>

<style>
</style>