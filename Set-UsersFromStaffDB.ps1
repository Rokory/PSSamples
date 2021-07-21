$server = 'localhost\sqlexpress'
$databaseName = 'Personal'

# Get SQL data reader for SELECT query
$connection = Connect-SqlServer -Database $databaseName -Server $server
$datareader = Get-SqlDataReader -Query 'SELECT * FROM Personen' -Connection $connection

# While there are new records
while ($datareader.Read()) {
    <#
    Der Operator -f setzt die Werte, die nach ihm in einer
    Komma-getrennten Liste folgen in die Platzhalter der Zeichenkette
    vor dem Operator ein. Die Platzhalter werden als {0}, {1}, {2} usw.
    geschrieben. Der erste Wert wird bei {0} eingesetzt, der zweite bei
    {1} usw. Die Werte können auch formatiert werden. Siehe auch:
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_operators?view=powershell-7.1#special-operators
    #>
    $filter = 'Name -eq "{0}"' -f $datareader['Name']

    # Find user with this name in AD
    # and set the extensionAttribute 9 to the value of the extension field
    Get-ADUser -Filter $filter |
    Set-ADUser -Replace @{ extensionAttribute9 = $datareader['Extension'] }

    # Check, if we were successful
    Get-ADUser -Filter $filter -Properties 'ExtensionAttribute9' | Select-Object Name, ExtensionAttribute9
}

# Clean up
$datareader.Close()
$connection.Close()