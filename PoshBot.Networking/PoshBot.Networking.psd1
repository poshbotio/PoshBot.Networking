@{
    RootModule        = 'PoshBot.Networking.psm1'
    ModuleVersion     = '1.2.0'
    GUID              = '527c526f-6c8c-48ae-996e-1691dd645385'
    Author            = 'Brandon Olin'
    CompanyName       = 'Community'
    Copyright         = '(c) 2017 Brandon Olin. All rights reserved.'
    Description       = 'PoshBot module for simple networking commands'
    PowerShellVersion = '5.0.0'
    RequiredModules   = @('PoshBot')
    FunctionsToExport = @('Invoke-Ping', 'Invoke-Dig', 'Invoke-TestPort', 'Get-WebServerInfo', 'Get-GeoLocIp', 'Get-NetASInfo')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        Permissions = @(
            @{
                Name        = 'test-network'
                Description = 'Run commands to test network connectivity'
            }
        )
        PSData      = @{
            Tags         = @('Networking', 'PoshBot', 'ChatOps', 'Dig', 'DNS', 'Ping')
            LicenseUri   = 'https://raw.githubusercontent.com/poshbotio/PoshBot.Networking/master/LICENSE'
            ProjectUri   = 'https://github.com/poshbotio/PoshBot.Networking'
            ReleaseNotes = 'https://raw.githubusercontent.com/poshbotio/PoshBot.Networking/master/CHANGELOG.md'
        }
    }
}

