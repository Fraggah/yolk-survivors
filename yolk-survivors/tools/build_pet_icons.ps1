$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$projectRoot = Split-Path $PSScriptRoot -Parent
$ids = @('sausage_dog','toaster_cat')
foreach ($id in $ids) {
    $source = [System.Drawing.Bitmap]::FromFile((Join-Path $projectRoot "assets/sprites/Pets/InGame/$(if ($id -eq 'toaster_cat') { 'toaster_cat_idle' } else { $id }).png"))
    $rotated = [System.Drawing.Bitmap]::new(600,600)
    $graphics = [System.Drawing.Graphics]::FromImage($rotated)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.TranslateTransform(300,300)
    $graphics.RotateTransform(-35)
    $graphics.DrawImage($source,-200,-200,400,400)
    $graphics.Dispose()
    $left=600; $top=600; $right=-1; $bottom=-1
    for($y=0;$y -lt 600;$y++) { for($x=0;$x -lt 600;$x++) {
        if($rotated.GetPixel($x,$y).A -lt 8) { continue }
        $left=[Math]::Min($left,$x); $top=[Math]::Min($top,$y)
        $right=[Math]::Max($right,$x); $bottom=[Math]::Max($bottom,$y)
    }}
    if($right -lt $left) { throw "Empty icon: $id" }
    $bounds=[System.Drawing.Rectangle]::FromLTRB($left,$top,$right+1,$bottom+1)
    $factor=180.0/[Math]::Max($bounds.Width,$bounds.Height)
    $width=[int]($bounds.Width*$factor); $height=[int]($bounds.Height*$factor)
    $icon=[System.Drawing.Bitmap]::new(200,200)
    $graphics=[System.Drawing.Graphics]::FromImage($icon)
    $graphics.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $destination=[System.Drawing.Rectangle]::new([int]((200-$width)/2),[int]((200-$height)/2),$width,$height)
    $graphics.DrawImage($rotated,$destination,$bounds,[System.Drawing.GraphicsUnit]::Pixel)
    $graphics.Dispose()
    $icon.Save((Join-Path $projectRoot "assets/sprites/Pets/Icons/$id.png"),[System.Drawing.Imaging.ImageFormat]::Png)
    $icon.Dispose(); $rotated.Dispose(); $source.Dispose()
}
Write-Output 'Prepared 2 pet icons at -35 degrees, centered with equal padding.'
