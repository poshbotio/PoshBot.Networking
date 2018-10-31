
$scoobyDooUri = 'https://raw.githubusercontent.com/poshbotio/PoshBot/master/Media/scooby_doo.jpg'

function Invoke-Ping {
    <#
    .SYNOPSIS
        Tests a connection to a host.
    .PARAMETER Name
        IPAddress or DNS name to ping.
    .PARAMETER Count
        The number of pings to send.
    .PARAMETER IPv6
        Use IPv6
    .EXAMPLE
        !ping (<www.google.com> | -name <www.google.com>) [-count 2] [-ipv6]
    #>
    [PoshBot.BotCommand(
        CommandName = 'ping',
        Permissions = 'test-network'
    )]
    [cmdletbinding()]
    param(
        [parameter(Mandatory, Position = 0)]
        [string]$Name,

        [parameter(Position = 1)]
        [int]$Count = 5,

        [parameter(position = 2)]
        [switch]$IPv6
    )

    if ($PSBoundParameters.ContainsKey('IPv6')) {
        $r = Invoke-Command -ScriptBlock { ping.exe $Name -n $Count -6 -a }
    } else {
        $r = Invoke-Command -ScriptBlock { ping.exe $Name -n $Count -4 -a }
    }

    New-PoshBotCardResponse -Type Normal -Text ($r -Join "`n")
}

function Invoke-Dig {
    <#
    .SYNOPSIS
        Perform DNS resolution on a host.
    .PARAMETER Name
        The DNS name to resolve.
    .PARAMETER Type
        THe DNS record type to resolve.
    .PARAMETER Server
        The DNS server to use.
    .EXAMPLE
        !dig (<www.google.com> | -name <www.google.com>) [-type <A>] [-server <8.8.8.8>]
    #>
    [PoshBot.BotCommand(
        CommandName = 'dig',
        Permissions = 'test-network'
    )]
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [string]$Name,

        [ValidateSet('A', 'A_AAAA', 'AAAA', 'NS', 'MX', 'MD', 'MF', 'CNAME', 'SOA', 'MB', 'MG', 'MR', 'NULL', 'WKS', 'PTR',
                     'HINFO', 'MINFO', 'TXT', 'RP', 'AFSDB', 'X25', 'ISDN', 'RT', 'SRV', 'DNAME', 'OPT', 'DS', 'RRSIG',
                     'NSEC', 'DNSKEY', 'DHCID', 'NSEC3', 'NSEC3PARAM', 'ANY', 'ALL')]
        [string]$Type = 'A_AAAA',

        [string]$Server
    )

    if ($PSBoundParameters.ContainsKey('Server')) {
        $r = Resolve-DnsName -Name $Name -Type $Type -Server $Server | Format-Table -Autosize | Out-String
    } else {
        $r = Resolve-DnsName -Name $Name -Type $Type -ErrorAction SilentlyContinue | Format-Table -Autosize | Out-String
    }

    if ($r) {
        New-PoshBotCardResponse -Type Normal -Text $r
    } else {
        New-PoshBotCardResponse -Type Warning -Text "Unable to resolve [$Name] :(" -Title 'Rut row' -ThumbnailUrl $scoobyDooUri
    }
}

function Invoke-TestPort {
    <#
    .SYNOPSIS
        Perform port testing on a host.
    .PARAMETER ComputerName
        The computure name or IP address to test.
    .PARAMETER Port
        The TCP port to test.
    .EXAMPLE
        !testport (srv.domain.local | --ComputerName src.domain.local) [--Port 443]
    #>
    [PoshBot.BotCommand(
        CommandName = 'testport',
        Permissions = 'test-network'
    )]
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [Alias('Name')]
        [string]$ComputerName,

        [parameter(Mandatory)]
        [string]$Port
    )

    if ($PSVersionTable.PSVersion.Major -ge 6) {
        $r = Test-Connection -TargetName $ComputerName -TCPPort $Port -ErrorAction SilentlyContinue |
                Select-Object @{Name = 'ComputerName'; Expression = {$ComputerName}}, @{Name = 'Port'; Expression = {$Port}}, @{Name = 'Result'; Expression = {$_}} |
                Format-Table -Autosize |
                Out-String
    } else {
        $r = Test-NetConnection -ComputerName $ComputerName -Port $Port -ErrorAction SilentlyContinue | Format-Table -Autosize | Out-String
    }

    if ($r) {
        New-PoshBotCardResponse -Type Normal -Text $r
    } else {
        New-PoshBotCardResponse -Type Warning -Text "Unable to resolve [$ComputerName] :(" -Title 'Rut row' -ThumbnailUrl $scoobyDooUri
    }
}

