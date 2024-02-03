var global = {};

// This approach might cause problems if the User's internet is too slow,
// perhaps a loading screen could be useful.
async function fetchInitialData() {
    global.mainPage = document.body.innerHTML; // Main page is saved in global upon loading so that a request is not required
    await getMOTD();
    global.subtabRegister = await fetchComponent("/component/subtabRegister.html");
    global.subtabLogin = await fetchComponent("/component/subtabLogin.html");
    global.subtabDesc = await fetchComponent("/component/subtabDesc.html");
}

async function getMainPage() {
    document.body.innerHTML = await fetchComponent("/component/mainPage");
}

async function fetchComponent(route) {
    let response = await fetch(route);
    if (response.ok) {
        return await response.text();
    } else {
        return str("Error " + str(response.status));
    }
}

function setOpenedSubtab(subtab) {
    const bottomLeft = document.getElementById("bottomleft");
    switch (subtab) {
        case "login":
            bottomLeft.innerHTML = global.subtabLogin;
            break;
        case "register":
            bottomLeft.innerHTML = global.subtabRegister;
            break;
        case "desc":
            bottomLeft.innerHTML = global.subtabDesc;
            break;
    }
}

async function getMOTD() {
    const response = await fetch("/motd");
    const textresp = await response.text();
    document.getElementById("motdQuote").innerHTML = textresp;
}

function setStatusMessage(message, color) {
    const statusText = document.getElementById("requestStatusText");
    statusText.innerHTML = message;
    switch (color) {
        case "default":
            statusText.className = "defaultColor";
            break;
        case "warning":
            statusText.className = "warningColor";
            break;
        case "success":
            statusText.className = "successColor";
            break;
    }
}

async function SendLoginInfo() {
    const usernameField = document.getElementById("usernameInput");
    const passwordField = document.getElementById("passwordInput");
    let response = await fetch("/login/submitinfo", {
        method: "POST",
        body: JSON.stringify({
            username: usernameField.value,
            password: passwordField.value
        })
    }
    );
    if (response.ok) {
        setStatusMessage("Success! Going to the game page...", "success");
        openGamePage();
    } else if (response.status == 400) {
        setStatusMessage("Incorrect login information", "warning");
    } else {
        setStatusMessage(str("HTTP error, status code: " + str(response.status)), "warning");
    }

}

async function SendRegisterInfo() {
    const usernameField = document.getElementById("usernameInput");
    const passwordField = document.getElementById("passwordInput");
    const confirmPasswordField = document.getElementById("confirmPassInput");
    if (passwordField.value.length < 8) {
        setStatusMessage("Your password needs to be atleast 8 characters long.", "warning");
        return;
    }
    if (passwordField.value != confirmPasswordField.value) {
        setStatusMessage("Passwords don't match.", "Warning");
        return;
    }
    let response = await fetch("/register/submitinfo", {
        method: "POST",
        body: JSON.stringify({
            username: usernameField.value,
            password: passwordField.value
        })
    }
    );
    if (response.ok) {
        setStatusMessage("Successfully registered! Please log in.", "success");
    } else if (response.status == 400) {
        setStatusMessage("Register info not valid.", "warning");
    } else {
        setStatusMessage(str("HTTP error, status code: " + str(response.status)), "warning");
    }
}

async function CheckNameAvailability() {
    const usernameField = document.getElementById("usernameInput");
    if (usernameField.value == "") {
        setStatusMessage("Input a name to check it's availability", "default");
        return;
    }
    let response = await fetch("/register/checkname", {
        method: "POST",
        body: usernameField.value
    }
    );
    if (response.ok) {
        setStatusMessage("Name is available!", "success");
    } else if (response.status == 400) {
        setStatusMessage("Name is not available.", "warning");
    } else {
        setStatusMessage(str("HTTP error, status code: " + str(response.status)), "warning");
    }
}

async function openGamePage() {
    if (global.gamePage == undefined) {
        global.gamePage = await fetchComponent("/component/gamePage.html");
    }
    document.body.innerHTML = global.gamePage;
}

function openMainPage() {
    document.body.innerHTML = global.mainPage;
}