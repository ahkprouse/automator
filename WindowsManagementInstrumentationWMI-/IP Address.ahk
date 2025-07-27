IPA := IPAddress()
MsgBox, % "Description:`t"      IPA[1] "`n"
        . "IPAddress:`t`t"      IPA[2] "`n"
        . "IPSubnet:`t`t"       IPA[3] "`n"
        . "DefaultIPGateway:`t" IPA[4] "`n"
        . "DNS-Server:`t"       IPA[5] "`n"
        . "MACAddress:`t"       IPA[6] "`n"
        . "DHCPEnabled:`t"      IPA[7] "`n" 

IPAddress()
{
	for objItem in ComObjGet("winmgmts:\\.\root\CIMV2").ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")
	{
		if (objItem.IPAddress[0] = A_IPAddress1)
		{
			return, % { 1 : objItem.Description[0], 2 : objItem.IPAddress[0], 3 : objItem.IPSubnet[0], 4 : objItem.DefaultIPGateway[0]
                      , 5 : ((objItem.DNSServerSearchOrder[1] = "") ? objItem.DNSServerSearchOrder[0] : objItem.DNSServerSearchOrder[0] ", " objItem.DNSServerSearchOrder[1])
                      , 6 : objItem.MACAddress, 7 : (objItem.DHCPEnabled[0] ? "No" : "Yes") }
		}
	}
}