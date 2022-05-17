import unicode, algorithm, strutils, sequtils

# define a type that contains every possible form of a character. 
type
    Letter = object
        standard: string
        isolated: string
        final: string # sticking to the next letter from left
        initial: string # sticking to the next letter from right
        medial: string # sticking to the next and previous letter from both sides
        prev_connect: bool # this is for check if this letter can stick to the previous letter
        next_connect: bool # this is for check if this letter can stick to the next letter

var
    harf_list: seq[Letter] # it contains all letters
    twoForm: seq[string] = @["\uFEFB", "\uFEF9", "\uFEF7", "\uFEF5", "\u0622", "\u0623", "\u0624", "\u0625",
"\u0627", "\u062F", "\u0630", "\u0631", "\u0632", "\u0648", "\u0629", "\u0649",
  "\u0698"] # letters with only two shapes
    fourForm: seq[string] = @["\u0626", "\u0628", "\u062A", "\u062B", "\u062C", "\u062D", "\u062E", "\u0633",
  "\u0634", "\u0635", "\u0636", "\u0637", "\u0638", "\u0639", "\u063A", "\u0641","\u0642", "\u0643", "\u0644", "\u0645", "\u0646", "\u0647", "\u064A", "\u06cc",
    "\u06a9", "\u067e", "\u06af", "\u0686"] # letters with four shapes
    bracket_standard: string =  "([{"
    bracket_mirror: string = ")]}"
    allForms = concat(twoForm, fourForm) # contains standard version of all letters in string format
    
proc seq_find(list: seq, target: string): int = # finds target position inside a sequence of letters
    for i,c in list:
        if c.standard == target:
            return i
    return -1

proc next(x:string): string = # this is for finding true shape of a letter
    # ord(x) prints number related to a character x 
    # Rune(x) prints string related to the number x
    # toRunes(x) converts string x into Rune x,  which is an array
    return $(Rune( ord(toRunes(x)[0])+1 ))
    
proc add_form(standard,  isolated: string) = # filling harf_list with true shapes of letters
    var harf: Letter
    harf.standard = standard
    harf.isolated = isolated
    if standard in twoForm:
        harf.final = next(isolated)
        harf.initial = isolated
        harf.medial = harf.final
        harf.prev_connect = true
        harf.next_connect = false
    elif standard in fourForm: 
        harf.final = next(isolated)
        harf.initial = next(harf.final)
        harf.medial = next(harf.initial)
        harf.prev_connect = true
        harf.next_connect = true
    else:
        harf.final = standard
        harf.initial = standard
        harf.medial = standard
        harf.prev_connect = false
        harf.next_connect = false

    harf_list.add(harf)

proc trueShape(prv, harf, nex:Letter): string = # returns true shape that a character should have inside a word
    var
        next_connection = harf.next_connect and nex.prev_connect
        prev_connection = harf.prev_connect and prv.next_connect
    if next_connection and prev_connection: return harf.medial
    elif next_connection and not prev_connection: return harf.initial
    elif prev_connection and not next_connection: return harf.final
    else: return harf.isolated

proc br_mirror(word:string):string = # this is for swapping brackets
    var 
        new_word = ""
        j1, j2: int
    for i,c in word:
        j1 = strutils.rfind(bracket_standard,c)
        j2 = strutils.rfind(bracket_mirror,c)
        if j1 != -1 and j2 == -1:
            new_word = new_word & bracket_mirror[j1]
        elif j2 != -1 and j1 == -1:
            new_word = new_word & bracket_standard[j2]
        else:
            new_word = new_word & c
    return new_word

proc str2uni_word(word: string): string = # returns true shape of a complete word
    var
        uni = ""
        prv, harf, nex: int
        wordRune = toRunes(word)
    wordRune = wordRune.reversed
    for i,c in wordRune:
        harf = seq_find(harf_list,$(c))
        if harf == -1:
            uni = uni & $(c)
        else:
            if i == wordRune.len - 1:
                prv = seq_find(harf_list,"")
                nex = seq_find(harf_list,$(wordRune[i-1]))
            elif i == 0:
                prv = seq_find(harf_list,$(wordRune[i+1]))
                nex = seq_find(harf_list,"")
            else:
                prv = seq_find(harf_list,$(wordRune[i+1]))
                nex = seq_find(harf_list,$(wordRune[i-1]))
            if prv != -1 and nex != -1:
                uni = uni & trueShape(harf_list[prv], harf_list[harf], harf_list[nex] )
            else:
                uni = uni & harf_list[harf].standard
    return uni

