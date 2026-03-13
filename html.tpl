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
font-size:18px;
margin-bottom:20px;
}

.dashboard{
display:flex;
justify-content:center;
gap:25px;
margin-bottom:30px;
flex-wrap:wrap;
}

.card{
background:white;
padding:15px;
border-radius:8px;
box-shadow:0px 2px 6px rgba(0,0,0,0.2);
text-align:center;
width:150px;
}

.count{
font-size:30px;
font-weight:bold;
}

.low{color:#27ae60;}
.medium{color:#f1c40f;}
.high{color:#e67e22;}
.critical{color:#e74c3c;}

table{
width:95%;
margin:auto;
border-collapse:collapse;
background:white;
}

th, td{
padding:10px;
border:1px solid #ddd;
text-align:left;
}

th{
background:#2c3e50;
color:white;
}

tr:nth-child(even){
background:#f2f2f2;
}

.sev-badge{
padding:5px 10px;
border-radius:5px;
font-weight:bold;
color:white;
}

.CRITICAL{background:#e74c3c;}
.HIGH{background:#e67e22;}
.MEDIUM{background:#f1c40f;color:black;}
.LOW{background:#27ae60;}

.reason{
max-width:450px;
word-wrap:break-word;
}

button{
display:block;
margin:20px auto;
padding:10px 20px;
font-size:16px;
cursor:pointer;
background:#3498db;
color:white;
border:none;
border-radius:5px;
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
<div class="count" id="totalVulns">0</div>
</div>

<div class="card">
<div class="critical">CRITICAL</div>
<div class="count critical" id="criticalCount">0</div>
</div>

<div class="card">
<div class="high">HIGH</div>
<div class="count high" id="highCount">0</div>
</div>

<div class="card">
<div class="medium">MEDIUM</div>
<div class="count medium" id="mediumCount">0</div>
</div>

<div class="card">
<div class="low">LOW</div>
<div class="count low" id="lowCount">0</div>
</div>

</div>

<div style="width:400px;margin:auto;">
<canvas id="severityChart"></canvas>
</div>

<button onclick="downloadPDF()">Download PDF Report</button>

<table>

<tr>
<th>Package</th>
<th>CVE</th>
<th>Severity</th>
<th>Installed</th>
<th>Fixed Version</th>
<th>Reason</th>
<th>References</th>
</tr>

{{- range . }}
{{- range .Vulnerabilities }}

<tr>

<td>{{ escapeXML .PkgName }}</td>

<td>{{ escapeXML .VulnerabilityID }}</td>

<td class="severityCell" data-severity="{{ escapeXML .Vulnerability.Severity }}">
<span class="sev-badge {{ escapeXML .Vulnerability.Severity }}">
{{ escapeXML .Vulnerability.Severity }}
</span>
</td>

<td>{{ escapeXML .InstalledVersion }}</td>

<td>{{ escapeXML .FixedVersion }}</td>

<td class="reason">
{{ escapeXML .Vulnerability.Title }}
</td>

<td>
{{- range .Vulnerability.References }}
<a href="{{ escapeXML . }}" target="_blank">Link</a><br>
{{- end }}
</td>

</tr>

{{- end }}
{{- end }}

</table>

<script>

document.addEventListener("DOMContentLoaded", function(){

let critical=0
let high=0
let medium=0
let low=0

document.querySelectorAll(".severityCell").forEach(function(el){

let sev=el.dataset.severity

if(sev==="CRITICAL"){critical++}
if(sev==="HIGH"){high++}
if(sev==="MEDIUM"){medium++}
if(sev==="LOW"){low++}

})

let total=critical+high+medium+low

document.getElementById("totalVulns").innerText=total
document.getElementById("criticalCount").innerText=critical
document.getElementById("highCount").innerText=high
document.getElementById("mediumCount").innerText=medium
document.getElementById("lowCount").innerText=low

const ctx=document.getElementById('severityChart')

new Chart(ctx,{
type:'pie',
data:{
labels:['CRITICAL','HIGH','MEDIUM','LOW'],
datasets:[{
data:[critical,high,medium,low],
backgroundColor:[
'#e74c3c',
'#e67e22',
'#f1c40f',
'#27ae60'
]
}]
},
options:{
plugins:{
legend:{
position:'bottom'
}
}
}
})

})

function downloadPDF(){

const { jsPDF } = window.jspdf

const doc=new jsPDF()

doc.text("Trivy Security Report",20,20)

doc.text("Total Vulnerabilities: "+document.getElementById("totalVulns").innerText,20,40)
doc.text("Critical: "+document.getElementById("criticalCount").innerText,20,50)
doc.text("High: "+document.getElementById("highCount").innerText,20,60)
doc.text("Medium: "+document.getElementById("mediumCount").innerText,20,70)
doc.text("Low: "+document.getElementById("lowCount").innerText,20,80)

doc.save("trivy-report.pdf")

}

</script>

</body>
</html>