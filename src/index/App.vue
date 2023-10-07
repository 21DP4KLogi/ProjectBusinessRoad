<script setup>
    async function getMOTD() {
        const response = await fetch("/motd");
        const textresp = await response.text();
        document.getElementById("motdQuote").innerHTML = textresp
    }
    function goToLoginPage() {
        window.location.href = "/login";
    }
    function goToRegisterPage() {
        window.location.href = "/register";
    }
    getMOTD();
</script>

<template>
    <h1>Welcome to Business Road!</h1>
    <div id="motd">
        <p><i><q id="motdQuote"></q></i></p>
    </div>
    <button v-on:click="goToLoginPage()">Login</button>
    <button v-on:click="goToRegisterPage()">Register</button>
</template>

<style>
</style>