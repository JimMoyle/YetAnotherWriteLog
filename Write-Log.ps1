function Write-Log {
    [CmdletBinding(DefaultParametersetName = "LOG")]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            ParameterSetName = 'LOG')]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $false,
            Position = 1,
            ParameterSetName = 'LOG')]
        [ValidateSet("Error", "Warn", "Info")]
        [string]$Level = "Info",

        [Parameter(Mandatory = $false,
            Position = 2)]
        [string]$Path = "$env:temp\PowershellScript.log",

        [Parameter(Mandatory = $false,
            Position = 3,
            ParameterSetName = 'STARTNEW')]
        [switch]$StartNew,

        [Parameter(Mandatory = $false,
            Position = 4,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'EXCEPTION')]
        [System.Management.Automation.ErrorRecord]$Exception

    )

    BEGIN {
        Set-StrictMode -version Latest
        $expandedParams = $null
        $PSBoundParameters.GetEnumerator() | ForEach-Object { $expandedParams += ' -' + $_.key + ' '; $expandedParams += $_.value }
        Write-Verbose "Starting: $($MyInvocation.MyCommand.Name)$expandedParams"
    }
    PROCESS {

        switch ($PSCmdlet.ParameterSetName) {
            EXCEPTION {
                Write-Log -Level Error -Message $Exception.Exception.Message
                break
            }
            STARTNEW {
                Write-Verbose -Message "Deleting log file $Path if it exists"
                Remove-Item $Path -Force -ErrorAction SilentlyContinue
                Write-Verbose -Message 'Deleted log file if it exists'
                Write-Log 'Starting Logfile'
                break
            }
            LOG {
                Write-Verbose 'Getting Date for our Log File'
                $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Write-Verbose 'Date is $FormattedDate'

                switch ( $Level ) {
                    'Error' { $LevelText = 'ERROR:  '; break }
                    'Warn'  { $LevelText = 'WARNING:'; break }
                    'Info'  { $LevelText = 'INFO:   '; break }
                }

                $logmessage = "$FormattedDate $LevelText $Message"
                Write-Verbose $logmessage

                $logmessage | Add-Content -Path $Path
            }
        }

    }
    END {
        Write-Verbose "Finished: $($MyInvocation.Mycommand)"
    }
} # enable logging

Write-Log -StartNew
Write-Log -Level Error 'Error test'
Write-Log -Level Warn 'Warn test'
$error.Clear()
get-item c:\nope -ErrorAction SilentlyContinue
$error[0] | Write-Log