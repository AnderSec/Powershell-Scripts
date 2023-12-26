# https://www.reddit.com/r/PowerShell/comments/4ad8or/create_user_menus_from_objectsarrays/
# https://www.reddit.com/r/PowerShell/comments/49tqgx/need_some_help_with_an_automation_script_im/
# http://stackoverflow.com/questions/885349/how-to-write-a-powershell-script-that-accepts-pipeline-input
# http://www.powertheshell.com/input_psv3/
# https://www.reddit.com/r/PowerShell/comments/9ra07k/switch_within_a_switch/e8faxic/

# similar
# https://gist.github.com/QuietusPlus/59d8612ec13ea929704542eb0bd8d52c # write-menu
# https://github.com/majkinetor/posh/blob/master/MM_Sugar/Get-Choice.ps1
# https://www.reddit.com/r/PowerShell/comments/61b4at/a_powershell_menu_system/

# TODO
# add parameter for specifying a default option

<#
.Synopsis
    This function provides a convenient way to convert a PowerShell object object to list of choices for user input.

.DESCRIPTION
    Creates a user selection menu based on a given object. Useful for converting any PowerShell object into a list of choices from which the user can select a subset of items.

.EXAMPLE
    PS>$locations = 'AMER', 'EMEA', 'APAC'
    PS>Out-Menu -Object $locations
    
    Description
    -----------
    lists folder contents and prompts user to select one of the items

    Choose an option
    01. AMER
    02. EMEA
    03. APAC

    1
    AMER

.EXAMPLE
    PS>$locations = 'AMER', 'EMEA', 'APAC'
    PS>Out-Menu -Object $locations -Header '---Location List---' -Footer '---Enter a location number---'
    
    Description
    -----------
    lists folder contents and prompts user to select one of the items between specified header and footer text

    ---Location List---
    01. AMER
    02. EMEA
    03. APAC
    ---Enter a location number---

    2
    EMEA
   
.EXAMPLE
    PS>$locations = 'AMER', 'EMEA', 'APAC'
    PS>Menu $locations -AllowMultiple
   
    Description
    -----------
    lists folder contents and allows user to select multiple items by giving a comma separated list of items (1, 2, 5)

    Choose an option
    To select multiple, enter numbers separated by a comma EX: 1, 2
    01. AMER
    02. EMEA
    03. APAC

    1, 3
    AMER
    APAC

.EXAMPLE
    PS>[IO.DriveInfo]::GetDrives() | Menu -AllowCancel
    
    Description
    -----------
    lists drives to choose from. if 'c' is entered, the menu selection is canceled and $null is returned

    Choose an option, or enter "c" to cancel.
    01. C:\
    02. D:\

    c

.INPUTS
    Accepts common PowerShell object types as input.

.OUTPUTS
    Outputs object at whichever item the user has selected.

.NOTES
    If a menu option is selected that does not exist, the menu will be shown again.

.COMPONENT
    Scripting Techniques

.ROLE
    Retrieving Input

.FUNCTIONALITY
    Quickly create a menu for a script that requires user choice.

.LINK
    https://gallery.technet.microsoft.com/scriptcenter/Out-Menu-41259908
    https://github.com/gangstanthony/PowerShell/blob/master/Out-Menu.ps1
    
    Similar functions:
    Read-Choice http://poshcode.org/5128
    Show-ConsoleMenu http://poshcode.org/5295
    Get-Input https://github.com/dfinke/powershell-for-developers/blob/master/chapter07/ShowUI/CommonControls/Get-Input.ps1
    Select-ViaUI https://github.com/dfinke/powershell-for-developers/blob/master/chapter07/ShowUI/CommonControls/Select-ViaUI.ps1
#>

function Out-Menu {
    param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$True,
            ValueFromPipelinebyPropertyName=$True)]
        [object[]]$Object,
        [string]$Header,
        [string]$Footer,
        [switch]$AllowCancel,
        [switch]$AllowMultiple
    )

    if ($input) {
        $Object = @($input)
    }

    if (!$Object) {
        throw 'Must provide an object.'
    }

    Write-Host ''

    do {
        $prompt = New-Object System.Text.StringBuilder
        switch ($true) {
            {[bool]$Header -and $Header -notmatch '^(?:\s+)?$'} { $null = $prompt.Append($Header); break }
            $true { $null = $prompt.Append('Choose an option') }
            $AllowCancel { $null = $prompt.Append(', or enter "c" to cancel.') }
            $AllowMultiple {$null = $prompt.Append("`nTo select multiple, enter numbers separated by a comma EX: 1, 2") }
        }
        Write-Host $prompt.ToString()
        
        $nums = $Object.Count.ToString().Length
        for ($i = 0; $i -lt $Object.Count; $i++) {
            Write-Host "$("{0:D$nums}" -f ($i+1)). $($Object[$i])"
        }

        if ($Footer) {
            Write-Host $Footer
        }

        Write-Host ''

        if ($AllowMultiple) {
            $answers = @(Read-Host).Split(',').Trim()

            if ($AllowCancel -and $answers -match 'c') {
                return
            }

            $ok = $true
            foreach ($ans in $answers) {
                if ($ans -in 1..$Object.Count) {
                    $Object[$ans-1]
                } else {
                    Write-Host 'Not an option!' -ForegroundColor Red
                    Write-Host ''
                    $ok = $false
                }
            }
        } else {
            $answer = Read-Host

            if ($AllowCancel -and $answer -eq 'c') {
                return
            }

            $ok = $true
            if ($answer -in 1..$Object.Count) {
                $Object[$answer-1]
            } else {
                Write-Host 'Not an option!' -ForegroundColor Red
                Write-Host ''
                $ok = $false
            }
        }
    } while (!$ok)
}

