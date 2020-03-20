function Get-Instances-Data()
{
  $data = @()
  $data1 = @()


  $InstancesList = gcloud compute instances list --format='csv(name,zone)'|Select-Object -Skip 1
  $InstancesString=$InstancesList -Replace(',','=')
  $InstancesDict=$InstancesString|ConvertFrom-StringData

 #Hash table Declaration
 
 #iterating over instances list
 for($i=0;$i -le $InstancesDict.Count;$i++)
  { 
   foreach($instance in $InstancesDict[$i].Keys)
     {
       echo "############"|out-null
       $instance|out-null
       echo "############"|out-null

       #setting variables values to null
       
       $machine=$null
       $Vmname=$null
       $business=$null
       $size=$null
       $status=$null
       $machinetype=$null
       $disksize=$null
       $Network=$null
       $SubNetwork=$null
       $InternalIP=$null
       $ExternalIP=$null
       $Obj1=$null
       $SubNetwork1=$null
       $SubNetwork2=$null
       $diskname=$null
       $size=$null
       $datadiskname=$null
       $datadisksize=$null
       $InternalIP2=$null
       $InternalIP1=$null
       $InternalIP=$null
       $Network1=$null
       $Network2=$null

      #Zone
      $zone=$InstancesDict[$i].values
      echo "The VM Instance:$instance" |out-null
      
      #Status of VM
      $Status = ((gcloud compute instances describe $instance --zone $zone |select-string status:).ToString()).Trim('status: ')
      echo "The VM Instance Status: $status" |out-null

      #MachineType of VM
      $machinetype = ((gcloud compute instances describe $instance --zone $zone|select-string machinetype).ToString()).Split('/')[-1]
      echo "The VM Instance MachineType: $machinetype" |out-null
   
      #Network of VM
      $Network = (( gcloud compute instances describe $instance --zone $zone|select-string  -pattern " network: "))
      echo "The VM Instance Network: $Network"|out-null


      #code to get network of VM
      if($Network.Count -gt '1')
      {

          for($y=0;$y -lt $Network.Count;$y++)
             {

               $Network1=$Network[$y].ToString().Split('/')[-1]
               $Network2+=$Network1 + ","

             }

               $Network= $Network2.TrimEnd(',')
               echo "The VM Instance Network: $Network"|out-null

      }

      else
      {

      $Network =  ((gcloud compute instances describe $instance --zone $zone |select-string  -pattern " network: ").ToString()).Split('/')[-1]

      echo "The VM Instance SubNetwork: $Network"|out-null

      }

      #ExternalIP Of VM
      $ExternalIP = ((gcloud compute instances describe $instance --zone $zone|select-string natIP).ToString()).trim('natIP: ')
      echo "The VM Instance ExternalIP: $ExternalIP"|out-null

      #SubNetwork of VM
      $SubNetwork = ( gcloud compute instances describe $instance --zone $zone|select-string SubNetwork:)

      #code to get subnetworks of VM
      if($SubNetwork.Count -gt '1')
      {

          for($k=0;$k -lt $SubNetwork.Count;$k++)
             {
                 $subnetwork1=$SubNetwork[$k].ToString().Split('/')[-1]
                 $subnetwork2+=$subnetwork1 + ","

             }

               $subnetwork = $subnetwork2.TrimEnd(',')
               echo "The VM Instance SubNetwork: $SubNetwork"|out-null

      }

      else
      {

         $SubNetwork =  ((gcloud compute instances describe $instance --zone $zone|select-string SubNetwork:).ToString()).Split('/')[-1]

         echo "The VM Instance SubNetwork: $SubNetwork"|out-null

      }

     #InternalIP of VM
     $InternalIP = ( gcloud compute instances describe  $instance --zone $zone|select-string networkIP:)

     #Code to get InternalIP of VM
     if($InternalIP.Count -gt '1')
     {
        for($l=0;$l -lt $InternalIP.Count;$l++)
           {
            $InternalIP1=$InternalIP[$l].ToString().TrimStart('networkIP: ')
            $InternalIP2+=$InternalIP1 + ","

           }

           $InternalIP = $InternalIP2.TrimEnd(',')
           echo "The VM Instance InternalIP: $InternalIP" |out-null

     }

     else
     {

         $InternalIP =  ((gcloud compute instances describe  $instance --zone $zone |select-string networkIP:).ToString()).trim('networkIP: ')

         echo "The VM Instance InternalIP: $InternalIP" |out-null
     }

       #VM DISK
       $dis = (gcloud compute instances describe $instance --zone $zone|select-string source:)

       #code to get VM's disk,size,datadisk,datadisk size

      for ($j=0;$j -lt $dis.Count;$j++)

          {
              if ($j -eq 0)
              {

              $diskname = ($dis[$j].ToString().TrimStart('source: ')).split('/')[-1]

              $sizenumber = (gcloud compute disks describe $diskname --zone $zone|select-string sizeGb).ToString()

              $size = $sizenumber.trim('sizeGb: ')

              #Code to append string GB to size
              if($size)
              {
              $size=($size+"GB").Replace("'",' ').trim()

              }

              }
              else
              {

              $datadiskname = ($dis[$j].ToString().TrimStart('source: ')).Split('/')[-1]

              $datasizenumber = (gcloud compute disks describe $datadiskname --zone $zone|select-string sizeGb).ToString()

              $datadisksize = $datasizenumber.trim('sizeGb: ')


              if($datadisksize)
              {
              $datadisksize=($datadisksize+"GB").Replace("'",' ').trim()

              }
              }

              #Adding disk properities to ps object
              $obj1=New-Object -TypeName psobject -Property @{

              "Disk Name"=$diskname;
              "Disk Size"= $size;

              "Data Disk Name"=$datadiskname;
              "Data Disk Size"= $datadisksize;


          }
        $data1 += $Obj1
      }

            #If values is empty replace with NA
            if(!$obj1.'Data Disk Name')
            {

            $obj1.'Data Disk Name'="NA"
            }

            if(!$obj1.'Data Disk Size')
            {

            $obj1.'Data Disk Size'="NA"
            }


            #If Value is empty replace with NONE
            if(!$ExternalIP)
            {

            $ExternalIP="None"
            }


            ####################
            ####################

            
                 $business_purpose_application=''

      ##################
      ##################



            #creating ordered ps object and adding properities to objetc

            $hashdata=[ordered]@{


            "VM Name"=$instance;
            "Business Purpose of Application"=$business_purpose_application;
            "Status"=$status;
            "Machine Type" =$machinetype;
            "Disk Name"=$obj1.'Disk Name';
            "Disk Size"= $obj1.'Disk Size';
            "Data Disk" = $obj1.'Data Disk Name';
            "Data Disk Size"=$obj1.'Data Disk Size';
            "Network"=$Network;
            "SubNetwork"=$SubNetwork;
            "Internal IP"=$InternalIP;
            "External IP"=$ExternalIP


            }

            $Obj = New-Object PSObject -Property $hashdata


            }

            #adding object to arrays
            $data += $Obj


      }
 return $data
}
