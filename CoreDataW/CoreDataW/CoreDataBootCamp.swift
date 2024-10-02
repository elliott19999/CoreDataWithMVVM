//
//  ContentView.swift
//  CoreDataW
//
//  Created by Мадина Валиева on 28.09.2024.
//

import SwiftUI
import CoreData
class CoreDataViewModel: ObservableObject {
    
    
//    Это объект, который управляет моделью данных, хранением и контекстом для взаимодействия с базой данных.
    let container: NSPersistentContainer
    
    @Published var savedEntities: [FruitEntity] = []
    
//    При инициализации контейнера задается имя модели данных ("FruitsContainer"), которая должна соответствовать имени, заданному в файле .xcdatamodeld.
    init() {
        container = NSPersistentContainer(name: "FruitsContainer")
        
//        вызывается метод loadPersistentStores, который загружает хранилище данных (базу данных). Если возникает ошибка во время загрузки, она выводится в консоль, иначе выводится сообщение об успешной загрузке.
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("error loading \(error)")
            } else {
                print("successfully loaded core data!")
            }
        }
        fetchFruits()
    }
//    Этот метод создаёт запрос к базе данных с целью извлечь все объекты сущности FruitEntity.
    func fetchFruits() {
        
//        NSFetchRequest<FruitEntity>(entityName: "FruitEntity") – запрос, который возвращает все записи из сущности FruitEntity (то есть таблицы с фруктами).
        let request = NSFetchRequest<FruitEntity>(entityName: "FruitEntity")
//        Если запрос выполнен успешно, массив объектов savedEntities обновляется с новыми данными. В случае ошибки выводится сообщение в консоль.
        do {
          savedEntities =  try container.viewContext.fetch(request)
        } catch let error {
            print("error fetching \(error)")
        }
    }
    
//    Этот метод создаёт новый объект сущности FruitEntity в контексте (context) Core Data.
//    После создания объекта ему присваивается значение, переданное в параметре text (в поле name).
//    Далее вызывается метод saveData(), который сохраняет изменения в базе данных.
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


//Чтобы актуализировать список фруктов, вызывается метод fetchFruits(), который заново загружает все записи из базы данных. Это позволяет интерфейсу обновиться и отобразить самые последние данные, включая все изменения, сделанные в процессе добавления или удаления фруктов.
