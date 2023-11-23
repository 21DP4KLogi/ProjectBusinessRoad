<script setup>
    import { ref } from 'vue'
    const submitError = ref('')
    async function SendLoginInfo() {
        const usernameField = document.getElementById("usernameInput");
        const passwordField = document.getElementById("passwordInput");
        let response = await fetch("/login/submitinfo", {
            method : "POST",
            body : JSON.stringify({
                username: usernameField.value,
                password: passwordField.value
                })
            }
        )
        if (response.ok) {
          submitError.value = "Successfully logged in!"
        } else if (response.status == 400) {
            submitError.value = "Incorrect login information"
        } else {
            submitError.value = "HTTP error, status code: " + str(response.status)
        }

    }
</script>

<template>
    <h3>Login to Business Road</h3>
    <p class="inputboxtitle">Username</p>
    <input type="text" id="usernameInput">
    <p class="inputboxtitle">Password</p>
    <input type="password" id="passwordInput">
    <br>
    <p v-if="submitError.value != ''">{{ submitError }}</p>
    <button v-on:click="SendLoginInfo()" id="infosubmitbutton">Login</button>
</template>

<style src="public/index_style.css">
</style>
