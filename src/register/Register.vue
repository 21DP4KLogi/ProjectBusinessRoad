<script setup>
    function RegisterInfoSubmitted() {
        window.location.href = "/test"
    }
</script>

<template>
    <h1 id="title"><a href="/" title="Click to go back to the Main Page">Business Road</a></h1>
    <h3>Register to Business Road</h3>
    <p class="inputboxtitle">Username</p>
    <input type="text">
    <button>Check availability</button>
    <p class="inputboxtitle">Password</p>
    <input type="password">
    <p class="inputboxtitle">Confirm password</p>
    <input type="password">
    <br>
    <button v-on:click="RegisterInfoSubmitted()" id="infosubmitbutton">Register</button>
    <p><i>Already have an account? <a href="/login">Login here!</a></i></p>
</template>

<style src="public/index_style.css">
</style>