Set-Alias -Name Menu -Value Out-Menu


#
# This script is designed to use Ninite's app URL paths to specify which apps are downloaded when the script runs ninite.exe.
#
#############
# HOW TO USE#
#############
#
# Edit the $url variable using the app URL path of each application you wish to install.
# https://ninite.com/urlpath1-urlpath2-urlpath3/ninite.exe
# The order in which the URL paths are placed in the URL does not matter.
# I have included a list of all applications Ninite offers and their URL path, see below.

################################
# APPLICATION     APP URL PATH #
################################

$applications = @{

# WEB BROWSERS
'Google Chrome'   = 'chrome'
'Firefox'         = 'firefox'
'Opera'           = 'operaChromium'

# UTILITIES
'Teamviewer 13'   = 'teamviewer13'
'ImgBurn'         = 'imgburn'
'RealVNC'         = 'realvnc'
'TeraCopy'        = 'teracopy'
'CDBurnerXP'      = 'cdburnerxp'
'Revo'            = 'revo'
'Launchy'         = 'launchy'
'WinDirStat'      = 'windirstat'
'Glary'           = 'glary'
'InfraRecorder'   = 'infrarecorder'
'Classic Start'   = 'classicstart'

# MESSAGING
'Discord'         = 'discord'
'Skype'           = 'skype'
'Pidgin'          = 'pidgin'
'Thunderbird'     = 'thunderbird'
'Trillian'        = 'trillian'

# COMPRESSION
'7-Zip'           = '7zip'
'PeaZip'          = 'peazip'
'WinRAR'          = 'winrar'

# MEDIA
'Itunes'          = 'itunes'
'VLC'             = 'vlc'
'AIMP'            = 'aimp'
'foobar2000'      = 'foobar'
'Winamp'          = 'winamp'
'MusicBee'        = 'musicbee'
'Audacity'        = 'audacity'
'K-Lite Codecs'   = 'klitecodecs'
'GOM'             = 'gom'
'Spotify'         = 'spotify'
'CCCP'            = 'cccp'
'MediaMonkey'     = 'mediamonkey'
'HandBrake'       = 'handbrake'

# RUNTIMES
'Java 8'          = 'java8'
'.NET 4.7.2'      = '.net4.7.2'
'Silverlight'     = 'silverlight'
'Air'             = 'air'
'Shockwave'       = 'shockwave'

# DEVELOPERTOOLS
'Python'          = 'python'
'FileZilla'       = 'filezilla'
'Notepad++'       = 'notepadplusplus'
'JDK 8'           = 'jdk8'
'JDK x64 8'       = 'jdkx8'
'WinSCP'          = 'winscp'
'PuTTy'           = 'putty'
'WinMerge'        = 'winmerge'
'Eclipse'         = 'eclipse'
'Vis Studio Code' = 'vscode'

# IMAGING
'Krita'           = 'krita'
'Blender'         = 'blender'
'Paint.NET'       = 'paint.net'
'GIMP'            = 'gimp'
'IrfanView'       = 'irfanview'
'XnView'          = 'xnview'
'Inkscape'        = 'inkscape'
'FastStone'       = 'faststone'
'GreenShot'       = 'greenshot'
'ShareX'          = 'sharex'

# DOCUMENTS
'Foxit Reader'    = 'foxit'
'LibreOffice'     = 'libreoffice'
'SumatraPDF'      = 'sumatrapdf'
'CutePDF'         = 'cutepdf'
'PDFCreator'      = 'pdfcreator'
'OpenOffice'      = 'openoffice'

# SECURITY
'MS Essentials'   = 'essentials'
'Malwarebytes'    = 'malwarebytes'
'Avast'           = 'avast'
'AVG'             = 'avg'
'Spybot 2'        = 'spybot2'
'Avira'           = 'avira'
'SPERAntiSpyWare' = 'super'

# FILE SHARING
'qBitTorrent'     = 'qbittorrent'

# OTHER
'Evernote'        = 'evernote'
'Google Earth'    = 'googleearth'
'Steam'           = 'steam'
'KeePass 2'       = 'keepass2'
'Everything'      = 'everything'
'NV Access-'      = 'nvda'

# ONLINE STORAGE
'Dropbox'         = 'dropbox'
'Google Backup'   = 'googlebackupandsync'
'Mozy'            = 'mozy'
'OneDrive'        = 'onedrive'
'SugarSync'       = 'sugarsync'

}


###################### Script Starts Here #############################
# Edit the URL using the URL paths listed above.
# EX: to download Firefox, Chrome, and 7-Zip change the URL to "https://ninite.com/chrome-firefox-7zip/ninite.exe"

$selections = $applications.Keys | sort | Out-Menu -AllowMultiple

Write-Host 'You have chosen the following:'
$selections | % {Write-Host $_}
$answer = Read-Host 'Continue? [Y]/n'
if ($answer -and $answer -ne 'y') {
    continue
}

$url = "https://ninite.com/$(($selections | % {$applications[$_]}) -join '-')/ninite.exe"
$output = "C:\Scripts\ninite.exe"

# Creates Scripts directory in the root of C:
$scriptspath = 'c:\scripts'
if (!(Test-Path $scriptspath)) {
    New-Item $scriptspath -ItemType Directory
}

# Calls upon Ninite URL to grab .exe
Invoke-WebRequest -Uri $url -OutFile $output

# Starts Ninite.exe
Start-Process -FilePath "C:\Scripts\ninite.exe"
