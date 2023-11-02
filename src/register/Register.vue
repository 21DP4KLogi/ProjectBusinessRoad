<script setup>
    async function SendRegisterInfo() {
        const usernameField = document.getElementById("usernameInput");
        const passwordField = document.getElementById("passwordInput");
        const confirmPasswordField = document.getElementById("confirmPassInput");
        if (passwordField.value != confirmPasswordField.value) {
            console.log("Passwords don't match!");
            return;
        }
        if (passwordField.value.length < 8) {
            console.log("Password too short")
            return;
        }
        await fetch("/register/submitinfo", {
            method : "POST",
            body : JSON.stringify({
                username: usernameField.value,
                password: passwordField.value
                })
            }
        )
    }
    
    async function CheckNameAvailability() {
        const usernameField = document.getElementById("usernameInput");
        if (usernameField.value == "") {
            console.log("Username field is empty")
            return
        }
        await fetch("/register/checkname", {
            method : "POST",
            body : usernameField.value
            }
        )
    }
</script>

<template>
    <h1 id="title"><a href="/" title="Click to go back to the Main Page">Business Road</a></h1>
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
    <p><i>Already have an account? <a href="/login">Login here!</a></i></p>
</template>

<style src="public/index_style.css">
</style>