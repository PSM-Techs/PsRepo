﻿<# Gets time stamps for all User in the domain that have NOT logged in since after specified date 
# Mod by Tilo 2014-04-01 
import-module activedirectory  
$domain = "mycharts.md"
$server = "mgt01b"  
$DaysInactive = 90  
$time = (Get-Date).Adddays(-($DaysInactive))
$DATE = get-date -Format yyyyMMdd_HHmmss 
  
# Get all AD User with lastLogonTimestamp less than our time and set to enable 
Get-ADUser -Server $server -Filter {LastLogonTimeStamp -lt $time -and enabled -eq $true} -Properties LastLogonTimeStamp | 
  
# Output Name and lastLogonTimestamp into CSV  
select-object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('yyyy-MM-dd_hh:mm:ss')}}|Sort-Object name|export-csv -Delimiter "`t" -LiteralPath $env:userprofile\documents\inactive_rdp_users$DATE.csv -notypeinformation
#>

<#PSScriptInfo 
 
.VERSION 1.6.3 
 
.GUID efd8653f-3a23-4d78-a7d1-b766da9015bf 
 
.AUTHOR Chris Carter 
 
.COMPANYNAME  
 
.COPYRIGHT (c)2013-2017 Chris Carter 
 
.TAGS ActiveDirectory, LastLogonTime 
 
.LICENSEURI http://creativecommons.org/licenses/by-sa/4.0/ 
 
.PROJECTURI https://gallery.technet.microsoft.com/Export-Last-Logon-Times-4fcb07cb 
 
.ICONURI  
 
.EXTERNALMODULEDEPENDENCIES ActiveDirectory 
 
.REQUIREDSCRIPTS  
 
.EXTERNALSCRIPTDEPENDENCIES  
 
.RELEASENOTES Most importantly, the Destination parameter was renamed to the Path parameter to bring it inline with other Export-* commands, but Destination can still be used as an alias to avoid breaking older code. Also, the Property, SortBy, and Descending parameters were added. The Property parameter is used to choose which properties are exported to the CSV file. The SortBy parameter was added due to a user request over at the PowerShell Gallery, and is used to specify which columns to sort on when exporting the objects. The Descending parameter is used to sort the objects into descending order. Due to the addition of the new parameters, the default output has been changed, and the DisplayName property is no longer included in the default output. This update also contains a fix for a bug that occurred when running the command against only one Domain Controller. This was happening because a one item array was incorrectly being converted into the item itself. 
 
 
#> 
 
<# 
.SYNOPSIS 
This command will export the account name and the last logon time of the users in the specified OU to a CSV file format at the specified destination. 
 
.DESCRIPTION 
Export-LastLogonTime takes the OU name or distinguished name specified in the OU parameter and retrieves its users' account names and last logon times.  Then it exports a CSV file to the destination given in the Path parameter. This command will search the entire domain for the OU name specified.  If the destination path contains spaces it must be wrapped in quotation marks, and the file name specified must end in .csv.  
  
Due to the fact that the LastLogonDate does not replicate between domain controllers, this script will search for domain controllers and compare the LastLogonDate from each one to find the most recent time a user logged. This will be the time reported in the CSV file, and a column named DomainController will contain the Domain Controller the time came from unless specific Domain Controllers are specified to the Server parameter. 
 
While available, supplying specific Domain Controllers to the Server parameter is discouraged because there is a possibility they will not be correct due to the reason described above. 
 
The Property and SortBy parameters can be used to specify what properties will be exported to the CSV file, and how the users are sorted, but the properties LastLogonDate and DomainController will always be present. 
 
.PARAMETER Descending 
Indicates that the objects should be sorted in descending order before export. The default is ascending order. 
 
.PARAMETER Force 
Overwrites the file specified in path without prompting. If you use the NoClobber parameter, this has no effect. 
 
.PARAMETER NoClobber 
Do not overwrite an existing file. By default, if a file exists in the specified path, Export-LastLogonTime overwrites the file without warning. 
 
The alias for this parameter is NoOverwrite. 
 
.PARAMETER OrganizationalUnit 
Specifies the name or the distinguished name of the OU from which to retrieve users. Any escape characters are still required to be escaped: http://social.technet.microsoft.com/wiki/contents/articles/5312.active-directory-characters-to-escape.aspx 
 
The alias for this parameter is OU. 
 
.PARAMETER Path 
Specifies the location and file name of the exported csv file.  If you do not specify a full path, the current location will be used.  The file name must have a .csv extension specified. 
 
The alias for this parameter is Destination (legacy purposes). 
 
.PARAMETER Property 
Specifies the properties of the Active Directory User objects to export to the CSV file. The default properties exported are Name, LastLogonDate, Enabled, and SamAccountName. 
 
Note that even if the LastLogonDate and DomainController properties are omitted, the CSV file will still include them. 
 
You can use Get-Help Select-Object -Parameter Property to learn more. 
 
