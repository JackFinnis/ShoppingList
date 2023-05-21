//
//  RootView.swift
//  ShoppingList
//
//  Created by Jack Finnis on 20/05/2023.
//

import SwiftUI
import MessageUI

struct RootView: View {
    @StateObject var vm = ViewModel()
    @FocusState var focused: Bool
    @State var showShareSheet = false
    @State var showEmailSheet = false
    @State var showUndoAlert = false
    @State var newItem = ""
    @State var recentlyRemovedItems = [String]()
    
    var body: some View {
        NavigationView {
            ScrollViewReader { list in
                List {
                    Section {
                        ForEach(vm.items, id: \.self) { item in
                            HStack(spacing: 15) {
                                Button {
                                    removeItem(item)
                                } label: {
                                    let removed = recentlyRemovedItems.contains(item)
                                    Image(systemName: removed ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(removed ? .accentColor : Color(.placeholderText))
                                        .font(.title2)
                                }
                                Text(item)
                                Spacer()
                                RegularToggle(item: item)
                            }
                        }
                        
                        TextField("Add Item", text: $newItem)
                            .id(0)
                            .submitLabel(.done)
                            .focused($focused)
                            .onSubmit(addNewItem)
                    }
                    
                    if vm.suggestions.isNotEmpty {
                        Section("Favourites") {
                            ForEach(vm.suggestions, id: \.self) { item in
                                HStack(spacing: 15) {
                                    Button {
                                        addItem(item)
                                    } label: {
                                        Image(systemName: "plus.circle")
                                            .font(.title2)
                                    }
                                    Text(item)
                                    Spacer()
                                    RegularToggle(item: item)
                                }
                            }
                        }
                        .headerProminence(.increased)
                    }
                }
                .animation(.default, value: vm.items)
                .animation(.default, value: vm.regulars)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        if vm.items.isNotEmpty {
                            Button("Clear", action: emptyList)
                                .horizontallyCentred()
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Menu {
                            Button {
                                showShareSheet = true
                            } label: {
                                Label("Share with a Friend", systemImage: "square.and.arrow.up")
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
                    }
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            if recentlyRemovedItems.isNotEmpty {
                                Button(action: undoRemove) {
                                    Image(systemName: "arrow.counterclockwise")
                                }
                            }
                            Spacer()
                            Button {
                                withAnimation {
                                    focused = true
                                    list.scrollTo(0)
                                }
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                        .overlay {
                            Text(vm.items.count.formatted(singular: "item"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .shareSheet(items: [Constants.appUrl], showsSharedAlert: true, isPresented: $showShareSheet)
        .emailSheet(recipient: Constants.email, subject: "\(Constants.name) Feedback", isPresented: $showEmailSheet)
        .onShake {
            guard recentlyRemovedItems.isNotEmpty else { return }
            Haptics.success()
            showUndoAlert = true
        }
        .alert("Undo Edit", isPresented: $showUndoAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Undo", action: undoRemove)
        }
        .environmentObject(vm)
    }
    
    func addNewItem() {
        defer {
            newItem = ""
        }
        let trimmed = newItem.trimmed
        guard trimmed.isNotEmpty else { return }
        if !vm.items.contains(trimmed) {
            addItem(trimmed)
        }
        focused = true
    }
    
    func addItem(_ item: String) {
        vm.items.append(item)
        recentlyRemovedItems.removeAll(item)
    }
    
    func removeItem(_ item: String) {
        guard !recentlyRemovedItems.contains(item) else { return }
        recentlyRemovedItems.append(item)
        Haptics.tap()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            vm.items.removeAll(item)
        }
    }
    
    func undoRemove() {
        guard let item = recentlyRemovedItems.popLast() else { return }
        vm.items.append(item)
        Haptics.tap()
    }
    
    func emptyList() {
        recentlyRemovedItems.append(contentsOf: vm.items)
        vm.items.removeAll()
        Haptics.success()
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
