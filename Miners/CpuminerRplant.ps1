﻿using module ..\Modules\Include.psm1

param(
    [PSCustomObject]$Pools,
    [Bool]$InfoOnly
)

if (-not $IsWindows -and -not $IsLinux) {return}

$ManualUri = "https://github.com/rplant8/cpuminer-opt-rplant/releases"
$Port = "532{0:d2}"
$DevFee = 0.0
$Version = "5.0.11"

if ($IsLinux) {
    $Path = ".\Bin\CPU-Rplant\cpuminer-$($f = $Global:GlobalCPUInfo.Features;$(if($f.avx512){'avx512'}elseif($f.avx2 -and $f.sha -and $f.aes){'ryzen'}elseif($f.avx2 -and $f.aes){'avx2'}elseif($f.avx -and $f.aes){'avx'}elseif($f.sse42){'sse42'}elseif($Global:GlobalCPUInfo.Vendor -eq "AMD"){'sse2amd'}else{'sse2'}))"
    $URI = "https://github.com/RainbowMiner/miner-binaries/releases/download/v5.0.11-rplant/cpuminer-rplant-5.0.11-linux.tar.gz"
} else {
    $Path = ".\Bin\CPU-Rplant\cpuminer-$($f = $Global:GlobalCPUInfo.Features;$(if($f.avx512){'avx512'}elseif($f.avx2 -and $f.sha -and $f.aes){'ryzen'}elseif($f.avx2 -and $f.aes){'avx2'}elseif($f.avx -and $f.aes){'avx'}elseif($f.sse42 -and $f.aes){'sse42-aes'}elseif($f.sse42){'sse42'}elseif($Global:GlobalCPUInfo.Vendor -eq "AMD"){'sse2amd'}else{'sse2'})).exe"
    $Uri = "https://github.com/RainbowMiner/miner-binaries/releases/download/v5.0.11-rplant/cpuminer-rplant-5.0.11-win.zip"
}

if (-not $Global:DeviceCache.DevicesByTypes.CPU -and -not $InfoOnly) {return} # No CPU present in system

