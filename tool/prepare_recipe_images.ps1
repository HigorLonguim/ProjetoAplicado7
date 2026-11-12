param(
  [Parameter(Mandatory = $true)]
  [string]$SourceDirectory,
  [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\assets\images\recipes')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$images = [ordered]@{
  'exec-8622609c-1abc-4351-8b4a-04f1d2fe4e64.png' = 'chicken.jpg'
  'exec-d8427b7c-5961-4a5b-8ab3-758b31951ff0.png' = 'beef.jpg'
  'exec-6237c9f7-fe67-44f3-aae2-441d78729e21.png' = 'fish.jpg'
  'exec-88a60309-5a23-4428-bd2e-d1a15d38bf09.png' = 'pasta.jpg'
  'exec-65643102-f8db-400a-87fe-b843aa67bca4.png' = 'vegetarian.jpg'
  'exec-8f06638a-ec33-4ff0-941b-2219ad2d4335.png' = 'breakfast.jpg'
  'exec-da840b65-cb4a-4cbf-b388-80ce3c5ea0bf.png' = 'soup.jpg'
  'exec-dd41a109-804e-4b42-bc44-5a7b2578111f.png' = 'salad.jpg'
  'exec-682cd92c-7e36-4175-ace5-a35af775e567.png' = 'sandwich.jpg'
  'exec-649cbff1-4772-4f3c-9820-a144e9925db9.png' = 'sweet.jpg'
  'exec-e04731c1-58b3-4a01-a8c7-50cf8f065564.png' = 'rice.jpg'
  'exec-613ad2bf-3de6-41e7-9340-7d61ac73976a.png' = 'baked.jpg'
}

$resolvedOutput = [System.IO.Path]::GetFullPath($OutputDirectory)
[System.IO.Directory]::CreateDirectory($resolvedOutput) | Out-Null

$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
  Where-Object MimeType -eq 'image/jpeg'
$quality = [System.Drawing.Imaging.Encoder]::Quality
$encoderParameters = [System.Drawing.Imaging.EncoderParameters]::new(1)
$encoderParameters.Param[0] = [System.Drawing.Imaging.EncoderParameter]::new($quality, 84L)

foreach ($entry in $images.GetEnumerator()) {
  $source = Join-Path $SourceDirectory $entry.Key
  if (-not (Test-Path -LiteralPath $source)) {
    throw "Imagem gerada não encontrada: $source"
  }

  $inputImage = [System.Drawing.Image]::FromFile($source)
  try {
    $outputImage = [System.Drawing.Bitmap]::new(960, 720)
    try {
      $graphics = [System.Drawing.Graphics]::FromImage($outputImage)
      try {
        $graphics.Clear([System.Drawing.Color]::Black)
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

        $scale = [Math]::Max(960 / $inputImage.Width, 720 / $inputImage.Height)
        $width = [int][Math]::Ceiling($inputImage.Width * $scale)
        $height = [int][Math]::Ceiling($inputImage.Height * $scale)
        $x = [int][Math]::Floor((960 - $width) / 2)
        $y = [int][Math]::Floor((720 - $height) / 2)
        $graphics.DrawImage($inputImage, $x, $y, $width, $height)
      }
      finally {
        $graphics.Dispose()
      }

      $destination = Join-Path $resolvedOutput $entry.Value
      $outputImage.Save($destination, $jpegCodec, $encoderParameters)
    }
    finally {
      $outputImage.Dispose()
    }
  }
  finally {
    $inputImage.Dispose()
  }
}

$encoderParameters.Dispose()
Get-ChildItem -LiteralPath $resolvedOutput -Filter '*.jpg' |
  Sort-Object Name |
  Select-Object Name, Length
