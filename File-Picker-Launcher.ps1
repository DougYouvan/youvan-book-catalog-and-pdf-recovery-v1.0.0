# Run from Windows PowerShell; choose the script instead of assuming its download filename.
Add-Type -AssemblyName System.Windows.Forms
$picker = New-Object System.Windows.Forms.OpenFileDialog
$picker.Filter = 'PowerShell scripts (*.ps1)|*.ps1'
$picker.Title = 'Select Collect-Youvan-PDFs-v2.ps1'
if ($picker.ShowDialog() -eq 'OK') {
    powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File $picker.FileName
}
