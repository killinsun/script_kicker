# script_kicker
#
# Description: 
# 　　
#　　 
# Author:
#    R.T
#
# Version:
#    2.0


#Include libraries
. ".\lib\CalcNetworkAddressv4.ps1"
Import-Module  ".\lib\ConvertFrom-Json.psm1"

#Variables 
$COND_DEF_DIR    = "C:\Users\aaaa\Documents\script_kicker-master"
$bat_defines_hash = @(@{
                        bat_dir= "C:\Windows\System32"
                        bat_name= "batA"
                        cond_def= "def1.ps1"
                        flag_path= "C:\Users\aaaa\Documents\script_kicker-master\FLAG_1"
                        };
                      @{
                        bat_dir= "C:\Windows\System32"
                        bat_name= "batB"
                        cond_def= "def2.ps1"
                        flag_path= "C:\Users\aaaa\Documents\script_kicker-master\FLAG_2"
                        }
                      )



#--------------------------------------------------------------------------
#  Main process
#--------------------------------------------------------------------------
function main(){

    $bat_defines_hash.GetEnumerator() | ForEach-Object{

        #[PRE-CHECK] isExist Flag file
        #If flag is not exist, execute post process.

        #import condition define file(json)
        Write-Host("-----------")
        Write-Host($_.bat_name)
        Write-Host("-----------")

        $def_path = Join-Path -Path $COND_DEF_DIR -ChildPath $_.cond_def
        . $def_path # $def = hash
        write-host $def 

        #Check Flag
        if((CheckFlag $_.flag_path)){ return }

        #Check Date
        if($def.dateCheck.checkSkip -eq $false -and `
            (checkDate $def.dateCheck.lastUpdate) -eq $false ){
                #Check result is fail. skip this .bat file.
                return 
        }elseif($def.dateCheck.checkSkip -eq $null){
                return
        }

        #Check user
        if($def.userCheck.checkSkip -eq $false -and `
            (checkUser $def.userCheck.userAccount ) -eq $false ){
                #Check result is fail. skip this .bat file.
                return 
        }elseif($def.dateCheck.checkSkip -eq $null){
                return
        }

        #Check joined segment
        if($def.segmentCheck.checkSkip -eq $false  -and `
            (CheckSegment $def.segmentCheck.networkAddr `
                            $def.segmentCheck.prefix) -eq $false ){
                #Check result is fail. skip this .bat file.
                return 
        }elseif($def.dateCheck.checkSkip -eq $null){
                return
        }


        #Execute bat file.
        $bat_path = Join-Path -Path $_.bat_dir -ChildPath ($_.bat_name + ".bat")
        try{
            Write-Host("All check process successfully completed.")
            Write-Host("Start " + $bat_path )
            #Start-Process $bat_path

            #Create FLAG file.
            Write-Host("A bat file completed.")
            Write-Host("Create flag file")
            New-Item -path $_.flag_path -ItemType file


        }catch{
            Write-Error("A .bat file  "+ $bat_path +"  occurred  error.")
            write-Error($error[1])
        }
        
    }


}
#--------------------------------------------------------------------------
# Check functions
#--------------------------------------------------------------------------

function checkFlag($path){
    Write-Host("flag exists check...")
    if(Test-Path $path ){
        Write-Host("flag exists check...OK")
        Write-Host("skip this bat file.")
        return $true
    }else{
        Write-Host("flag exists check...not exist")
        Write-Host("continue post process.")
        return $false
    }
}

function checkDate($target_date){

    $today = Get-Date -Format "yyyy/MM/dd"
    Write-host("Date check...")
    if($today -gt $target_date){
        Write-Host("Date check...the date is over(today:"+ $today +" target:"+ $target_date + ")")
        return $true
    }else{
        Write-Host("Date check...the date is not over(today:"+ $today +" target:"+ $target_date + ")") -ForegroundColor Yellow
        Write-Host("skip this bat file.")
        return $false
    }


}

function checkUser($target_user){
    $userinfo = [System.Security.Principal.WindowsIdentity]::GetCurrent()

    Write-Host("User check...")
    if($userinfo.Name -eq $target_user){
        Write-Host("User check...A user is match(this account:"+ $userinfo.Name +" target:"+ $target_user + ")")
        return $true
    }else{
        Write-Host("User check...A user is unmatch(this account:"+ $userinfo.Name +" target:"+ $target_user + ")") -ForegroundColor Yellow
        Write-Host("skip this bat file.")
        return $false
    }


}

function checkSegment($target_network, $target_prefix){
    #Get local machine's ip addr
    
    Write-Host("Network address check...")
    $break_flag = $false
    Get-WmiOBject win32_networkAdapterConfiguration  | where{$_.DHCPEnabled -eq $True -and $_.IPAddress -ne $null} | %{ 
        $networkObj = CalcNetworkAddressv4 $_.IPAddress[0] $_.IPSubnet[0]

        if($target_network -eq $networkObj.network -and $target_prefix -eq $networkObj.prefix){
            Write-Host("Network address check...Network is match(interface network addr is : "+ $networkObj.network +"/"+ $networkObj.prefix+ ")")
            $break_flag = $true
            return $true
        }else{

            return $false
        }
    }
    if(-not $break_flag){
        Write-Host("Network address check...Unmached all interfaces network address.")
        Write-Host("skip this bat file.")
        return $false
    }

}

main