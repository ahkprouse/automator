#Requires AutoHotkey v2.0
ContextMenuTrigger(path, action:="Open") 
{
    static shellapp := ComObject("Shell.Application")
    if FileExist(path)  ~= 'D'
    {
        window := shellapp.NameSpace(path)
        for verb in window.self.Verbs
            if StrReplace(verb.name, '&') = action
                return verb.doit()
    }
    else
    {
        SplitPath path, &file_name,&dir
        window := shellapp.NameSpace(dir)
        for item in  window.items
            if item.name = file_name
                for verb in item.Verbs
                    if StrReplace(verb.name, '&') = action
                        return verb.doit()
    }
}


ContextMenuGet(path)
{
    iverb := ""
    static shellapp := ComObject("Shell.Application")
    if FileExist(path)  ~= 'D'
    {
        window := shellapp.NameSpace(path)
        for verb in window.self.Verbs
            iverb .= verb.name "`n"
    }
    else
    {
        SplitPath path, &file_name,&dir
        window := shellapp.NameSpace(dir)
        for item in  window.items
            if item.name = file_name
                for verb in item.Verbs
                    iverb .= verb.name "`n"
    }

    return strreplace(iverb,"&")
}
