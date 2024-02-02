function setOpenedSubtab(subtab) {
    const bottomLeft = document.getElementById("bottomleft")
    switch (subtab) {
        case "login":
            bottomLeft.innerHTML = 
            `   <h3>Login to Business Road</h3>
            <p class="inputboxtitle">Username</p>
            <input type="text" id="usernameInput">
            <p class="inputboxtitle">Password</p>
            <input type="password" id="passwordInput">
            <br>
            <button onclick="SendLoginInfo()" id="infosubmitbutton">Login</button>
            <p id="requestStatusText"></p>
            `
            break
        case "register":
            bottomLeft.innerHTML =
            `   <h3>Register to Business Road</h3>
            <p class="inputboxtitle">Username</p>
            <input id="usernameInput" type="text">
            <button onclick="CheckNameAvailability()">Check availability</button>
            <p class="inputboxtitle">Password</p>
            <input id="passwordInput" type="password">
            <p class="inputboxtitle">Confirm password</p>
            <input id="confirmPassInput" type="password">
            <br>
            <button onclick="SendRegisterInfo()" id="infosubmitbutton">Register</button>
            <p id="requestStatusText"></p>
            `
            break
        case "desc":
            bottomLeft.innerHTML =
            `    <h3>This is a description for the game</h3>
            <p>&emsp;Call me Ishmael. Some years ago—never mind how long precisely—having
            little or no money in my purse, and nothing particular to interest me
            on shore, I thought I would sail about a little and see the watery part
            of the world. It is a way I have of driving off the spleen and
            regulating the circulation. Whenever I find myself growing grim about
            the mouth; whenever it is a damp, drizzly November in my soul; whenever
            I find myself involuntarily pausing before coffin warehouses, and
            bringing up the rear of every funeral I meet; and especially whenever
            my hypos get such an upper hand of me, that it requires a strong moral
            principle to prevent me from deliberately stepping into the street, and
            methodically knocking people’s hats off—then, I account it high time to
            get to sea as soon as I can. This is my substitute for pistol and ball.
            With a philosophical flourish Cato throws himself upon his sword; I
            quietly take to the ship. There is nothing surprising in this. If they
            but knew it, almost all men in their degree, some time or other,
            cherish very nearly the same feelings towards the ocean with me.</p>
            `
            break
    }
}

async function getMOTD() {
    const response = await fetch("/motd");
    const textresp = await response.text();
    document.getElementById("motdQuote").innerHTML = textresp
}

function setStatusMessage(message, color) {
    const statusText = document.getElementById("requestStatusText")
    statusText.innerHTML = message
    switch(color) {
        case "default":
            statusText.className = "defaultColor"
            break
        case "warning":
            statusText.className = "warningColor"
            break
        case "success":
            statusText.className = "successColor"
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
        setStatusMessage("Success! Going to the game page...", "success")
        window.location.href = "/game"
    } else if (response.status == 400) {
        setStatusMessage("Incorrect login information", "warning")
    } else {
        setStatusMessage(str("HTTP error, status code: " + str(response.status)), "warning")
    }

}

async function SendRegisterInfo() {
    const usernameField = document.getElementById("usernameInput");
    const passwordField = document.getElementById("passwordInput");
    const confirmPasswordField = document.getElementById("confirmPassInput");
    if (passwordField.value.length < 8) {
        setStatusMessage("Your password needs to be atleast 8 characters long.", "warning")
        return
    }
    if (passwordField.value != confirmPasswordField.value) {
        setStatusMessage("Passwords don't match.", "Warning")
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
        setStatusMessage("Successfully registered! Please log in.", "success")
    } else if (response.status == 400) {
        setStatusMessage("Register info not valid.", "warning")
    } else {
        setStatusMessage(str("HTTP error, status code: " + str(response.status)), "warning")
    }
}

async function CheckNameAvailability() {
    const usernameField = document.getElementById("usernameInput");
    if (usernameField.value == "") {
        setStatusMessage("Input a name to check it's availability", "default")
        return
    }
    let response = await fetch("/register/checkname", {
        method : "POST",
        body : usernameField.value
        }
    )
    if (response.ok) {
        setStatusMessage("Name is available!", "success")
    } else if (response.status == 400) {
        setStatusMessage("Name is not available.", "warning")
    } else {
        setStatusMessage(str("HTTP error, status code: " + str(response.status)), "warning")
    }
}