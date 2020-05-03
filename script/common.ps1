# 命名ルール
class NamingRule {
    [string]$RootDir
    [string]$Version

    NamingRule( [string]$RootDir, [string]$Version ) {
        $this.RootDir = $RootDir
        $this.Version = $Version
    }
    [string]CommonDir() {
        return $this.RootDir + "\common"
    }
    [string]CommonNodeDir() {
        return $this.CommonDir() + "\node"
    }
    [string]CommonNpmDir() {
        return $this.CommonDir() + "\npm_global"
    }
    [string]VersionsDir() {
        return $this.RootDir + "\versions"
    }
    [string]Arch() {
        $arch = "x86"
        if( [Environment]::Is64BitOperatingSystem ) {
            $arch = "x64"
        }
        return $arch
    }
    [string]DistName() {
        $arch = $this.Arch()
        $name = "node-v$($this.Version)-win-$arch"
        return $name;
    }
    [string]DistNodeDir() {
        return $this.VersionsDir() + "\" + $this.DistName();
    }
    [string]DistNpmDir() {
        $dist = $this.DistName()
        return $this.RootDir + "\versions\$dist\npm_global"
    }
    [string]Uri() {
        $dist = $this.DistName()
        $uri = "https://nodejs.org/dist/v$($this.Version)/$dist.zip"
        return $uri
    }
}

# zipファイルをダウンロードして展開する
function Expand-WebArchive {
    param( [string]$Uri,
           [string]$DestinationPath )
    $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } -PassThru
    $ProgressPreference = 'SilentlyContinue'
    try {
        Invoke-WebRequest -Uri $Uri -OutFile $tmp
        Expand-Archive -Path $tmp -DestinationPath $DestinationPath
    } catch {
        # とりあえず何もしない
    } finally {
        Remove-Item $tmp
    }
}

# シンボリックリンクのターゲットを変更する
function Update-SymbolicLink {
    param( [string]$From, [string]$To )

    if( !( Test-Path -LiteralPath $To ) ) {
        throw "リンク先がありません。: $To "
    }

    if( Test-Path $From ) {
        if( Test-SymbolicLink -Path $From ) {
            Remove-Item -Recurse -Force -Path $From
        } else {
            throw "シンボリックリンクではありません。ファイルを削除するか移動してください。: $From"
        }
    }

    New-Item -Force -Path $From -ItemType Junction -Value $To
}

# シンボリックリンクを判定する
function Test-SymbolicLink {
    param( [string]$Path )
    (Get-ItemProperty $Path).Mode.Substring(5,1) -eq 'l'
}

function Install-Node {
    param( [string]$RootDir,
           [string]$Version )
    $rule = New-Object NamingRule( $RootDir, $Version )
    
    if( !( Test-Path $rule.VersionsDir() ) ) {
        New-Item $rule.VersionsDir() -ItemType Directory
    }

    if( !( Test-Path $rule.CommonDir() ) ) {
        New-Item $rule.CommonDir() -ItemType Directory
    }

    if( !( Test-Path $rule.DistNodeDir() ) ) {
        Expand-WebArchive -Uri $rule.Uri() -DestinationPath $rule.VersionsDir()
    }
    
    if( !( Test-Path $rule.DistNpmDir() ) ) {
        New-Item $rule.DistNpmDir() -ItemType Directory
    }

    # 暫定: 強制的にPATH追加
    $Env:Path = $rule.CommonNodeDir() + ";" + $rule.CommonNpmDir() + ";" + $Env:Path

    # 暫定: インストールしたNode.jsにPATHが通るようシンボリックリンクを更新
    Set-NodeVersion -RootDir $RootDir -Version $Version
}

# Node関連のシンボリックリンクを置き換える
function Set-NodeVersion {
    param( [string]$RootDir,
           [string]$Version )
    $rule = New-Object NamingRule( $RootDir, $Version )
    Update-SymbolicLink -From $rule.CommonNodeDir() -To $rule.DistNodeDir()
    Update-SymbolicLink -From $rule.CommonNpmDir() -To $rule.DistNpmDir()
}
