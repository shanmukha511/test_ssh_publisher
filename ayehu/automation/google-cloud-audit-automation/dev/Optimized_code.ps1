#code to check directory exists or not,if not create one

$name = $ENV:WORKSPACE + "\ayehu\automation\google-cloud-audit-automation\dev\Gcloud_Inventory_Module.ps1"

import-module -name $name -DisableNameChecking  -Force

$DesktopPath = "/tmp/"+"Gcloud_Inventory_Files"

$OldPath = "/tmp/" +"old_Inventory_Files"
$NewPath = "/tmp/" +"new_Inventory_Files"
$UpdatePath = "/tmp"/ +"update_Inventory_Files"

if(!(test-path $DesktopPath))
{
 echo "Directory Not exists"
 echo "----- Creating the Directory -----"
 [system.io.directory]::CreateDirectory($DesktopPath)
}
else
{
 echo "Directory already exists"
}
if(!(test-path $OldPath))
{
 echo "Directory Not exists"
 echo "----- Creating the Directory -----"
 [system.io.directory]::CreateDirectory($OldPath)
}
else
{
 echo "Directory already exists"
}
if(!(test-path $NewPath))
{
 echo "Directory Not exists"
 echo "----- Creating the Directory -----"
 [system.io.directory]::CreateDirectory($NewPath)
}
else
{
 echo "Directory already exists"
}
if(!(test-path $UpdatePath))
{
 echo "Directory Not exists"
 echo "----- Creating the Directory -----"
 [system.io.directory]::CreateDirectory($UpdatePath)
}
else
{
 echo "Directory already exists"
}

$Newfilepath = $NewPath + "\" +"DEV Non Production.csv"
$oldfilepath = $OldPath + "\" +"DEV Non Production.csv"



try
{
if(Get-ChildItem -path $Newfilepath)
{
move-Item -Path $Newfilepath -Destination $oldfilepath -Force
}
}
catch
{
$_.Exception |out-null
}

$transcriptpath  = $DesktopPath+"\Transcript_$(get-date -f yyyy_MM_dd_HH_mm__ss).txt"

Start-Transcript -Path $transcriptpath


#Code to generate csv filename with timestamp

[string]$filepath = $DesktopPath+"\"+"DEV-nonproduction.csv";
[string]$directory = [System.IO.Path]::GetDirectoryName($filePath);
[string]$strippedFileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath);
[string]$extension = [System.IO.Path]::GetExtension($filePath);
[string]$newFileName = $strippedFileName+"_" + [DateTime]::Now.ToString("yyyy_MM_dd_HH_mm_ss") + $extension;
[string]$filename = [System.IO.Path]::Combine($directory, $newFileName);



#Function call for instances data

$data = Get-Instances-Data

#Exporting data to CSV

$data = $data |Select-Object -SkipLast 1

$path2 = $ENV:WORKSPACE + "\ayehu\automation\google-cloud-audit-automation\dev\DEV Non Production.csv"



$data |Export-Csv -Path $filename -NoTypeInformation

$data |Export-Csv -Path $path2 -NoTypeInformation

$data |Export-Csv -Path $Newfilepath -NoTypeInformation

#Code for Comparsion of Old CSV with New csv to get Updated CSV with changes

$reference=$null

try
{
$reference = Import-Csv -Path $oldfilepath
}

catch 
{
$_.Exception |out-null
}

