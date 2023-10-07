<script setup>
    function goToLoginPage() {
        window.location.href = "/login"
    }
    function goToRegisterPage() {
        window.location.href = "/register"
    }
</script>

<template>
    <h1>Welcome to Business Road!</h1>
    <p><i>Generic but somewhat exciting description!</i></p>
    <button v-on:click="goToLoginPage()">Login</button>
    <button v-on:click="goToRegisterPage()">Register</button>
</template>

<style>
</style>