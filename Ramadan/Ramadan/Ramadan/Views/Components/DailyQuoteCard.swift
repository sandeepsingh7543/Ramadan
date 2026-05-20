//
//  DailyQuoteCard.swift
//  Ramadan
//
//  Created by Mobi iOS on 25/02/26.
//

import SwiftUI

struct DailyQuoteCard: View {
    @State private var currentQuote: Quote
    @State private var showNewQuote = false
    
    init() {
        _currentQuote = State(initialValue: Quote.daily)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "quote.opening")
                    .font(.title3)
                    .foregroundColor(AppColors.accent)
                
                Text("Daily Inspiration")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button(action: refreshQuote) {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline)
                        .foregroundColor(AppColors.primary)
                }
            }
            
            Text(currentQuote.text)
                .font(.body)
                .foregroundColor(AppColors.textPrimary)
                .lineSpacing(6)
                .opacity(showNewQuote ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: showNewQuote)
            
            if let author = currentQuote.author {
                Text("— \(author)")
                    .font(.caption.italic())
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.surface,
                            AppColors.surface.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.accent.opacity(0.3), AppColors.primary.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: AppColors.accent.opacity(0.2), radius: 15, x: 0, y: 8)
        .onAppear {
            withAnimation {
                showNewQuote = true
            }
        }
    }
    
    private func refreshQuote() {
        withAnimation {
            showNewQuote = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentQuote = Quote.random
            withAnimation {
                showNewQuote = true
            }
        }
    }
}

struct Quote {
    let text: String
    let author: String?
    
    static let quotes: [Quote] = [
        Quote(text: "The best among you are those who have the best manners and character.", author: "Prophet Muhammad (PBUH)"),
        Quote(text: "Verily, with hardship comes ease.", author: "Quran 94:6"),
        Quote(text: "Do not lose hope, nor be sad.", author: "Quran 3:139"),
        Quote(text: "Allah does not burden a soul beyond that it can bear.", author: "Quran 2:286"),
        Quote(text: "The most beloved deeds to Allah are those that are most consistent, even if they are small.", author: "Prophet Muhammad (PBUH)"),
        Quote(text: "Patience is the key to relief.", author: "Islamic Wisdom"),
        Quote(text: "Seek knowledge from the cradle to the grave.", author: "Prophet Muhammad (PBUH)"),
        Quote(text: "The strong person is not the one who can wrestle someone else down. The strong person is the one who can control himself when he is angry.", author: "Prophet Muhammad (PBUH)"),
        Quote(text: "When you see a person who has been given more than you in money and beauty, look to those who have been given less.", author: "Prophet Muhammad (PBUH)"),
        Quote(text: "Kindness is a mark of faith, and whoever is not kind has no faith.", author: "Prophet Muhammad (PBUH)"),
        Quote(text: "The believer's shade on the Day of Resurrection will be his charity.", author: "Prophet Muhammad (PBUH)"),
        Quote(text: "Make things easy and do not make them difficult, cheer the people up and do not repel them.", author: "Prophet Muhammad (PBUH)"),
        Quote(text: "A good word is charity.", author: "Prophet Muhammad (PBUH)"),
        Quote(text: "The best of people are those who are most beneficial to people.", author: "Prophet Muhammad (PBUH)"),
        Quote(text: "Whoever believes in Allah and the Last Day should speak good or remain silent.", author: "Prophet Muhammad (PBUH)")
    ]
    
    static var daily: Quote {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return quotes[dayOfYear % quotes.count]
    }
    
    static var random: Quote {
        quotes.randomElement() ?? quotes[0]
    }
}
