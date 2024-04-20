// var global = {};

// This approach might cause problems if the User's internet is too slow,
// perhaps a loading screen could be useful.

async function fetchInitialData() {
  // global.mainPage = document.body.innerHTML; // Main page is saved in global upon loading so that a request is not required
  await getMOTD();
  // global.subtabRegister = $.get("/component/subtabRegister.html");
  // global.subtabLogin = $.get("/component/subtabLogin.html");
  // global.subtabDesc = $.get("/component/subtabDesc.html");
}

async function getMainPage() {
  await $(document.body).load("/component/mainPage.html", () => {
    $("#motdQuote").load("/page/motd");
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
    case "play":
      bottomLeft.load("/component/subtabPlay.html");
      break;
    // case "login":
    //   bottomLeft.load("/component/subtabLogin.html");
    //   break;
    // case "register":
    //   bottomLeft.load("/component/subtabRegister.html");
    //   break;
    case "desc":
      bottomLeft.load("/component/subtabDesc.html");
      break;
  }
}

async function getMOTD() {
  $("#motdQuote").load("/page/motd");
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

async function LogIn() {
  // const username = $("#usernameInput").val();
  // const password = $("#passwordInput").val();
  // const saveCookieCheckboxChecked = $("#SaveLoginCookieBox").is(":checked");
  // if (username == "" || password == "") {
  //   setStatusMessage("Please input both the Username and Password", "warning");
  //   return;
  // }
  // $.post(
  //   "/auth/login/submitinfo",
  //   JSON.stringify({
  //     username: username,
  //     password: password,
  //   }),
  //   function (response, status) {
  //     if (status == "success") {
  //       switch (response) {
  //         case "Failure":
  //           setStatusMessage("Incorrect login information", "warning");
  //           break;
  //         case "NameNotFound":
  //           setStatusMessage("Username not found", "warning");
  //           break;
  //         default:
  //           if (saveCookieCheckboxChecked) {
  //             Cookies.set("authToken", response, {
  //               expires: 7,
  //               sameSite: "strict",
  //               secure: true,
  //             });
  //           }
  //           global.authToken = response;
  //           setStatusMessage("Success! Going to the game page...", "success");
  //           openGamePage();
  //           break;
  //       }
  //     } else {
  //       setStatusMessage(
  //         String("HTTP error, status code: " + String(status)),
  //         "warning",
  //       );
  //     }
  //   },
  // );
  const inputtedCode = $("#loggingIn > input").val();
  const rememberMeBoxChecked = $("#SaveLoginCookieBox").is(":checked");
  if (inputtedCode.length != 8) {
    setStatusMessage("An account code is 8 characters long.", "warning");
    return;
  }
  $.get("/auth/login", {code: inputtedCode, remember: rememberMeBoxChecked})
    .done(() => {
      openGamePage();
    })
    .fail(() => {
      setStatusMessage("Failure to log in, idk why", "warning");
    });
}

async function RegisterAccount() {
  $("#registration > button")
    .text("Requesting new account...")
    .attr("disabled", "true");
  $.get("/auth/register", (data) => {
    $("#registration > h1").text(data);
  })
    .done(() => {
      $("#registration > button").text("Account created!");
    })
    .fail(() => {
      setStatusMessage("An unknown error has occured.");
      $("#registration > button").text("Try again").attr("disabled", "");
    });
}

// async function CheckNameAvailability() {
//   const username = $("#usernameInput").val();
//   if (username == "") {
//     setStatusMessage("Input a name to check it's availability", "default");
//     return;
//   }
//   $.post("/auth/register/checkname", username, (response, status) => {
//     if (status == "success") {
//       switch (response) {
//         case "NameIsAvailable":
//           setStatusMessage("Name is available!", "success");
//           break;
//         case "NameIsTaken":
//           setStatusMessage("Name is not available.", "warning");
//           break;
//       }
//     } else {
//       setStatusMessage("Error, status: " + status, "warning");
//     }
//   });
// }

async function openGamePage() {
  $(document.body).load("/component/gamePage.html");
}

async function logOut() {
  // $.post("/auth/logout", global.authToken, () => {
  //   getMainPage(),
  //     Cookies.remove("authToken", {
  //       expires: 7,
  //       sameSite: "strict",
  //       secure: true,
  //     });
  // });
  $.get("/auth/logout")
    .done(() => getMainPage())
    .fail(() => {
      alert(
        "Failed to request a logout, you may have to delete the cookie from the browser manually.",
      );
    });
}

async function getMoney() {
  $("#moneyCount").load("/game/player/money", global.authToken);
}
