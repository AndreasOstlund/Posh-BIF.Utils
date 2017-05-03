﻿# Det funkar inte bra med validateSet och mellanslag i de värden som finns i set'et.
# https://social.technet.microsoft.com/Forums/office/en-US/91d85311-f1a6-4c21-ad9d-f909c468bea2/validateset-and-tab-completion-does-not-work-on-strings-with-spaces?forum=winserverpowershell
# http://stackoverflow.com/questions/30633098/powershell-param-validateset-values-with-spaces-and-tab-completion
# https://social.technet.microsoft.com/Forums/windowsserver/en-US/91d85311-f1a6-4c21-ad9d-f909c468bea2/validateset-and-tab-completion-does-not-work-on-strings-with-spaces?forum=winserverpowershell
#
# Dock verkar det finns några lösningar...
# https://powershell.org/forums/topic/dynamic-parameter-question/#post-22381
# https://powershell.org/forums/topic/cant-get-dynamicparam-to-work-when-set-values-include-commas/
# Bl.a med en custom C#-klass
#
# Den här lösningen använder en C#-klass enl.
# Från https://powershell.org/forums/topic/dynamic-parameter-question/#post-22381

Add-Type @"
    public class DynParamQuotedString {
 
        public DynParamQuotedString(string quotedString) : this(quotedString, "'") {}
        public DynParamQuotedString(string quotedString, string quoteCharacter) {
            OriginalString = quotedString;
            _quoteCharacter = quoteCharacter;
        }

        public string OriginalString { get; set; }
        string _quoteCharacter;

        public override string ToString() {		
            if (OriginalString.Contains(" ")) {
                return string.Format("{1}{0}{1}", OriginalString, _quoteCharacter);
            }
            else {
                return OriginalString;
            }
        }
    }
"@
