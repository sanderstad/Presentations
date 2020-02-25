Import-Module dbaclone

# Get the available images
Get-DcnImage

# Get the clones
Get-DcnClone

# Create a new clone
$params = @{
    Destination = 'C:\projects\dbaclone\clone\'
    Database    = 'AdventureWorks2017'
    CloneName   = 'AW2017C1'
    LatestImage = $true
}

New-DcnClone @params