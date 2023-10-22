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
    <button v-on:click="goToLoginPage()" class="Rbutton">Login</button>
    <button v-on:click="goToRegisterPage()" class="Rbutton">Register</button>
    <h1 id="title">Welcome to Business Road!</h1>
    <div id="motd">
        <p><i>~&nbsp;<q id="motdQuote"></q></i></p>
    </div>
</template>

<style src="public/index_style.css">
</style>