$(document).ready(() => {
  getMOTD();
});

async function getMainPage() {
  await $(document.body).load("/component/mainPage.html", () => {
    $("#motdQuote").load("/page/motd");
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
  $("#requestStatusText")
    .text(message)
    .attr("class", color + "Color");
}

async function LogIn() {
  const inputtedCode = $("#codeInput").val();
  const rememberMeBoxChecked = $("#SaveLoginCookieBox").is(":checked");
  if (inputtedCode.length != 8) {
    setStatusMessage("An account code is 8 characters long.", "warning");
    return;
  }
  $.get("/auth/login", { code: inputtedCode, remember: rememberMeBoxChecked })
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
    .attr("disabled");
  $.get("/auth/register", (data) => {
    $("#registration > h1").text(data);
  })
    .done(() => {
      $("#registration > button").text("Account created!");
    })
    .fail(() => {
      setStatusMessage("An unknown error has occured.");
      $("#registration > button").text("Try again").removeAttr("disabled");
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
