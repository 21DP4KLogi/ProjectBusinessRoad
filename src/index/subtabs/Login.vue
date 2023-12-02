<script setup>
    import { ref } from 'vue'
    const submitError = ref('')
    const submitStatusColor = ref('defaultColor')
    function setStatusColor(color) {
        switch(color) {
            case "default":
                submitStatusColor.value = "defaultColor"
                break
            case "warning":
                submitStatusColor.value = "warningColor"
                break
            case "success":
                submitStatusColor.value = "successColor"
                break
        }
    }
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
          setStatusColor("success")
          window.location.href = "/game"
        } else if (response.status == 400) {
            submitError.value = "Incorrect login information"
            setStatusColor("warning")
        } else {
            submitError.value = "HTTP error, status code: " + str(response.status)
            setStatusColor("warning")
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
    <p v-if="submitError.value != ''" :class="submitStatusColor">{{ submitError }}</p>
</template>

<style src="public/index_style.css">
</style>
