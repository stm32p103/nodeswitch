# zip�t�@�C�����_�E�����[�h���ēW�J����
function Expand-WebArchive {
    param( [string]$Uri,
           [string]$DestinationPath )
    $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } -PassThru
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $Uri -OutFile $tmp
    Expand-Archive -Path $tmp -DestinationPath $DestinationPath
    Remove-Item $tmp
}

# Node.js��dist�����擾����
function Get-NodeDistName {
    param( [string]$Version )
    $arch = "x86"
    if( [Environment]::Is64BitOperatingSystem ) {
        $arch = "x64"
    }
    $name = "node-v$Version-win-$arch"
    return $name;
}

# Node.js��URL���擾����
function Get-NodeDistUrl {
    param( [string]$Version )
    $dist = Get-NodeDistName -Version $Version
    $uri = "https://nodejs.org/dist/v$Version/$dist.zip"
    return $uri
}

# �V���{���b�N�����N�̃^�[�Q�b�g��ύX����
function Update-SymbolicLink {
    param( [string]$From, [string]$To )

    if( Test-Path $From ) {
        if( Test-SymbolicLink -Path $From ) {
            Remove-Item -Recurse -Force -Path $From
        } else {
            throw "$From �̓V���{���b�N�����N�ł͂���܂���B"
        }
        New-Item -Force -Path $From -ItemType Junction -Value $To 
    }
}

# �V���{���b�N�����N�𔻒肷��
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

# Node�֘A�̃V���{���b�N�����N��u��������
function Set-NodeVersion {
    param( [string]$Version )
    $common = "..\common"
    $verRoot = "..\versions\$Version\"
    Update-SymbolicLink -From "$common\node" -To "$verRoot\node"
    Update-SymbolicLink -From "$common\npm_global" -To "$verRoot\npm_global"
}
