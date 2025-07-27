; Want a clear path for learning AutoHotkey? Go to https://the-Automator.com/Learn
; based on SKAN's v1 orginal version https://www.autohotkey.com/r?p=252539
; Converted by Xeo786, the-Automator
#SingleInstance
#Requires Autohotkey v2.0+
/**
 *
 * @param fpath
 * @param {"Name"|"Size"|"Item type"|"Date modified"|"Date created"|"Date accessed"
 * |"Attributes"|"Offline status"|"Availability"|"Perceived type"|"Owner"|"Kind"
 * |"Date taken"|"Contributing artists"|"Album"|"Year"|"Genre"|"Conductors"|"Tags"
 * |"Rating"|"Authors"|"Title"|"Subject"|"Categories"|"Comments"|"Copyright"|"#"
 * |"Length"|"Bit rate"|"Protected"|"Camera model"|"Dimensions"|"Camera maker"
 * |"Company"|"File description"|"Masters keywords"|"Masters keywords"|"Program name"
 * |"Duration"|"Is online"|"Is recurring"|"Location"|"Optional attendee addresses"
 * |"Optional attendees"|"Organizer address"|"Organizer name"|"Reminder time"
 * |"Required attendee addresses"|"Required attendees"|"Resources"|"Meeting status"
 * |"Free/busy status"|"Total size"|"Account name"|"Task status"|"Computer"
 * |"Anniversary"|"Assistant's name"|"Assistant's phone"|"Birthday"|"Business address"
 * |"Business city"|"Business country/region"|"Business P.O. box"|"Business postal code"
 * |"Business state or province"|"Business street"|"Business fax"|"Business home page"
 * |"Business phone"|"Callback number"|"Car phone"|"Children"|"Company main phone"
 * |"Department"|"E-mail address"|"E-mail2"|"E-mail3"|"E-mail list"|"E-mail display name"
 * |"File as"|"First name"|"Full name"|"Gender"|"Given name"|"Hobbies"|"Home address"
 * |"Home city"|"Home country/region"|"Home P.O. box"|"Home postal code"|"Home state or province"
 * |"Home street"|"Home fax"|"Home phone"|"IM addresses"|"Initials"|"Job title"|"Label"
 * |"Last name"|"Mailing address"|"Middle name"|"Cell phone"|"Nickname"|"Office location"
 * |"Other address"|"Other city"|"Other country/region"|"Other P.O. box"
 * |"Other postal code"|"Other state or province"|"Other street"|"Pager"
 * |"Personal title"|"City"|"Country/region"|"P.O. box"|"Postal code"|"State or province"
 * |"Street"|"Primary e-mail"|"Primary phone"|"Profession"|"Spouse/Partner"|"Suffix"
 * |"TTY/TTD phone"|"Telex"|"Webpage"|"Content status"|"Content type"|"Date acquired"
 * |"Date archived"|"Date completed"|"Device category"|"Connected"|"Discovery method"
 * |"Friendly name"|"Local computer"|"Manufacturer"|"Model"|"Paired"|"Classification"
 * |"Status"|"Status"|"Client ID"|"Contributors"|"Content created"|"Last printed"
 * |"Date last saved"|"Division"|"Document ID"|"Pages"|"Slides"|"Total editing time"
 * |"Word count"|"Due date"|"End date"|"File count"|"File extension"|"Filename"
 * |"File version"|"Flag color"|"Flag status"|"Space free"|"Group"|"Sharing type"
 * |"Bit depth"|"Horizontal resolution"|"Width"|"Vertical resolution"|"Height"
 * |"Importance"|"Is attachment"|"Is deleted"|"Encryption status"|"Has flag"|"Is completed"
 * |"Incomplete"|"Read status"|"Shared"|"Creators"|"Date"|"Folder name"
 * |"File location"|"Folder"|"Participants"|"Path"|"By location"|"Type"|"Contact names"
 * |"Entry type"|"Language"|"Date visited"|"Description"|"Link status"|"Link target"
 * |"URL"|"Media created"|"Date released"|"Encoded by"|"Episode number"|"Producers"
 * |"Publisher"|"Season number"|"Subtitle"|"User web URL"|"Writers"|"Attachments"
 * |"Bcc addresses"|"Bcc"|"Cc addresses"|"Cc"|"Conversation ID"|"Date received"
 * |"Date sent"|"From addresses"|"From"|"Has attachments"|"Sender address"
 * |"Sender name"|"Store"|"To addresses"|"To do title"|"To"|"Mileage"|"Album artist"
 * |"Sort album artist"|"Album ID"|"Sort album"|"Sort contributing artists"
 * |"Beats-per-minute"|"Composers"|"Sort composer"|"Disc"|"Initial key"
 * |"Part of a compilation"|"Mood"|"Part of set"|"Period"|"Color"|"Parental rating"
 * |"Parental rating reason"|"Space used"|"EXIF version"|"Event"|"Exposure bias"
 * |"Exposure program"|"Exposure time"|"F-stop"|"Flash mode"|"Focal length"
 * |"35mm focal length"|"ISO speed"|"Lens maker"|"Lens model"|"Light source"
 * |"Max aperture"|"Metering mode"|"Orientation"|"People"|"Program mode"|"Saturation"
 * |"Subject distance"|"White balance"|"Priority"|"Project"|"Channel number"
 * |"Episode name"|"Closed captioning"|"Rerun"|"SAP"|"Broadcast date"|"Program description"
 * |"Recording time"|"Station call sign"|"Station name"|"Summary"|"Snippets"
 * |"Auto summary"|"Relevance"|"File ownership"|"Sensitivity"|"Shared with"
 * |"Sharing status"|"Product name"|"Product version"|"Support link"|"Source"
 * |"Start date"|"Sharing"|"Availability status"|"Status"|"Billing information"
 * |"Complete"|"Task owner"|"Sort title"|"Total file size"|"Legal trademarks"
 * |"Last change author email"|"Last change author name"|"Last change date"
 * |"Last change ID"|"Last change message"|"Version status"|"Video compression"
 * |"Directors"|"Data rate"|"Frame height"|"Frame rate"|"Frame width"|"Spherical"
 * |"Stereo"|"Video orientation"|"Total bitrate"|"Audio tracks"|"Bit depth"
 * |"Contains chapters"|"Content compression"|"Subtitles"|"Subtitle tracks"
 * |"Video tracks"} attr
 * @returns {String}
 */
