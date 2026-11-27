param(
    [Parameter(Mandatory)][int]$NativeW,
    [Parameter(Mandatory)][int]$NativeH,
    [Parameter(Mandatory)][int]$StretchW,
    [Parameter(Mandatory)][int]$StretchH
)

Add-Type @"
using System;
using System.Runtime.InteropServices;

public class DisplayRes {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
    public struct DEVMODE {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmDeviceName;
        public short dmSpecVersion;
        public short dmDriverVersion;
        public short dmSize;
        public short dmDriverExtra;
        public int   dmFields;
        public int   dmPositionX;
        public int   dmPositionY;
        public int   dmDisplayOrientation;
        public int   dmDisplayFixedOutput;
        public short dmColor;
        public short dmDuplex;
        public short dmYResolution;
        public short dmTTOption;
        public short dmCollate;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmFormName;
        public short dmLogPixels;
        public int   dmBitsPerPel;
        public int   dmPelsWidth;
        public int   dmPelsHeight;
        public int   dmDisplayFlags;
        public int   dmDisplayFrequency;
        public int   dmICMMethod;
        public int   dmICMIntent;
        public int   dmMediaType;
        public int   dmDitherType;
        public int   dmReserved1;
        public int   dmReserved2;
        public int   dmPanningWidth;
        public int   dmPanningHeight;
    }

    [DllImport("user32.dll", CharSet = CharSet.Ansi)]
    public static extern bool EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE devMode);

    [DllImport("user32.dll", CharSet = CharSet.Ansi)]
    public static extern int ChangeDisplaySettings(ref DEVMODE devMode, int flags);

    public const int ENUM_CURRENT_SETTINGS = -1;
    public const int CDS_UPDATEREGISTRY    = 0x01;
    public const int CDS_TEST              = 0x02;
    public const int DISP_CHANGE_SUCCESSFUL = 0;
    public const int DM_PELSWIDTH  = 0x80000;
    public const int DM_PELSHEIGHT = 0x100000;
}
"@

$dm = New-Object DisplayRes+DEVMODE
$dm.dmSize = [System.Runtime.InteropServices.Marshal]::SizeOf($dm)

if (-not [DisplayRes]::EnumDisplaySettings($null, [DisplayRes]::ENUM_CURRENT_SETTINGS, [ref]$dm)) {
    Write-Error "Could not read current display settings."
    exit 1
}

# Decide target: if currently stretched -> native, otherwise -> stretched
if ($dm.dmPelsWidth -eq $StretchW -and $dm.dmPelsHeight -eq $StretchH) {
    $targetW = $NativeW;  $targetH = $NativeH
} else {
    $targetW = $StretchW; $targetH = $StretchH
}

# Keep current refresh rate / color depth, change only width + height
$dm.dmPelsWidth  = $targetW
$dm.dmPelsHeight = $targetH
$dm.dmFields     = [DisplayRes]::DM_PELSWIDTH -bor [DisplayRes]::DM_PELSHEIGHT

# Test first so we never leave the screen in a broken state
if ([DisplayRes]::ChangeDisplaySettings([ref]$dm, [DisplayRes]::CDS_TEST) -ne [DisplayRes]::DISP_CHANGE_SUCCESSFUL) {
    Write-Error "Windows reports ${targetW}x${targetH} is not supported on this display."
    exit 2
}

$result = [DisplayRes]::ChangeDisplaySettings([ref]$dm, [DisplayRes]::CDS_UPDATEREGISTRY)
if ($result -ne [DisplayRes]::DISP_CHANGE_SUCCESSFUL) {
    Write-Error "Resolution change failed (code $result)."
    exit 3
}
exit 0
