﻿<#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER xxxx

    .EXAMPLE

    .NOTES

    .LINK

#>
Function Add-BIFCustomer {
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory=$True
                  ,ValueFromPipelineByPropertyName=$True
        )]
        [string]$CustomerName,
        [Parameter(Mandatory=$True
                  ,ValueFromPipelineByPropertyName=$True
        )]
        [string]$Shortname,

        [Parameter(Mandatory=$True)]
        [ValidateSet('Prod','Test','QA')]
        [string]$Environment
    )

    BEGIN {
        try {
            [xml]$ConfigData = Get-Content $script:EnvironmentConfig[$Environment] -ErrorAction Stop
        }
        catch {
            Throw "Could not load configuration from `"$($script:EnvironmentConfig[$Environment])`". Make sure the file exists and your account has access to it."
        }

        _Backup-ConfigFile -FileName $script:EnvironmentConfig[$Environment]

        $customer = $ConfigData.OLLBIF.Customers.Customer | ? { $_.name -eq $CustomerName -or $_.shortname -eq $Shortname }

        if($customer) {
            Throw "Customer $CustomerName already exists, or shortname $Shortname already defined"
        }

    }

    PROCESS {
        $NewCustomer = $ConfigData.CreateElement("Customer")
        $NewCustomer.SetAttribute("name",$CustomerName)
        $NewCustomer.SetAttribute("shortname",$Shortname)

        # out-null här eftersom AppendChild även returnerar datat som läggs till.
        # Vi vill inte förorena pipelime med oavsiktlig output
        $Configdata.OLLBIF.Customers.AppendChild($NewCustomer) | Out-Null

    }

    END {
        $Configdata.save($script:EnvironmentConfig[$Environment])
    }
}
