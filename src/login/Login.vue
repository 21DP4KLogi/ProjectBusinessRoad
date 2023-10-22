<script setup>
    async function LoginInfoSubmitted() {
        const requestOptions = {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: "Login Info Submitted"
        };
        await fetch("/login", requestOptions);
        window.location.href = "/test";
    }
</script>

<template>
    <h1 id="title">Business Road</h1>
    <h3>Login to Business Road</h3>
    <p class="inputboxtitle">Email</p>
    <input type="email" id="emailinput">
    <p class="inputboxtitle">Password</p>
    <input type="password" id="passwordinput">
    <br>
    <button v-on:click="LoginInfoSubmitted()" id="infosubmitbutton">Login</button>
    <p><i>Don't have an account? <a href="/register">Register here!</a></i></p>
</template>

<style src="public/index_style.css">
</style>