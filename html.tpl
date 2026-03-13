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
gap:40px;
margin-bottom:30px;
}

.card{
background:white;
padding:20px;
border-radius:8px;
box-shadow:0px 2px 6px rgba(0,0,0,0.2);
text-align:center;
width:200px;
}

.count{
font-size:32px;
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

.severity{
font-weight:bold;
text-align:center;
}

.severity-LOW{background:#27ae6040;}
.severity-MEDIUM{background:#f1c40f40;}
.severity-HIGH{background:#e67e2240;}
.severity-CRITICAL{background:#e74c3c40;}

.reason{
max-width:500px;
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

<br>

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

<tr class="severity-{{ escapeXML .Vulnerability.Severity }}">

<td>{{ escapeXML .PkgName }}</td>

<td>{{ escapeXML .VulnerabilityID }}</td>

<td class="severity">{{ escapeXML .Vulnerability.Severity }}</td>

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

let critical=0
let high=0
let medium=0
let low=0

document.querySelectorAll(".severity").forEach(function(el){

let sev=el.innerText.trim()

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
}
})

function downloadPDF(){

const { jsPDF } = window.jspdf

const doc=new jsPDF()

doc.text("Trivy Security Report",20,20)

doc.text("Total Vulnerabilities: "+total,20,40)
doc.text("Critical: "+critical,20,50)
doc.text("High: "+high,20,60)
doc.text("Medium: "+medium,20,70)
doc.text("Low: "+low,20,80)

doc.save("trivy-report.pdf")

}

</script>

</body>
</html>
