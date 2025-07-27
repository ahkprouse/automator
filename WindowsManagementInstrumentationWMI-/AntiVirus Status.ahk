for objItem in ComObjGet("winmgmts:\\.\root\SecurityCenter2").ExecQuery("SELECT * FROM AntiVirusProduct")
    MsgBox, % "AntiVirus:`t`t" . objItem.displayName . "`n"
            . "Guid:`t`t" . objItem.instanceGuid . "`n"
            . "ProductExe:`t" . objItem.pathToSignedProductExe . "`n"
            . "ReportingExe:`t" . objItem.pathToSignedReportingExe . "`n"
            . "RealTimeProtection:`t" . ((SubStr(DecTo(objItem.productState, 16), 3, 2) = 10) ? "Enabled" : "Disabled") "`n"
            . "VirusDefUpdate:`t" . ((SubStr(DecTo(objItem.productState, 16), 5, 2) = 00) ? "Up to Date" : "Out of Date")

DecTo(n, to)
{
	hex := "0123456789ABCDEF"
	while (n > 0)
	{
		rem := mod(n, to)
		n /= to
		y := SubStr(hex, rem + 1, 1)
		result = %y%%result%
	}
	return, "0" . result
}