$Commands = [PSCustomObject[]]@(
    [PSCustomObject]@{MainAlgorithm = "argon2ad"; Params = ""} #Argon2ad (URX)
    [PSCustomObject]@{MainAlgorithm = "argon2d500"; Params = ""} #Argon2d500 (DYN)
    [PSCustomObject]@{MainAlgorithm = "argon2d4096"; Params = ""} #Argon2d4096 (UIS)
    [PSCustomObject]@{MainAlgorithm = "argon2d-glt"; GLT="argon2d-glt"; Params = ""} #Argon2d (GLT)
    [PSCustomObject]@{MainAlgorithm = "argon2i-glt"; GLT="argon2i-glt"; Params = ""} #Argon2i (GLT)
    [PSCustomObject]@{MainAlgorithm = "argon2m"; Params = ""} #Argon2m (Merge)
    [PSCustomObject]@{MainAlgorithm = "balloon"; Algorithm = "BalloonZenX"; Params = ""} #ZentoshiCoin (ZENX)
    [PSCustomObject]@{MainAlgorithm = "circcash"; Params = ""} #CircCash
	[PSCustomObject]@{MainAlgorithm = "cpupower"; Params = ""} #CpuPower
    [PSCustomObject]@{MainAlgorithm = "cryptovantaa"; Params = ""} #IOtE
    #[PSCustomObject]@{MainAlgorithm = "curvehash"; Params = ""} #CurveHash/Oblivion, still broken in v4.5.18
    [PSCustomObject]@{MainAlgorithm = "hodl"; Params = ""} #Hodl
    #[PSCustomObject]@{MainAlgorithm = "honeycomb"; Params = ""} #Honeycomb
    [PSCustomObject]@{MainAlgorithm = "lyra2cz"; Params = ""} #Lyra2cz
	[PSCustomObject]@{MainAlgorithm = "lyra2h"; Params = ""; LinuxOnly = $true} #Lyra2h
    [PSCustomObject]@{MainAlgorithm = "lyra2tdc"; Params = ""} #Lyra2TDC
    [PSCustomObject]@{MainAlgorithm = "lyra2z330"; Params = ""; ExcludePoolName = "^Zpool"} #Lyra2z330
    [PSCustomObject]@{MainAlgorithm = "minotaur"; Params = ""} #Minotaur/RING
    [PSCustomObject]@{MainAlgorithm = "phi5"; Params = ""} #Combode Coin
    #[PSCustomObject]@{MainAlgorithm = "power2b"; Params = ""; MaxRejectedShareRatio = 0.7} #Yespower2b, Jayddee faster
    ####[PSCustomObject]@{MainAlgorithm = "qureno"; Params = ""} #X33 (new QRN) from v4.5.17 on
	#[PSCustomObject]@{MainAlgorithm = "scrypt:1048576"; Params = ""} #ScryptN2, CpuminerVerium and CpuminerJayddee faster
	[PSCustomObject]@{MainAlgorithm = "scryptjane:16"; Params = ""; LinuxOnly = $true} #ScryptJane16
    [PSCustomObject]@{MainAlgorithm = "x22"; Params = ""} #X22 from v4.5.20 on
    ####[PSCustomObject]@{MainAlgorithm = "x33"; Params = ""} #X33 (QRN) from v4.5.16 on
    [PSCustomObject]@{MainAlgorithm = "yescryptr16"; Params = ""} #YescryptR16
    [PSCustomObject]@{MainAlgorithm = "yescryptr16v2"; GLT="yescryptr16v2glt"; Params = ""} #YescryptR16v2
    [PSCustomObject]@{MainAlgorithm = "yescryptr24"; GLT="yescryptr24glt"; Params = ""} #YescryptR24
    [PSCustomObject]@{MainAlgorithm = "yescryptr32"; GLT="yescryptr32glt"; Params = ""} #YescryptR32
    [PSCustomObject]@{MainAlgorithm = "yescryptr8"; GLT="yescryptr8glt"; Params = ""} #YescryptR8
    [PSCustomObject]@{MainAlgorithm = "yescryptr8g"; Params = ""} #YescryptR8g (KOTO)
    [PSCustomObject]@{MainAlgorithm = "yespower"; Params = ""} #Yespower
    [PSCustomObject]@{MainAlgorithm = "yespowerr16"; Params = ""} #YespowerR16
    [PSCustomObject]@{MainAlgorithm = "yespowerIC"; Params = ""} #Yespower IsotopeC (IC)
    [PSCustomObject]@{MainAlgorithm = "yespowerITC"; Params = ""} #Yespower Intercoin (ITC)
    [PSCustomObject]@{MainAlgorithm = "yespowerIOTS"; Params = ""} #Yespower .. (IOTS)
    [PSCustomObject]@{MainAlgorithm = "yespowerLITB"; Params = ""} #Yespower LightBit (LITB)
    [PSCustomObject]@{MainAlgorithm = "yespowerLTNCG"; Params = ""} #Yespower LighningCash-Gold v3 (LTNCG)
    [PSCustomObject]@{MainAlgorithm = "yespowerRES"; Params = ""} #Yespower Resistance (RES)
    [PSCustomObject]@{MainAlgorithm = "yespowerSUGAR"; Params = ""} #Yespower SugarChain (SUGAR)
    [PSCustomObject]@{MainAlgorithm = "yespowerTIDE"; Params = ""} #Yespower Tidecoin (TDC)
    [PSCustomObject]@{MainAlgorithm = "yespowerURX"; Params = ""} #Yespower Uranium-X (URX)
    [PSCustomObject]@{MainAlgorithm = "sha256csm"; Params = ""} #SHA256csm
)

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName

if ($InfoOnly) {
    [PSCustomObject]@{
        Type      = @("CPU")
        Name      = $Name
        Path      = $Path
        Port      = $Miner_Port
        Uri       = $Uri
        DevFee    = $DevFee
        ManualUri = $ManualUri
        Commands  = $Commands
    }
    return
}

