var global = {};

// This approach might cause problems if the User's internet is too slow,
// perhaps a loading screen could be useful.

async function fetchInitialData() {
    global.mainPage = document.body.innerHTML; // Main page is saved in global upon loading so that a request is not required
    await getMOTD();
    global.subtabRegister = $.get("/component/subtabRegister.html");
    global.subtabLogin = $.get("/component/subtabLogin.html");
    global.subtabDesc = $.get("/component/subtabDesc.html");
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
    const bottomLeft = $("#bottomleft");
    switch (subtab) {
        case "login":
            $("#bottomleft").load("/component/subtabLogin.html");
            break;
        case "register":
            $("#bottomleft").load("/component/subtabRegister.html");
            break;
        case "desc":
            $("#bottomleft").load("/component/subtabDesc.html");
            break;
    }
}

async function getMOTD() {
    $("#motdQuote").load("/motd")
}

function setStatusMessage(message, color) {
    $("#requestStatusText").text(message);
    switch (color) {
        case "default":
            $("#requestStatusText").className = "defaultColor";
            break;
        case "warning":
            $("#requestStatusText").className = "warningColor";
            break;
        case "success":
            $("#requestStatusText").className = "successColor";
            break;
    }
}

async function SendLoginInfo() {
    const usernameField = $("#usernameInput").val();
    const passwordField = $("#passwordInput").val();
    const saveCookieCheckbox = $("#SaveLoginCookieBox");
    if (usernameField == "" || passwordField == "") {
        setStatusMessage("Please input both the Username and Password", "warning")
    }
    $.post(
        "/login/submitinfo",
        JSON.stringify({
            username: usernameField,
            password: passwordField
        }),
        function(response, status){
            if (status.ok) {
                console.log(response);
                switch (response) {
                    case "Failure":
                        setStatusMessage("Incorrect login information", "warning");
                        break;
                    case "NameNotFound":
                        setStatusMessage("Username not found", "warning");
                        break;
                    default:
                        if (saveCookieCheckbox.checked == true) {
                            Cookies.set("authToken", response, {expires: 7, sameSite: "strict", secure: true });
                        }
                        global.authToken = response;
                        setStatusMessage("Success! Going to the game page...", "success");
                        openGamePage();
                        break;
                }
            } else {
                setStatusMessage(String("HTTP error, status code: " + String(response.status)), "warning");
            }
        }
    )
}

async function SendRegisterInfo() {
    const usernameField = $("#usernameInput");
    const passwordField = $("#passwordInput");
    const confirmPasswordField = $("#confirmPassInput");
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
            case "Success":
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
    const usernameField = $("#usernameInput");
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