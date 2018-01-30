function Write-Log {
    <#
    .SYNOPSIS

    Single function to enable logging to a file
    .DESCRIPTION

    The Log file can be output to any directory (defaults to temp) and are timestamped. A single log entry looks like this:
    2018-01-30 14:40:35 INFO:    Processing c:\jimm\temp\8\8.vhdx

    Log entries can be Info, Warn or Error

    The function takes pipeline input and you can pipe exceptions straight to the file for automatic logging.

    .PARAMETER Message

    This is the body of the log line and should contain information relevant to what you need to log.
    .PARAMETER Level

    One of three logging levels: INFO, WARN or ERROR.  This is an optional parameter and defaults to INFO
    .PARAMETER Path

    The path where you want the log file to be created.  This is an optional parameter and defaults to "$env:temp\PowershellScript.log"
    .PARAMETER StartNew

    This will blank any current log in the path, it should be used at the start of a script when you don't want to append to an existing log.
    .PARAMETER Exception

    Used to pass a powershell exception to the logging function for automatic logging
    .EXAMPLE
    Write-Log -StartNew
    Starts a new logfile in the default location
    .EXAMPLE
    Write-Log -StartNew -Path c:\logs\new.log
    Starts a new logfile in the specified location
    .EXAMPLE
    Write-Log 'This is some information'
    Appends a new information line to the log.
    .EXAMPLE
    Write-Log -level warning 'This is a warning'
    Appends a new warning line to the log.
    .EXAMPLE
    Write-Log -level Error 'This is an Error'
    Appends a new Error line to the log.
    .EXAMPLE
    Write-Log -Exception $error[0]
    Appends a new Error line to the log with the message being the contents of the exception message.
    .EXAMPLE
    $error[0] | Write-Log
    Appends a new Error line to the log with the message being the contents of the exception message.
    #>

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
                Write-Log -Level Error -Message $Exception.Exception.Message -Path $Path
                break
            }
            STARTNEW {
                Write-Verbose -Message "Deleting log file $Path if it exists"
                Remove-Item $Path -Force -ErrorAction SilentlyContinue
                Write-Verbose -Message 'Deleted log file if it exists'
                Write-Log 'Starting Logfile' -Path $Path
                break
            }
            LOG {
                Write-Verbose 'Getting Date for our Log File'
                $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Write-Verbose 'Date is $FormattedDate'

                switch ( $Level ) {
                    'Error' { $LevelText = 'ERROR:  '; break }
                    'Warn' { $LevelText = 'WARNING:'; break }
                    'Info' { $LevelText = 'INFO:   '; break }
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
