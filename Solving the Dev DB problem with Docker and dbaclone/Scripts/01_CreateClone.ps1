
param(
    [string]$Destination,
    [string]$Database,
    [string]$CloneName,
    [switch]$LatestImage
)

begin {
    Import-Module dbaclone
}

process {
    # Create a new clone
    $params = @{
        Destination = $Destination
        Database    = $Database
        CloneName   = $CloneName
        LatestImage = $LatestImage
    }

    New-DcnClone @params
}



