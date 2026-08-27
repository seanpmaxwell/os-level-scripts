# ToggleResolution.ps1  (v2 - fixed)
# Toggles the primary display between 2560x1600 and 3840x1600.
# All Win32 work is done inside C# to avoid PowerShell struct-marshaling issues.

Add-Type @"
using System;
using System.Runtime.InteropServices;

public class ResToggle {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    struct DEVMODE {
        private const int CCHDEVICENAME = 32;
        private const int CCHFORMNAME = 32;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = CCHDEVICENAME)]
        public string dmDeviceName;
        public short dmSpecVersion;
        public short dmDriverVersion;
        public short dmSize;
        public short dmDriverExtra;
        public int dmFields;
        public int dmPositionX;
        public int dmPositionY;
        public int dmDisplayOrientation;
        public int dmDisplayFixedOutput;
        public short dmColor;
        public short dmDuplex;
        public short dmYResolution;
        public short dmTTOption;
        public short dmCollate;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = CCHFORMNAME)]
        public string dmFormName;
        public short dmLogPixels;
        public int dmBitsPerPel;
        public int dmPelsWidth;
        public int dmPelsHeight;
        public int dmDisplayFlags;
        public int dmDisplayFrequency;
        public int dmICMMethod;
        public int dmICMIntent;
        public int dmMediaType;
        public int dmDitherType;
        public int dmReserved1;
        public int dmReserved2;
        public int dmPanningWidth;
        public int dmPanningHeight;
    }

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern bool EnumDisplaySettings(string lpszDeviceName, int iModeNum, ref DEVMODE lpDevMode);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern int ChangeDisplaySettings(ref DEVMODE lpDevMode, int dwFlags);

    const int ENUM_CURRENT_SETTINGS = -1;
    const int DM_PELSWIDTH  = 0x00080000;
    const int DM_PELSHEIGHT = 0x00100000;
    const int DISP_CHANGE_SUCCESSFUL = 0;

    public static string Toggle() {
        DEVMODE dm = new DEVMODE();
        dm.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));

        if (!EnumDisplaySettings(null, ENUM_CURRENT_SETTINGS, ref dm))
            return "ERROR: Could not read current display settings.";

        int w = dm.dmPelsWidth;
        int h = dm.dmPelsHeight;

        if (w == 2560 && h == 1600) {
            dm.dmPelsWidth = 3840;
            dm.dmPelsHeight = 1600;
        }
        else if (w == 3840 && h == 1600) {
            dm.dmPelsWidth = 2560;
            dm.dmPelsHeight = 1600;
        }
        else {
            return "Current resolution is " + w + "x" + h + " - not one of the two toggle resolutions. No change made.";
        }

        dm.dmFields = DM_PELSWIDTH | DM_PELSHEIGHT;

        int result = ChangeDisplaySettings(ref dm, 0);
        if (result == DISP_CHANGE_SUCCESSFUL)
            return "Resolution changed to " + dm.dmPelsWidth + "x" + dm.dmPelsHeight;
        else
            return "ERROR: Failed to change resolution (code " + result + "). The display may not support " + dm.dmPelsWidth + "x" + dm.dmPelsHeight + ".";
    }
}
"@

$msg = [ResToggle]::Toggle()
Write-Host $msg

if ($msg.StartsWith("ERROR") -or $msg.Contains("No change")) {
    Start-Sleep -Seconds 4
}
