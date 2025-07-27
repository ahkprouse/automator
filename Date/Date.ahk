dates :=
(
	"June 15th '23
	'23 15 June
	15th June, 2023
	March 3rd, '24
	'24 March 3
	3rd of March, 2024
	March 15, '23
	2023 June 15th
	3 March '24
	15th of June, 2023
	'23 March 15
	June 3rd, 2024
	15th '23 June
	March 15th, '23
	'24 3rd March
	15 June, '23
	2024 March 3rd
	3rd March, '24
	June '23 15th
	15th of March, 2024"
)


for dt in StrSplit(dates, '`n', '`r')
	OutputDebug Date.Parse(dt, 'MM/dd/yyyy') '->' dt '`n'

class Date
{
	static Parse(str, dtFormat:='yyyy-MM-dd')
	{
		local matched
		static regex :=
		(
			"ixS)(?(DEFINE)
			(?<df_day>(?<!')\d{1,2})
			(?:(?<df_month>jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\w*)
			(?<df_year>(?<=')?\d{4}|(?<=')\d{2})
			`)
			^(?=.*?\b(?<day>(?&df_day))(?:st|nd|rd|th)?\b)
			(?=.*?(?<month>(?&df_month)))
			(?=.*?(?<year>(?&df_year))).*$"
		)
		static month := Map(
			'jan', '01',
			'feb', '02',
			'mar', '03',
			'apr', '04',
			'may', '05',
			'jun', '06',
			'jul', '07',
			'aug', '08',
			'sep', '09',
			'oct', '10',
			'nov', '11',
			'dec', '12'
		)

		if !RegExMatch(str, regex, &matched)
			return str
		
		date := (StrLen(matched.year) = 2 ? 20 . matched.year : matched.year)
		       . month[StrLower(matched.month)]
		       . Format('{:02d}', matched.day)

		fmt_date := FormatTime(date, dtFormat)
		return fmt_date ? fmt_date : str
	}
}