$(document).ready(() => {
  getMOTD();
});

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

async function openGamePage() {
  $(document.body).load("/component/gamePage.html");
}

async function logOut() {
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