FileExPro(fpath, attr)
{
	static attr_map := Map()
	static objShl := ComObject("Shell.Application")

	SplitPath fpath, &_FileExt, &_Dir
	objDir := objShl.Namespace(_Dir)
	objItm := objDir.ParseName(_FileExt)

	if attr_map.Count = 0
	{
		empty_values := 0
		loop
		{
			no_more_values := empty_values > 50 ? true : false

			row := A_Index - 1
			attr_map.Set(val := objDir.GetDetailsOf(0, row), row)
			if !val
				empty_values++
			else
				empty_values := 0

		}
		until no_more_values

		attr_map.Delete('')
	}

	if !attr_map.Has(attr)
		return ''

	return detail := objDir.GetDetailsOf(objItm, attr_map[attr])
}

/**
 * 
 * @param {String}
 * @returns {Map} 
 */
FileExProAll(fpath)
{
	static attr_map := Map()
	static objShl := ComObject("Shell.Application")

	SplitPath fpath, &_FileExt, &_Dir
	objDir := objShl.Namespace(_Dir)
	objItm := objDir.ParseName(_FileExt)
	if attr_map.Count = 0
	{
		empty_values := 0
		loop
		{
			no_more_values := empty_values > 50 ? true : false

			row := A_Index - 1
			attr_map.Set(val := objDir.GetDetailsOf(0, row), row)
			if !val
				empty_values++
			else
				empty_values := 0

		}
		until no_more_values

		attr_map.Delete('')
	}
	allprop := Map()
	for PropName,PropNum in attr_map {
		Value := objDir.GetDetailsOf(objItm, PropNum)
		if value
			allprop[PropName] := Value
	}
	return allprop
}


