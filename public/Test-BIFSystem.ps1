﻿<#
    .SYNOPSIS
        Kontrollerar om ett visst system finns registerat för en viss kund.

    .DESCRIPTION
        Kontrollerar om ett visst system finns registerat för en viss kund.

    .PARAMETER CustomerName
        Anger vilken kund informationen skall hämtas för.

    .PARAMETER SystemName
        Anger vilket system informationen skall hämtas för.

    .PARAMETER Environment
        Anger den driftmiljö som konfigurationen skall hämtas för.

    .EXAMPLE
        Test-BIFSystem -CustomerName "Region Örebro län" -SystemName "Kibi" -Environment Prod

    .NOTES

    .LINK

#>
Function Test-BIFSystem {
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]$CustomerName

        ,[Parameter(Mandatory=$True)]
        [string]$SystemName

        <#
        ,[Parameter(Mandatory=$True)]
        [ValidateSet('Prod','Test','QA')]
        [string]$Environment
        #>
    )
    DynamicParam {
        $RuntimeParameterDictionary = _New-DynamicValidateSetParam -ParameterName "Environment" `
                                                                   -ParameterType [DynParamQuotedString] `
                                                                   -Mandatory $True `
                                                                   -FillValuesWith "_OLL.BIF.Utils-dynamic-params_Get-EnvironmentShortNames"

        return $RuntimeParameterDictionary
    }

    BEGIN {
        if(-Not $script:EnvironmentConfig) {
            Throw "Global Environment config is not set! Is the module properly loaded? use Use-BIFSettings to re-read configuration data."
        }

        $Environment = $PSBoundParameters["Environment"].OriginalString

        try {
            $EnvConfigFile = $script:EnvironmentConfig[$Environment]
            # use resolve-path to get the full path of file.
            # on .NET core there seems to be problem with saving to a relative path
            $EnvConfigFile = (Resolve-Path -Path $EnvConfigFile).Path

            [xml]$ConfigData = Get-Content $EnvConfigFile -ErrorAction Stop
        }
        catch {
            Throw "Could not load configuration from `"$EnvConfigFile`". Make sure the file exists and your account has access to it, or that EnvironmentConfig is defined, is the module loaded properly?"
        }
    }

    PROCESS {
        $System = $ConfigData.OLLBIF.Customers.customer | ? { $_.Name -eq $CustomerName } | select -ExpandProperty Systems | select -ExpandProperty system | ? { $_.Name -eq $SystemName }

        if( $system ) {
            return $True
        } else {
            return $False
        }
    }

    END {
    }
}
