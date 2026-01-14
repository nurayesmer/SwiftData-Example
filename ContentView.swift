//
//  ContentView.swift
//  ExampleSwiftData
//
//  Created by n.esmer on 14.01.2026.
//

import SwiftUI
import SwiftData

@Model
class MyBook {
    var bookName: String
    var author: String
    var publicationYear: Date
    var createdDate: Date = Date.now
    var bookGenre: BookGenre
    
    init(bookName: String, author: String, publicationYear: Date, createdDate: Date, bookGenre: BookGenre) {
        self.bookName = bookName
        self.author = author
        self.publicationYear = publicationYear
        self.createdDate = createdDate
        self.bookGenre = bookGenre
    }
}

enum BookGenre: String, Identifiable, CaseIterable, Codable {
    var id: String { rawValue }
    case fantasy = "Fantasy"
    case scienceFiction = "Science Fiction"
    case mystery = "Mystery"
    
}

struct BookAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State var bookName: String = ""
    @State var author: String = ""
    @State var publicationYear: Date = Date.now
    @State var bookGenre: BookGenre = BookGenre.scienceFiction
    var body: some View {
        NavigationStack {
            List {
                TextField("Book Name", text: $bookName, axis: .vertical)
                TextField("Author", text: $author, axis: .vertical)
                DatePicker("Publication Year", selection: $publicationYear, displayedComponents: .date)
                Picker("Genre", selection: $bookGenre) {
                    ForEach(BookGenre.allCases, id: \.self) { genre in
                        Text(genre.rawValue)
                            .tag(genre)
                    }
                }
            }
            #if os(iOS)
            .listRowSpacing(10)
            #endif
            .navigationTitle("Add Book")
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Add", systemImage: "plus") {
                        addBook()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
    }
    func addBook() {
        let newBook = MyBook(bookName: bookName, author: author, publicationYear: publicationYear, createdDate: Date.now, bookGenre: bookGenre)
        modelContext.insert(newBook)
        try! modelContext.save()
    }
 }

struct BookEditView: View {
    @Bindable var myBook: MyBook
    @Environment(\.dismiss) private var dismiss
    @State var bookName: String = ""
    @State var author: String = ""
    @State var publicationYear: Date = Date.now
    @State var bookGenre: BookGenre = BookGenre.scienceFiction
    var body: some View {
        NavigationStack {
            List {
                TextField("Book Name", text: $bookName, axis: .vertical)
                TextField("Author", text: $author, axis: .vertical)
                DatePicker("Publication Year", selection: $publicationYear, displayedComponents: .date)
                Picker("Genre", selection: $bookGenre) {
                    ForEach(BookGenre.allCases, id: \.self) { genre in
                        Text(genre.rawValue)
                            .tag(genre)
                    }
                }
            }
            .navigationTitle("Edit Book")
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Save", systemImage: "checkmark") {
                        editBook()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            bookName = myBook.bookName
            author = myBook.author
            publicationYear = myBook.publicationYear
            bookGenre = myBook.bookGenre
        }
    }
    
    func editBook() {
        myBook.bookName = bookName
        myBook.author = author
        myBook.publicationYear = publicationYear
        myBook.bookGenre = bookGenre
    }
}

struct BookDetailView: View {
    var myBook: MyBook
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(myBook.bookName)
                        .font(Font.title3)
                    Text(myBook.author)
                        .font(Font.caption)
                    HStack {
                        Text(myBook.bookGenre.rawValue)
                        Text("\(myBook.publicationYear.formatted(date: .numeric, time: .omitted))")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .navigationTitle("Book Detail")
                .scrollIndicators(.hidden)
                .toolbar {
                    ToolbarItem(placement: .destructiveAction) {
                        NavigationLink {
                            BookEditView(myBook: myBook)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                }
            }
        }
    }
}

struct BookListView: View {
    @Query(sort: [SortDescriptor(\MyBook.bookName, order: .forward)]) var myBook: [MyBook]
    @Environment(\.modelContext) private var modelContext
    init(sort: SortDescriptor<MyBook>, searchText: String) {
        _myBook = Query(filter: #Predicate {
            if searchText.isEmpty {
                return true
            } else {
                return $0.bookName.localizedStandardContains(searchText) || $0.author.localizedStandardContains(searchText)
            }
        }, sort: [sort] )
    }
    var body: some View {
        if myBook.isEmpty {
            ContentUnavailableView("No Book", systemImage: "book", description: Text("No Book yet. Tap the plus button to add a new book."))
        } else {
            List {
                ForEach(myBook) { book in
                    NavigationLink {
                        BookDetailView(myBook: book)
                    } label: {
                        VStack {
                            Text(book.bookName)
                                .font(Font.headline)
                            Text(book.author)
                                .font(Font.caption)
                        }
                    }
                }
                .onDelete(perform: deleteBook)
            }
            #if os(iOS)
            .listRowSpacing(10)
            #endif
        }
    }
    
    func deleteBook(_ indexset: IndexSet) {
        for index in indexset {
            modelContext.delete(myBook[index])
            try! modelContext.save()
        }
    }
}

struct ContentView: View {
    @State var searchText: String = ""
    @State var sortOrder = SortDescriptor(\MyBook.bookName, order: .forward)
    var body: some View {
        NavigationStack {
            BookListView(sort: sortOrder, searchText: searchText)
                .navigationTitle("Book")
                .toolbar {
                    ToolbarItem(placement: .destructiveAction) {
                        Menu("Sort", systemImage: "arrow.up.arrow.down") {
                            Picker("Sort", selection: $sortOrder) {
                                Text("Book Name A-Z")
                                    .tag(SortDescriptor(\MyBook.bookName, order: .forward))
                                Text("Book Name Z-A")
                                    .tag(SortDescriptor(\MyBook.bookName, order: .reverse))
                                Text("Author Name A-Z")
                                    .tag(SortDescriptor(\MyBook.author, order: .forward))
                                Text("Author Name Z-A")
                                    .tag(SortDescriptor(\MyBook.author, order: .reverse))
                            }
                        }
                        
                    }
                    ToolbarItem(placement: .destructiveAction) {
                        NavigationLink {
                            BookAddView()
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                .searchable(text: $searchText)
            
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [MyBook.self], inMemory: false)
}