proc hasLetter(word: string , subset: seq): bool = # check if the word has at least one letter from harf_list
    for i,c in subset:
        if word.find(c) != -1:
            return true
    return false

proc str2uni*(line:string): string = # returns true shape of a whole line
    var
        uni: string = ""
        new_line: string = br_mirror(line)
        word_seq: seq = new_line.split(" ")
        new_word: string
    word_seq = word_seq.reversed
    for word in word_seq:
        if word.hasLetter(allForms) :
            uni = uni & " " & str2uni_word(word)
        else:
            var 
                word_sec: seq[string]
                tmp = ""
                new_sec: bool = false
            for i,c in word:
                if c.isDigit:
                    if not new_sec:
                        word_sec.add(tmp)
                        tmp = ""
                    new_sec = true
                else:
                    if not i in @[0,word.len - 1]:
                        if c == '.' and word[i-1].isDigit and word[i+1].isDigit:
                            new_sec = true
                        else:
                            new_sec = false
                tmp = tmp & c
            word_sec.add(tmp)
            word_sec = word_sec.reversed
            for n in word_sec:
                new_word = n.reversed
                uni = uni & " " & str2uni_word(new_word)
    return uni

add_form("", "")
add_form("\uFEFB",  "\uFEFB")
add_form("\uFEF9",  "\uFEF9")
add_form("\uFEF7",  "\uFEF7")
add_form("\uFEF5",  "\uFEF5")
# Hamza groups
add_form("\u0622",  "\uFE81")
add_form("\u0623",  "\uFE83")
add_form("\u0624",  "\uFE85")
add_form("\u0625",  "\uFE87")
add_form("\u0626",  "\uFE89")
# Main letters
add_form("\u0627",  "\uFE8D")
add_form("\u0628",  "\uFE8F")
add_form("\u062A",  "\uFE95")
add_form("\u062B",  "\uFE99")
add_form("\u062C",  "\uFE9D")
add_form("\u062D",  "\uFEA1")
add_form("\u062E",  "\uFEA5")
add_form("\u062F",  "\uFEA9")
add_form("\u0630",  "\uFEAB")
add_form("\u0631",  "\uFEAD")
add_form("\u0632",  "\uFEAF")
add_form("\u0633",  "\uFEB1")
add_form("\u0634",  "\uFEB5")
add_form("\u0635",  "\uFEB9")
add_form("\u0636",  "\uFEBD")
add_form("\u0637",  "\uFEC1")
add_form("\u0638",  "\uFEC5")
add_form("\u0639",  "\uFEC9")
add_form("\u063A",  "\uFECD")
add_form("\u0641",  "\uFED1")
add_form("\u0642",  "\uFED5")
add_form("\u0643",  "\uFED9")
add_form("\u0644",  "\uFEDD")
add_form("\u0645",  "\uFEE1")
add_form("\u0646",  "\uFEE5")
add_form("\u0647",  "\uFEE9")
add_form("\u0648",  "\uFEED")
add_form("\u064A",  "\uFEF1")
# Letters that are not directly in the alphabet
add_form("\u0629",  "\uFE93")
add_form("\u0649",  "\uFEEF")
# tatweel
#add_form("\u0640",  "\u0640",  "\u0640",  "\u0640",  "\u0640",  True,  True)

# persian support
add_form("\u06cc",  "\uFEF1") # ی
add_form("\u06a9",  "\uFB8E") # ک
add_form("\u067e",  "\uFB56") # پ
add_form("\u0698",  "\uFB8A") # ژ
add_form("\u06af",  "\uFB92") # گ
add_form("\u0686",  "\uFB7A") # چ


