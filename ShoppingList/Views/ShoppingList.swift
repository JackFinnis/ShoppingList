//
//  RootView.swift
//  ShoppingList
//
//  Created by Jack Finnis on 20/05/2023.
//

import SwiftUI
import MessageUI

struct ShoppingList: View {
    @StateObject var vm = ViewModel()
    @FocusState var focused: Bool
    @State var showShareSheet = false
    @State var showEmailSheet = false
    @State var showUndoAlert = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            NavigationView {
                ScrollViewReader { list in
                    List {
                        Section {
                            ForEach(vm.items, id: \.self) { item in
                                ItemRow(item: item, suggested: false)
                            }
                            
                            TextField("Add Item", text: $vm.newItem)
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
                    .listStyle(.insetGrouped)
                    .animation(.default, value: vm.items)
                    .animation(.default, value: vm.regulars)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            if vm.items.isNotEmpty {
                                Button("Clear") {
                                    vm.emptyList()
                                }
                                .horizontallyCentred()
                            }
                        }
                        ToolbarItem(placement: .principal) {
                            Menu {
                                Button {
                                    showShareSheet = true
                                } label: {
                                    Label("Share the App", systemImage: "square.and.arrow.up")
                                }
                                Button {
                                    Store.requestRating()
                                } label: {
                                    Label("Rate the App", systemImage: "star")
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
                                } else if let url = Emails.mailtoUrl(subject: "\(Constants.name) Feedback"), UIApplication.shared.canOpenURL(url) {
                                    Button {
                                        UIApplication.shared.open(url)
                                    } label: {
                                        Label("Send us Feedback", systemImage: "envelope")
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(Constants.name)
                                        .font(.headline)
                                    MenuChevron()
                                }
                                .foregroundColor(.primary)
                            }
                            .sharePopover(items: [Constants.appUrl], showsSharedAlert: true, isPresented: $showShareSheet)
                        }
                        ToolbarItem(placement: .primaryAction) {
                            if vm.items.isNotEmpty {
                                Button("Copy") {
                                    vm.copyList()
                                }
                            }
                        }
                        ToolbarItem(placement: .bottomBar) {
                            if vm.recentlyRemovedItems.isNotEmpty {
                                Button {
                                    vm.undoRemove()
                                } label: {
                                    Image(systemName: "arrow.counterclockwise")
                                }
                            } else {
                                Text("")
                            }
                        }
                        ToolbarItem(placement: .status) {
                            Text(vm.items.count.formatted(singular: "item"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        ToolbarItem(placement: .bottomBar) {
                            Button {
                                withAnimation {
                                    focused = true
                                    list.scrollTo(0)
                                }
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: 500)
            .navigationViewStyle(.stack)
        }
        .emailSheet(recipient: Constants.email, subject: "\(Constants.name) Feedback", isPresented: $showEmailSheet)
        .onShake {
            guard vm.recentlyRemovedItems.isNotEmpty else { return }
            Haptics.success()
            showUndoAlert = true
        }
        .alert("Undo Edit", isPresented: $showUndoAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Undo") {
                vm.undoRemove()
            }
        }
        .environmentObject(vm)
    }
}

struct ShoppingList_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingList()
    }
}
