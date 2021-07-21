<#
Parameterwerte, die mehr als einmal verwendet werden, oder die häufig
geändert werden müssen, z. B. Pfade, sollten als Variablen am Beginn
definiert werden.
#>

# Pfad für die CSV-Datei
$path = 'E:\Allfiles\adatumusers.csv'

# Begrenzungszeichen für die CSV-Datei
$delimiter = ';'

# Benutzer in eine CSV-Datei exportieren
function Export-UsersToCsv {
    <#
    Der Befehl exportiert die Benutzer mit den am häufigsten verwendeten
    Eigenschaften. Um zusätzliche Eigenschaften zu exportieren, ist bei
    Get-ADUser der Parameter -Properties gefolgt von einer Liste der Namen
    der Eigenschaften anzufügen.
    #>
    Get-ADUser -Filter * | Export-Csv -Path $path -Delimiter $delimiter -NoTypeInformation
    Write-Host "Benutzer wurden nach $path exportiert."
    Write-Host "Bitte ergänzen Sie eine Spalte mti dem Namen Printer, bevor Sie die Datei wieder importieren."
}

# Import von CSV

function Import-UsersFromCsv {

    <# 
    Die Printer-Eigenschaft der importierten Benutzer in ein AD-Attribut schreiben

    ForEach-Object behandelt jedes Objekt des vorhergehenden Befehls in der
    Pipeline einzeln.
    #>

    Import-Csv -Path $path -Delimiter $delimiter |
    ForEach-Object {
        <#
        $PSItem enthält das jeweils einzelne Objekt der Pipeline,
        das in jedem Schleifendurchlauf behandelt wird (Laufvariable).
        $PSItem wird häufig auch als $_ geschrieben.

        Der Operator -f setzt die Werte, die nach ihm in einer
        Komma-getrennten Liste folgen in die Platzhalter der Zeichenkette
        vor dem Operator ein. Die Platzhalter werden als {0}, {1}, {2} usw.
        geschrieben. Der erste Wert wird bei {0} eingesetzt, der zweite bei
        {1} usw. Die Werte können auch formatiert werden. Siehe auch:
        https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_operators?view=powershell-7.1#special-operators
        #>

        $filter = 'Name -eq "{0}"' -f $PSItem.Name

        <#
        Suche den Benutzer über dessn vollständigen Namen und ersetze
        Eigenschaften.

        Der -Replace Parameter erfordert eine sogenannte Hashtabel als Wert.
        Eine Hashtable wird mit @{} bezeichnet. In den Klammern werden
        Name-Wert-Paare der Form Name = Wert durch Strichpunkte oder
        Zeilenschaltungen getrennt geschrieben. Hier erhält Url den Wert
        der Printer-Eigenschaft (der Printer-Spalte) aus der CSV-Datei.
        #>
        Get-ADUser -Filter $filter |
        Set-ADUser -Replace @{ Url = $PSItem.Printer }
    }
}

Write-Host 'Funktionen definiert'
Write-Host 'Um Benutzer in eine CSV-Datei zu exportierten, rufen Sie Export-UsersToCsv auf.'
Write-Host 'Um Benutzereigenschaften aus der CSV-Datei zu importieren, rufen Sie Import-UsersFromCsv auf.'
