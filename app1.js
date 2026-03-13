const { google } = require("googleapis");
const fs = require("fs");
const nodemailer = require("nodemailer");

const credentials = JSON.parse(
  fs.readFileSync("JSON_PATH")
);

const auth = new google.auth.GoogleAuth({
  credentials,
  scopes: ["https://www.googleapis.com/auth/spreadsheets.readonly"],
});

const spreadsheetId = "1pEanYKVZ8gX-dUGN136uWooGOB0UiZsXtyddNikZGRg";

let emailSet = new Set();


function extractEmails(rows) {

  rows.forEach((row, i) => {

    if (i <= 1) return;

    const email = row[0];

    if (email && email.includes("@")) {
      emailSet.add(email.trim());
    }

  });

}


function tableToHTML(rows, title, headerOnly=false) {

  let html = `<h3>${title}</h3>`;
  html += `<table border="1" cellspacing="0" cellpadding="6">`;

  rows.forEach((row, i) => {

    const isGrandTotal =
      row[0] && row[0].toLowerCase().includes("grand");

    html += `<tr ${isGrandTotal ? 'class="grandtotal"' : ""}>`;

    row.forEach(cell => {

      if (headerOnly) {
        if (i === 0)
          html += `<th>${cell || ""}</th>`;
        else
          html += `<td>${cell || ""}</td>`;
      }
      else {
        if (i <= 1)
          html += `<th>${cell || ""}</th>`;
        else
          html += `<td>${cell || ""}</td>`;
      }

    });

    html += "</tr>";

  });

  html += "</table><br>";

  return html;
}


async function getTable(sheets, range, title, headerOnly=false) {

  const response = await sheets.spreadsheets.values.get({
    spreadsheetId,
    range
  });

  const rows = response.data.values || [];

  extractEmails(rows);

  if (headerOnly && rows.length <= 1) {
    return "";
  }

  return tableToHTML(rows, title, headerOnly);
}


async function main() {

  const client = await auth.getClient();

  const sheets = google.sheets({
    version: "v4",
    auth: client
  });

  let tables = "";

  tables += await getTable(
    sheets,
    "Daily Summary!A73:N100",
    "Table 1: AMOUNT RECEIVED SO FAR AFTER 15 FEBRUARY, 2026 (For KAM)"
  );

  tables += await getTable(
    sheets,
    "Daily Summary!AC74:AC83",
    "Table 2: Sales not performed by KAM till now",
    true
  );

  tables += await getTable(
    sheets,
    "Daily Summary!Q73:Z100",
    "Table 3: PIPELINE MARCH'2026 (KAM)"
  );


  const mailBody = `
  <html>
  <head>
  <style>
  body{font-family:Arial}

  table{
    border-collapse:collapse;
  }

  th{
    background:#eee;
  }

  th, td{
    text-align:center;
  }

  .grandtotal{
    font-weight:bold;
    background:#eee;
  }

  </style>
  </head>

  <body>

  <p>Hi Everyone,</p>

  <p>
  Please find the KAM wise performance report from Feb 15, 2026, to this date.
  </p>

  <p>
  I have also attached the KAM wise pipeline report for your reference.
  </p>

  ${tables}

  <br>

  <p>Regards,</p>

  <p>
  <b>Shashank Shandilya</b><br>
  Executive-Data Analytics<br>
  DotPe Private Limited<br>
  M: +918860844270
  </p>

  </body>
  </html>
  `;


  const today = new Date();

  const formattedDate =
    String(today.getDate()).padStart(2, '0') + "/" +
    String(today.getMonth()+1).padStart(2, '0') + "/" +
    today.getFullYear();


  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: "shashank.shandilya@dotpe.in",
      pass: "xcor empn mdwt hrys"
    }
  });


  const ccEmails = [
    ...emailSet,
    "pradeep.singh1@dotpe.in",
    "shriya.gupta@dotpe.in",
    "sujeeth.deepak@dotpe.in",
    "amit.shaw@dotpe.in",
    "abhishek.pareek@dotpe.in",
    "kartik.awanti@dotpe.in"
  ];


  await transporter.sendMail({
    from: "shashank.shandilya@dotpe.in",

    to: [
      "shailaz@dotpe.in",
      "anurag@dotpe.in",
      "somnath.sengupta@dotpe.in",
      "ritika.malhotra@dotpe.in",
      "mohnish.carani@dotpe.in"
    ],

    cc: [...new Set(ccEmails)],

    subject: `Mission 1cr- Daily Update (${formattedDate})`,
    html: mailBody
  });

  console.log("Email sent successfully");

}

main();