<#
.SYNOPSIS
	MUP Package Generator.
.DESCRIPTION
	Takes the file InstallerMup.xml, updates its Product and  Upgrade GUIDs, feeds it to CreateMup.exe
	which then creates a Mup.xml file. Afterwards the Mup.xml along with Setup.exe and all the driver files in the $DriversFolder
	are zipped into a zip file and placed in the Packed directory.
.PARAMETER CreateNewProductGuid
	Product GUID needed by MUP.xml. If $true, a new GUID is generated, otherwise what is in the file Installer.
.PARAMETER CreateNewUpgradeGuid
	Upgrade GUID needed by MUP.xml. If $true, a new GUID is generated, otherwise what is in the file Installer.
.PARAMETER DriversFolder
	Relative or absolute path to the Drivers folder.
.EXAMPLE
	#From the Powershell prompt without specifying a path to the Drivers folder(Accepting the default Drivers folder in current path.)
	C:\PS>./GenerateMup.ps1 $true $true
.EXAMPLE
	#From the Powershell prompt specifying a path to the Drivers folder.
	C:\PS>./GenerateMup.ps1 $true $true ..\MyDriverFolder\Drivers
.EXAMPLE
	#From the DOS prompt without specifying a path to the Drivers folder(Accepting the default Drivers folder in current path.)
	C:\>powershell -ExecutionPolicy Bypass GenerateMup.ps1 $true $true
.EXAMPLE
	#From the DOS prompt specifying a path to the Drivers folder.
	C:\>powershell -ExecutionPolicy Bypass GenerateMup.ps1 $true $true ..\MyDriverFolder\Drivers
.INPUTS
	CreateNewProductGuid - boolean ($true | $ false) indicating if a new Product GUID should be generated. 
	CreateNewUpgradeGuid - boolean ($true | $ false) indicating if a new Upgarde GUID should be generated. 
	DriversFolder - Optional absolute or relative path to the Drivers folder
.OUTPUTS
	Packed\Setup.zip
.NOTES
	Author: The Installer Team
	Date: 09/05/2012
#>
Param(
		[parameter(Mandatory=$true,HelpMessage="Generate a new Product GUID <true> | <false>")]
		[alias("PG")]
		[ValidateNotNullOrEmpty()]
		[bool]
		$CreateNewProductGuid = $(Throw "Pleae indicate $true or $false as to whether generate a new Product GUID or use the existing GUID."),
		[parameter(Mandatory=$true,HelpMessage="Generate a new Upgrade GUID <true> | <false>")]
		[alias("UG")]
		[ValidateNotNullOrEmpty()]
		[bool]
		$CreateNewUpgradeGuid = $(Throw "Pleae indicate $true or $false as to whether generate a new Upgrade GUID or use the existing GUID."),
		[parameter(Mandatory=$false,HelpMessage="Drivers folder. Default is Drivers")]
		[alias("D")]
		[ValidateNotNullOrEmpty()]
		[string]
		$DriversFolder="Drivers")
		
$MupFileName = "$pwd\InstallerMup.xml";
$Winzip = "${Env:ProgramFiles(x86)}\Winzip\wzzip.exe"


if ((Test-Path $MupFileName) -ne $True)
{
	Write-Host "MUP File InstallerMup.xml does not exist!";
	Exit;
}

if ((Test-Path -path $Winzip) -ne $True)
{
	Write-host "Winzip Command Line Support Add-on 3.0 (wzzip.exe) was not found on this machine. Please obtain it from http://iss.intel.com/ProductInfo/TabProductInfo.asp?Product=8357 and install it before continuing."
	
	Exit;
}

$ProdCodeGuid;
$UpgradeCodeGuid;

$ProdCodeGuid = [guid]::NewGuid();
$UpgradeCodeGuid = [guid]::NewGuid();

$xml = [xml](get-content $MupFileName);

if ($CreateNewProductGuid)
{
	Write-Host "Write the New Product Guid...";
	
	$xml.MUPDefinition.inventorymetadata.fullpackageidentifier.msis.msi.ChildNodes.Item(0).'#text' = '{' + $ProdCodeGuid.ToString() + '}';
}

if ($CreateNewUpgradeGuid)
{
	Write-Host "Write the New Upgrade Guid...";
	
	$xml.MUPDefinition.inventorymetadata.fullpackageidentifier.msis.msi.ChildNodes.Item(1).'#text' = '{' + $UpgradeCodeGuid.ToString() + '}';
}

Write-Host "Writing the MUP...";

if ($CreateNewProductGuid -or $CreateNewUpgradeGuid) { $xml.Save($MupFileName); }

Write-Host "Creating a zip file with Drivers folder, Mup.xml and Setup.exe...";

cmd /c CreateMup.exe mupTemplatePath=. installerFolder=$DriversFolder pkgDescription="Setup.exe" pkgMainINFName=$DriversFolder

$PackedDir = "$Pwd\Packed";
$ExeName = "$Pwd\Setup.exe"

if ((Test-Path -path $PackedDir) -ne $True) { md $PackedDir };

cmd /c $Winzip -r -p '-x*.pdb' $PackedDir\Setup.zip $ExeName $DriversFolder $DriversFolder\Mup.xml






		