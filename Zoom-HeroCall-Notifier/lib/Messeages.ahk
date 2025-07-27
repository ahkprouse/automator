GetMsg(SchTime)
{
    link := '<a href="http://the-Automator.com/AHKHeroMember?src=Reminder" >Hero call</a>'
    Msg := [
    'Attention all programming enthusiasts!`nThe Hero Call is scheduled to begin in just ' SchTime '. Please join the ' Link ' on time.',
    'Do not forget!`nThe Hero Call is scheduled to start in just ' SchTime '.`nWe hope to see you there! ' Link '',
    'The Hero Call is just ' SchTime ' away.`nPlease make sure to join the call on time`n ' Link '',
    'The Hero Call is scheduled to start in just ' SchTime '.`nWe look forward to seeing you there ' Link '' ,
    'Get ready! The Hero Call is just ' SchTime ' away. `nPlease join the call on time ' Link '',
    'The Hero Call is scheduled to start in just ' SchTime '.`nPlease Join click here ' Link '.',
    'The Hero Call is just ' SchTime '.`nPlease join the call and learn togather ' Link '.',
    'The Hero Call is scheduled to start in just ' SchTime '.`nPlease join us on Zoom ' Link '.' ,
    'The Hero Call is just ' SchTime ' away.`nPlease join us and learning some programming tips ' Link '.'  ,
    'The Hero Call is scheduled to start in just ' SchTime '.`nPlease ensure that you have a comfortable seat and a beverage of your choice ' Link '.' ,
    ]
    return msg[Random(1,10)]

}


GetMsgNoLink(SchTime)
{
    link := '<a href="http://the-Automator.com/AHKHeroMember?src=Reminder" >Hero call</a>'
    Msg := [
    'Attention all programming enthusiasts!`nThe Hero Call is scheduled to begin in just ' SchTime '.',
    'Do not forget!`nThe Hero Call is scheduled to start in just ' SchTime '.`nWe hope to see you there!',
    'The Hero Call is just ' SchTime ' away.`nPlease make sure to join the call on time',
    'The Hero Call is scheduled to start in just ' SchTime '.`nWe look forward to seeing you there',
    'Get ready! The Hero Call is just ' SchTime ' away. `nPlease join the call on time',
    'The Hero Call is scheduled to start in just ' SchTime '.',
    'The Hero Call is just ' SchTime '.`nPlease join the call and learn togather.',
    'The Hero Call is scheduled to start in just ' SchTime '.`nPlease join us on Zoom.' ,
    'The Hero Call is just ' SchTime ' away.`nPlease join us and learning some programming tips ' Link '.'  ,
    'The Hero Call is scheduled to start in just ' SchTime '.`nPlease ensure that you have a comfortable seat and a beverage of your choice ' Link '.' ,
    ]
    return msg[Random(1,10)]
}