$csvPath = 'E:\Printers.csv'
$delimiter = ';'

#region Erstelle OU

$oUName = 'Printer Groups'
$parentPath = 'DC=Adatum, DC=com'
$path = "OU=$oUName, $parentPath"

<# 
[adsi]::Exists ruft die statische Methode Exists in der .NET-Klasse adsi auf.
Die Methode Exists nimmt einen LDAP-URI als Parameter und liefert $true oder $false zurück.
-not kehrt das Ergebnis um.
#>

if (-not [adsi]::Exists("LDAP://$path")) {
    New-ADOrganizationalUnit -Name $oUName -Path $parentPath 
}

#endregion

# Importiere CSV-Datei

$printers = Import-Csv -Path $csvPath -Delimiter $delimiter
foreach ($printer in $printers) {
    #region Erstellen eine Sicherheitsgruppe

    $groupName = $printer.Gruppenname
    $groupDn = "CN=$groupName, $path"

    if (-not [adsi]::Exists("LDAP://$groupDn")) {
        New-ADGroup -Path $path -Name $groupName -GroupCategory Security -GroupScope Global
    }

    #endregion

    #region Setze das Attribut URL der Sicherheitsgruppe

    Get-ADGroup -Identity $groupDn | Set-ADGroup -Replace @{ Url = $printer.URL }

    #endregion

    #region Füge Computer zur Sicherheitsgruppe als Mitglied hinzu

    $members = $printer.Mitglieder -split ','
    <#
    In foreach-Schleifen können die Objekte der Sammlung, die durchlaufen wird, nicht
    geändert werden. Deshalb wird hier eine simple for-Schleife verwendet.
    Die 1970er-Jahre lassen grüßen :-)
    #>
    for ($i = 0; $i -lt $members.Count; $i++) {
        <#
        Innerhalb der Zeichenkette markiert $() einen Ausdruck. Innerhalb der Klammern
        kann ein beliebiger PowerShell-Ausdruck stehen. Dahinter wird ein $ Zeichen
        angehänngt.

        Es wird angenommen, dass nur Computerkonten als Mitglieder hinzugefügt werden.
        Wenn das Skript alle Arten von Konten als Gruppenmitglieder akzeptieren soll,
        ist die folgende Zeile auszukommentieren und stattdessen bei der übernächsten Zeile
        die Kommentarmarkierung zu entfernen. In diesem Fall müssen Computerkonten schon 
        in der CSV-Datei ein $-Zeichen angehängt bekommen.
        #>
        $members[$i] = "$($members[$i].Trim())$"
        # $members[$i] = $members[$i].Trim()
    }

    Add-ADGroupMember -Identity $groupDn -Members $members

    #endregion   
}