function Get-WebServerInfo {
    <#
    .SYNOPSIS
        Check HTTP header for serverinfo.
    .PARAMETER Uri
        Uri to retrieve HTTP server information for.
    .EXAMPLE
        !webserverinfo http://uri
    #>
    [PoshBot.BotCommand(
        CommandName = 'webserverinfo',
        Permissions = 'test-network'
    )]
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [Alias('WebServer')]
        [string]$Uri
    )

    try {
        $httpResponse = Invoke-WebRequest -UseBasicParsing -Uri $Uri
        if ($httpResponse.Headers.server.count -gt 0) {
            $response = $httpResponse.Headers.server -join ' '
        } else {
            $errorMessage = 'No Server Info'
        }
    } catch [System.Net.WebException] {
        switch ($_.Exception.Response.StatusCode) {
            'BadRequest' {
                $errorMessage = 'Server Error'
            }
            'InternalServerError' {
                $errorMessage = 'Server Error 500'
            }
            default {
                $errorMessage =  "Server Error: $($_.Exception)"
            }
        }
    } catch {
        Write-Debug $_.Exception
        $errorMessage =  "Received a general error: $($_.Exception)"
    } finally {
        if ($errorMessage) {
            New-PoshBotCardResponse -Type Warning -Text "$errorMessage :(" -Title 'Rut row' -ThumbnailUrl $scoobyDooUri
        }
        if ($response) {
            New-PoshBotCardResponse -Type Normal -Text $response
        }
    }
}

function Get-GeoLocIp {
    <#
    .SYNOPSIS
        Get Geo location for an IP or a CIDR network from the RIPE database
    .PARAMETER IPAddress
        IP address to retrieve geo location information for.
    .EXAMPLE
        !geolocip 83.23.45.3
        !geolocip 83.23.45.0/21
     #>
    [PoshBot.BotCommand(
        CommandName = 'geolocip',
        Permissions = 'test-network'
    )]
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [Alias('IP')]
        [string]$IPAddress
    )

    try {
        $httpResponse = Invoke-WebRequest -UseBasicParsing -Uri "https://stat.ripe.net/data/geoloc/data.json?resource=$($IPAddress)"
        if ($httpResponse) {
            $jsonResponse = $httpResponse | ConvertFrom-Json
            if ($jsonResponse.data.locations.count -gt 0) {
                $response = ''
                foreach ($location in $jsonResponse.data.locations) {
                    $response += "$($location.City) $($location.country) `n"
                }
            } else {
                $errorMessage = 'Not Found'
            }
        }
    } catch [System.Net.WebException] {
        switch ($_.Exception.Response.StatusCode) {
            'BadRequest' {
                $errorMessage = 'Server Error'
            }
            'InternalServerError' {
                $errorMessage = 'Server Error 500'
            }
            default {
                 $errorMessage =  "Server Error: $($_.Exception)"
            }
        }
    } catch {
        Write-debug $_.Exception
        $errorMessage =  "Receive a general error: $($_.Exception)"
    } finally {
        if ($errorMessage) {
            New-PoshBotCardResponse -Type Warning -Text "$errorMessage :(" -Title 'Rut row' -ThumbnailUrl $scoobyDooUri
        }
        if ($response) {
            New-PoshBotCardResponse -Type Normal -Text $response
        }
    }
}

function Get-NetASInfo {
    <#
    .SYNOPSIS
        Check HTTP header for server information.
    .PARAMETER IPAddress
        IP address to retrieve network AS information for.
    .EXAMPLE
        !netasinfo IPAddress
    #>
    [PoshBot.BotCommand(
        CommandName = 'netasinfo',
        Permissions = 'test-network'
    )]
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [Alias('IP')]
        [string]$IPAddress
    )

    try {
        $httpResponse = Invoke-WebRequest -UseBasicParsing -Uri "https://stat.ripe.net/data/searchcomplete/data.json?resource=$($IPAddress)"
        if ($httpResponse) {
            $jsonResponse = $httpResponse | ConvertFrom-Json
            if ($null -ne $jsonResponse.data.categories) {
                if ($jsonResponse.data.categories.suggestions.count -gt 0) {
                    foreach ($row in  $jsonResponse.data.categories.suggestions) {
                        if ($row.value -like 'AS*') {
                            $asCode = $row.value
                        }
                    }
                } else {
                    $asCode =  $jsonResponse.data.categories.suggestions.value
                }

                if ($asCode) {
                    $asInfoResponse = Invoke-WebRequest -UseBasicParsing -Uri "https://stat.ripe.net/data/as-overview/data.json?resource=$($asCode)"
                    $jsonAsInfo = $asInfoResponse | ConvertFrom-Json
                    $response = "$asCode $($jsonAsInfo.data.holder)"
                } else {
                    $errorMessage = 'Not Data Found'
                }
            } else {
                $errorMessage = 'Not Data Found'
            }
        }
    } catch [System.Net.WebException] {
        switch ($_.Exception.Response.StatusCode) {
            'BadRequest' {
                $errorMessage = 'Server Error'
            }
            'InternalServerError' {
                $errorMessage = 'Server Error 500'
            }
            default {
                $errorMessage =  "Server Error: $($_.Exception)"
            }
        }
    } catch {
        Write-debug $_.Exception
        $errorMessage =  "Receive a general error: $($_.Exception)"
    } finally {
        if ($errorMessage) {
            New-PoshBotCardResponse -Type Warning -Text "$errorMessage :(" -Title 'Rut row' -ThumbnailUrl $scoobyDooUri
        }
        if ($response) {
            New-PoshBotCardResponse -Type Normal -Text $response
        }
    }
}

Export-ModuleMember -Function 'Invoke-Ping', 'Invoke-Dig', 'Invoke-TestPort', 'Get-WebServerInfo', 'Get-GeoLocIp', 'Get-NetASInfo'
