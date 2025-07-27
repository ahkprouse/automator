for objItem in ComObjGet("winmgmts:\\.\root\CIMV2").ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")
{
    if (objItem.IPAddress[0] = A_IPAddress1)
    {
        MsgBox, % "Description:`t" objItem.Description[0] "`n"
                . "IPAddress:`t`t" objItem.IPAddress[0] "`n"
                . "IPSubnet:`t`t" objItem.IPSubnet[0] "`n"
                . "DefaultIPGateway:`t" objItem.DefaultIPGateway[0] "`n"
                . "DNS-Server:`t" (objItem.DNSServerSearchOrder[1] = "") ? objItem.DNSServerSearchOrder[0] : objItem.DNSServerSearchOrder[0] ", " objItem.DNSServerSearchOrder[1] "`n"
                . "MACAddress:`t" objItem.MACAddress "`n"
                . "DHCPEnabled:`t" (objItem.DHCPEnabled[0] ? "No" : "Yes") "`n"
    }
}