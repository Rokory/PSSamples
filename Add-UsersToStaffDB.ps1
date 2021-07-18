$server = 'localhost\sqlexpress'
$databaseName = 'Personal'

# Suffix to be appended after each record in the command
$suffix = ", `r`n"

# Get users from AD
$users = Get-ADUser -Filter *

# Initialize command SQL INSERT INTO
<#
A string builder provides a much better performance when composing a string out of large number or partial strings
See https://powershellexplained.com/2017-11-20-Powershell-StringBuilder/ for some numbers
#>
$commandBuilder = [System.Text.StringBuilder]::new('INSERT INTO Personen (Name, Extension) VALUES ')

# Add Values for each user
foreach ($user in $users) {
    # Replace single quote with two single quotes to escape character for SQL
    $name = $user.Name -replace '''', ''''''

    # Generate some random value
    $extension = Get-Random

    # Append values
    $commandBuilder.Append("('{0}', '{1}')$suffix" -f ($name, $extension)) | Out-Null
}
# Remove last suffix
$commandBuilder.Remove($commandBuilder.Length - $suffix.Length, $suffix.Length) | Out-Null

# Generate string
$command = $commandBuilder.ToString()

# Execute command against SQL server
$connection = Connect-SqlServer -Database $databaseName -Server $server
Invoke-SqlCommand -Connection $connection -Command $command
$connection.Close()