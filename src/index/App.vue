<script setup>
    import { ref } from 'vue'
    import DescriptionPage from './subtabs/Description.vue'
    import loginPage from './subtabs/Login.vue'
    import registerPage from './subtabs/Register.vue'
    const openedSubtab = ref("none")
    async function getMOTD() {
        const response = await fetch("/motd");
        const textresp = await response.text();
        document.getElementById("motdQuote").innerHTML = textresp
    }
    /*
    function goToLoginPage() {
        openedSubtab.value = "login";
    }
    function goToRegisterPage() {
        openedSubtab.value = "register";
    }
    */
    getMOTD(); 
</script>

<template>
    <button v-on:click="openedSubtab = 'login'" class="Rbutton">Login</button>
    <button v-on:click="openedSubtab = 'register'" class="Rbutton">Register</button>
    <button v-on:click="openedSubtab = 'desc'" class="Rbutton">More info</button>
    <h1 id="title">Welcome to Business Road!</h1>
    <div id="motd">
        <p><i>~&nbsp;<q id="motdQuote"></q></i></p>
    </div>
    <hr>
    <div id="subtabs">
        <loginPage v-if="openedSubtab == 'login'" />
        <registerPage v-if="openedSubtab == 'register'" />
        <DescriptionPage v-if="openedSubtab == 'desc'"/>
    </div>
    
</template>

<style src="public/index_style.css">
</style>