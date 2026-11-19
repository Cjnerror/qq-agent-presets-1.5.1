#Requires -RunAsAdministrator
# Keep the machine running with the lid closed (so qq-bridge / SnowLuma / DSH stay alive).
# Applies: lid-close action = "do nothing", and never sleep / hibernate, on AC and DC.
# ASCII only on purpose: keeps this file safe under PowerShell 5.1 + any codepage.
$ErrorActionPreference = 'Stop'

function Show-Setting($sub, $name) {
  $out = & powercfg /q SCHEME_CURRENT $sub $name 2>&1 | Out-String
  $ac = [regex]::Match($out, '0x([0-9a-fA-F]+)\s*$', 'Multiline')
  Write-Output $out.Trim()
  Write-Output ''
}

Write-Output '== 1/5  lid-close action: unhide + set to "do nothing" (0) =='
& powercfg -attributes SUB_BUTTONS 5ca83367-6e45-459f-a27b-476b1d01c936 -ATTRIB_HIDE
& powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
& powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0

Write-Output '== 2/5  never sleep / hibernate (AC + DC) =='
& powercfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 0
& powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 0
& powercfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 0
& powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 0

Write-Output '== 3/5  apply active scheme =='
& powercfg /setactive SCHEME_CURRENT

Write-Output '== 4/5  verify =='
Show-Setting SUB_BUTTONS LIDACTION
Show-Setting SUB_SLEEP STANDBYIDLE
Show-Setting SUB_SLEEP HIBERNATEIDLE

Write-Output '== 5/5  done =='
Write-Output 'lid close = do nothing, idle sleep/hibernate = never (AC + DC).'
