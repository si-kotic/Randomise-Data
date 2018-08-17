<#

.SYNOPSIS

Randomises the data within an XML file.

.DESCRIPTION

The Randomise-Data function takes an XML file and randomises all of the

data within each tag.  Alphanumeric characters are replaced with like for

like characters.  For example UPPERCASE characters are replaced with

UPPERCASE characters, INTEGERS are replaced with INTEGERS and

non-alphanumeric characters are retained from the original data.

.PARAMETER path2xml

Specify the full filename of the XML file you wish to randomise.

.PARAMETER exclude

Specify the full XPATH of a tag which you would like to exclude from

ranomisation.  This is useful for retaining Criteria values when randomising

LIVE data ready for testing in AUTOFORM LN.

.EXAMPLE


--------------- EXAMPLE 1 -----------------


Randomise-Data -Path2XML "C:\path\to\XML\File.xml"


--------------- EXAMPLE 2 -----------------


Randomise-Data -Path2XML "C:\path\to\XML\File.xml" -Exclude "/Globus/TxnDesc"



#>

Function Randomise-Data {
    Param (
        [String]$Path2XML,
        [String]$Exclude,
		[Switch]$ShittyXML
    )

    IF ($Exclude) {
        $Exclude = $Exclude.Replace("\","/")
    }
    IF (!(Test-Path $Path2XML)) {
        Write-Host "SUPPLIED FILEPATH DOES NOT RESOLVE TO A VALID XML FILE!"
        Break;
    }
    ELSE {
        $Path2XML = (Resolve-Path -Path $Path2XML).Path
    }
    IF ($Exclude -and !(Select-XML -Path $Path2XML -XPath $Exclude)) {
        Write-Host "SUPPLIED XPATH DOES NOT EXIST WITHIN THE SUPPLIED XML FILE!"
        Break;
    }

    $curXML = [XML](Get-Content $Path2XML)
    IF ($Exclude) {
        $excludedVal = $curXML.SelectNodes($Exclude)."#text"
    }
    $curXML.SelectNodes("//*/text()") | Foreach-Object {
        $parent = $_.ParentNode.Name
        $curVal = $_.Value
        $length = $_.Length
        $newVal = ""
        IF (!($curVal -match '(\d{2}[-\/.]\d{2}[-\/.]\d{4})|(\d{4}-\d{2}-\d{2})')) {
            Write-Debug -Message "FIELD IDENTIFIED AS NOT BEING A DATE VALUE"
            For ($i=0; $i -lt $length; $i++) {
                Write-Debug -Message ("i = " + $i)
                IF ($curVal[$i] -match '\d') {
                    Write-Debug -Message "CURRENT CHAR = INT"
                    # GENERATE RANDOM SINGLE DIGIT NUMBER
                    $newVal += Get-Random -Maximum 10
                }
                ELSEIF ($curVal[$i] -match '\W') {
                    Write-Debug -Message "CURRENT CHAR = PUNCTUATION"
                    # RETAIN PUNCTUATION
                    $newVal += $curVal[$i]
                }
                ELSEIF ($curVal[$i] -cmatch '[A-Z]') {
                    Write-Debug -Message "CURRENT CHAR = UPPER"
                    # GENERATE RANDOM SINGLE UPPERCASE CHARACTER
                    $newVal += [char](65..90 | Get-Random)
                }
                ELSEIF ($curVal[$i] -cmatch '[a-z]') {
                    Write-Debug -Message "CURRENT CHAR = LOWER"
                    # GENERATE RANDOM SINGLE LOWERCASE CHARACTER
                    $newVal += [char](97..122 | Get-Random)
                }
                Write-Debug -Message ("REPLACING " + $curVal[$i] + " WITH " + $newVal[-1])
            }
            Write-Debug -Message ("newVal = " + $newVal)
            # NEED TO REPLACE VALUE IN TAG WITH newVal
			$_.InnerText = $newVal
        }
    }
	IF ($excludedVal -is [Array]) {
		$totalExclusions = $excludedVal.Length
		$curIndex = 0
	    $curXML.SelectNodes($exclude) | Foreach-Object {
	        $_.InnerText = $excludedVal[$curIndex]
			$curIndex++
	    }
	}
	ELSEIF ($Exclude) {
		$curXML.SelectNodes($exclude) | Foreach-Object {
	    $_.InnerText = $excludedVal
	    }
	}
    $curXML.Save($Path2XML)
}