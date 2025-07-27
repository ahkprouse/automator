#Requires AutoHotkey v2.0+
/**
 * ============================================================================ *
 * @Author   : the-automator                                                          *
 * @Homepage : the-automator.com                                               *
 *                                                                             *
 * @Created  : Dec 16, 2024                                                    *
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover       *
 * They're structured in a way to make learning AHK EASY                        *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
 * ============================================================================ *
 */

/*
This work by the-Automator.com is licensed under CC BY 4.0

Attribution — You must give appropriate credit , provide a link to the license,
and indicate if changes were made.
You may do so in any reasonable manner, but not in any way that suggests the licensor
endorses you or your use.
No additional restrictions — You may not apply legal terms or technological measures that
legally restrict others from doing anything the license permits.
*/

/**
 * 
 * @param {Number} number             - the number that you want to format
 * @param {Number} decimal_places     - the number of decimal places to display
 * @param {String} thousand_separator - the separator that you want to use
 * @param {String} decimal_separator  - the decimal separator that you want to use
 * 
 * ### Example usage:
 * ```
    Msgbox ThousandSeparator(1234567)           ; ->  1,234,567       Basic integer formatting
    Msgbox ThousandSeparator(-1234567)          ; -> -1,234,567       Handles negative numbers 
    Msgbox ThousandSeparator(4454641234567.226, 3)       ; ->  1,234,567.89    Preserves decimal points
    Msgbox ThousandSeparator(1234567, A_Space)  ; ->  1 234 567       Works with different separators
 * ```
 */
ThousandSeparator(number, decimal_places := 2, thousand_separator := ",", decimal_separator := '.')
{
    if number is Float
        number := Format('{:.' decimal_places 'f}', number)
    
    part := StrSplit(number, decimal_separator)

    ; Pattern explanation:
    ; (?<=\d)                    # Only match positions after a digit (lookbehind)
    ; (?=                        # Start of lookahead - what comes after must match:
    ;   (\d{3})+                 # One or more groups of exactly 3 digits
    ;   (?!\d)                   # Not followed by another digit (end of number)
    ; )                          # End of lookahead
    part[1] := RegExReplace(part[1], "(?<=\d)(?=(\d{3})+(?!\d))", thousand_separator)

    if !part.Has(2)
        return part[1]
    else
        return part[1] . decimal_separator . part[2]
}