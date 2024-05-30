/*
  Project Business Road
  AGPL-3.0-or-later
  Source code available at https://github.com/21DP4KLogi/ProjectBusinessRoad/
*/
$(document).ready(() => {
  getMOTD();
});

function getCurrentMoney() {
  $.get("/game/money", (data) => {
    $("#moneyCounter").text("$" + data);
  });
}
var moneyInterval;

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
  const altchaSolution = $("[name='altcha']").val() 
  if (inputtedCode.length != 8) {
    setStatusMessage("An account code is 8 characters long.", "warning");
    return;
  }
  $.get("/auth/login", { code: inputtedCode, remember: rememberMeBoxChecked, altcha: altchaSolution })
    .done(() => {
      openGamePage();
    })
    .fail(() => {
      setStatusMessage("Failure to log in, idk why", "warning");
    });
}

async function RegisterAccount() {
  const altchaSolution = $("[name='altcha']").val() 
  $("#registration > button")
    .text("Requesting new account...")
    .attr("disabled", true);
  $.get("/auth/register", {altcha: altchaSolution}, (data) => {
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
  getCurrentMoney();
  moneyInterval = setInterval(getCurrentMoney, 1000);
  listBusinesses();
}

async function logOut() {
  clearInterval(moneyInterval);
  $.get("/auth/logout")
    .done(() => getMainPage())
    // .fail(() => {
    //   alert(
    //     "Failed to request a logout, you may have to delete the cookie from the browser manually.",
    //   );
    // });
}

async function fullLogOut() {
  clearInterval(moneyInterval);
  $.get("/auth/secureLogout")
    .done(() => getMainPage());
}

async function deleteAccount() {
  clearInterval(moneyInterval);
  const altchaSolution = $("[name='altcha']").val() 
  const inputtedCode = $("#accountDeletion input").val();
  $.get("/auth/deleteAccount", {code: inputtedCode, altcha: altchaSolution})
    .done(() => alert("Account " + inputtedCode + " deleted!"));
}

function createBusinessElement(id, field, value) {
  // Not optimal but im a bit busy
  return `
    <div class="businessCard" onclick="inspectBusiness(${id});">
      <h2>${field}</h2>
      <p>Val: ${value}</p>
    </div>
  `
}

async function listBusinesses() {
  $.getJSON("/game/business/list", (data) => {
    let businessList = data["businesses"];
    $("#businessList").empty();
    for (index in businessList) {
      let biz = businessList[index];
      $("#businessList").append(createBusinessElement(biz["id"], biz["field"], biz["value"]));
    }
  });
}

async function searchForEmployees(businessID) {
  $.getJSON("/game/business/findemployees/" + businessID, (data) => {
    let potentialEmployees = data["interviewees"];
    $("#potentialEmployees ul").empty();
    for (index in potentialEmployees) {
      let emp = potentialEmployees[index];
      $("#potentialEmployees ul")
        .append(`
        <li>
          ${emp["name"]}, ${emp["proficiency"]}
          <button onclick="hireEmployee(${businessID}, ${emp["id"]})">Hire</button>
        </li>
      `);
    }
  });
}

async function hireEmployee(businessID, employeeID) {
  $.get("/game/business/hireemployee/" + businessID + "/" + employeeID);
}


function inspectBusiness(id) {
  $.getJSON("/game/business/inspectbusiness/" + id, (data) => {
    let business = data["business"];
    let employeeList = data["employees"];
    let potentialEmployees = data["interviewees"];
    $("#bottomleft")
      .empty()
      .append(`
        <h1>${business["field"]} business</h1>
        <p>Business value: ${business["value"]}<br>
        Employee count: ${employeeList.length}</p>
        <ul id="employeeList"></ul>
        <button onclick="searchForEmployees(${business["id"]})">Find job seekers</button>
        <div id="potentialEmployees">
          <ul></ul>
        </div>
        `);
    for (index in employeeList) {
      let emp = employeeList[index];
      $("#employeeList").append(`<li>${emp["name"]}, ${emp["proficiency"]}</li>`);
    }
    for (index in potentialEmployees) {
      let emp = potentialEmployees[index];
      $("#potentialEmployees ul").append(`
        <li>
          ${emp["name"]}, ${emp["proficiency"]}
          <button onclick="hireEmployee(${business["id"]}, ${emp["id"]})">Hire</button>
        </li>
      `);
    }
  });
}

async function foundNewBusiness(field) {
  $.get("/game/business/create/" + field, () => {
    listBusinesses();
    getCurrentMoney();
  });
}

async function openCreateBusiness() {
  $("#bottomleft")
    .empty()
    .append(`
    <div id=newBusinessSelection>
      <h1>Choose the field for your new business</h1>
      <h3>Founding a business costs <b>$5000</b></h3>
      <button onclick="foundNewBusiness('baking')">Baking</button>
      <p>A bakery to produce goods of the baked variety</p><br>
      <button onclick="foundNewBusiness('programming')">Programming</button>
      <p>The home of a new JavaScript framework</p><br>
    </div>
  `);
  listBusinesses();
}
