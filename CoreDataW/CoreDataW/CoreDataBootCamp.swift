//
//  ContentView.swift
//  CoreDataW
//
//  Created by Мадина Валиева on 28.09.2024.
//

import SwiftUI
import CoreData
class CoreDataViewModel: ObservableObject {
    
    let container: NSPersistentContainer
    @Published var savedEntities: [FruitEntity] = []
    
    init() {
        container = NSPersistentContainer(name: "FruitsContainer")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("error loading \(error)")
            } else {
                print("successfully loaded core data!")
            }
        }
        fetchFruits()
    }
    func fetchFruits() {
        let request = NSFetchRequest<FruitEntity>(entityName: "FruitEntity")
        do {
          savedEntities =  try  container.viewContext.fetch(request)
        } catch let error {
            print("error fetching \(error)")
        }
    }
    func addFruit(text: String) {
        let newFruit = FruitEntity(context: container.viewContext)
        newFruit.name = text
        saveData()
    }
    func deleteFruit(indexSet: IndexSet) {
        guard let index = indexSet.first  else { return }
        let entity = savedEntities[index]
        container.viewContext.delete(entity)
        saveData()
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchFruits()
        } catch let error {
            print("error saving \(error)")
        }
    }
}
struct CoreDataBootCamp: View {
    @StateObject var vm = CoreDataViewModel()
    @State var textFieldText = ""
    var body: some View {
        NavigationView {
            VStack(spacing: 20){
                TextField("Добавь название фрукта сюда...", text: $textFieldText)
                    .font(.headline)
                    .padding(.leading)
                    .frame(height: 50)
                    .background(Color(.lightGray))
                    .cornerRadius(10)
                    .padding(.horizontal)
                Button(action: {
                    guard !textFieldText.isEmpty else { return }
                    vm.addFruit(text: textFieldText)
                    textFieldText = ""
                }, label: {
                    Text("Button")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemPink))
                        .cornerRadius(10)
                        .padding(.horizontal)
                })
                List {
                    ForEach(vm.savedEntities) { enteity in
                        Text(enteity.name ?? "")
                    }
                    .onDelete(perform: vm.deleteFruit)
                    
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Fruits")
        }
    }
}

#Preview {
    CoreDataBootCamp()
}
