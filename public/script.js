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
  await $(document.body).load("/component/mainPage.html", () => {
    $("#motdQuote").load("/motd");
  });
}

async function fetchComponent(route) {
  $.get(route, (response, status) => {
    if (status == "success") {
      return response;
    } else {
      return "Error, status: " + status;
    }
  });
}

function setOpenedSubtab(subtab) {
  const bottomLeft = $("#bottomleft");
  switch (subtab) {
    case "login":
      bottomLeft.load("/component/subtabLogin.html");
      break;
    case "register":
      bottomLeft.load("/component/subtabRegister.html");
      break;
    case "desc":
      bottomLeft.load("/component/subtabDesc.html");
      break;
  }
}

async function getMOTD() {
  $("#motdQuote").load("/motd");
}

function setStatusMessage(message, color) {
  $("#requestStatusText").text(message);
  switch (color) {
    case "default":
      $("#requestStatusText").attr("class", "defaultColor");
      break;
    case "warning":
      $("#requestStatusText").attr("class", "warningColor");
      break;
    case "success":
      $("#requestStatusText").attr("class", "successColor");
      break;
  }
}

async function SendLoginInfo() {
  const username = $("#usernameInput").val();
  const password = $("#passwordInput").val();
  const saveCookieCheckboxChecked = $("#SaveLoginCookieBox").is(":checked");
  if (username == "" || password == "") {
    setStatusMessage("Please input both the Username and Password", "warning");
    return;
  }
  $.post(
    "/login/submitinfo",
    JSON.stringify({
      username: username,
      password: password,
    }),
    function (response, status) {
      if (status == "success") {
        switch (response) {
          case "Failure":
            setStatusMessage("Incorrect login information", "warning");
            break;
          case "NameNotFound":
            setStatusMessage("Username not found", "warning");
            break;
          default:
            if (saveCookieCheckboxChecked) {
              Cookies.set("authToken", response, {
                expires: 7,
                sameSite: "strict",
                secure: true,
              });
            }
            global.authToken = response;
            setStatusMessage("Success! Going to the game page...", "success");
            openGamePage();
            break;
        }
      } else {
        setStatusMessage(
          String("HTTP error, status code: " + String(status)),
          "warning",
        );
      }
    },
  );
}

async function SendRegisterInfo() {
  const username = $("#usernameInput").val();
  const password = $("#passwordInput").val();
  const confirmPassword = $("#confirmPassInput").val();
  if (password.length < 8) {
    setStatusMessage(
      "Your password needs to be atleast 8 characters long.",
      "warning",
    );
    return;
  }
  if (password != confirmPassword) {
    setStatusMessage("Passwords don't match.", "Warning");
    return;
  }
  $.post(
    "/register/submitinfo",
    JSON.stringify({
      username: username,
      password: password,
    }),
    (response, status) => {
      if (status == "success") {
        switch (response) {
          case "Success":
            setStatusMessage(
              "Successfully registered! Please log in.",
              "success",
            );
            break;
          case "NameAlreadyTaken":
            setStatusMessage("Username is already taken.", "warning");
            break;
        }
      } else {
        setStatusMessage("Error, status: " + status, "warning");
      }
    },
  );
}

async function CheckNameAvailability() {
  const username = $("#usernameInput").val();
  if (username == "") {
    setStatusMessage("Input a name to check it's availability", "default");
    return;
  }
  $.post("/register/checkname", username, (response, status) => {
    if (status == "success") {
      switch (response) {
        case "NameIsAvailable":
          setStatusMessage("Name is available!", "success");
          break;
        case "NameIsTaken":
          setStatusMessage("Name is not available.", "warning");
          break;
      }
    } else {
      setStatusMessage("Error, status: " + status, "warning");
    }
  });
}

async function openGamePage() {
  $(document.body).load("/component/gamePage.html");
}

async function logOut() {
  $.post("/logout", global.authToken, () => {
    getMainPage(),
      Cookies.remove("authToken", {
        expires: 7,
        sameSite: "strict",
        secure: true,
      });
  });
}

async function fetchMoney() {
  $.post("/player/money", global.authToken, (response, status) => {
    if (status == "success") {
      return response;
    } else {
      return "Error";
    }
  });
}
