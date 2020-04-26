function Get-TargetPath {
    param( [string]$ScriptPath,
           [string]$Pwd,
           [string[]]$Options )
    #環境変数取得
    $version = $Env:NODE_VERSION

    # config 取得
    $pathList = @( $pwd, $Env:HOMEPATH, $scriptPath )
    $config = Find-Config -PathList $pathList

    if( ![string]::IsNullOrEmpty( $config.version ) ) {
        $version = $config.version
    }

    if( [string]::IsNullOrEmpty( $version ) ) {
        Write-Error "バージョンの指定がありません。NODE_VERSION または node-version.json の version を定義してください。"
        exit
    }

    # バージョンに対応するフォルダを指定
    $nodePath = ( Convert-Path "$ScriptPath\.." ) + "\$version\node"
    if( !( Test-Path $nodePath ) ) {
        Write-Error "$nodePath が見つかりません。"
        exit
    }
    return $nodePath
}

function Get-Config {
    param( [string]$Path )
    $res = @{}
    $configPath = "$Path\node-version.json"
    if( Test-Path $configPath ) {
        $res = Get-Content $configPath -Encoding UTF8 -Raw | ConvertFrom-Json
    }
    return $res
}

function Find-Config {
    param( [string[]]$PathList )
    $config = @{}
    foreach( $path in $PathList ) {
        $config = Get-Config -Path $path
        break
    }
    return  $config
}

# コマンドライン引数の抽出
$target = $Args[0]
$scriptPath = $Args[1] + "\.."
$pwd = $Args[2]
$options = @()
if( $Args.Count -gt 3 ) {
    $options = $Args[3..($Args.Count-1)]
}

# バッチファイル名(拡張子除く)
$path = Get-TargetPath -ScriptPath $scriptPath -Pwd $pwd

if( $options.Count -gt 0 ) {
    Start-Process -FilePath $path\$target -ArgumentList "$options" -NoNewWindow -Wait
} else {
    Start-Process -FilePath $path\$target -NoNewWindow -Wait
}
