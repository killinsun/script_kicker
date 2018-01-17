# This function refered from 
# http://www.vwnet.jp/Windows/PowerShell/CalcNetworkAddressv4.htm
function CalcNetworkAddressv4( $IP, $Subnet ){


    if( $Subnet -eq $null ){
        $Temp = $IP -split "/"
        $IP = $Temp[0]
        $CIDR = $Temp[1]
        $intCIDR = [int]$Temp[1]
        for( $i = 0 ; $i -lt 4 ; $i++ ){
            # all 1
            if( $intCIDR -ge 8 ){
                $Subnet += "255"
                $intCIDR -= 8
            }
            # all 0
            elseif($intCIDR -le 0){
                $Subnet += "0"
                $intCIDR = 0
            }
            else{
                $intNumberOfNodes = [Math]::Pow(2,8 - $intCIDR)
                $intSubnetOct = 256 - $intNumberOfNodes
                $Subnet += [string]$intSubnetOct
                $intCIDR = 0
            }
            
            if( $i -ne 3 ){
                $Subnet += "."
            }
        }
    }
    else{
        $SubnetOct = $Subnet -split "\."
        $intCIDR = 0
        for( $i = 0 ; $i -lt 4 ; $i++ ){
            $intSubnetOct = $SubnetOct[$i]
            $strBitMask = [Convert]::ToString($intSubnetOct,2)
            
            for( $j = 0 ; $j -lt 8; $j++ ){
                if( $strBitMask[$j] -eq "1" ){
                    $intCIDR++
                }
            }
        }
        $CIDR = [string]$intCIDR
    }

    $SubnetOct = $Subnet -split "\."
    $IPOct = $IP -split "\."

    $StrNetworkID = ""
    for( $i = 0 ; $i -lt 4 ; $i++ ){
        $intSubnetOct = [int]$SubnetOct[$i]
        $intIPOct = [int]$IPOct[$i]
        $intNetworkID = $intIPOct -band $intSubnetOct

        $StrNetworkID += [string]$intNetworkID

        if( $i -ne 3 ){
            $StrNetworkID += "."
        }
    }

    $NetworkIDOct = $StrNetworkID  -split "\."
    for( $i = 0 ; $i -lt 4 ; $i++ ){
        $intSubnetOct = [int]$SubnetOct[$i]
        $intNetworkIDOct = [int]$NetworkIDOct[$i]
        $BitPattern = $intSubnetOct -bxor 255
        $intBroadcastAddress = $intNetworkIDOct -bxor $BitPattern
        $StrBroadcastAddress += [string]$intBroadcastAddress

        if( $i -ne 3 ){
            $StrBroadcastAddress += "."
        }
    }
    
    $networkData = [PSCustomObject]@{
        ipaddr = $IP
        netmask = $Subnet
        prefix = $CIDR
        network = $StrNetworkID
        broadcast = $StrBroadcastAddress
    }
    write-host $networkData
    return $networkData
}
