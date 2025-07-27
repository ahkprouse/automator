#Include .\lib\Native.ahk

class JSON {
    static __New() {

        loop files, A_ScriptDir '\*ahk-json.dll', 'FDR'
            dstPath := A_LoopFileFullPath
        else
            throw OSError( 'JSON library not found (ahk-json.dll)', A_ThisFunc)

        Native.LoadModule(dstPath, ['JSON'])
        ; this.DefineProp('true', {value: 1})
        ; this.DefineProp('false', {value: 0})
        ; this.DefineProp('null', {value: ''})
    }

    /**
     *
     * @param {String} str
     * @returns {Object}
     */
    static parse(str) => 1

    /**
     *
     * @param   {Object} obj
     * @param   {Any}    space
     * @returns {String} JSON String
     */
    static stringify(obj, space := 0) => 1
}