param([string]$PlanPath = (Join-Path $PSScriptRoot 'art_plan.json'))
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Drawing;
public static class WeaponArtBounds {
    // Add a small ink underlay after fitting. Preserve every original color
    // and interior detail; never paint inward over narrow handles or whisk wires.
    public static void StrengthenContour(Bitmap image, int width) {
        int w=image.Width, h=image.Height;
        Color[,] pixels=new Color[w,h];
        for(int y=0;y<h;y++) for(int x=0;x<w;x++) pixels[x,y]=image.GetPixel(x,y);
        for(int y=0;y<h;y++) for(int x=0;x<w;x++) {
            Color original=pixels[x,y];
            if(original.A==255) continue;
            int outlineAlpha=original.A;
            for(int dy=-width;dy<=width;dy++) for(int dx=-width;dx<=width;dx++) {
                if(dx*dx+dy*dy>width*width) continue;
                int px=x+dx, py=y+dy;
                if(px>=0 && py>=0 && px<w && py<h) outlineAlpha=Math.Max(outlineAlpha,pixels[px,py].A);
            }
            if(outlineAlpha>original.A) {
                double top=original.A/255.0, under=(outlineAlpha/255.0)*(1-top);
                double alpha=top+under;
                image.SetPixel(x,y,Color.FromArgb((int)Math.Round(alpha*255),
                    (int)Math.Round((original.R*top+18*under)/alpha),
                    (int)Math.Round((original.G*top+21*under)/alpha),
                    (int)Math.Round((original.B*top+17*under)/alpha)));
            }
        }
    }
    public static Rectangle Find(Bitmap image) {
        int left=image.Width, top=image.Height, right=-1, bottom=-1;
        for(int y=0;y<image.Height;y++) for(int x=0;x<image.Width;x++) {
            if(image.GetPixel(x,y).A < 80) continue;
            left=Math.Min(left,x); top=Math.Min(top,y); right=Math.Max(right,x); bottom=Math.Max(bottom,y);
        }
        if(right<left) throw new Exception("Empty sprite");
        return Rectangle.FromLTRB(left,top,right+1,bottom+1);
    }
}
'@ -ReferencedAssemblies System.Drawing.Common,System.Drawing.Primitives
$plan = Get-Content -LiteralPath $PlanPath -Raw | ConvertFrom-Json
foreach ($entry in $plan) {
    $original = [System.Drawing.Bitmap]::FromFile((Join-Path $projectRoot ('assets/sprites/Weapons/' + $entry.old)))
    $source = [System.Drawing.Bitmap]::FromFile((Join-Path $projectRoot ('assets/sprites/Weapons/Redesign/Source/' + $entry.name + '.png')))
    $oldBounds = [WeaponArtBounds]::Find($original)
    $sourceBounds = [WeaponArtBounds]::Find($source)
    $game = [System.Drawing.Bitmap]::new($original.Width, $original.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($game)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.DrawImage($source, $oldBounds, $sourceBounds, [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.Dispose()
    $outlinePadding = 2
    if ($null -ne $entry.PSObject.Properties['outline_padding']) { $outlinePadding = [int]$entry.outline_padding }
    [WeaponArtBounds]::StrengthenContour($game, $outlinePadding)
    $game.Save((Join-Path $projectRoot ('assets/sprites/Weapons/Redesign/InGame/' + $entry.name + '.png')), [System.Drawing.Imaging.ImageFormat]::Png)
    # The icon is mechanically rotated from the exact in-game bitmap, never redrawn.
    $rotated = [System.Drawing.Bitmap]::new(300,300)
    $graphics = [System.Drawing.Graphics]::FromImage($rotated)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.TranslateTransform(150,150)
    $graphics.RotateTransform(-35)
    $graphics.DrawImage($game, -100, -50, 200, 100)
    $graphics.Dispose()
    $rotatedBounds = [WeaponArtBounds]::Find($rotated)
    $icon = [System.Drawing.Bitmap]::new(200,200)
    $graphics = [System.Drawing.Graphics]::FromImage($icon)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $fitScale = 180.0 / [Math]::Max($rotatedBounds.Width,$rotatedBounds.Height)
    $fitWidth = [int]($rotatedBounds.Width * $fitScale)
    $fitHeight = [int]($rotatedBounds.Height * $fitScale)
    $iconBounds = [System.Drawing.Rectangle]::new([int]((200-$fitWidth)/2),[int]((200-$fitHeight)/2),$fitWidth,$fitHeight)
    $graphics.DrawImage($rotated,$iconBounds,$rotatedBounds,[System.Drawing.GraphicsUnit]::Pixel)
    $graphics.Dispose()
    $icon.Save((Join-Path $projectRoot ('assets/sprites/Weapons/Redesign/Icons/' + $entry.name + '.png')),[System.Drawing.Imaging.ImageFormat]::Png)
    $entry | Add-Member -NotePropertyName original_bounds -NotePropertyValue @($oldBounds.X,$oldBounds.Y,$oldBounds.Width,$oldBounds.Height) -Force
    $original.Dispose(); $source.Dispose(); $game.Dispose(); $rotated.Dispose(); $icon.Dispose()
    Write-Output ('Prepared ' + $entry.name)
}
$plan | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $PlanPath
