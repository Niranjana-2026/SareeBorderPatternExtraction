<#
.SYNOPSIS
    Starts an interactive Localhost Web Server on port 8080 (zero dependencies).
#>

$port = 8080
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()

Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "  SAREE BORDER SIMILARITY DASHBOARD - RUNNING ON LOCALHOST          " -ForegroundColor Cyan
Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "Local URL: http://localhost:$port/gui_preview.html" -ForegroundColor Green
Write-Host "Press Ctrl + C in this terminal to stop the server." -ForegroundColor Gray
Write-Host ""

Start-Process "http://localhost:$port/gui_preview.html"

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $rawUrl = $request.RawUrl.TrimStart('/')
        if ([string]::IsNullOrEmpty($rawUrl) -or $rawUrl -eq "/") {
            $rawUrl = "gui_preview.html"
        }
        $rawUrl = $rawUrl.Split('?')[0] # Remove query parameters

        $filePath = Join-Path $scriptDir $rawUrl.Replace('/', '\')

        if (Test-Path $filePath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $mime = "application/octet-stream"
            switch ($ext) {
                ".html" { $mime = "text/html" }
                ".jpg"  { $mime = "image/jpeg" }
                ".jpeg" { $mime = "image/jpeg" }
                ".png"  { $mime = "image/png" }
                ".css"  { $mime = "text/css" }
                ".js"   { $mime = "application/javascript" }
            }
            $response.ContentType = $mime
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $errBytes = [System.Text.Encoding]::UTF8.GetBytes("File Not Found: $rawUrl")
            $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
        }
        $response.Close()
    }
} finally {
    $listener.Stop()
}
