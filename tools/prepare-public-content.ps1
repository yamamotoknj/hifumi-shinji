$ErrorActionPreference = 'Stop'

$contentRoot = Join-Path $PSScriptRoot '..\content'
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

Get-ChildItem -LiteralPath $contentRoot -Recurse -File -Filter '*.md' | ForEach-Object {
    $path = $_.FullName
    $text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    $updated = [regex]::Replace($text, '\[\[([^\]]+?)\|([^\]]+?)\]\]', {
        param($match)
        '[[' + $match.Groups[1].Value + '\|' + $match.Groups[2].Value + ']]'
    })
    if ($updated -notmatch '(?m)^title:' -and $updated -match '\A---\r?\nタイトル:\s*([^\r\n]+)') {
        $title = $Matches[1]
        $updated = [regex]::Replace($updated, '\A---\r?\n', "---`ntitle: $title`n", 1)
    }

    if ($updated -cne $text) {
        [System.IO.File]::WriteAllText($path, $updated, $utf8NoBom)
    }
}
