Write-Log -StartNew
Write-Log -Level Error 'Error test'
Write-Log -Level Warn 'Warn test'
$error.Clear()
get-item c:\nope -ErrorAction SilentlyContinue
$error[0] | Write-Log