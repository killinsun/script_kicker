$def   = @{
    dateCheck= @{ 
        lastUpdate  = "2018/01/12" 
        checkSkip   = $true
    };
    userCheck= @{
        userAccount = "aaaaa"
        checkSkip   = $true
    }
    segmentCheck = @{
        networkAddr = "10.0.0.0"
        prefix      = 8
        checkSkip   = $false
    }
}
