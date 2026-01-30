//
//  ContentView.swift
//  Flashzilla
//
//  Created by  He on 2026/1/29.
//

import SwiftUI
import Combine
import SwiftData

struct ContentView: View {
    @Query var cards: [Card]
    @State private var removedCardIDs: Set<Card.ID> = []
    @State private var timeRemaining = 100
    @State private var isActive = true
    @State private var showingEditScreen = false
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var activeCards: [Card] {
        cards.filter { !removedCardIDs.contains($0.id) }
    }
    
    var body: some View {
        ZStack {
            Image(decorative: "background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Text("Time: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(.capsule)
                
                ZStack {
                    ForEach(0..<activeCards.count, id: \.self) { index in
                        CardView(card: activeCards[index]) {
                            withAnimation {
                                removeCard(at: index)
                            }
                        }
                            .stacked(at: index, in: activeCards.count)
                            .allowsHitTesting(index == activeCards.count - 1)//只允许最后一张(也就是界面的第一张)交互
                            .accessibilityHidden(index < activeCards.count - 1)//界面的第一张以下对辅助功能隐藏
                    }
                }
                .allowsHitTesting(timeRemaining > 0)//时间到后禁止交互
                
                if activeCards.isEmpty {
                    Button("再来一局", action: resetCards)
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(.capsule)
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        showingEditScreen = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(.circle)
                    }
                }
                
                Spacer()
            }
            .foregroundStyle(.white)
            .font(.largeTitle)
            .padding()
            
            if accessibilityDifferentiateWithoutColor || accessibilityVoiceOverEnabled {//不以颜色区分和无障碍启用
                VStack {
                    Spacer()
                    
                    HStack {
                        Button {
                            withAnimation {
                                removeCard(at: activeCards.count - 1)//移除最上面
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                                .accessibilityLabel("错误")
                                .accessibilityHint("你将答案标记为错误")
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                removeCard(at: activeCards.count - 1)//移除最上面
                            }
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                                .accessibilityLabel("正确")
                                .accessibilityHint("你将答案标记为正确")
                        }
                    }
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer) { _ in
            guard isActive else { return }//非激活状态暂停
            
            guard activeCards.count > 0 else {
                return
            }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue == .active && activeCards.isEmpty == false {
                isActive = true
            } else {
                isActive = false
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards) {
            EditCards()
        }
        .onAppear(perform: resetCards)
    }
    
    func removeCard(at index: Int) {
        guard index >= 0 else { return }//没有卡片时直接返回
        
        removedCardIDs.insert(activeCards[index].id)
        
        if activeCards.isEmpty {
            isActive = false
        }
    }
    
    func resetCards() {
        removedCardIDs.removeAll()
        timeRemaining = 100
        isActive = true
    }
}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(y: offset * 10)
    }
}

#Preview {
    ContentView()
}
