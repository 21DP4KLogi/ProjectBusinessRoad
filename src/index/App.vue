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
    getMOTD();
</script>

<template>
    <div id="topbar">
        <div id="title">
            <h1>Welcome to Business Road!</h1>
            <p><i>~&nbsp;<q id="motdQuote"></q></i></p>
        </div>
        <button v-on:click="openedSubtab = 'login'">Login</button>
        <button v-on:click="openedSubtab = 'register'">Register</button>
        <button v-on:click="openedSubtab = 'desc'">More info</button>
    </div>
    <div id="bottomhalf">
        <div id="bottomleft">
            <loginPage v-if="openedSubtab == 'login'" />
            <registerPage v-if="openedSubtab == 'register'" />
            <DescriptionPage v-if="openedSubtab == 'desc'"/>
        </div>
        <div id="bottomright">
        </div>
    </div>

</template>

<style src="public/index_style.css">
</style>
