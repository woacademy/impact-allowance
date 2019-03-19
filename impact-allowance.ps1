#!/usr/bin/env pwsh

# Input paramters.
Param(
    [string]$data,
    [string]$userfile
)

If (!$data) {
    Throw 'Missing required argument "-data".'
} ElseIf (!$userfile) {
    Throw 'Missing required argument "-userfile".'
}

# Functions.
function New-ImpactAllowance()
{
    Param(
        [decimal]$FreeAdded,
        [decimal]$FreeUnspent,
        [decimal]$FreeNoneSpent
    )

    $ImpactAllowance = [PSCustomObject]@{
        FreeAdded = $FreeAdded
        FreeUnspent = $FreeUnspent
        FreeNoneSpent = $FreeNoneSpent
    }

    $ImpactAllowance
}

<#
 #
 #>

# Arrays to store users.
$Users = @{}
$OurUsers = Get-Content -Path $userfile

# Loop through each line in the data file.
ForEach ($line in Get-Content $data)
{
    <#
     # Run a regex match against each line to determine what type of entry it is.
     # [0] Full match.
     # [1] Name.
     # [2] Amount added/removed.
     # [3] "Free Meal Allowance Added" or "Unsued Free Meal Allowance".
     #>
    If ($line -match '\\fs20\s([^\\\/]+\s[^\\\/]+)\\plain\s\\tab.*-*([0-9]+.[0-9]+)\\.*\\fs20\s([a-zA-Z\s]+)')
    {
        # Check what kind of entry it is.
        Switch ($matches[3])
        {
            "Free Meal Allowance Added"
            {
                # Ignore users from other sites.
                If ($OurUsers -Contains $matches[1])
                {
                    # Check if the user already exists in the hash table, if not, add them.
                    If (!$Users.ContainsKey($matches[1]))
                    {
                        $ImpactAllowance = New-ImpactAllowance 0.0 0.0 0.0
                        $Users.Add($matches[1], $ImpactAllowance)
                    }

                    # Add the allowance to the relevant total.
                    $Users[$matches[1]].FreeAdded += $matches[2]
                }
            }

            "Unused Free Meal Allowance"
            {
                # Ignore users from other sites.
                If ($OurUsers -Contains $matches[1])
                {
                    # Check if the user already exists in the hash table, if not, add them.
                    If (!$Users.ContainsKey($matches[1]))
                    {
                        $ImpactAllowance = New-ImpactAllowance 0.0 0.0 0.0
                        $Users.Add($matches[1], $ImpactAllowance)
                    }

                    # Add the allowance t othe relevant total (none spent is different than some spent).
                    If ($matches[2] -eq "2.10")
                    {
                        $Users[$matches[1]].FreeNoneSpent += $matches[2]
                    }
                    Else
                    {
                        $Users[$matches[1]].FreeUnspent += $matches[2]
                    }
                }
            }
        }
    }
}

# Calculate basic statistics.
$Total = New-ImpactAllowance 0.0 0.0 0.0
$UserCount = $Users.Count

ForEach ($User in $Users.Keys) {
    $Total.FreeAdded += $Users[$User].FreeAdded
    $Total.FreeUnspent += $Users[$User].FreeUnspent
    $Total.FreeNoneSpent += $Users[$User].FreeNoneSpent
}

# Print statistics.
Write-Output @"



The following statistics are for $UserCount users.
They were allocated a total of $($Total.FreeAdded) GBP.
They spent a total of $(($Total.FreeAdded - $Total.FreeUnspent) - $Total.FreeNoneSpent) GBP.
They didn't spent a total of $($Total.FreeUnspent) GBP.
The FreeNoneSpent value was $($Total.FreeNoneSpent) GBP.
-
Averages per student:
$($Total.FreeAdded / $UserCount) GBP allocated.
$(($Total.FreeAdded - $Total.FreeUnspent) / $UserCount) GBP spent.
$($Total.FreeUnspent / $UserCount) GBP unspent.
$($Total.FreeNoneSpent / $UserCount) GBP FreeNoneSpent.



"@
