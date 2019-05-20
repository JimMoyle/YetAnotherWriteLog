$here = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'Write-Log' {

    Context 'Input'{
        It 'Takes an object as pipeline input' {
            # Arrange
            $pipeInput = [PSCustomObject]@{
                Message    = 'ValueFromPipelineByPropertyName Input'
                Level      = 'Warning'
                JSONFormat = $true
                Path       = 'TestDrive:\Pipeline.log'
            }
            # Act
            $pipeInput | Write-Log
            # Assert
            (Get-Content TestDrive:\Pipeline.log | ConvertFrom-Json).Message | Should -Be 'ValueFromPipelineByPropertyName Input'
        }
        It 'Takes a single string as pipeline Input' {
            # Act
            'Pipeline String Input' | Write-Log -Path TestDrive:\PipelineSingle.log -JSONFormat
            # Assert
            (Get-Content TestDrive:\PipelineSingle.log | ConvertFrom-Json).Message | Should -Be 'Pipeline String Input'
        }
        It 'Takes an Exception as pipeline input and outputs the correct message' {
            # Arrange
            $Error.Clear()
            Get-Item TestDrive:\NotExist.Fake -ErrorAction SilentlyContinue
            # Act
            $Error[0] | Write-Log -Path TestDrive:\PipelineErr.log -JSONFormat
            # Assert
            (Get-Content TestDrive:\PipelineErr.log | ConvertFrom-Json).Message | Should -Be "Cannot find path 'TestDrive:\NotExist.Fake' because it does not exist."
        }
        It 'Takes an Exception as pipeline input and outputs the correct level' {
            # Assert
            (Get-Content TestDrive:\PipelineErr.log | ConvertFrom-Json).Level | Should -Be 'ERROR:  '
        }
        It 'Takes Parameters Positionally'{
            # Act
            Write-Log 'Positional Input' 'Warning' 'TestDrive:\Position.log'
            # Assert
            (Get-Content -Path 'TestDrive:\Position.log')[1] | Should -BeLike "*Positional Input*"
        }
    }

    Context 'Execution'{

        It 'Has a single line of logging in the human readable log' {
            Write-Log 'Single Line' -path TestDrive:\Line.log
            # Assert
            (Get-Content TestDrive:\Line.log).Count | Should -Be 2
        }

        It 'Has a single line in the JSON log' {
            # Act
            Write-Log 'JSONLine Line' -path TestDrive:\json.log -JSONFormat
            $json = Get-Content TestDrive:\json.log | ConvertFrom-Json
            # Assert
            ($json.PSObject.Properties | Measure-Object).Count | Should -Be 3
        }

        It 'Restarts a log' {
            # Arrange
            Write-Log -Message 'Line 1' -Path TestDrive:\Restart.log
            Write-Log -Message 'Line 2' -Path TestDrive:\Restart.log
            # Act
            Write-Log -StartNew -Path TestDrive:\Restart.log
            # Assert
            Get-Content TestDrive:\Restart.log | Should -HaveCount 2
        }
    }

    Context 'Output'{

        It 'Produces comment based help' {
            # Act
            $h = help Write-Log
            # Assert
            $h.count | Should BeGreaterThan 10
        }

        It 'Has a timestamp' {
            # Act
            Write-Log 'Timestamp test' -path TestDrive:\json.log -JSONFormat
            # Assert
            [DateTime](Get-Content TestDrive:\json.log | ConvertFrom-Json).timestamp | Should -BeOfType [DateTime]
        }

        It 'Has Info Level' {
            # Assert
            (Get-Content TestDrive:\json.log | ConvertFrom-Json).Level | Should -Be 'INFO:   '
        }

        It 'Has Warning Level' {
            # Act
            Write-Log -Level Warning -Message 'Warning Test' -JSONFormat -Path TestDrive:\Warning.log
            # Assert
            (Get-Content TestDrive:\Warning.log | ConvertFrom-Json).Level | Should -Be 'WARNING:'
        }

        It 'Has Error Level' {
            # Act
            Write-Log -Level Error -Message 'Error Test' -JSONFormat -Path TestDrive:\Error.log
            # Assert
            (Get-Content TestDrive:\Error.log | ConvertFrom-Json).Level | Should -Be 'ERROR:  '
        }

        It 'Has Debug Level' {
            # Act
            Write-Log -Level Debug -Message 'Debug Test' -JSONFormat -Path TestDrive:\Debug.log
            # Assert
            (Get-Content TestDrive:\Debug.log | ConvertFrom-Json).Level | Should -Be 'DEBUG:  '
        }

        It 'Has the correct message' {
            # Act
            Write-Log -Message 'Message Test' -JSONFormat -Path TestDrive:\Message.log
            # Assert
            (Get-Content TestDrive:\Message.log | ConvertFrom-Json).Message | Should -Be 'Message Test'
        }

        It 'Only outputs a single verbose line' {
            # Act
            $verboseLine = Write-Log 'Verbose Test' -Path TestDrive:\Verbose.txt -Verbose 4>&1
            # Assert
            $verboseLine.count | Should -Be 1
        }

        It 'Imports Human readable log as a CSV file' {
            # Act
            Write-log 'CSV Test' -Path TestDrive:\CSV.log
            $csv = Import-Csv -Path TestDrive:\CSV.log -Delimiter "`t"
            # Assert
            $csv.message | Should -Be 'CSV Test'
        }

        It 'Has the correct date format in user readable log' {
            #Act
            Write-log 'Date Test' -Path TestDrive:\Date.log
            $csv = Import-Csv -Path TestDrive:\Date.log -Delimiter "`t"
            #Assert
            $csv.TimeStamp | Should -Match "\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}"
        }

        It 'Has the correct date format in user readable log' {
            #Act
            Write-log 'Date Test' -Path TestDrive:\Date.log
            $csv = Import-Csv -Path TestDrive:\Date.log -Delimiter "`t"
            #Assert
            $csv.TimeStamp | Should -Match "\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}"
        }
    }
}