AutoCloseBraces=EventClass:new(Common)
  --------------------------------------------------------------------------------
  -- OnChar(charAdded)
  --
  -- AutoComplete Braces and Qoutes.
  --https://www.autoitscript.com/forum/topic/67008-solved-autoclosebraceslua-for-scite/
  -- Parameters:
  --    charAdded - The character typed.
  --------------------------------------------------------------------------------
  
function AutoCloseBraces:OnChar(charAdded)
  --    trace(charAdded)
      local toClose = { ['('] = ')', ['{'] = '}', ['['] = ']', ['"'] = '"', ["'"] = "'" }
  
      if toClose[charAdded] ~= nil then
          local pos = editor.CurrentPos
          editor:ReplaceSel(toClose[charAdded])
          editor:SetSel(pos, pos)
      end
      return false  -- Let next handler to process event
 --    return true  -- Don't let next handler to process event
end