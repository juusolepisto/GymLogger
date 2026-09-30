$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$projectRoot = Split-Path $PSScriptRoot -Parent
$source = [Drawing.Image]::FromFile((Join-Path $projectRoot 'assets/branding/gym_logger_logo.png'))
function Write-Icon([string]$relativePath, [int]$size) {
    $target = Join-Path $projectRoot $relativePath
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($target)) | Out-Null
    $bitmap = [Drawing.Bitmap]::new($size, $size, [Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.DrawImage($source, 0, 0, $size, $size)
        $bitmap.Save($target, [Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}
try {
    foreach ($density in @{mdpi=1; hdpi=1.5; xhdpi=2; xxhdpi=3; xxxhdpi=4}.GetEnumerator()) {
        Write-Icon "android/app/src/main/res/mipmap-$($density.Key)/ic_launcher.png" ([int](48 * $density.Value))
        Write-Icon "android/app/src/main/res/mipmap-$($density.Key)/ic_launcher_foreground.png" ([int](108 * $density.Value))
    }
    $catalog = Get-Content (Join-Path $projectRoot 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json') -Raw | ConvertFrom-Json
    foreach ($icon in $catalog.images) {
        $size = [double]::Parse(($icon.size -split 'x')[0], [Globalization.CultureInfo]::InvariantCulture)
        $scale = [int]($icon.scale -replace 'x', '')
        Write-Icon "ios/Runner/Assets.xcassets/AppIcon.appiconset/$($icon.filename)" ([int]($size * $scale))
    }
} finally {
    $source.Dispose()
}
