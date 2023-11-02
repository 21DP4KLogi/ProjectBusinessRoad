<script setup>
    async function SendRegisterInfo() {
        const username = document.getElementById("usernameInput");
        const password = document.getElementById("passwordInput");
        const confirmPassword = document.getElementById("confirmPassInput");
        if (password.value != confirmPassword.value) {
            console.log("Passwords don't match!");
            return;
        }
        if (password.value.length < 8) {
            console.log("Password too short")
            return;
        }
        await fetch("/register", {
            method : "POST",
            // headers = "application/json; charset=UTF-8",
            body : JSON.stringify({
                username: username.value,
                password: password.value
                })
            }
        )

    }
</script>

<template>
    <h1 id="title"><a href="/" title="Click to go back to the Main Page">Business Road</a></h1>
    <h3>Register to Business Road</h3>
    <p class="inputboxtitle">Username</p>
    <input id="usernameInput" type="text">
    <button>Check availability</button>
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