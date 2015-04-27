import os
import glob
import sys

obstruents = {'b':'B', 'd':'D', 'g':'G'}
nasals = ['m', 'n', 'N']
# Vocales
vowels = ['a', 'e', 'i', 'o', 'u']
# Semivocales
semivowels = ['%', '#', '@', '$', '&', '!', '*', '+', '-', '3']
# Voiced consonants
voiced = ['b', 'B', 'd', 'D', 'g', 'G', 'm', 'n', 'N', '|', 'J', 'r', 'R']

# Track the number of utterances
numUtterances = 0
# Track the number of words
numWords = 0
#wordsPerUtterance = []
phonemesPerWord = []

def interVocalicRules(sent):
    newSent = sent
    
    # Create all the dipthongs that occur between words
    newSent = newSent.replace('a i', '- ')
    newSent = newSent.replace('a u', '+ ')
    # Do I indicate vowel lengthening?
    newSent = newSent.replace('a a', 'aa ')
    newSent = newSent.replace('e i', '* ')
    newSent = newSent.replace('e e', 'ee ')
    newSent = newSent.replace('i a', '% ')
    newSent = newSent.replace('i e', '# ')
    newSent = newSent.replace('i o', '@ ')
    newSent = newSent.replace('i i', 'ii ')
    newSent = newSent.replace('o i', '3 ')
    newSent = newSent.replace('o o', 'oo ')
    # This is not a dipthong replacement but it still needs to happen:
    # lo ultimo = [lultimo]
    newSent = newSent.replace('o u', 'u ')
    newSent = newSent.replace('u a', '& ')
    newSent = newSent.replace('u e', '$ ')
    newSent = newSent.replace('u i', '! ')
    newSent = newSent.replace('u u', 'uu ')
    
    # Turn b/d/g's into B/D/G's where appropriate
    strList = list(newSent)
    i = 0
    prev = None
    for symbol in strList:
        if symbol in obstruents:
            if not prev or prev in nasals:
                i += 1
                continue
            else:
                strList[i] = obstruents[symbol]
        if symbol in voiced:
            if prev == 's':
                strList[i-1] = 'z'
        prev = symbol
        i += 1
    newSent = "".join(strList)
    
    return newSent

def sententialRules(sentence):
    # Apply rules between words, like when a [b] occurs between vowels, turn it into a [B]
    # Vowels together.. a aser = aser
    # Apply rule for two vowels being together.. si aqui = s(ia dipthong)ki...
    
    # Split the sentence into chunks based on pauses.
    # This distinction exists because:
    
    chunks = sentence.split('[/]')
    # This has to be done here because I allow [/] to be remain up until this point
    # for the purpose of knowing where boundaries occur, but we don't want to count [/]

    newChunkList = []
    for chunk in chunks:
        #wordsPerUtterance.append(len(chunk.split()))
        globals()["numWords"] += len(chunk.split())
        
        newChunk = interVocalicRules(chunk)
        print newChunk
                      
        newChunkList.append(newChunk)
        
    return newChunkList   

def main():
    dictFile = "Spanish/dicts/dict_converted.txt"
    
    file = open(dictFile, 'r')
    lines = file.readlines()
    file.close()
    
    # Word bank is a dictionary - lookup by its key retrieves its IPA translation
    word = {}
    
    # Split by whitespace since that's how it's set up
    for line in lines:
        x = line.split()
        word[x[0].lower()] = x[1]

    keyErrors = open("Spanish/dicts/keyErrors_Morph.txt", "w")
    outFile = open("Spanish/morphology_Spanish.txt", 'w')
    
    for fileName in ['Spanish/morphology_Spanish_ortho.txt']:
        print fileName
        file = open(fileName, 'r')
        lines = file.readlines()
        file.close()
        
        for line in lines:
            print 'Original line: ' + line
            # Split on pauses to separate utterances and count them
            #numUtterances += len(line.split('[/]'))
            # Split the sentence into individual words
            words = line.split()
            # Build the IPA-translated sentence
            ipaSentence = ""

            # Look up individual words
            for x in words[1:]:
                # Ignore punctuation
                if x == '.' or x == '?' or x == '!':
                    continue
                    
                try:
                    ipaSentence += word[x.lower()]
                    ipaSentence += " "
                except KeyError:
                    keyErrors.write("KeyError with: " + x.lower() + "\n")
                    continue
                
            newChunks = sententialRules(ipaSentence)
            ipaSentence = ""
                
            for chunk in newChunks:
                ipaSentence += chunk
                ipaSentence += " "
                
            newChunks = ipaSentence.split()
            ipaSentence = ""
            for chunk in newChunks:
                ipaSentence += chunk
                ipaSentence += " "
            # Remove trailing whitespace
            ipaSentence = ipaSentence.rstrip()
            # Calculate phonemes per word
            ipaWords = ipaSentence.split()
            phonemesInWord = 0
            for ipaWord in ipaWords:
                phonemesInWord += len(ipaWord)
            # Number of original words is the length of the "words" variable beyond the first
            # part that indicates the speaker(i.e. *INV:)

               
            print ipaSentence
            if len(ipaSentence) >= 0:
                outFile.write(ipaSentence + '\n')
                globals()["numUtterances"] += 1
            #file.write(ipaSentence + '\n')

        #file.close()
    outFile.close()
    keyErrors.close()
    
    
if __name__ == "__main__":
    main()
    
