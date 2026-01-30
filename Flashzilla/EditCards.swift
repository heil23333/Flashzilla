//
//  EditCards.swift
//  Flashzilla
//
//  Created by  He on 2026/1/30.
//

import SwiftUI

struct EditCards: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var cards = [Card]()
    @State private var newPrompt: String = ""
    @State private var newAnswer: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section("添加新卡片") {
                    TextField("提示(问题)", text: $newPrompt)
                    
                    TextField("答案", text: $newAnswer)
                    
                    Button("添加卡片", action: addCard)
                }
                
                Section {
                    ForEach(0..<cards.count, id: \.self) { index in
                        VStack (alignment: .leading) {
                            Text(cards[index].prompt)
                                .font(.headline)
                            
                            Text(cards[index].answer)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: removeCard)
                }
            }
            .navigationTitle("编辑卡片")
            .toolbar {
                Button("完成", action: done)
            }
        }
        .onAppear(perform: loadData)
    }
    
    func done() {
        dismiss()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
    }
    
    func saveData() {
        if let data = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(data, forKey: "Cards")
        }
    }
    
    func addCard() {
        let trimmedPrompt = newPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnswer = newAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedPrompt.isEmpty, !trimmedAnswer.isEmpty else {
            return
        }
        
        let newCard = Card(prompt: trimmedPrompt, answer: trimmedAnswer)
        cards.insert(newCard, at: 0)
        saveData()
    }
    
    func removeCard(at offsets: IndexSet) {
        cards.remove(atOffsets: offsets)
        saveData()
    }
}

#Preview {
    EditCards()
}
