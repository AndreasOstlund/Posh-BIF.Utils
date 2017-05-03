<#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER xxxx

    .EXAMPLE

    .NOTES

    .LINK

#>
Function _OLL.BIF.Utils-dynamic-params_Get-EnvironmentShortNames {
    [CmdletBinding()]
    Param(
    )
    BEGIN {
    }

    PROCESS {
        # Vi skapar en array av object av typen [DynParamQuotedString]
        # Detta f�r att hantera str�ngar som kan inneh�lla space.
        # Den str�ng som sedan v�ljs kommer plockas upp via property'n OriginalString fr�n objektet.
        $QuotedStringObjects = ${script:EnvironmentConfig}.Keys | ForEach-Object { [DynParamQuotedString] $_.ToString() }
		
        return $QuotedStringObjects
    }

    END {
    }
}


function _Test_OLL.BIF.Utils-dynamic-params_Get-ObjectTypesForValidateSet {

    _OLL.BIF.Utils-dynamic-params_Get-EnvironmentShortNames

}