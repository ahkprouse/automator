main := Default()
main.SetFont('s14')

edtWidth := 300
main.AddEdit('vItem w' edtWidth)
main.AddEdit('vLocation w' edtWidth)
main.AddEdit('vPrice x+m w' edtWidth)
main.AddEdit('vMake xm w' edtWidth)
main.AddEdit('vModel x+m w' edtWidth)
main.AddEdit('vSerialNo xm w' edtWidth)
main.AddEdit('vPurchaseDate x+m w' edtWidth)
main.AddEdit('vNotes xm w' edtWidth*2+main.MarginX ' r20').Focus()

for cue in ['PurchaseDate', 'Item','Price','Make','Model','SerialNo','Location']
	SetCueBanner(main[cue], cue)

pic := main.AddPic('ym w' edtWidth*2 ' r20 Border', '')
lv := main.AddListView('w' edtWidth*2 ' r5', ['Img Path'])

main.AddButton('w75 x+-' 75*2 + main.MarginX ' y+m', 'OK').OnEvent('Click', (*)=>main.TransferToExcel())
main.AddButton('w75 x+m', 'Cancel').OnEvent('Click', (*)=>main.Reset())

class Default extends Gui {
	id := 0

	Show(opts?)
	{
		this.id := DateDiff(A_Now, '19700101000000', 's')
		this.name := 'Item: ' this.id
		super.Show(opts??'')
	}

	Reset()
	{
		this.Hide()
		this.id := 0
		for ctrl in this
		{
			switch ctrl.type
			{
			case 'ListView':
				ctrl.Delete()
			case 'Edit':
				ctrl.value := ''
			default:
				continue
			}
		}
	}

	TransferToExcel()
	{
		if !this['Item'].value
			return MsgBox('Item is a required field.', 'Error', 'IconX OK')
		if !this['Location'].value
			return MsgBox('Location is a required field.', 'Error', 'IconX OK')

		date := FormatTime(A_Now, 'yyyy-MM-dd')

		last_row := xl.Cells.Find("*",,,,1,2).Row
		last_row++

		loop lv.GetCount()
		{

			xl.Range('A' last_row).Value := this.id
			xl.Range('B' last_row).Value := lv.GetText(A_Index, 1)

			if A_Index = 1
			{
				xl.Range('C' last_row).Value := this['Item'].value
				xl.Range('D' last_row).Value := this['Price'].value
				xl.Range('E' last_row).Value := this['Make'].value
				xl.Range('F' last_row).Value := this['Model'].value
				xl.Range('G' last_row).Value := this['SerialNo'].value
				xl.Range('H' last_row).Value := this['Location'].value
				xl.Range('I' last_row).Value := this['Notes'].value
				xl.Range('J' last_row).Value := this['PurchaseDate'].value
				xl.Range('K' last_row).Value := date
			}
			last_row++
		}

		this.Reset()
	}
}