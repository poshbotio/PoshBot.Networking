
# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.2.0] - 2018-10-30

### Added

- [**#3**](https://github.com/poshbotio/PoshBot.Networking/pull/3) Add new commands `Get-WebServerInfo`, `Get-GeoLocIp`, and `Get-NetASInfo` (via [@omiossec](https://github.com/omiossec))

## [1.1.0] - 2018-10-09

### Added

- [**#2**](https://github.com/poshbotio/PoshBot.Networking/pull/2) Add `Invoke-TestPort` command to allow testing ports on remote machines.
  It makes use of `Test-NetConnection` on Windows PowerShell or `Test-Connection` on PowerShell core. (via [@ChrisLGardner](https://github.com/ChrisLGardner))

## [1.0.1] - 2017-03-24

### Changed

- Explicitly export function in module manifest

- Renamed functions to conform to PowerShell conventions (verb-noun) and set bot command names to ping/dig via [PoshBot.BotCommand()] attribute.

## [1.0.0] - 2017-03-21

### Added

- Initial commit
