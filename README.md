
# PoshBot.Networking

A simple [PoshBot](https://github.com/devblackops/PoshBot) plugin for networking commands.

## Install Module

To install the module from the [PowerShell Gallery](https://www.powershellgallery.com/):

```
PS C:\> Install-Module -Name PoshBot.Networking -Repository PSGallery
```

## Install Plugin

To install the plugin from within PoshBot:

```
!install-plugin --name poshbot.networking
```

## Commands

- Ping
- Dig

## Usage

```
!ping www.google.com

Pinging www.google.com [172.217.3.164] with 32 bytes of data:
Reply from 172.217.3.164: bytes=32 time=11ms TTL=54
Reply from 172.217.3.164: bytes=32 time=10ms TTL=54
Reply from 172.217.3.164: bytes=32 time=11ms TTL=54
Reply from 172.217.3.164: bytes=32 time=12ms TTL=54
Reply from 172.217.3.164: bytes=32 time=12ms TTL=54

Ping statistics for 172.217.3.164:
    Packets: Sent = 5, Received = 5, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 10ms, Maximum = 12ms, Average = 11ms
```

```
!ping --name www.google.com --count 1 --ipv6

Pinging www.google.com [2607:f8b0:400a:808::2004] with 32 bytes of data:
Reply from 2607:f8b0:400a:808::2004: time=12ms

Ping statistics for 2607:f8b0:400a:808::2004:
    Packets: Sent = 1, Received = 1, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 12ms, Maximum = 12ms, Average = 12ms
```

```
!dig www.google.com

Name           Type TTL Section IPAddress
----           ---- --- ------- ---------
www.google.com AAAA 202 Answer  2607:f8b0:400a:808::2004
www.google.com A    202 Answer  172.217.3.196
```

```
!dig --name www.google.com --type SOA --server 8.8.8.8

Name       Type TTL Section   PrimaryServer  NameAdministrator    SerialNumber
----       ---- --- -------   -------------  -----------------    ------------
google.com SOA  59  Authority ns4.google.com dns-admin.google.com 150821008
```

```
!testport server1 443
ComputerName RemotePort RemoteAddress PingSucceeded PingReplyDetails (RTT) TcpTestSucceeded
------------ ---------- ------------- ------------- ---------------------- ----------------
server1       443        1.2.3.4      False                                True
```

```
!testport --computername server2  --port 5986
ComputerName RemotePort RemoteAddress PingSucceeded PingReplyDetails (RTT) TcpTestSucceeded
------------ ---------- ------------- ------------- ---------------------- ----------------
server2       5986       1.2.3.4      False                                True
```
