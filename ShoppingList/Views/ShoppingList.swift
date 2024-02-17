//
//  RootView.swift
//  ShoppingList
//
//  Created by Jack Finnis on 20/05/2023.
//

import SwiftUI
import MessageUI
import StoreKit

struct ShoppingList: View {
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject var storage: StorageVM
    @FocusState var focused: Bool
    @State var showEmailSheet = false
    @State var showUndoAlert = false
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont.roundedSystemFont(style: .headline)]
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollViewReader { list in
                NavigationStack {
                    List {
                        Section {
                            ForEach(storage.items, id: \.self) { item in
                                ItemRow(item: item, suggested: false)
                            }
                            
                            ClearableField(placeholder: "Add Item", text: $storage.newItem)
                                .id(0)
                                .submitLabel(.done)
                                .focused($focused)
                                .onSubmit {
                                    focused = storage.addNewItem()
                                }
                        }
                        
                        if storage.suggestions.isNotEmpty {
                            Section {
                                ForEach(storage.suggestions, id: \.self) { item in
                                    ItemRow(item: item, suggested: true)
                                }
                            } header: {
                                HStack {
                                    Text("Favourites")
                                        .font(.title3.weight(.semibold))
                                    Spacer()
                                    Button("Add All") {
                                        storage.addAllSuggestions()
                                    }
                                    .font(.body)
                                }
                            }
                            .headerProminence(.increased)
                        }
                    }
                    .contentMargins(.vertical, 10, for: .scrollContent)
                    .contentMargins(.horizontal, max(16, (geo.size.width - 500) / 2), for: .scrollContent)
                    .listStyle(.insetGrouped)
                    .animation(.default, value: storage.items)
                    .animation(.default, value: storage.regulars)
                    .navigationTitle(Constants.name)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDocument(Constants.appURL, preview: SharePreview(Constants.name, image: Image(.logo)))
                    .toolbarTitleMenu {
                        Button {
                            requestReview()
                        } label: {
                            Label("Rate \(Constants.name)", systemImage: "star")
                        }
                        Button {
                            AppStore.writeReview()
                        } label: {
                            Label("Write a Review", systemImage: "quote.bubble")
                        }
                        if MFMailComposeViewController.canSendMail() {
                            Button {
                                showEmailSheet.toggle()
                            } label: {
                                Label("Send us Feedback", systemImage: "envelope")
                            }
                        } else if let url = Emails.url(subject: "\(Constants.name) Feedback"), UIApplication.shared.canOpenURL(url) {
                            Button {
                                UIApplication.shared.open(url)
                            } label: {
                                Label("Send us Feedback", systemImage: "envelope")
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Clear") {
                                storage.emptyList()
                            }
                            .disabled(storage.items.isEmpty)
                        }
                        ToolbarItem(placement: .primaryAction) {
                            Button("Copy") {
                                storage.copyList()
                            }
                            .disabled(storage.items.isEmpty)
                        }
                        ToolbarItem(placement: .bottomBar) {
                            Button("Undo") {
                                storage.undoRemove()
                            }
                            .disabled(storage.recentlyRemovedItems.isEmpty)
                        }
                        ToolbarItem(placement: .status) {
                            Text(storage.items.count.formatted(singular: "item"))
                                .foregroundColor(.secondary)
                        }
                        ToolbarItem(placement: .bottomBar) {
                            Button("Add Item") {
                                withAnimation {
                                    focused.toggle()
                                    list.scrollTo(0)
                                }
                            }
                        }
                    }
                }
                .emailSheet(recipient: Constants.email, subject: "\(Constants.name) Feedback", isPresented: $showEmailSheet)
                .fontDesign(.rounded)
            }
        }
    }
}

#Preview {
    ShoppingList()
        .environmentObject(StorageVM())
}
