$here = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'Write-Log' {

    Context 'Input'{
        It 'Takes an object as pipeline input' {
            # Arrange
            $pipeInput = [PSCustomObject]@{
                Message    = 'ValueFromPipelineByPropertyName Pipeline Input'
                Level      = 'Warn'
                JSONFormat = $true
                Path       = 'TestDrive:\Pipeline.log'
            }
            # Act
            $pipeInput | Write-Log
            # Assert
            Get-Content TestDrive:\Pipeline.log | Should -BeLike "*ValueFromPipelineByPropertyName Pipeline Input*"
        }
        It 'Takes a single string as pipeline Input' {
            'Pipeline String Input' | Write-Log -Path TestDrive:\PipelineSingle.log -JSONFormat
            (Get-Content TestDrive:\PipelineSingle.log | ConvertFrom-Json).Message | Should -Be 'Pipeline String Input'
        }
        It 'Takes an Exception as pipeline input and outputs the correct message' {
            $Error.Clear()
            Get-Item TestDrive:\NotExist.Fake -ErrorAction SilentlyContinue
            $Error[0] | Write-Log -Path TestDrive:\PipelineErr.log -JSONFormat
            (Get-Content TestDrive:\PipelineErr.log | ConvertFrom-Json).Message | Should -Be "Cannot find path 'TestDrive:\NotExist.Fake' because it does not exist."
        }
        It 'Takes an Exception as pipeline input and outputs the correct level' {
            (Get-Content TestDrive:\PipelineErr.log | ConvertFrom-Json).Level | Should -Be 'Error'
        }
        It 'Takes Parameters Positionally'{
            Write-Log 'Positional Input' 'Warn' 'TestDrive:\Position.log'
            Get-Content -Path 'TestDrive:\Position.log' | Should -BeLike "*Positional Input*"
        }
    }

    Context 'Execution'{

        It 'Has a single line in the human readable log' {
            Write-Log 'Single Line' -path TestDrive:\Line.log
            (Get-Content TestDrive:\Line.log).Count | Should -Be 1
        }

        It 'Has a single line in the JSON log' {
            Write-Log 'JSONLine Line' -path TestDrive:\json.log -JSONFormat
            $json = Get-Content TestDrive:\json.log | ConvertFrom-Json
            ($json.PSObject.Properties | Measure-Object).Count | Should -Be 3
        }

        It 'Restarts a log' {
            Write-Log -Message 'Line 1' -Path TestDrive:\Restart.log
            Write-Log -Message 'Line 2' -Path TestDrive:\Restart.log
            Write-Log -StartNew -Path TestDrive:\Restart.log
            Get-Content TestDrive:\Restart.log | Should -HaveCount 1
        }
    }
    
    Context 'Output'{

        It 'Produces comment based help' {
            $h = help Write-Log
            $h.count | Should BeGreaterThan 10
        }

        It 'Has a timestamp' {
            Write-Log 'Timestamp test' -path TestDrive:\json.log -JSONFormat
            [DateTime](Get-Content TestDrive:\json.log | ConvertFrom-Json).timestamp | Should -BeOfType [DateTime]
        }

        It 'Has Info Level' {
            (Get-Content TestDrive:\json.log | ConvertFrom-Json).Level | Should -Be 'Info'
        }

        It 'Has Warn Level' {
            Write-Log -Level Warn -Message 'Warning Test' -JSONFormat -Path TestDrive:\Warn.log
            (Get-Content TestDrive:\Warn.log | ConvertFrom-Json).Level | Should -Be 'Warn'
        }

        It 'Has Error Level' {
            Write-Log -Level Error -Message 'Error Test' -JSONFormat -Path TestDrive:\Error.log
            (Get-Content TestDrive:\Error.log | ConvertFrom-Json).Level | Should -Be 'Error'
        }

        It 'Has Debug Level' {
            Write-Log -Level Debug -Message 'Debug Test' -JSONFormat -Path TestDrive:\Debug.log
            (Get-Content TestDrive:\Debug.log | ConvertFrom-Json).Level | Should -Be 'Debug'
        }

        It 'Has the correct message' {
            Write-Log -Message 'Message Test' -JSONFormat -Path TestDrive:\Message.log
            (Get-Content TestDrive:\Message.log | ConvertFrom-Json).Message | Should -Be 'Message Test'
        }

        It 'Only outputs a single verbose line' {
            $verboseLine = Write-Log 'Verbose Test' -Verbose 4>&1
            $verboseLine.count | Should -Be 1
        }
    }
}