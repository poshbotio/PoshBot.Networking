
function Invoke-Ping {
    <#
    .SYNOPSIS
        Tests a connection to a host
    .EXAMPLE
        !ping (<www.google.com> | --name <www.google.com>) [--count 2] [--ipv6]
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
        Perform DNS resolution on a host
    .EXAMPLE
        !dig (<www.google.com> | --name <www.google.com>) [--type <A>] [--server <8.8.8.8>]
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
        New-PoshBotCardResponse -Type Warning -Text "Unable to resolve [$Name] :(" -Title 'Rut row' -ThumbnailUrl 'http://images4.fanpop.com/image/photos/17000000/Scooby-Doo-Where-Are-You-The-Original-Intro-scooby-doo-17020515-500-375.jpg'
    }
}

function Invoke-TestPort {
    <#
    .SYNOPSIS
        Perform port testing on a host
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
                Select-Object @{Name ='ComputerName';Expression={$ComputerName}},@{Name='Port';Expression={$Port}},@{Name='Result';Expression={$_}} |
                Format-Table -Autosize |
                Out-String
    }
    else {
        $r = Test-NetConnection -ComputerName $ComputerName -Port $Port -ErrorAction SilentlyContinue | Format-Table -Autosize | Out-String
    }
    if ($r) {
        New-PoshBotCardResponse -Type Normal -Text $r
    } else {
        New-PoshBotCardResponse -Type Warning -Text "Unable to resolve [$ComputerName] :(" -Title 'Rut row' -ThumbnailUrl 'http://images4.fanpop.com/image/photos/17000000/Scooby-Doo-Where-Are-You-The-Original-Intro-scooby-doo-17020515-500-375.jpg'
    }
}


function get-webServerInfos {
    <#
    .SYNOPSIS
        Check HTTP header for serverinfo
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

    $HttpResponse = Invoke-WebRequest -UseBasicParsing -Uri $Uri 

    if ($HttpResponse.Headers.server.count -gt 0) {
        $Response = $HttpResponse.Headers.server -join " "
    }
    else {
        $ErrorMessage = "No Server Info"
    }

}
    Catch [System.Net.WebException] {

        switch ($_.Exception.Response.StatusCode) {
            "BadRequest" { 
                $ErrorMessage = "Server Error"
             }
           
            "InternalServerError" { 
                $ErrorMessage = "Server Error 500"
            }
            Default {
                 $ErrorMessage =  "Server Error"  +  $_.Exception
            }
        }
    }
    catch {
        write-debug $_.Exception
        $ErrorMessage =  "Receive a general error " +  $_.Exception
    }

    finally {

        if ($ErrorMessage) {
            New-PoshBotCardResponse -Type Warning -Text "$ErrorMessage :(" -Title 'Rut row' -ThumbnailUrl 'https://raw.githubusercontent.com/poshbotio/PoshBot/master/Media/scooby_doo.jpg'
        }

        if ($Response) {
            New-PoshBotCardResponse -Type Normal -Text $Response
        }
        
    }

}

function get-GeoLocIp {
    <#
    .SYNOPSIS
        Get Geo location for an IP or a CIDR network from the RIPE database
    
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
        [string]$IP
    )

 
 try {

    $HttpResponse = Invoke-WebRequest -UseBasicParsing -Uri "https://stat.ripe.net/data/geoloc/data.json?resource=$($IP)"

    if ($HttpResponse) {

        $JsonResponse = $HttpResponse | ConvertFrom-Json
        

        if ($JsonResponse.data.locations.count -gt 0) {
        
            $Response = ""

            foreach ($location in $JsonResponse.data.locations) {

                $Response += "$($location.City) $($location.country) `n"

            }


        }
        else {
            $ErrorMessage = "Not Found"
        }
    }



}
    Catch [System.Net.WebException] {

        switch ($_.Exception.Response.StatusCode) {
            "BadRequest" { 
                $ErrorMessage = "Server Error"
             }
           
            "InternalServerError" { 
                $ErrorMessage = "Server Error 500"
            }
            Default {
                 $ErrorMessage =  "Server Error"  +  $_.Exception
            }
        }
    }
    catch {
        write-debug $_.Exception
        $ErrorMessage =  "Receive a general error " +  $_.Exception
    }

    finally {

        if ($ErrorMessage) {
            New-PoshBotCardResponse -Type Warning -Text "$ErrorMessage :(" -Title 'Rut row' -ThumbnailUrl 'https://raw.githubusercontent.com/poshbotio/PoshBot/master/Media/scooby_doo.jpg'
        }

        if ($Response) {
            New-PoshBotCardResponse -Type Normal -Text $Response

        }
        
    }

}

function get-NetASInfo {
    <#
    .SYNOPSIS
        Check HTTP header for serverinfo
    .EXAMPLE
        !NetASInfo IP
    #>
    [PoshBot.BotCommand(
        CommandName = 'NetASInfo',
        Permissions = 'test-network'
    )]
     
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [string]$IP
    )
   
 
 try {

    $HttpResponse = Invoke-WebRequest -UseBasicParsing -Uri "https://stat.ripe.net/data/searchcomplete/data.json?resource=$($IP)"

    if ($HttpResponse) {

        $JsonResponse = $HttpResponse | ConvertFrom-Json
        
        
        
        if ($JsonResponse.data.categories -ne $null) {
        
            if ($JsonResponse.data.categories.suggestions.count -gt 0) {
            
                foreach ($RowData in  $JsonResponse.data.categories.suggestions) {

                        if ($RowData.value -like 'AS*') {
                            $AsCode = $RowData.value
                            
                        }
                }
            }
            else {
                $AsCode =  $JsonResponse.data.categories.suggestions.value
            }
            

            if ($AsCode) {

                $AsInfoResponse = Invoke-WebRequest -UseBasicParsing -Uri "https://stat.ripe.net/data/as-overview/data.json?resource=$($AsCode)"

                $JsonAsInfo = $AsInfoResponse | ConvertFrom-Json

                $Response = $AsCode + " " + $JsonAsInfo.data.holder
                 
            }
            else {
                $ErrorMessage = "Not Data Found"
            }

           
            


        }
        else {
            $ErrorMessage = "Not Data Found"
        }
    }



}
    Catch [System.Net.WebException] {

        switch ($_.Exception.Response.StatusCode) {
            "BadRequest" { 
                $ErrorMessage = "Server Error"
             }
           
            "InternalServerError" { 
                $ErrorMessage = "Server Error 500"
            }
            Default {
                 $ErrorMessage =  "Server Error"  +  $_.Exception
            }
        }
    }
    catch {
        write-debug $_.Exception
        $ErrorMessage =  "Receive a general error " +  $_.Exception
    }

    finally {

        if ($ErrorMessage) {
            New-PoshBotCardResponse -Type Warning -Text "$ErrorMessage :(" -Title 'Rut row' -ThumbnailUrl 'https://raw.githubusercontent.com/poshbotio/PoshBot/master/Media/scooby_doo.jpg'
        }

        if ($Response) {
            New-PoshBotCardResponse -Type Normal -Text $Response
        }
        
    }

}


get-NetASInfo -ip "178.ezarez.208.20"



Export-ModuleMember -Function 'Invoke-Ping', 'Invoke-Dig', 'Invoke-TestPort', 'Get-WebServerInfos','get-GeoLocIp','get-NetASInfo'
