$server = 'localhost\sqlexpress'
$databaseName = 'Personal'

# Get SQL data reader for SELECT query
$connection = Connect-SqlServer -Database $databaseName -Server $server
$datareader = Get-SqlDataReader -Query 'SELECT * FROM Personen' -Connection $connection

# While there are new records
while ($datareader.Read()) {
    # Get some field called name
    $name = $datareader['Name']

    # Find user with this name in AD
    # and set the extensionAttribute 9 to the value of the extension field
    Get-ADUser -Filter ('Name -eq "{0}"' -f  $name) |
    Set-ADUser -Replace @{ extensionAttribute9 = $datareader['Extension'] }

    # Check, if we were successful
    Get-ADUser -Filter ('Name -eq "{0}"' -f  $name) -Properties 'ExtensionAttribute9' | Select-Object Name, ExtensionAttribute9
}

# Clean up
$datareader.Close()
$connection.Close()