.PARAMETER Server 
Specifies the Active Directory Domain Services instance (Domain Controller) to connect to by providing the NETBios name or the fully qualified directory server name. If left blank all Domain Controllers are used. 
 
The alias for this parameter is DC. 
.PARAMETER SortBy 
Specifies the properties to use when sorting before exporting to the CSV file. The default is to sort on the Name property. The property specified here must be present in the list supplied to the Property parameter. 
 
Use Get-Help Sort-Object -Parameter Property to learn more. 
 
.INPUTS 
System.String 
 
 
You can pipe Organizational Unit names and distinguished names as strings to Export-LastLogonTime. 
 
.OUTPUTS 
None 
 
 
Export-LastLogonTimes.ps1 does not generate any output. 
 
.EXAMPLE 
PS C:\> Export-LastLogonTime -OrganizationalUnit Users -Destination "C:\Users\administrator\Documents\LastLogon.csv" 
 
The following command will get the account name and latest last logon times out of all Domain Controllers for the OU named Users and export the information to a .csv file named LastLogon.csv in the Administrator's Documents folder. 
.EXAMPLE 
PS C:\> 'Users', 'OU=Restricted Users,DC=example,DC=com' | Export-LastLogonTime -Destination "C:\Users\administrator\Documents\LastLogon.csv" 
 
This command will export the latest last logon times out of all Domain Controllers for all of the users in the Users and Restricted Users OUs. Note that Restricted Users is given as its distinguished name, while Users is not. The command will accept either. 
.EXAMPLE 
PS C:\> Export-LastLogonTime -OrganizationalUnit 'Users','Restricted Users' -Server DC01 -Destination C:\Users\administrator\Documents\LastLogon.csv 
 
THis command will export the last logon times from the Domain Controller DC01 for all of the users in the Users and Restricted Users OUs to the file in the Destination parameter. 
.EXAMPLE 
PS C:\> Export-LastLogonTime -OU Users -DC 'DC01','DC02' -Destination C:\Users\administrator\Documents\LastLogon.csv 
 
This command will export the latest last logon times out of the Domain Controllers DC01 and DC02 for all of the users in the Users OU to a csv file in the path specified in the Destination parameter. 
.EXAMPLE 
PS C:> Export-LastLogonTime -OU Users -Path C:\<path to csv\LoginTimes.csv -Property Name, LastLogonDate -SortBy LastLogonDate 
 
This command will export the latest last logon times out of all Domain Controllers for the OU Users and export the information to a .csv file named LoginTimes.csv. Only the Name and LastLogonDate properties will be present in the csv file, and it will be sorted by the LastLogonDate property. 
.NOTES 
This command uses the ActiveDirectory PowerShell Module. This module is automatically installed on domain controllers and workstations or member servers that have installed the Remote Server Administration Tools (RSAT).  If you are not on a machine that meets this criteria, the command will fail to work. 
 
.LINK 
Get-ADUser 
.LINK 
Get-ADObject 
.LINK 
Get-ADDomainController 
.LINK 
Export-Csv 
#> 
 
#Requires -Version 3.0 
[CmdletBinding(HelpURI='https://gallery.technet.microsoft.com/Export-Last-Logon-Times-4fcb07cb')] 
 
Param( 
    [Switch]$Descending, 
 
    [Switch]$Force, 
 
    [Alias("NoOverwrite")] 
        [Switch]$NoClobber, 
 
    [Parameter(Mandatory=$true, Position=0,ValueFromPipeline=$true)] 
    [Alias("OU")] 
        [String[]]$OrganizationalUnit, 
 
    [Parameter(Mandatory=$true, Position=1)] 
    [ValidatePattern("\.csv$")] 
    [Alias("Destination")] 
        [String]$Path, 
 
    [String[]]$Property=@('Name','LastLogonDate','Enabled','SamAccountName','DomainController'), 
 
    [Alias("DC")] 
        [String[]]$Server, 
         
    [String[]]$SortBy='Name' 
) 
 
