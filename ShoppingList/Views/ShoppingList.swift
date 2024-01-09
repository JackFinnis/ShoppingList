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
    @EnvironmentObject var vm: ViewModel
    @FocusState var focused: Bool
    @State var showEmailSheet = false
    @State var showUndoAlert = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollViewReader { list in
                    List {
                        Section {
                            ForEach(vm.items, id: \.self) { item in
                                ItemRow(item: item, suggested: false)
                            }
                            
                            ClearableField(placeholder: "Add Item", text: $vm.newItem)
                                .id(0)
                                .submitLabel(.done)
                                .focused($focused)
                                .onSubmit {
                                    focused = vm.addNewItem()
                                }
                        }
                        
                        if vm.suggestions.isNotEmpty {
                            Section {
                                ForEach(vm.suggestions, id: \.self) { item in
                                    ItemRow(item: item, suggested: true)
                                }
                            } header: {
                                HStack {
                                    Text("Favourites")
                                    Spacer()
                                    Button("Add All") {
                                        vm.addAllSuggestions()
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
                    .animation(.default, value: vm.items)
                    .animation(.default, value: vm.regulars)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(Constants.name)
                    .toolbarTitleMenu {
                        ShareLink("Share \(Constants.name)", item: Constants.appURL)
                        Button {
                            requestReview()
                        } label: {
                            Label("Rate \(Constants.name)", systemImage: "star")
                        }
                        Button {
                            Store.writeReview()
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
                                vm.emptyList()
                            }
                            .disabled(vm.items.isEmpty)
                        }
                        ToolbarItem(placement: .primaryAction) {
                            Button("Copy") {
                                vm.copyList()
                            }
                            .disabled(vm.items.isEmpty)
                        }
                        ToolbarItem(placement: .bottomBar) {
                            Button("Undo") {
                                vm.undoRemove()
                            }
                            .disabled(vm.recentlyRemovedItems.isEmpty)
                        }
                        ToolbarItem(placement: .status) {
                            Text(vm.items.count.formatted(singular: "item"))
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
            }
        }
        .emailSheet(recipient: Constants.email, subject: "\(Constants.name) Feedback", isPresented: $showEmailSheet)
    }
}

struct ShoppingList_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingList()
    }
}