if($reference)
{

$lookup = $reference | Group-Object -AsHashTable -AsString -Property "VM Name"

$results = $null

$results = Import-Csv -Path $Newfilepath | foreach {
    
$server = $_."VM Name"

Write-Verbose "Looking for $server"

    if ($lookup.ContainsKey($server))
    {
      
        $ExternalIP=$Null
        $Business=$Null
        $Status=$Null
        $Machine =$Null
        $Disk_Name=$Null
        $Disk_Size=$Null
        $Data_Disk=$Null
        $Data_Disk_Size=$Null
        $Network=$Null
        $SubNetwork=$Null
        $Internal_IP =$Null
        $DataDiskSize=$null
        $disksize=$null
        

        $ExternalIP = ($lookup[$server])."External IP"
        $Business = ($lookup[$server])."Business Purpose of Application"
        $Status = ($lookup[$server])."Status"
        $Machine  = ($lookup[$server])."Machine Type"
        $Disk_Name = ($lookup[$server])."Disk Name"
        $Disk_Size  = ($lookup[$server])."Disk Size"
        
        $Data_Disk = ($lookup[$server])."Data Disk"
        $Data_Disk_Size  = ($lookup[$server])."Data Disk Size"
        $Network = ($lookup[$server])."Network"
        $SubNetwork  = ($lookup[$server])."subnetwork"
        $Internal_IP = ($lookup[$server])."Internal IP"
       
        $disksize = $_."Disk Size".trim()
        $DataDiskSize=$_."Data Disk Size".trim()

          }
    else
    {
      
        $ExternalIP=$_."External IP"
        $Business=$_."Business Purpose of Application"
        $Status=$_."Status"
        $Machine = $_."Machine Type"
        $Disk_Name=$_."Disk Name"
        $Disk_Size=$_."Disk Size"
        $Data_Disk=$_."Data Disk"
        $Data_Disk_Size=$_."Data Disk Size".trim()
        $Network=$_."network"
        $SubNetwork=$_."SubNetwork"
        $Internal_IP =$_."Internal IP"


        $_."External IP"=$null
        $_."Business Purpose of Application"=$null
        $_."Status"=$null
        $_."Machine Type"=$null
        $_."Disk Name"=$null
        $_."Data Disk"=$null
        $_."Network"=$null
        $_."SubNetwork"=$null
        $_."Internal IP"=$null
        $_."Data Disk Size"=$null
        $_."Disk Size"=$null

    }
 
    if ($_."External IP" -ne $ExternalIP -or $_."Business Purpose of Application" -ne $Business -or $_."Status" -ne $Status -or $_."Machine Type" -ne $Machine -or $_."Disk Name" -ne $Disk_Name -or $_."Data Disk" -ne $Data_Disk -or $_."Network" -ne $Network -or $_."SubNetwork" -ne $SubNetwork -or $_."Internal IP" -ne $Internal_IP -or $DataDiskSize -ne $Data_Disk_Size -or $disksize -ne $Disk_Size  -or $_."External IP" -eq $ExternalIP -or $_."Business Purpose of Application" -eq $Business -or $_."Status" -eq $Status -or $_."Machine Type" -eq $Machine -or $_."Disk Name" -eq $Disk_Name -or $_."Data Disk" -eq $Data_Disk -or $_."Network" -eq $Network -or $_."SubNetwork" -eq $SubNetwork -or $_."Internal IP" -eq $Internal_IP -or $DataDiskSize -eq $Data_Disk_Size -or $disksize -eq $Disk_Size)
    
    {

      if($_."External IP" -eq $ExternalIP)
      {
       
       $_."External IP"=$null

      }
      if($_."Business Purpose of Application" -eq $Business)
      {
       $_."Business Purpose of Application"=$null

      }

      if($_."Status" -eq $Status)
      {
       $_."Status"=$null

      }
      if($_."Machine Type" -eq $Machine)
      {
      $_."Machine Type" =$null

      }

      if($_."Disk Name" -eq $Disk_Name)
      {
       $_."Disk Name"=$null

      }
      if($_."Data Disk" -eq $Data_Disk)
      {
       $_."Data Disk" =$null

      }

     if($DataDiskSize -eq $Data_Disk_Size)
      {
       $DataDiskSize=$null

      }
      if($disksize -eq $Disk_Size)
      {
       $disksize=$null

      }

      if($_."SubNetwork" -eq $SubNetwork)
      {
       $_."SubNetwork"=$null
      }

      if($_."network" -eq $network)
      {
       $_."network"=$null

      }
      
      if($_."Internal IP" -eq $Internal_IP)
      { 

       $_."Internal IP" =$null

      }

        [PSCustomObject]@{
           
             
            "VMNAME" = $server
            "Business Purpose of Application"=$business
            "Status" =$status
            "Machine Type"=$Machine
            "Disk Name"=$Disk_Name
            "Disk Size"=$Disk_Size
            "Data Disk" = $Data_Disk
            "Data Disk Size" = $Data_Disk_Size
            "Network" = $Network
            "SubNetwork" = $SubNetwork
            "Internal IP" = $Internal_IP
            "External IP" = $ExternalIP


            "New Business Purpose of Application"=$_."Business Purpose of Application"
            "New Status" = $_."status"
            "New Machine Type"=$_."Machine Type"
            "New Disk Name"=$_."Disk Name"
            "New Disk Size" = $disksize
            "New Data Disk" = $_."Data Disk"
            "New Data Disk Size" = $DataDiskSize
            "New Network" = $_."Network"
            "New SubNetwork" = $_."SubNetwork"
            "New Internal IP" = $_."Internal IP"
            "New External IP" = $_."External IP"
        }
    }
}



$results | Out-GridView

$updatetxtpath = $updatepath + "\" + "updated_DEV-nonproduction.txt" 
$updatecsvpath = $updatepath + "\" + "DEV Non Production Updated.csv"  




$path = $ENV:WORKSPACE + "\ayehu\automation\google-cloud-audit-automation\dev\DEV Non Production Updated.csv"

$results | Export-Csv -Path $path  -NoTypeInformation

$results |Export-Csv -Path $updatecsvpath -NoTypeInformation

}

else
{

write-host "Reference file doesnt exist for comparison"

}

Stop-Transcript
