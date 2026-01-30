//
//  EditCards.swift
//  Flashzilla
//
//  Created by  He on 2026/1/30.
//

import SwiftUI
import SwiftData

struct EditCards: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Query private var cards: [Card]
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
                    ForEach(cards) { card in
                        VStack (alignment: .leading) {
                            Text(card.prompt)
                                .font(.headline)
                            
                            Text(card.answer)
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
    }
    
    func done() {
        dismiss()
    }
    
    func addCard() {
        let trimmedPrompt = newPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnswer = newAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedPrompt.isEmpty, !trimmedAnswer.isEmpty else {
            return
        }
        
        let newCard = Card(prompt: trimmedPrompt, answer: trimmedAnswer)
        modelContext.insert(newCard)
        
        newPrompt = ""
        newAnswer = ""
    }
    
    func removeCard(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(cards[index])
        }
    }
}

#Preview {
    EditCards()
}
