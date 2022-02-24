//
//  ContentView.swift
//  DadJokes
//
//  Created by Russell Gordon on 2022-02-21.
//

import SwiftUI

struct ContentView: View {
    
   
    // MARK: Stored properties
    // Holds the joke that has just been recieved
    @State var currentJoke: DadJoke = DadJoke(id: "",
                                              joke: "Knock, knock...",
                                              status: 0)
    
  
    @State var favourites: [DadJoke] = [] // [] = empty list
    // Square brackets used to define a list
    
    
    
    // MARK: Computed properties
    var body: some View {
        VStack {
            
            Text(currentJoke.joke)
                .font(.title)
                .multilineTextAlignment(.leading)
                .padding(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary, lineWidth: 4)
                )
                .padding(10)
            //
            Image(systemName: "heart.circle")
                .font(.largeTitle)
                .onTapGesture {
                    // Add the current joke to the list
                    favourites.append(currentJoke) // append = add
                    // Same thing as manually adding to a list but the computer automatically adds it for us.
                }
            
            
            Button(action: {
                print("I've been pressed.")
                
                // Call Load new joke
                // It must be called within a task structure
                // So that it runs asynchronously
                // NOTE: button's action normally expects synchronous code.
                Task {
                    await loadNewJoke()
                }
                
                
                
                
            }, label: {
                Text("Another one!")
            })
                .buttonStyle(.bordered)
            
            HStack {
                Text("Favourites")
                    .bold()
                
                Spacer()
            }
            
           // Iterate (loop) over the list (array) of jokes
           // Make each joke accessible using the name "currentJoke"
            // id: \.self  <- that tells the list structures to indentify each joke using the text of the joke itself
            List(favourites, id: \.self) { currentJoke in
                Text(currentJoke.joke)
                
            }
            
            Spacer()
            
        }
        // When the app opens, get a new joke from the web service
        .task {
            // We "call" the loadnewjoke function to the computer
            // To get a new joke.
            // By typing "await" we are acknowledging tha we know thus
            // Function may ber un at the saem time as other tasks in the app
           await loadNewJoke()
            
            //DEBUG
            print("Have just attempted to load a new joke")
        }
        .navigationTitle("icanhazdadjoke?")
        .padding()
    }
    
    // MARK: Functions
    // This function loads a new joke by talking to an endpoint on the web.
    // We must mark the function as "Asnyc" so that it can be assynchronously which
    // Means it may be run at hte saem time as other tasks.
    // This is the function definition (it is where the computer "learns" waht
    // It takes to load a new joke).
    func loadNewJoke() async {
     
        // Assemble the URL that points to the endpoint
        let url = URL(string: "https://icanhazdadjoke.com/")!
        
        // Define the type of data we want from the endpoint
        // Configure the request to the web site
        var request = URLRequest(url: url)
        // Ask for JSON data
        request.setValue("application/json",
                         forHTTPHeaderField: "Accept")
        
        // Start a session to interact (talk with) the endpoint
        let urlSession = URLSession.shared
        
        // Try to fetch a new joke
        // It might not work, so we use a do-catch block
        do {
            
            // Get the raw data from the endpoint
            let (data, _) = try await urlSession.data(for: request)
            
            // Attempt to decode the raw data into a Swift structure
            // Takes what is in "data" and tries to put it into "currentJoke"
            //                                 DATA TYPE TO DECODE TO
            //                                         |
            //                                         V
            currentJoke = try JSONDecoder().decode(DadJoke.self, from: data)
            
            // catch is almost as if it fails this is what will happen. Like a return style code.
            
        } catch {
            print("Could not retrieve or decode the JSON from endpoint.")
            // Print the contents of the "error" constant that the do-catch block
            // populates
            print(error)
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}
