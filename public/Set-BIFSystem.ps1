﻿<#
    .SYNOPSIS
        Ändrar inställningar för ett visst system.

    .DESCRIPTION
        Ändrar inställningar för ett visst system.

    .PARAMETER Environment
        Anger för vilken miljö systemet läsas från.

    .PARAMETER CustomerName
        Anger för vilken kund systemet tillhör.

    .PARAMETER SystemName
        Anger namnet på systemet.

    .PARAMETER SystemHSAId
        Anger HSA-Id't på systemet.
        Detta är HSA-Id på det certifikat som systemet använder för att autentisera sig mot lokala säkerhetstjänster.

    .EXAMPLE
        Set-BIFSystem -CustomerName "Customer name 1" -SystemName System2 -newname "System22" -NewHSAId "SE232xxxxxxxxx-4444" -Environment test

        Ändrar namn på systemet "System2" till "System22" samt dess hsa-id till SE232xxxxxxxxx-4444"

    .NOTES

    .LINK

#>
Function Set-BIFSystem {
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]$CustomerName

        ,[Parameter(Mandatory=$True
                   ,ParameterSetName='SystemName')]
        [string]$SystemName

        ,[Parameter(Mandatory=$True
            ,ParameterSetName='hsaid')]
        [string]$SystemHSAId

        ,[Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$NewName

        ,[Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$NewHsaId
    )
    DynamicParam {
        $RuntimeParameterDictionary = _New-DynamicValidateSetParam -ParameterName "Environment" `
                                                                   -ParameterType [DynParamQuotedString] `
                                                                   -Mandatory $True `
                                                                   -FillValuesWith "_OLL.BIF.Utils-dynamic-params_Get-EnvironmentShortNames"

        return $RuntimeParameterDictionary
    }

    BEGIN {
        #TODO: Add more functionality, line changing name etc

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



        $CustomerConf = $ConfigData.OLLBIF.Customers.Customer | ? { $_.name -eq $CustomerName }

        if(-Not $CustomerConf) {
            Throw "Customer `"{0}`" does not exist!" -f $Customer
        }

        if($SystemHSAId) {
            $sys = $ConfigData.OLLBIF.Customers.customer.systems.system | ? { $_.hsaid -eq $SystemHSAId }
            if(-Not $sys) {
                Throw "Can not find a system  with hsaid `"{0}`"" -f $SystemHSAId
            }
        } elseif($SystemName) {
            $sys = $ConfigData.OLLBIF.Customers.customer.systems.system | ? { $_.name -eq $SystemName }
            if(-Not $sys) {
                Throw "Can not find a system with name `"{0}`"" -f $SystemName
            }
        }
    }

    PROCESS {

        if($NewName) {

            $systest = $ConfigData.OLLBIF.Customers.customer.systems.system | ? { $_.name -eq $NewName }
            if($systest) {
                Throw "System `"{0}`" already exists!" -f $NewName
            }

            $sys.name = $NewName
        }


        if($NewHsaId) {
            $systest = $ConfigData.OLLBIF.Customers.customer.systems.system | ? { $_.hsaid -eq $SystemHSAId }
            if($systest) {
                Throw "A system with hsa-id `"{0}`" already exists!" -f $NewHsaId
            }

            $sys.hsaid = $NewHsaId
        }



    }

    END {
        if($EnvConfigFile) {

            Write-Verbose "Saving configuration to $EnvConfigFile"

          #Apparently xmldocument.Save(string filename) is not available on .NET core (OSX)
          if($PSEdition -eq "Core") {
            # we use a streamWriter instead.
            # this approach is probably available on full .NET as well
            $Configdata.Save([System.IO.StreamWriter]::new($EnvConfigFile))
          } else {
            $Configdata.save($EnvConfigFile)
          }
        } else {
            Throw "Can't save configuration! Which file to save to is not set!"
        }
    }
}