Begin { 
    #Function to test for module installation and successful load.  Thank you to Hey, Scripting Guy! blog for this one. 
    Function Test-Module { 
        Param ( 
            [Parameter(Mandatory=$true, Position=0)][String]$Name 
        ) 
 
        #Test for module imported 
        if (!(Get-Module -Name $Name)) { 
            #Test for module availability 
            if (Get-Module -ListAvailable | Where-Object {$_.Name -eq $Name}) { 
                #If not loaded but available, import module  
                Import-Module $Name 
                $True 
            } 
            #Module not installed 
            else {$False} 
        } 
        #Module already imported 
        else {$True} 
    } 
 
    Function Get-LogonTimes($OU) { 
        if ($OU -imatch '(?:(?:(?:OU|CN)=.+?)(?<!\\),)+?(?:(?:DC=.+?)(?<!\\),)?DC=.+$') { 
            Write-Verbose "Distinguished Name entered" 
            $OUDN = $OU 
        } 
        else { 
            #Search for input OU and store distinguished name property 
            Write-Verbose "Resolving Distinguished Names" 
            $OUDN = (Get-ADOrganizationalUnit -Filter "Name -eq '$OU'" -ea SilentlyContinue).DistinguishedName 
        } 
 
        #test for valid result of OU 
        if ($OUDN) { 
            #Iterate through in case multiple OUs have equal Name properties 
            foreach ($DN in $OUDN) { 
                Write-Verbose "Getting users of OU $DN..." 
                #If distinguished name exists, get users' account name and last logon times 
                $users = Get-ADUser -Filter * -SearchBase $DN 
 
                #Iterate through each user and get its LastLogonDate property from each domain controller 
                foreach ($user in $users) { 
                    Write-Verbose "Getting logon times for user $($user.Name)..." 
                    $UserLogonTimes = @() 
                    foreach ($dc in $DCs) { 
                        Write-Verbose "Getting logon times from DC $($dc.Name)..." 
                        #When getting the user, send to Select-Object to effect a change to PSCustomObject 
                        #so a DomainController property can be added. 
                        $UserLogonTimes += Get-ADUser -Identity $user.SamAccountName -Server $dc.Name -Properties * |  
                            Select-Object -Property * | 
                            Add-Member -NotePropertyName DomainController -NotePropertyValue $dc.Name -PassThru 
                    } 
                    #Sort the dates to get the highest date on top 
                    Write-Verbose "Determining the latest time of all logons...`n`n" 
                    $UserLogonTimes | Sort-Object -Property LastLogonDate -Descending |  
                        Select-Object -First 1 -Property $Property 
                } 
            } 
        } 
        #No OU was found with the name supplied 
        else { 
            #Generate alert for no OU found 
            Write-Error "The OU $OU is not a valid OU name in the domain." 
        } 
    } 
 
    #Store list of logon times 
    $result = @() 
 
    #Add LastLogonDate property to the Property parameter if it doesn't already have it, since that is the point of the script after all. 
    if ("LastLogonDate" -notin $Property) { $Property += "LastLogonDate" } 
    #Add the DomainController property to the Property parameter if it doesn't already have it. 
    if ("DomainController" -notin $Property) { $Property += "DomainController" } 
 
    #Test for ActiveDirectory Module 
    Write-Verbose "Testing for ActiveDirectory Module..." 
    if (!(Test-Module -Name "ActiveDirectory")) { 
        #If not installed, alert 
        Write-Error "There was a problem loading the Active Directory module.  Either you are not on a domain controller or your workstation does not have Remote Server Administration Tools (RSAT) installed." 
        exit 
    } 
    Write-Verbose "ActiveDirectory Module installed" 
 
    #Get Domain Controllers - this can take a while 
    #Use ArrayList so the Remove method can be used 
    $DCs = New-Object System.Collections.ArrayList 
    Write-Verbose "Getting Domain Controllers..." 
    if ($Server) { 
        foreach ($s in $Server) { 
            try { 
                $DCs.Add((Get-ADDomainController -Identity $s)) | Out-Null 
            } 
            catch { Write-Error "There was not a matching Domain Controller $s found in this domain." } 
        } 
    } 
    else {  
        foreach ($dc in (Get-ADDomainController -Filter * -ea SilentlyContinue)) { $DCs.Add($dc) | Out-Null } 
    } 
     
    #Check that any Domain Controllers were retrieved from Active Directory. 
    if (!$DCs) { 
        Write-Error "No Domain Controllers were found. Either there is a network problem or no Domain Controllers are running Active Directory Web Services." 
        exit 
    } 
    else { Write-Verbose "$($DCs.Count) Domain Controllers received" } 
 
    #Test that the dcs are running AD Web Services, and remove from the list if they are not. 
    #Clone because objects can't be removed while enumerating 
    Write-Verbose "Testing that all Domain Controllers are up and running Active Directory Web Services..." 
    foreach ($dc in $DCs.Clone()) { 
        if (!(Get-Service -ComputerName $dc.Name -Name ADWS -ea SilentlyContinue)) { 
            $DCs.Remove($dc) 
            Write-Warning "The Domain Controller $($dc.Name) is either down, or does not have Active Directory Web Services running. It will be skipped during checking." 
        } 
    } 
 
    #Check that any Domain Controllers remaining after ADWS test. 
    if (!$DCs) { 
        Write-Error "None of the Domain Controllers being requested are responding or they do not have Active Directory Web Services running." 
        exit 
    } 
    else { Write-Verbose "All eligible Domain Controllers added to the list." } 
} 
 
Process { 
    foreach ($OU in $OrganizationalUnit) { 
        $result += Get-LogonTimes -OU $OU 
    } 
} 
 
End { 
    Write-Verbose "Getting the results to export" 
    #Sort and export the desired information to a .csv file 
    $result | Sort-Object -Property $SortBy -Descending:$Descending | 
        Export-Csv -Path $Path -NoTypeInformation -NoClobber:$NoClobber -Force:$Force 
    if ($?) { Write-Verbose "Results exported." } 
    else { Write-Verbose "No results exported." } 
}