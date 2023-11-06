<script setup>
    async function SendLoginInfo() {
        const usernameField = document.getElementById("usernameInput");
        const passwordField = document.getElementById("passwordInput");
        await fetch("/login/submitinfo", {
            method : "POST",
            body : JSON.stringify({
                username: usernameField.value,
                password: passwordField.value
                })
            }
        )
    }
</script>

<template>
    <h1 id="title"><a href="/" title="Click to go back to the Main Page">Business Road</a></h1>
    <h3>Login to Business Road</h3>
    <p class="inputboxtitle">Username</p>
    <input type="text" id="usernameInput">
    <p class="inputboxtitle">Password</p>
    <input type="password" id="passwordInput">
    <br>
    <button v-on:click="SendLoginInfo()" id="infosubmitbutton">Login</button>
    <p><i>Don't have an account? <a href="/register">Register here!</a></i></p>
</template>

<style src="public/index_style.css">
</style>