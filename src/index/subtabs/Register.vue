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
    async function SendRegisterInfo() {
        const usernameField = document.getElementById("usernameInput");
        const passwordField = document.getElementById("passwordInput");
        const confirmPasswordField = document.getElementById("confirmPassInput");
        if (passwordField.value.length < 8) {
            submitError.value = "Your password needs to be atleast 8 characters long."
            setStatusColor("warning")
            return
        }
        if (passwordField.value != confirmPasswordField.value) {
            submitError.value = "Passwords don't match."
            setStatusColor("warning")
            return
        }
        let response = await fetch("/register/submitinfo", {
            method : "POST",
            body : JSON.stringify({
                username: usernameField.value,
                password: passwordField.value
                })
            }
        )
        if (response.ok) {
            submitError.value = 'Successfully registered! Please log in.'
            setStatusColor("success")
        } else if (response.status == 400) {
            submitError.value = "Register info not valid."
            setStatusColor("warning")
        } else {
            submitError.value = "HTTP error, status code: " + str(response.status)
            setStatusColor("warning")
        }
    }

    async function CheckNameAvailability() {
        const usernameField = document.getElementById("usernameInput");
        if (usernameField.value == "") {
            submitError.value = "Input a name to check it's availability"
            setStatusColor("default")
            return
        }
        let response = await fetch("/register/checkname", {
            method : "POST",
            body : usernameField.value
            }
        )
        if (response.ok) {
            submitError.value = "Name is available!"
            setStatusColor("success")
        } else if (response.status == 400) {
            submitError.value = "Name is not available."
            setStatusColor("warning")
        } else {
            submitError.value = "HTTP error, status code: " + str(response.status)
            setStatusColor("warning")
        }
    }
</script>

<template>
    <h3>Register to Business Road</h3>
    <p class="inputboxtitle">Username</p>
    <input id="usernameInput" type="text">
    <button v-on:click="CheckNameAvailability()">Check availability</button>
    <p class="inputboxtitle">Password</p>
    <input id="passwordInput" type="password">
    <p class="inputboxtitle">Confirm password</p>
    <input id="confirmPassInput" type="password">
    <br>
    <button v-on:click="SendRegisterInfo()" id="infosubmitbutton">Register</button>
    <p v-if="submitError.value != ''" :class="submitStatusColor">{{ submitError }}</p>
</template>

<style src="public/index_style.css">
</style>
