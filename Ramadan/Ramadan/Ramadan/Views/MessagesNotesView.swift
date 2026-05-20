//
//  MessagesNotesView.swift
//  Ramadan
//
//  Created by Mobi iOS on 23/02/26.
//

import SwiftUI

struct MessagesNotesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MessageNote.createdAt, ascending: false)],
        animation: .default)
    private var notes: FetchedResults<MessageNote>
    
    @State private var showingAddSheet = false
    @State private var searchText = ""
    @State private var sortOrder = SortOrder.dateDescending
    
    enum SortOrder: String, CaseIterable {
        case dateDescending = "Newest"
        case dateAscending = "Oldest"
        case titleAscending = "A-Z"
    }
    
    var filteredNotes: [MessageNote] {
        var result = Array(notes)
        
        if !searchText.isEmpty {
            result = result.filter { note in
                (note.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (note.content?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        switch sortOrder {
        case .dateDescending:
            result.sort { ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) }
        case .dateAscending:
            result.sort { ($0.createdAt ?? Date()) < ($1.createdAt ?? Date()) }
        case .titleAscending:
            result.sort { ($0.title ?? "") < ($1.title ?? "") }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchBar
                sortPicker
                notesList
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Notes")
            .navigationBarItems(trailing: addButton)
            .sheet(isPresented: $showingAddSheet) {
                AddNoteView()
            }
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textMuted)
            
            TextField("Search notes...", text: $searchText)
                .textFieldStyle(.plain)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textMuted)
                }
            }
        }
        .padding(AppSpacing.sm)
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.md)
        .padding()
    }
    
    private var sortPicker: some View {
        Picker("Sort", selection: $sortOrder) {
            ForEach(SortOrder.allCases, id: \.self) { order in
                Text(order.rawValue).tag(order)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom, AppSpacing.sm)
    }
    
    private var notesList: some View {
        Group {
            if filteredNotes.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: AppSpacing.sm) {
                        ForEach(Array(filteredNotes.enumerated()), id: \.element.id) { index, note in
                            NavigationLink(destination: NoteDetailView(note: note)) {
                                NoteCard(note: note)
                            }
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05), value: filteredNotes.count)
                        }
                        .onDelete(perform: deleteNotes)
                    }
                    .padding()
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: AppSpacing.xxl) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "note.text")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.primary)
            }
            
            Text(searchText.isEmpty ? "No notes yet" : "No matching notes")
                .font(.title3.bold())
                .foregroundColor(AppColors.textPrimary)
            
            Text(searchText.isEmpty ? "Tap + to create your first note" : "Try a different search term")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var addButton: some View {
        Button(action: { showingAddSheet = true }) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(AppColors.primary)
        }
    }
    
    private func deleteNotes(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let note = filteredNotes[index]
                viewContext.delete(note)
            }
            PersistenceController.shared.save()
        }
    }
}

struct NoteCard: View {
    @ObservedObject var note: MessageNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text(note.title ?? "")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            
            Text(note.content ?? "")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(2)
            
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                Text(note.createdAt ?? Date(), style: .date)
                    .font(.caption)
            }
            .foregroundColor(AppColors.textMuted)
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.xl)
        .shadow(color: AppShadow.md.color, radius: AppShadow.md.radius, x: AppShadow.md.x, y: AppShadow.md.y)
    }
}

struct AddNoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, content
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                Form {
                    Section(header: Text("Title").foregroundColor(AppColors.textSecondary)) {
                        TextField("Enter title", text: $title)
                            .focused($focusedField, equals: .title)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Section(header: Text("Content").foregroundColor(AppColors.textSecondary)) {
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                            .focused($focusedField, equals: .content)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
                    .foregroundColor(AppColors.textSecondary),
                trailing: Button("Save") {
                    saveNote()
                    dismiss()
                }
                .bold()
                .foregroundColor(AppColors.primary)
                .disabled(title.isEmpty)
            )
            .onAppear {
                focusedField = .title
            }
        }
    }
    
    private func saveNote() {
        let note = MessageNote(context: viewContext)
        note.id = UUID()
        note.title = title
        note.content = content
        note.createdAt = Date()
        note.updatedAt = Date()
        PersistenceController.shared.save()
    }
}

struct NoteDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var note: MessageNote
    
    @State private var isEditing = false
    @State private var editTitle = ""
    @State private var editContent = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                if isEditing {
                    VStack(spacing: AppSpacing.sm) {
                        TextField("Title", text: $editTitle)
                            .font(.title2.bold())
                            .textFieldStyle(.roundedBorder)
                            .foregroundColor(AppColors.textPrimary)
                        
                        TextEditor(text: $editContent)
                            .frame(minHeight: 300)
                            .padding(8)
                            .background(AppColors.surface)
                            .cornerRadius(AppCornerRadius.md)
                            .foregroundColor(AppColors.textPrimary)
                    }
                } else {
                    Text(note.title ?? "")
                        .font(.title.bold())
                        .foregroundColor(AppColors.textPrimary)
                    
                    HStack(spacing: AppSpacing.md) {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "calendar")
                                .foregroundColor(AppColors.textMuted)
                            Text(note.createdAt ?? Date(), style: .date)
                                .foregroundColor(AppColors.textMuted)
                        }
                        .font(.caption)
                        
                        if let updated = note.updatedAt, updated != note.createdAt {
                            Label("Edited", systemImage: "pencil")
                                .font(.caption)
                                .foregroundColor(AppColors.textMuted)
                        }
                    }
                    
                    Divider()
                        .background(AppColors.textMuted)
                    
                    Text(note.content ?? "")
                        .font(.body)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            .padding()
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: editButton)
    }
    
    private var editButton: some View {
        Button(isEditing ? "Done" : "Edit") {
            if isEditing {
                saveChanges()
            } else {
                editTitle = note.title ?? ""
                editContent = note.content ?? ""
            }
            withAnimation {
                isEditing.toggle()
            }
        }
        .bold()
        .foregroundColor(AppColors.primary)
    }
    
    private func saveChanges() {
        note.title = editTitle
        note.content = editContent
        note.updatedAt = Date()
        PersistenceController.shared.save()
    }
}
