# YetAnotherWriteLog


	 Created on:   	25/01/2017 09:35
	 Created by:   	Jim Moyle
	 Github: https://github.com/JimMoyle/YetAnotherWriteLog
	 Twitter: @jimmoyle

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

