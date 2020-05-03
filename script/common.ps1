# �������[��
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

# zip�t�@�C�����_�E�����[�h���ēW�J����
function Expand-WebArchive {
    param( [string]$Uri,
           [string]$DestinationPath )
    $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } -PassThru
    $ProgressPreference = 'SilentlyContinue'
    try {
        Invoke-WebRequest -Uri $Uri -OutFile $tmp
        Expand-Archive -Path $tmp -DestinationPath $DestinationPath
    } catch {
        # �Ƃ肠�����������Ȃ�
    } finally {
        Remove-Item $tmp
    }
}

# �V���{���b�N�����N�̃^�[�Q�b�g��ύX����
function Update-SymbolicLink {
    param( [string]$From, [string]$To )

    if( !( Test-Path -LiteralPath $To ) ) {
        throw "�����N�悪����܂���B: $To "
    }

    if( Test-Path $From ) {
        if( Test-SymbolicLink -Path $From ) {
            Remove-Item -Recurse -Force -Path $From
        } else {
            throw "�V���{���b�N�����N�ł͂���܂���B�t�@�C�����폜���邩�ړ����Ă��������B: $From"
        }
    }

    New-Item -Force -Path $From -ItemType Junction -Value $To
}

# �V���{���b�N�����N�𔻒肷��
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

    # �b��: �����I��PATH�ǉ�
    $Env:Path = $rule.CommonNodeDir() + ";" + $rule.CommonNpmDir() + ";" + $Env:Path

    # �b��: �C���X�g�[������Node.js��PATH���ʂ�悤�V���{���b�N�����N���X�V
    Set-NodeVersion -RootDir $RootDir -Version $Version
}

# Node�֘A�̃V���{���b�N�����N��u��������
function Set-NodeVersion {
    param( [string]$RootDir,
           [string]$Version )
    $rule = New-Object NamingRule( $RootDir, $Version )
    Update-SymbolicLink -From $rule.CommonNodeDir() -To $rule.DistNodeDir()
    Update-SymbolicLink -From $rule.CommonNpmDir() -To $rule.DistNpmDir()
}