$Global:DeviceCache.DevicesByTypes.CPU | Select-Object Vendor, Model -Unique | ForEach-Object {
    $First = $true
    $Miner_Model = $_.Model
    $Miner_Device = $Global:DeviceCache.DevicesByTypes.CPU.Where({$_.Model -eq $Miner_Model})

    $Commands.Where({-not $_.LinuxOnly -or $IsLinux}).ForEach({

        $Algorithm_Norm_0 = Get-Algorithm "$(if ($_.Algorithm) {$_.Algorithm} else {$_.MainAlgorithm})"

        $CPUThreads = if ($Session.Config.Miners."$Name-CPU-$Algorithm_Norm_0".Threads)  {$Session.Config.Miners."$Name-CPU-$Algorithm_Norm_0".Threads}  elseif ($Session.Config.Miners."$Name-CPU".Threads)  {$Session.Config.Miners."$Name-CPU".Threads}  elseif ($Session.Config.CPUMiningThreads)  {$Session.Config.CPUMiningThreads}
        $CPUAffinity= if ($Session.Config.Miners."$Name-CPU-$Algorithm_Norm_0".Affinity) {$Session.Config.Miners."$Name-CPU-$Algorithm_Norm_0".Affinity} elseif ($Session.Config.Miners."$Name-CPU".Affinity) {$Session.Config.Miners."$Name-CPU".Affinity} elseif ($Session.Config.CPUMiningAffinity) {$Session.Config.CPUMiningAffinity}

        $DeviceParams = "$(if ($CPUThreads){" -t $CPUThreads"})$(if ($CPUAffinity){" --cpu-affinity $CPUAffinity --no-smart"})"

		foreach($Algorithm_Norm in @($Algorithm_Norm_0,"$($Algorithm_Norm_0)-$($Miner_Model)")) {
			if ($Pools.$Algorithm_Norm.Host -and $Miner_Device -and (-not $_.ExcludePoolName -or $Pools.$Algorithm_Norm.Name -notmatch $_.ExcludePoolName)) {
                if ($First) {
                    $Miner_Port = $Port -f ($Miner_Device | Select-Object -First 1 -ExpandProperty Index)
                    $Miner_Name = (@($Name) + @($Miner_Device.Name | Sort-Object) | Select-Object) -join '-'
                    $First = $false
                }
                $Miner_Coin = $Pools.$Algorithm_Norm.CoinSymbol
				[PSCustomObject]@{
					Name           = $Miner_Name
					DeviceName     = $Miner_Device.Name
					DeviceModel    = $Miner_Model
					Path           = $Path
					Arguments      = "-b `$mport -a $(if ($Miner_Coin -and $_.$Miner_Coin) {$_.$Miner_Coin} else {$_.MainAlgorithm}) -o stratum+tcp$(if ($Pools.$Algorithm_Norm.SSL) {"s"})://$($Pools.$Algorithm_Norm.Host):$($Pools.$Algorithm_Norm.Port) -u $($Pools.$Algorithm_Norm.User)$(if ($Pools.$Algorithm_Norm.Pass) {" -p $($Pools.$Algorithm_Norm.Pass)"})$($DeviceParams) --no-doh $($_.Params)"
					HashRates      = [PSCustomObject]@{$Algorithm_Norm = $Global:StatsCache."$($Miner_Name)_$($Algorithm_Norm_0)_HashRate".Week}
					API            = "Ccminer"
					Port           = $Miner_Port
					Uri            = $Uri
                    FaultTolerance = $_.FaultTolerance
					ExtendInterval = if ($_.ExtendInterval -ne $null) {$_.ExtendInterval} else {2}
                    Penalty        = 0
                    MaxRejectedShareRatio = $_.MaxRejectedShareRatio
					DevFee         = $DevFee
					ManualUri      = $ManualUri
                    Version        = $Version
                    PowerDraw      = 0
                    BaseName       = $Name
                    BaseAlgorithm  = $Algorithm_Norm_0
				}
			}
		}
    })
}