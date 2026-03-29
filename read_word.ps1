param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

Add-Type -AssemblyName System.IO.Compression.FileSystem
try {
    $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)
    $entry = $zip.Entries | Where-Object { $_.FullName -eq 'word/document.xml' }
    if ($entry) {
        $stream = $entry.Open()
        $reader = New-Object System.IO.StreamReader($stream)
        $xmlStr = $reader.ReadToEnd()
        $reader.Close()
        
        $xml = [xml]$xmlStr
        $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
        $ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
        
        $nodes = $xml.SelectNodes("//w:t", $ns)
        $text = ""
        foreach ($node in $nodes) {
            $text += $node.InnerText + " "
        }
        Write-Output $text
    }
    $zip.Dispose()
} catch {
    Write-Output "Error: $_"
}
