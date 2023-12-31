<#
.SYNOPSIS
	Installs updates for the local machine (needs admin rights)
.DESCRIPTION
	This PowerShell script installs updates for the local machine (needs admin rights).
.EXAMPLE
	PS> ./install-updates
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz | License: CC0
#>


try {
	$StopWatch = [system.diagnostics.stopwatch]::startNew()

	if ($IsLinux) {
		"⏳ Step 1/4 - Fetching update infos for installed Debian packages..."
		& sudo apt update

		"⏳ Step 2/4 - Upgrading installed Debian packages..."
		& sudo apt upgrade --yes

		"⏳ Step 3/4 - Removing obsolete Debian packages..."
		& sudo apt autoremove --yes

		"⏳ Step 4/4 - Upgrading installed Snap packages..."
		& sudo snap refresh
	} else {
		"⏳ Step 1/2 - Fetching update infos..."
		winget upgrade --accept-source-agreements --accept-package-agreements

		"⏳ Step 2/2 - Upgrading applications..."
		winget upgrade --all --accept-source-agreements --accept-package-agreements
	}

	[int]$Elapsed = $StopWatch.Elapsed.TotalSeconds
	"✔️ installed updates in $Elapsed sec"
	exit 0 # success
} catch {
	"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
}
