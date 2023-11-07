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
    <h3>Login to Business Road</h3>
    <p class="inputboxtitle">Username</p>
    <input type="text" id="usernameInput">
    <p class="inputboxtitle">Password</p>
    <input type="password" id="passwordInput">
    <br>
    <button v-on:click="SendLoginInfo()" id="infosubmitbutton">Login</button>
</template>

<style src="public/index_style.css">
</style>