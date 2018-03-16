function Get-DemoRandomString {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Length = 5
    )

    # Generate random string
    [string]$random = -join ((65..90) + (97..122) | Get-Random -Count $Length | Foreach-Object {[char]$_})

    return $random
}