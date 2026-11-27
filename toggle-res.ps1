param(
    [Parameter(Mandatory)][int]$NativeW,
    [Parameter(Mandatory)][int]$NativeH,
    [Parameter(Mandatory)][int]$StretchW,
    [Parameter(Mandatory)][int]$StretchH
)

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class DisplayRes {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    struct DEVMODE {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmDeviceName;
        public ushort dmSpecVersion;
        public ushort dmDriverVersion;
        public ushort dmSize;
        public ushort dmDriverExtra;
        public uint   dmFields;
        public int    dmPositionX;
        public int    dmPositionY;
        public uint   dmDisplayOrientation;
        public uint   dmDisplayFixedOutput;
        public short  dmColor;
        public short  dmDuplex;
        public short  dmYResolution;
        public short  dmTTOption;
        public short  dmCollate;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmFormName;
        public ushort dmLogPixels;
        public uint   dmBitsPerPel;
        public uint   dmPelsWidth;
        public uint   dmPelsHeight;
        public uint   dmDisplayFlags;
        public uint   dmDisplayFrequency;
        public uint   dmICMMethod;
        public uint   dmICMIntent;
        public uint   dmMediaType;
        public uint   dmDitherType;
        public uint   dmReserved1;
        public uint   dmReserved2;
        public uint   dmPanningWidth;
        public uint   dmPanningHeight;
    }

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern bool EnumDisplaySettingsW(string deviceName, int modeNum, ref DEVMODE devMode);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern int ChangeDisplaySettingsW(ref DEVMODE devMode, uint flags);

    const int  ENUM_CURRENT_SETTINGS = -1;
    const uint CDS_UPDATEREGISTRY = 0x01;
    const uint CDS_TEST = 0x02;
    const uint DM_PELSWIDTH  = 0x80000;
    const uint DM_PELSHEIGHT = 0x100000;

    // Returns: 0 = success, 1 = can't read settings, 2 = mode unsupported, 3 = change failed
    public static int Toggle(int nativeW, int nativeH, int stretchW, int stretchH,
                             out int targetW, out int targetH) {
        targetW = 0; targetH = 0;

        DEVMODE dm = new DEVMODE();
        dm.dmDeviceName = "";
        dm.dmFormName = "";
        dm.dmSize = (ushort)Marshal.SizeOf(typeof(DEVMODE));

        if (!EnumDisplaySettingsW(null, ENUM_CURRENT_SETTINGS, ref dm)) return 1;

        if (dm.dmPelsWidth == (uint)stretchW && dm.dmPelsHeight == (uint)stretchH) {
            targetW = nativeW;  targetH = nativeH;
        } else {
            targetW = stretchW; targetH = stretchH;
        }

        dm.dmPelsWidth  = (uint)targetW;
        dm.dmPelsHeight = (uint)targetH;
        dm.dmFields     = DM_PELSWIDTH | DM_PELSHEIGHT;

        if (ChangeDisplaySettingsW(ref dm, CDS_TEST) != 0) return 2;
        if (ChangeDisplaySettingsW(ref dm, CDS_UPDATEREGISTRY) != 0) return 3;
        return 0;
    }
}
"@

$tw = 0; $th = 0
$code = [DisplayRes]::Toggle($NativeW, $NativeH, $StretchW, $StretchH, [ref]$tw, [ref]$th)

switch ($code) {
    0 { exit 0 }
    1 { Write-Host "Could not read current display settings."; exit 1 }
    2 { Write-Host "Windows reports ${tw}x${th} is not supported on this display."; exit 2 }
    3 { Write-Host "Resolution change to ${tw}x${th} failed."; exit 3 }
}
