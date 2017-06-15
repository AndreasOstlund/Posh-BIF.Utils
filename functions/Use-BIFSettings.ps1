﻿<#
	.SYNOPSIS        

	.DESCRIPTION        

    .PARAMETER         

	.EXAMPLE        

	.NOTES

	.LINK

#>
Function Use-BIFSettings {
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
        [string]$Path
    )

    # Generated with New-FortikaPSFunction

    BEGIN {
		# If -debug is set, change $DebugPreference so that output is a little less annoying.
		#	http://learn-powershell.net/2014/06/01/prevent-write-debug-from-bugging-you/
		If ($PSBoundParameters['Debug']) {
			$DebugPreference = 'Continue'
		}

        # This whole thing needs looking at...
        

        $ModuleRoot = Split-Path -Path ${PSScriptRoot} -Parent

        if(-not $Path) {
            # if $Path are unspecified, assume we shall go look for the config in module directory
            #$ConfigStoragePath = Split-Path $PSCmdlet.MyInvocation.PSScriptRoot -Parent
            $ConfigStoragePath = Join-Path -Path $ModuleRoot -ChildPath 'OLL.BIF.Utils.conf'
        } else {
            
        }


        if($(Test-Path -Path $ConfigStoragePath)) {
            
            try {
                $script:EnvironmentConfig = Import-Clixml -Path $ConfigStoragePath -ErrorAction stop
            }
            catch {
                Write-Warning "Unable to load base configuration from $ConfigStoragePath"
            }
        } else {
            Write-Warning "Can't find base config! Use Initialize-BIFSettings to create a base config and then use Use-BIFSettings to load the settings or reload the module."        
        }
    }

    PROCESS {

    }

    END {

    }
}