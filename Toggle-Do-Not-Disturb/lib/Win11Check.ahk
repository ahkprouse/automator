Win11Check()
{
	if GetWinNum() = 'W11'
		return true
	else
		return false
}

GetWinNum()
{
 	build := RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'CurrentBuild')
	if build > 20000
		return 'W11'
	else if build > 19000
		return 'W10'
	else if build > 10000
		return 'W8'
	else if build > 6000
		return 'W7'
	else if build > 5000
		return 'WXP'
	else
		return 'W2K'
}