# MouseButtonSwap
# powershell script
# can be executed during user logon: activated in gpedit.msc  user - windows - scripts
# Icons mouse-l.ico and mouse-r.ico must be in same directory as the script
#
# attention: 
# power shell scrips must be allowed - this is usually not default 
#
# V0.2 20230304 ri
#
# Read SwapMouseButtons in registry and store to opposite
#



# required for mouse swap dll direct call
Add-Type -TypeDefinition '
using System.Runtime.InteropServices;
namespace PInvoke
{
    public static class NativeMethods
    {
        [DllImport("user32.dll")]
        public static extern bool SwapMouseButton(bool swap);
    }
}'

# function is executed when symbol is clicked, no matter if right or left
# read from registry, execute swap and store opposite value in registry
function SwapMouse {

    $CurrentValue = Get-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name SwapMouseButtons
    $CurrentValue = $CurrentValue.SwapMouseButtons
    $CurrentValue = [convert]::ToInt32($CurrentValue)
    if ($CurrentValue -eq 0) {
        [PInvoke.NativeMethods]::SwapMouseButton($true)
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name SwapMouseButtons -Value 1
        $notifyIcon.Icon = New-Object System.Drawing.Icon($iconPathL)
        [System.Console]::Beep(1890, 300)

    } else {
        [PInvoke.NativeMethods]::SwapMouseButton($false)
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name SwapMouseButtons -Value 0
        $notifyIcon.Icon = New-Object System.Drawing.Icon($iconPathR)

        #[System.Console]::Beep(2090, 300)
        [System.Console]::Beep(1890, 300)
    }
}

Add-Type -AssemblyName System.Windows.Forms

# following only required, if context menue with Exit needed

#$contextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip

#$exitMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem("Exit")
#$exitMenuItem.add_Click({ [System.Environment]::Exit(0) })

#$swapMouseMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem("SwapMouseButtons")
#$swapMouseMenuItem.add_Click({ SwapMouse })

#$contextMenuStrip.Items.Add($swapMouseMenuItem)
#$contextMenuStrip.Items.Add($exitMenuItem)

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
#$notifyIcon.Icon = [System.Drawing.SystemIcons]::Information

# Symbol for the form 
$iconPathL = Join-Path $PSScriptRoot ".\mouse-l.ico"
$iconPathR = Join-Path $PSScriptRoot ".\mouse-r.ico"
#$notifyIcon.Icon = New-Object System.Drawing.Icon($iconPathL)

$CurrentValue = Get-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name SwapMouseButtons
$CurrentValue = $CurrentValue.SwapMouseButtons
$CurrentValue = [convert]::ToInt32($CurrentValue)
    if ($CurrentValue -eq 0) {
            $notifyIcon.Icon = New-Object System.Drawing.Icon($iconPathR)
            } else {
            $notifyIcon.Icon = New-Object System.Drawing.Icon($iconPathL)
    }


$notifyIcon.ContextMenuStrip = $contextMenuStrip
$notifyIcon.Visible = $true

# what happens when notifocation icon is clicked 
# Register-ObjectEvent -InputObject $notifyIcon -EventName MouseClick -Action { SwapMouse }
$notifyIcon.add_MouseDown({
    if ($_.Button -eq "Left") {
        SwapMouse
    } else {
        SwapMouse
    }
})


[System.Windows.Forms.Application]::Run()