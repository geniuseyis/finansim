# Claude API anahtarını Cloud Functions sırrı (ANTHROPIC_API_KEY) olarak kaydeder.
# Kullanım (proje klasöründe):  powershell -ExecutionPolicy Bypass -File scripts\set-ai-key.ps1
# Anahtar ekranda görünmez, geçici dosyası işlem bitince silinir.

$ErrorActionPreference = 'Stop'
$secure = Read-Host 'Claude API anahtarini yapistir (sk-ant-...) ve Enter''a bas' -AsSecureString
$key = [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)).Trim()

if (-not $key.StartsWith('sk-ant-')) {
    Write-Host 'Bu bir Claude API anahtari gibi gorunmuyor (sk-ant- ile baslamali).' -ForegroundColor Red
    exit 1
}

$tmp = [IO.Path]::GetTempFileName()
try {
    [IO.File]::WriteAllText($tmp, $key)
    firebase functions:secrets:set ANTHROPIC_API_KEY --data-file $tmp
} finally {
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    $key = $null
}
