# zipファイルをダウンロードして展開する
function Expand-WebArchive {
    param( [string]$Uri,
           [string]$DestinationPath )
    $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } -PassThru
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $Uri -OutFile $tmp
    Expand-Archive -Path $tmp -DestinationPath $DestinationPath
    Remove-Item $tmp
}

# Node.jsのdist名を取得する
function Get-NodeDistName {
    param( [string]$Version )
    $arch = "x86"
    if( [Environment]::Is64BitOperatingSystem ) {
        $arch = "x64"
    }
    $name = "node-v$Version-win-$arch"
    return $name;
}

# Node.jsのURLを取得する
function Get-NodeDistUrl {
    param( [string]$Version )
    $dist = Get-NodeDistName -Version $Version
    $uri = "https://nodejs.org/dist/v$Version/$dist.zip"
    return $uri
}

# シンボリックリンクのターゲットを変更する
function Update-SymbolicLink {
    param( [string]$From, [string]$To )

    if( Test-Path $From ) {
        if( Test-SymbolicLink -Path $From ) {
            Remove-Item -Recurse -Force -Path $From
        } else {
            throw "$From はシンボリックリンクではありません。"
        }
        New-Item -Force -Path $From -ItemType Junction -Value $To 
    }
}

# シンボリックリンクを判定する
function Test-SymbolicLink {
    param( [string]$Path )
    (Get-ItemProperty $Path).Mode.Substring(5,1) -eq 'l'
}

function Install-Node {
    param( [string]$Version,
           [string]$RootDir )
    $distName = Get-NodeDistName -Version $Version
    $uri = Get-NodeDistUrl -Version $Version
    $commonDir = $RootDir + "\common"
    $versionsDir = $RootDir + "\versions"
    $distPath = $versionsDir + "\" + $distName
    $npmPath = $distPath + "\npm_global"

    Write-host $RootDir
    Write-host $versionsDir
    Write-host $distPath
    Write-host $npmPath
    if( !( Test-Path $versionsDir ) ) {
        New-Item $versionsDir -ItemType Directory
    }

    if( !( Test-Path $distPath ) ) {
        #Expand-WebArchive -Uri $uri -DestinationPath $versionsDir
    }
    
    if( !( Test-Path $versionsDir ) ) {
        New-Item $versionsDir -ItemType Directory
    }

    if( !( Test-Path $commonDir ) ) {
        New-Item $commonDir -ItemType Directory
    }

    if( !( Test-Path $npmPath ) ) {
        New-Item $npmPath -ItemType Directory
    }
}

# Node関連のシンボリックリンクを置き換える
function Set-NodeVersion {
    param( [string]$Version )
    $common = "..\common"
    $verRoot = "..\versions\$Version\"
    Update-SymbolicLink -From "$common\node" -To "$verRoot\node"
    Update-SymbolicLink -From "$common\npm_global" -To "$verRoot\npm_global"
}
