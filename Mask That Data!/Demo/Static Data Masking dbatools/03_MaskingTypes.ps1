Break

###################################################################
## Randomizer types
###################################################################

# Get all the types
Get-DbaRandomizedType

# Get the types for finance
Get-DbaRandomizedType -RandomizedType Finance

# Get the types based on the sub type
Get-DbaRandomizedType -RandomizedSubType FirstName

# Get types based on pattern
Get-DbaRandomizedType -Pattern "Credit"


###################################################################
## Get random values
###################################################################

# Get random value based on data type
Get-DbaRandomizedValue -DataType char

# Get random value int with minimum value
Get-DbaRandomizedValue -DataType int -Min 10000

# Get a random first name
Get-DbaRandomizedValue -RandomizerSubType FirstName