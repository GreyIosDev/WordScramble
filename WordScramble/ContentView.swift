//
//  ContentView.swift
//  WordScramble
//
//  Created by Grey  on 28.06.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0 // Track the player's score
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.none)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.green)
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .toolbar {
                            // Add a toolbar button that calls startGame() when tapped
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("New Word"){
                                    startGame()
                                }
                                .foregroundColor(.black)
                            }
                        }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            // Add a Text view to display the player's score
                        Text("Score: \(score)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
        }
        
        
        
    }// Always note that a function is called at the end of the view. But it remains in the struct.
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        guard answer.count > 3 else { return } // Here we Dissallowed answers that aer shorter than 3 letters
        
        guard answer != rootWord else {
               wordError(title: "Same as root word", message: "You can't use the same word as the root word!")
               return
           }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                
                // If we are here everything has worked, so we can exit
                return
            }
        }
        
        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//// Import SwiftUI framework, which is used for building user interfaces in Swift
//import SwiftUI
//
//// Define a new SwiftUI View called ContentView
//struct ContentView: View {
//
//    // Define some State properties to store data that can change during the app's runtime
//    @State private var usedWords = [String]()
//    @State private var rootWord = ""
//    @State private var newWord = ""
//
//    // State properties to handle error messages and alerts
//    @State private var errorTitle = ""
//    @State private var errorMessage = ""
//    @State private var showingError = false
//
//    // The main body of the ContentView
//    var body: some View {
//
//        // Create a NavigationView, which is a container for navigation-related views
//        NavigationView {
//
//            // Create a List view, which displays a scrollable list of items
//            List {
//
//                // Create a section for user input
//                Section {
//
//                    // Add a TextField where the user can enter a word
//                    TextField("Enter your word", text: $newWord)
//                        .textInputAutocapitalization(.none) // Disable auto-capitalization
//                }
//
//                // Create another section to display used words
//                Section {
//
//                    // Use a ForEach loop to iterate through usedWords and display each word
//                    ForEach(usedWords, id: \.self) { word in
//                        HStack {
//                            // Display an image with a circle icon based on the word's character count
//                            Image(systemName: "\(word.count).circle")
//                            Text(word) // Display the word
//                        }
//                    }
//                }
//            }
//
//            // Customize the List with various modifiers
//            .scrollContentBackground(.hidden) // Hide the background when scrolling
//            .background(Color.green) // Set the background color to green
//            .navigationTitle(rootWord) // Set the navigation bar title
//
//            // Add an action when the user submits a word
//            .onSubmit(addNewWord)
//
//            // Perform an action when the view appears on the screen
//            .onAppear(perform: startGame)
//
//            // Display an alert if there's an error
//            .alert(errorTitle, isPresented: $showingError) {
//                Button("OK", role: .cancel) { }
//            } message: {
//                Text(errorMessage)
//            }
//        }
//    }
//
//    // Define a function to add a new word to the list
//    func addNewWord() {
//        // Normalize the user's input (convert to lowercase and remove extra spaces)
//        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//
//        // Exit the function if the input is empty
//        guard answer.count > 0 else { return }
//
//        // Check if the word is not already in the usedWords list
//        guard isOriginal(word: answer) else {
//            wordError(title: "Word used already", message: "Be more original")
//            return
//        }
//
//        // Check if the word can be formed from the rootWord
//        guard isPossible(word: answer) else {
//            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
//            return
//        }
//
//        // Check if the word is a valid English word
//        guard isReal(word: answer) else {
//            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
//            return
//        }
//
//        // If all checks pass, add the word to the usedWords list
//        withAnimation {
//            usedWords.insert(answer, at: 0)
//        }
//
//        // Clear the newWord input field
//        newWord = ""
//    }
//
//    // Define a function to start the game
//    func startGame() {
//        // Attempt to load a list of words from a file in the app's bundle
//
//        // If successful, pick a random word as the rootWord
//        // If unsuccessful, crash the app and report an error
//    }
//
//    // Define a function to check if a word is original (not used before)
//    func isOriginal(word: String) -> Bool {
//        // Check if the word is not in the usedWords list
//        return !usedWords.contains(word)
//    }
//
//    // Define a function to check if a word can be formed from the rootWord
//    func isPossible(word: String) -> Bool {
//        // Check if the word can be constructed using the letters from the rootWord
//        // If so, return true; otherwise, return false
//    }
//
//    // Define a function to check if a word is a real English word
//    func isReal(word: String) -> Bool {
//        // Use a spell checker to determine if the word is real
//        // If it's a valid English word, return true; otherwise, return false
//    }
//
//    // Define a function to set error messages and show an alert
//    func wordError(title: String, message: String) {
//        errorTitle = title
//        errorMessage = message
//        showingError = true
//    }
//}
//
//// A preview provider for the ContentView
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
