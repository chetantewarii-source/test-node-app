<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Trivy Security Dashboard</title>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>

<style>

body{
font-family: Arial, Helvetica, sans-serif;
background:#f4f6f8;
padding:20px;
}

h1{
text-align:center;
}

.summary{
text-align:center;
margin-bottom:20px;
font-size:16px;
}

.dashboard{
display:flex;
justify-content:center;
gap:20px;
margin-bottom:30px;
flex-wrap:wrap;
}

.card{
background:white;
padding:15px;
border-radius:8px;
box-shadow:0 2px 6px rgba(0,0,0,0.2);
width:140px;
text-align:center;
}

.count{
font-size:28px;
font-weight:bold;
}

.CRITICAL{color:#e74c3c}
.HIGH{color:#e67e22}
.MEDIUM{color:#f1c40f}
.LOW{color:#27ae60}

table{
width:95%;
margin:auto;
border-collapse:collapse;
background:white;
}

th,td{
padding:10px;
border:1px solid #ddd;
}

th{
background:#34495e;
color:white;
}

tr:nth-child(even){
background:#f2f2f2;
}

.badge{
padding:4px 8px;
border-radius:4px;
font-weight:bold;
color:white;
}

.badge.CRITICAL{background:#e74c3c}
.badge.HIGH{background:#e67e22}
.badge.MEDIUM{background:#f1c40f;color:black}
.badge.LOW{background:#27ae60}

.reason{
max-width:450px;
word-wrap:break-word;
}

button{
display:block;
margin:25px auto;
padding:10px 20px;
background:#3498db;
color:white;
border:none;
border-radius:5px;
cursor:pointer;
}

</style>
</head>

<body>

<h1>Container Security Dashboard</h1>

<div class="summary">
Target Image: {{ escapeXML ( index . 0 ).Target }} <br>
Generated: {{ now }}
</div>

<div class="dashboard">

<div class="card">
<div>Total</div>
<div class="count" id="total">0</div>
</div>

<div class="card">
<div class="CRITICAL">CRITICAL</div>
<div class="count CRITICAL" id="critical">0</div>
</div>

<div class="card">
<div class="HIGH">HIGH</div>
<div class="count HIGH" id="high">0</div>
</div>

<div class="card">
<div class="MEDIUM">MEDIUM</div>
<div class="count MEDIUM" id="medium">0</div>
</div>

<div class="card">
<div class="LOW">LOW</div>
<div class="count LOW" id="low">0</div>
</div>

</div>

<div style="width:400px;margin:auto">
<canvas id="chart"></canvas>
</div>

<button onclick="downloadPDF()">Download PDF Report</button>

<table id="vulnTable">

<tr>
<th>Package</th>
<th>CVE</th>
<th>Severity</th>
<th>Installed</th>
<th>Fixed</th>
<th>Reason</th>
<th>Reference</th>
</tr>

{{- range . }}
{{- range .Vulnerabilities }}

<tr data-severity="{{ escapeXML .Vulnerability.Severity }}">

<td>{{ escapeXML .PkgName }}</td>

<td>{{ escapeXML .VulnerabilityID }}</td>

<td>
<span class="badge {{ escapeXML .Vulnerability.Severity }}">
{{ escapeXML .Vulnerability.Severity }}
</span>
</td>

<td>{{ escapeXML .InstalledVersion }}</td>

<td>{{ escapeXML .FixedVersion }}</td>

<td class="reason">{{ escapeXML .Vulnerability.Title }}</td>

<td>
<a href="{{ escapeXML (index .Vulnerability.References 0) }}" target="_blank">Advisory</a>
</td>

</tr>

{{- end }}
{{- end }}

</table>

<script>

document.addEventListener("DOMContentLoaded",function(){

let critical=0
let high=0
let medium=0
let low=0

let rows=document.querySelectorAll("#vulnTable tr[data-severity]")

rows.forEach(function(row){

let sev=row.dataset.severity

if(sev==="CRITICAL") critical++
if(sev==="HIGH") high++
if(sev==="MEDIUM") medium++
if(sev==="LOW") low++

})

let total=critical+high+medium+low

document.getElementById("total").innerText=total
document.getElementById("critical").innerText=critical
document.getElementById("high").innerText=high
document.getElementById("medium").innerText=medium
document.getElementById("low").innerText=low

const ctx=document.getElementById("chart")

new Chart(ctx,{
type:"pie",
data:{
labels:["CRITICAL","HIGH","MEDIUM","LOW"],
datasets:[{
data:[critical,high,medium,low],
backgroundColor:[
"#e74c3c",
"#e67e22",
"#f1c40f",
"#27ae60"
]
}]
},
options:{
plugins:{legend:{position:"bottom"}}
}
})

})

function downloadPDF(){

const { jsPDF } = window.jspdf

const doc=new jsPDF()

doc.text("Trivy Security Report",20,20)

doc.text("Total: "+document.getElementById("total").innerText,20,40)
doc.text("Critical: "+document.getElementById("critical").innerText,20,50)
doc.text("High: "+document.getElementById("high").innerText,20,60)
doc.text("Medium: "+document.getElementById("medium").innerText,20,70)
doc.text("Low: "+document.getElementById("low").innerText,20,80)

doc.save("trivy-report.pdf")

}

</script>

</body>
</html>