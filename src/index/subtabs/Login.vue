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
          submitError.value = "Success! Going to the game page..."
          window.location.href = "/game"
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
    <button v-on:click="SendLoginInfo()" id="infosubmitbutton">Login</button>
    <p v-if="submitError.value != ''">{{ submitError }}</p>
</template>

<style src="public/index_style.css">
</style>
