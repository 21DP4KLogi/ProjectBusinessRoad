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
    if (global.motd == undefined) {
        const response = await fetch("/motd");
        global.motd = await response.text();
    }
    document.getElementById("motdQuote").innerHTML = global.motd;
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
    const saveCookieCheckbox = document.getElementById("SaveLoginCookieBox");
    if (usernameField.value == "" || passwordField.value == "") {
        setStatusMessage("Please input both the Username and Password", "warning")
    }
    let response = await fetch("/login/submitinfo", {
        method: "POST",
        body: JSON.stringify({
            username: usernameField.value,
            password: passwordField.value
        })
    }
    );
    if (response.ok) {
        let responseText = await response.text()
        switch (responseText) {
            case "Failure":
                setStatusMessage("Incorrect login information", "warning");
                break;
            case "NameNotFound":
                setStatusMessage("Username not found", "warning");
                break;
            default:
                if (saveCookieCheckbox.checked == true) {
                    Cookies.set("authToken", responseText, {expires: 7, sameSite: "strict", secure: true });
                }
                global.authToken = responseText;
                setStatusMessage("Success! Going to the game page...", "success");
                openGamePage();
                break;

        }
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
        switch (await response.text()) {
            case "Success!":
                setStatusMessage("Successfully registered! Please log in.", "success");
                break;
            case "NameAlreadyTaken":
                setStatusMessage("Username is already taken.", "warning");
                break;
        }
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
        switch (await response.text()) {
            case "NameIsAvailable":
                setStatusMessage("Name is available!", "success");
                break;
            case "NameIsTaken":
                setStatusMessage("Name is not available.", "warning");
                break;
        }
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

function logOut() {
    fetch("/logout", {
        method: "POST",
        body: global.authToken
    });
    document.body.innerHTML = global.mainPage;
    Cookies.remove("authToken", {expires: 7, sameSite: "strict", secure: true });
    getMOTD();
}

async function fetchMoney() {
    let response = await fetch("/player/money", {
        method: "POST",
        body: global.authToken
    });
    return await response.text;
}