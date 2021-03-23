# PowerShell Samples

This repository contains some small sample scripts.

## Classes.ps1

This script demonstrates the usage of object-oriented features in PowerShell. It is recommended to run this in debug mode to understand what's going on. The comments will help understanding the concepts.

## Menu.ps1

Demonstrates a reusable patter for creating text-based menus in controller scripts.

## Setup-CIDatabase.ps1 and Update-CIAssets.ps1

### Synopsis

Sample powershell script for retrieving computer inventory data and storing it in a database. Demonstrates working with SQL and error handling.

### Requirements

Module SQLUtility and BITSDownload, which you can clone from <https://github.com/Rokory/SQLUtility> and <https://github.com/Rokory/BITSDownload>.

### Getting started

1. Install some edition of Microsoft SQL server on the local computer. You can use ````Install-SQLServer```` from the SQLUtility module to quickly install an Express edition
2. Run the Setup-CIDatabase to create the database structure.
3. Run the Update-CIAssets to store the computer inventory information in the database.
