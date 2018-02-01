$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$here = Split-Path $here
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'Write-Log' {
    It 'Should not throw when writing JSON files' {
        Write-Log 'throw test' -path TestDrive:\json.log
    }
    It 'Should produce help' {
        $h = help Write-Log
        $h.count | Should BeGreaterThan 10
    }
    It 'Should not throw when writing JSON files' {
        Write-Log 'JSON test' -path TestDrive:\json.log -JSONFormat
    }
}