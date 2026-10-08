# Restore only original texture references, preserving later gameplay/UI edits.
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
foreach ($snapshot in Get-ChildItem -LiteralPath $PSScriptRoot -Recurse -Filter '*.before-redesign.txt') {
    $relativePath = [System.IO.Path]::GetRelativePath($PSScriptRoot, $snapshot.FullName).Replace('.before-redesign.txt', '')
    $targetPath = Join-Path $projectRoot $relativePath
    $currentText = [System.IO.File]::ReadAllText($targetPath)
    $originalText = [System.IO.File]::ReadAllText($snapshot.FullName)
    foreach ($originalLine in [regex]::Matches($originalText, '(?m)^\[ext_resource type="Texture2D"[^\r\n]+\]')) {
        $resourceId = [regex]::Match($originalLine.Value, ' id="([^"]+)"').Groups[1].Value
        $resourcePattern = '(?m)^\[ext_resource type="Texture2D"[^\r\n]*id="' + [regex]::Escape($resourceId) + '"\]'
        $restoreLine = $originalLine.Value
        $currentText = [regex]::Replace($currentText, $resourcePattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $restoreLine })
    }
    [System.IO.File]::WriteAllText($targetPath, $currentText)
}
Write-Output 'Original weapon texture references restored. New and original sprites were kept.'
