$here = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'Write-Log' {
    It 'Does not throw when writing files' {
        { Write-Log 'throw test' -path TestDrive:\thrw.log } | Should not throw
    }
    It 'Does not throw when writing JSON files' {
       { Write-Log 'JSON test' -path TestDrive:\json.log -JSONFormat } | Should not throw
    }
    It 'Produces help' {
        $h = help Write-Log
        $h.count | Should BeGreaterThan 10
    }
    It 'Has a timestamp' {
        [DateTime](Get-Content TestDrive:\json.log | ConvertFrom-Json).timestamp | Should BeOfType [DateTime]
    }
    It 'Has Info Level' {
        (Get-Content TestDrive:\json.log | ConvertFrom-Json).Level | Should Be 'Info'
    }
    It 'Has Warn Level' {
        Write-Log -Level Warn -Message 'Warning Test' -JSONFormat -Path TestDrive:\Warn.log
        (Get-Content TestDrive:\Warn.log | ConvertFrom-Json).Level | Should Be 'Warn'
    }
    It 'Has Error Level' {
        Write-Log -Level Error -Message 'Error Test' -JSONFormat -Path TestDrive:\Error.log
        (Get-Content TestDrive:\Error.log | ConvertFrom-Json).Level | Should Be 'Error'
    }
    It 'Has Debug Level' {
        Write-Log -Level Debug -Message 'Debug Test' -JSONFormat -Path TestDrive:\Debug.log
        (Get-Content TestDrive:\Debug.log | ConvertFrom-Json).Level | Should Be 'Debug'
    }
    It 'Has a message' {
        Write-Log -Message 'Message Test' -JSONFormat -Path TestDrive:\Message.log
        (Get-Content TestDrive:\Message.log | ConvertFrom-Json).Message | Should Be 'Message Test'
    }
    It 'Has a single line of human readable text' {
        (Get-Content TestDrive:\thrw.log).Count | Should Be 1
    }
    It 'Has a single line of JSON text' {
        (Get-Content TestDrive:\json.log).Count | Should Be 1
    }
    It 'Restarts a log' {
        Write-Log -Message 'Line 1' -Path TestDrive:\Restart.log
        Write-Log -Message 'Line 2' -Path TestDrive:\Restart.log
        Write-Log -StartNew -Path TestDrive:\Restart.log
        (Get-Content TestDrive:\Restart.log).Count | Should Be 1
    }
    It 'Takes an object as pipeline Input' {
        $pipeInput = [PSCustomObject]@{
            Message    = 'Pipeline Input'
            Level      = 'Warn'
            JSONFormat = $true
            Path       = 'TestDrive:\Pipeline.log'
        }
        $pipeInput | Write-Log
        (Get-Content TestDrive:\Pipeline.log).Count | Should Be 1
    }
    It 'Takes a single string as pipeline Input' {
        'Pipeline String Input' | Write-Log -Path TestDrive:\PipelineSingle.log -JSONFormat
        (Get-Content TestDrive:\PipelineSingle.log | ConvertFrom-Json).Message | Should Be 'Pipeline String Input'
    }
    It 'Takes an Exception as pipeline input' {
        Get-Item TestDrive:\NotExist.Fake -ErrorAction SilentlyContinue
        $error[0] | Write-Log -Path TestDrive:\PipelineErr.log -JSONFormat
        (Get-Content TestDrive:\PipelineErr.log | ConvertFrom-Json).Message | Should Be "Cannot find path 'TestDrive:\NotExist.Fake' because it does not exist."
    }
    It 'Only outputs a single verbose line' {
        $verboseLine = Write-Log 'Verbose Test' -Verbose 4>&1
        $verboseLine.count | Should Be 1
    }
}