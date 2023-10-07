<script setup>
    function LoginInfoSubmitted() {
        window.location.href = "/test"
    }
</script>

<template>
    <h1>Business Road</h1>
    <h3>Login to Business Road</h3>
    <p>Email</p>
    <input type="email">
    <p>Password</p>
    <input type="password">
    <br>
    <button v-on:click="LoginInfoSubmitted()">Login</button>
    <p><i>Don't have an account? <a href="/register">Register here!</a></i></p>
</template>

<style>
</style>