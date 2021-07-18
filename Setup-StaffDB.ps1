$server = 'localhost\sqlexpress'
$databaseName = 'Personal'

# Create Database
New-SqlDatabase -Name $databaseName -Server $server

# Define command to create the table
$command = @"
CREATE TABLE [dbo].[Personen](
	[ID] [int] IDENTITY(1,1) PRIMARY KEY,
	[Name] [nvarchar](100) NOT NULL,
	[Extension] [nvarchar](100) NULL
)
"@

# Run command
$connection = Connect-SqlServer -Database 'Personal' -Server $server
Invoke-SqlCommand -Connection $connection -Command $command
$connection.Close()