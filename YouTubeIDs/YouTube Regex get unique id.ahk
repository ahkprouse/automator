;**********; See regex example of this here  https://regexr.com/6buqd****************************

;~ ID:=YouTubeVideoID("http://www.youtube.com/?v=hZRggm8RkhM")
YouTubeVideoID(URL){
	RegExMatch(URL,"(\/|%3D|vi=|v=)(?P<ID>[0-9A-z-_]{11})([%#?&/]|$)",YouTube_) 
	If youtube_ID
		return youtube_ID
	else
		return "ID not found"
}

/*;********************URLS it works on***********************************
	http://www.youtube.com/?feature=player_embedded&v=hZRggm8RkhM
	http://www.youtube.com/?v=hZRggm8RkhM
	http://www.youtube.com/attribution_link?a=JdfC0C9V6ZI&u=%2Fwatch%3Fv%3DhZRggm8RkhM%26feature%3Dshare
	http://www.youtube.com/e/hZRggm8RkhM
	http://www.youtube.com/embed/hZRggm8RkhM
	http://www.youtube.com/embed/hZRggm8RkhM?rel=0
	http://www.youtube.com/JoeGlines-Automator#p/u/11/hZRggm8RkhM
	http://www.youtube.com/oembed?url=http%3A//www.youtube.com/watch?v%3DhZRggm8RkhM&format=json
	http://www.youtube.com/user/Scobleizer#p/u/1/hZRggm8RkhM
	http://www.youtube.com/v/hZRggm8RkhM
	http://www.youtube.com/v/hZRggm8RkhM?fs=1&hl=en_US&rel=0
	http://www.youtube.com/v/hZRggm8RkhM?version=3&autohide=1
	http://www.youtube.com/watch?feature=player_embedded&v=hZRggm8RkhM
	http://www.youtube.com/watch?v=hZRggm8RkhM
	http://www.youtube.com/watch?v=hZRggm8RkhM#t=0m10s
	http://www.youtube.com/watch?v=hZRggm8RkhM&feature=channel
	http://www.youtube.com/watch?v=hZRggm8RkhM&feature=feedrec_grec_index
	http://www.youtube.com/watch?v=hZRggm8RkhM&feature=youtu.be
	http://www.youtube.com/watch?v=hZRggm8RkhM&feature=youtube_gdata_player
	http://www.youtube.com/watch?v=hZRggm8RkhM&playnext_from=TL&videos=PL3JprvrxlW25O_tkyCmO77MXEsrxCP3qK&feature=sub
	http://www.youtube.com/ytscreeningroom?v=hZRggm8RkhM
	http://www.youtube-nocookie.com/embed/hZRggm8RkhM?version=3&hl=en_US&rel=0
	http://youtu.be/hZRggm8RkhM
	http://youtu.be/hZRggm8RkhM&feature=channel
	http://youtu.be/hZRggm8RkhM?feature=youtube_gdata_player
	http://youtube.com/?feature=channel&v=hZRggm8RkhM
	http://youtube.com/?v=hZRggm8RkhM&feature=channel
	http://youtube.com/?vi=hZRggm8RkhM&feature=channel
	http://youtube.com/v/hZRggm8RkhM?feature=youtube_gdata_player
	http://youtube.com/vi/hZRggm8RkhM&feature=channel
	http://youtube.com/watch?v=hZRggm8RkhM&feature=channel
	http://youtube.com/watch?v=hZRggm8RkhM&feature=youtube_gdata_player
	http://youtube.com/watch?vi=hZRggm8RkhM&feature=channel
	https://www.youtube.com/attribution_link?a=8g8kPrPIi-ecwIsS&u=/watch%3Fv%3DhZRggm8RkhM%26feature%3Dem-uploademail
	https://www.youtube.com/embed/hZRggm8RkhM?rel=0
	https://www.youtube.com/JoeGlines-Automator#p/a/u/2/hZRggm8RkhM
	https://www.youtube.com/JoeGlines-Automator#p/u/1/hZRggm8RkhM
	https://www.youtube.com/user/JoeGlines#p/a/u/1/hZRggm8RkhM
	https://www.youtube.com/v/hZRggm8RkhM?fs=1&amp;hl=en_US&amp;rel=0
	https://www.youtube.com/watch?v=hZRggm8RkhM
	https://www.youtube.com/watch?v=hZRggm8RkhM#t=0m10s
	https://www.youtube.com/watch?v=hZRggm8RkhM&feature=em-uploademail
	https://www.youtube.com/watch?v=hZRggm8RkhM&feature=feedrec_grec_index
	https://www.youtube.com/watch?v=hZRggm8RkhM&list=PL3JprvrxlW25O_tkyCmO77MXEsrxCP3qK&index=106&shuffle=2655
	https://www.youtube-nocookie.com/embed/hZRggm8RkhM?rel=0
	https://youtu.be/hZRggm8RkhM
	https://youtu.be/hZRggm8RkhM?list=PL3JprvrxlW25O_tkyCmO77MXEsrxCP3qK
	https://youtu.be/hZRggm8RkhM?t=690
*/