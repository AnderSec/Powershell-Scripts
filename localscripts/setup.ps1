Set-ExecutionPolicy -ExecutionPolicy Unrestricted
# For at begynde skal du konfigurere noget signaturoplysninger for hvordan Powershell kan kalde ind i dette bibliotek.
$signature = @"
[DllImport("user32.dll")]
public static extern bool SystemParametersInfo(int uAction, int uParam, ref int lpvParam, int flags );
"@
# Dette er ret ligetil. Vi bruger det kode til at oprette et aliaskald til filen user32.dll.

# Næste ting at gøre er at oprette en Powershell-samling og tildele den til en variabel.
$systemParamInfo = Add-Type -memberDefinition  $signature -Name ScreenSaver -passThru

#Nu skal vi bare oprette vores Powershell-funktioner for at gøre brug af denne nye in-memory-samling, der er blevet oprettet. 
Function Get-ScreenSaverTimeout
{
  [Int32]$value = 0
  $systemParamInfo::SystemParametersInfo(14, 0, [REF]$value, 0)
  $($value/60)
}
Get-ScreenSaverTimeout
 
Function Set-ScreenSaverTimeout
{
  Param ([Int32]$value)
  $seconds = $value + 300
  [Int32]$nullVar = 0
  $systemParamInfo::SystemParametersInfo(15, $seconds, [REF]$nullVar, 2)
}
Set-ScreenSaverTimeout
Function Set-OnResumeDisplayLogon
{
    Param ([Int32]$value)
    [Int32]$nullVar = 0
    $systemParamInfo::SystemParametersInfo(119, $value, [REF]$nullVar, 2)
}
Set-OnResumeDisplayLogon(1)



# Variabel som gemmer de initialer du taster ind.
$initialer = Read-host -Prompt "Venligst indtaste dine initialer"

# Variabel som gemmer adgangskode ved at tage initialer og sætter det i form af ",intialer1234," som er default password.
$password = "," + $initialer + "1234," | ConvertTo-SecureString -AsPlainText -Force

# Variabel som gemmer pc navnet efter den har tilføjet intialer til den nuværende PC navn.
$nypcnavn = $initialer + "-" + $env:computername

# Laver en bruger ved at bruge de initialer vi har indtastet og den kode der bliver dannede udefra det.
New-LocalUser -Name $initialer -Password $password

# Tilføjer brugern til Administratorer gruppen
Add-LocalGroupMember -Group Administratorer -Member $initialer

# Omdøber PC-navnet til det nye navn.
rename-computer -Newname $nypcnavn

# Set timezone automatisk
Set-TimeZone -ID "Romance Standard Time"

# Henter de bruger konti der findes på computern
Get-Wmiobject win32_desktop | where name -match $env:USERNAME

# Laver et pop-up vindue som giver besked om at genstarte sin PC.
powershell -WindowStyle hidden -Command "& {[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('Venligst, genstarte din PC for at alle ændringer træder i kræft','OBS!')}"
