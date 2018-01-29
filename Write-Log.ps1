<#
	.NOTES
	===========================================================================
	 Created on:   	25/01/2017 09:35
	 Created by:   	Jim Moyle
	 Github: https://github.com/JimMoyle/Write-Log
	 Twitter: @jimmoyle
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

function Write-Log {
    [CmdletBinding(DefaultParametersetName = "LOG")]
    Param (
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            ParameterSetName = 'LOG')]
        [ValidateNotNullOrEmpty()]
        [Alias("LogContent")]
        [string]$Message,

        [Parameter(Mandatory = $false,
            Position = 1,
            ParameterSetName = 'LOG')]
        [ValidateSet("Error", "Warn", "Info")]
        [string]$Level,

        [Parameter(Mandatory = $false,
            Position = 2)]
        [Alias('LogPath')]
        [string]$Path = "$env:temp\PowershellScript.log",

        [Parameter(Mandatory = $false,
            Position = 0,
            ParameterSetName = 'STARTNEW')]
        [Alias('Delete')]
        [switch]$StartNew,

        [Parameter(Mandatory = $false,
            Position = 3,
            ParameterSetName = 'LOG')]
        [switch]$IncludeDebug,

        [Parameter(Mandatory = $false,
            Position = 4,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'LOG')]
        [object]$InvocationInfo,

        [Parameter(Mandatory = $false,
            Position = 5,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'LOG')]
        [object]$Exception

    )

    BEGIN {
        Set-StrictMode -version Latest
        $expandedParams = $null
        $PSBoundParameters.GetEnumerator() | ForEach-Object { $expandedParams += ' -' + $_.key + ' '; $expandedParams += $_.value }
        Write-Verbose "Starting: $($MyInvocation.MyCommand.Name)$expandedParams"
        $outMessage = @()
    }
    PROCESS {
        if ($Exception) {
            $Message = $Exception.message
            $Level = 'Error'
        }

        if ($null -eq $Level) {
            $Level = 'Info'
        }

        if ($StartNew) {
            Write-Verbose -Message "Deleting log file $Path if it exists"
            Remove-Item $Path -Force -ErrorAction SilentlyContinue
            $Message = 'Starting Log'
            Write-Verbose -Message 'Deleted log file if it exists'
        }

        if (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            New-Item $Path -Force -ItemType File | Out-Null
            Write-Verbose 'Created Log File'
        }

        Write-Verbose 'Getting Date for our Log File'
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Verbose 'Date is $FormattedDate'

        $normalOut = [PSCustomObject]@{
            Message = $message; Level = $level
        }

        $outMessage += $normalOut

        if ($IncludeDebug -and $InvocationInfo) {
            $Debug = [PSCustomObject]@{
                Message = $InvocationInfo.line.TrimEnd(); Level = 'Debug'
            }
            $outMessage += $Debug
        }

        $outmessage | ForEach-Object {

            # Write message to error, warning, or verbose pipeline and specify $LevelText
            switch ($_.Level) {
                'Error' {
                    $LevelText = 'ERROR:  '; break
                }
                'Warn' {
                    $LevelText = 'WARNING:'; break
                }
                'Info' {
                    $LevelText = 'INFO:   '; break
                }
                'Debug' {
                    $LevelText = 'DEBUG:  '; break
                }
                default {
                    Write-Verbose 'Did not find a match in switch'
                }
            }

            $logmessage = "$FormattedDate $LevelText $($_.Message)"
            Write-Verbose $logmessage

            # Write log entry to $Path

            $logmessage | Out-File -FilePath $Path -Append

        }
    }
    END {
        Write-Verbose "Finished: $($MyInvocation.Mycommand)"
    }
} # enable logging