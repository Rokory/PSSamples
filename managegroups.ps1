#region Erstelle OU
#region Eingabe
$oUName = 'Printer Groups'
$parentPath = 'DC=Adatum, DC=com'
#endregion

#region Verarbeitung
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

# Ausgabe
#endregion


#region Konfiguriere Gruppen aus CSV-Datei

#region Eingabe
# Importiere CSV-Datei
$csvPath = 'E:\Printers.csv'
$delimiter = ';'
$printers = Import-Csv -Path $csvPath -Delimiter $delimiter
#endregion

#region Verarbeitung
foreach ($printer in $printers) {
    # Eingabe
    $groupName = $printer.Gruppenname

    #region Verarbeitung
    # Prüfe, ob gültiger Gruppenname importiert wurde
    if (-not [string]::IsNullOrWhiteSpace($groupName)) {
        #region Eingabe
        $groupDn = "CN=$groupName, $path"
        $url = $printer.URL
        $members = $printer.Mitglieder -split ','
        #endregion

        #region Verarbeitung

        # Erstelle Gruppe
        if (-not [adsi]::Exists("LDAP://$groupDn")) {
            New-ADGroup -Path $path -Name $groupName -GroupCategory Security -GroupScope Global
        }

        # Setze das Attribut URL der Sicherheitsgruppe

        Get-ADGroup -Identity $groupDn | Set-ADGroup -Replace @{ Url = $url }


        # Füge Computer zur Sicherheitsgruppe als Mitglied hinzu

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

        if ($members.Count -gt 0) {
            Add-ADGroupMember -Identity $groupDn -Members $members
        }

        #endregion

        # Ausgabe
    }
    #endregion

    # Ausgabe
}
#endregion

# Ausgabe
#endregion
