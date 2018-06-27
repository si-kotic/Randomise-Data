# XML Data Cleanser

This powershell function will replace all of the data values within an XML file with random strings.  This is so that, when we receive production data from a customer, we can utilise it for testing while removing any sensitive information within.

Characters are switched like-for-like; for example lower case letters are replaced with lower case letters, numbers are replaced with numbers etc.

Dates values are ignored if they are in any of the following formats:
* dd/MM/yyyy
* dd.MM.yyyy
* dd-MM-yyyy

If we find other date formats in which we regularly receive data then this function can be expanded to ignore them too.

## Parameters

### Path2XML

Use this parameters to specify the full path to the file for which you wish to randomise the data.

For example:

```powershell
Randomise-Data -Path2XML "C:\path\to\XML\File.xml"
```

### Exclude

Use this parameter to specify the XPath of an XML Node for which you wish the original data to be retained.  A common use for this would be to retain the criteria value so that the data can continue to be processed by AUTOFORM LN.

For example:

```powershell
Randomise-Data -Path2XML "C:\path\to\XML\File.xml" -Exclude "/Globus/TxnDesc"
```

## Help Manual

A full help manual can be found by running ```Get-Help Randomise-Data``` at the powershell prompt.

## Installation

In order to use the function you must load it into Windows Powerhsell.  To do this, download the file _Randomise-Data.ps1_ from this repository and then run the following at the powershell prompt:

```powershell
. c:\path\to\Randomise-Data.ps1
```