; inlcludeFilexPro()
; {
; 	return '
; 	(	
; /**
;  *
;  * @param fpath
;  * @param {"Name"|"Size"|"Item type"|"Date modified"|"Date created"|"Date accessed"
;  * |"Attributes"|"Offline status"|"Availability"|"Perceived type"|"Owner"|"Kind"
;  * |"Date taken"|"Contributing artists"|"Album"|"Year"|"Genre"|"Conductors"|"Tags"
;  * |"Rating"|"Authors"|"Title"|"Subject"|"Categories"|"Comments"|"Copyright"|"#"
;  * |"Length"|"Bit rate"|"Protected"|"Camera model"|"Dimensions"|"Camera maker"
;  * |"Company"|"File description"|"Masters keywords"|"Masters keywords"|"Program name"
;  * |"Duration"|"Is online"|"Is recurring"|"Location"|"Optional attendee addresses"
;  * |"Optional attendees"|"Organizer address"|"Organizer name"|"Reminder time"
;  * |"Required attendee addresses"|"Required attendees"|"Resources"|"Meeting status"
;  * |"Free/busy status"|"Total size"|"Account name"|"Task status"|"Computer"
;  * |"Anniversary"|"Assistant's name"|"Assistant's phone"|"Birthday"|"Business address"
;  * |"Business city"|"Business country/region"|"Business P.O. box"|"Business postal code"
;  * |"Business state or province"|"Business street"|"Business fax"|"Business home page"
;  * |"Business phone"|"Callback number"|"Car phone"|"Children"|"Company main phone"
;  * |"Department"|"E-mail address"|"E-mail2"|"E-mail3"|"E-mail list"|"E-mail display name"
;  * |"File as"|"First name"|"Full name"|"Gender"|"Given name"|"Hobbies"|"Home address"
;  * |"Home city"|"Home country/region"|"Home P.O. box"|"Home postal code"|"Home state or province"
;  * |"Home street"|"Home fax"|"Home phone"|"IM addresses"|"Initials"|"Job title"|"Label"
;  * |"Last name"|"Mailing address"|"Middle name"|"Cell phone"|"Nickname"|"Office location"
;  * |"Other address"|"Other city"|"Other country/region"|"Other P.O. box"
;  * |"Other postal code"|"Other state or province"|"Other street"|"Pager"
;  * |"Personal title"|"City"|"Country/region"|"P.O. box"|"Postal code"|"State or province"
;  * |"Street"|"Primary e-mail"|"Primary phone"|"Profession"|"Spouse/Partner"|"Suffix"
;  * |"TTY/TTD phone"|"Telex"|"Webpage"|"Content status"|"Content type"|"Date acquired"
;  * |"Date archived"|"Date completed"|"Device category"|"Connected"|"Discovery method"
;  * |"Friendly name"|"Local computer"|"Manufacturer"|"Model"|"Paired"|"Classification"
;  * |"Status"|"Status"|"Client ID"|"Contributors"|"Content created"|"Last printed"
;  * |"Date last saved"|"Division"|"Document ID"|"Pages"|"Slides"|"Total editing time"
;  * |"Word count"|"Due date"|"End date"|"File count"|"File extension"|"Filename"
;  * |"File version"|"Flag color"|"Flag status"|"Space free"|"Group"|"Sharing type"
;  * |"Bit depth"|"Horizontal resolution"|"Width"|"Vertical resolution"|"Height"
;  * |"Importance"|"Is attachment"|"Is deleted"|"Encryption status"|"Has flag"|"Is completed"
;  * |"Incomplete"|"Read status"|"Shared"|"Creators"|"Date"|"Folder name"
;  * |"File location"|"Folder"|"Participants"|"Path"|"By location"|"Type"|"Contact names"
;  * |"Entry type"|"Language"|"Date visited"|"Description"|"Link status"|"Link target"
;  * |"URL"|"Media created"|"Date released"|"Encoded by"|"Episode number"|"Producers"
;  * |"Publisher"|"Season number"|"Subtitle"|"User web URL"|"Writers"|"Attachments"
;  * |"Bcc addresses"|"Bcc"|"Cc addresses"|"Cc"|"Conversation ID"|"Date received"
;  * |"Date sent"|"From addresses"|"From"|"Has attachments"|"Sender address"
;  * |"Sender name"|"Store"|"To addresses"|"To do title"|"To"|"Mileage"|"Album artist"
;  * |"Sort album artist"|"Album ID"|"Sort album"|"Sort contributing artists"
;  * |"Beats-per-minute"|"Composers"|"Sort composer"|"Disc"|"Initial key"
;  * |"Part of a compilation"|"Mood"|"Part of set"|"Period"|"Color"|"Parental rating"
;  * |"Parental rating reason"|"Space used"|"EXIF version"|"Event"|"Exposure bias"
;  * |"Exposure program"|"Exposure time"|"F-stop"|"Flash mode"|"Focal length"
;  * |"35mm focal length"|"ISO speed"|"Lens maker"|"Lens model"|"Light source"
;  * |"Max aperture"|"Metering mode"|"Orientation"|"People"|"Program mode"|"Saturation"
;  * |"Subject distance"|"White balance"|"Priority"|"Project"|"Channel number"
;  * |"Episode name"|"Closed captioning"|"Rerun"|"SAP"|"Broadcast date"|"Program description"
;  * |"Recording time"|"Station call sign"|"Station name"|"Summary"|"Snippets"
;  * |"Auto summary"|"Relevance"|"File ownership"|"Sensitivity"|"Shared with"
;  * |"Sharing status"|"Product name"|"Product version"|"Support link"|"Source"
;  * |"Start date"|"Sharing"|"Availability status"|"Status"|"Billing information"
;  * |"Complete"|"Task owner"|"Sort title"|"Total file size"|"Legal trademarks"
;  * |"Last change author email"|"Last change author name"|"Last change date"
;  * |"Last change ID"|"Last change message"|"Version status"|"Video compression"
;  * |"Directors"|"Data rate"|"Frame height"|"Frame rate"|"Frame width"|"Spherical"
;  * |"Stereo"|"Video orientation"|"Total bitrate"|"Audio tracks"|"Bit depth"
;  * |"Contains chapters"|"Content compression"|"Subtitles"|"Subtitle tracks"
;  * |"Video tracks"} attr
;  * @returns {String}
;  */
; FileExPro(fpath, attr)
; {
; 	static attr_map := Map()
; 	static objShl := ComObject("Shell.Application")

; 	SplitPath fpath, &_FileExt, &_Dir
; 	objDir := objShl.Namespace(_Dir)
; 	objItm := objDir.ParseName(_FileExt)

; 	if attr_map.Count = 0
; 	{
; 		empty_values := 0
; 		loop
; 		{
; 			no_more_values := empty_values > 50 ? true : false

; 			row := A_Index - 1
; 			attr_map.Set(val := objDir.GetDetailsOf(0, row), row)
; 			if !val
; 				empty_values++
; 			else
; 				empty_values := 0

; 		}
; 		until no_more_values

; 		attr_map.Delete('')
; 	}

; 	if !attr_map.Has(attr)
; 		return ''

; 	return detail := objDir.GetDetailsOf(objItm, attr_map[attr])
; }
; 	)'
; }