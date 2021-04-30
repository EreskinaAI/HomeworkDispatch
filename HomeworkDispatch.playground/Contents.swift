import Foundation


//MARK:  Direct(static) dispatch (нет наследования, нет полиморфизма)

protocol MyProtocol {
   
}

extension MyProtocol {
    
    func toDoSomething() {
        print("Good bye everybody")
    }
}

class MyClass: MyProtocol {
    
}

extension MyClass {
    func toDoSomething() {
        print("Hello everybody")
    }
}

 let myClassInstance = MyClass()
myClassInstance.toDoSomething() // сработал вызов table dispatch

let myClassInstance2: MyProtocol = MyClass()
myClassInstance2.toDoSomething()//  сработал вызов direct dispatch

//MARK: Witness-table dispatch (нет наследования, но есть полиморфизм)

protocol EntityProtocol {
    func someMethod()
}

struct MyEntity: EntityProtocol { // либо final class MyEntity: EntityProtocol
    func someMethod() {
            print("Good mood to all")
    }
}
 
let instanseStruct = MyEntity()
instanseStruct.someMethod()



//MARK: Vitrual-table dispatch (есть наследование, есть полиморфизм и при этом существенные затраты на компиляцию)
 
class MyClass1 {
    func myClass1Function() {
        print("Do everything from MyClass1")
    }
}

class MyClass2: MyClass1 {
    override func myClass1Function() {
        print("Do something")
    }
    func myClass2Function() {
        print("Do everything from MyClass2")
    }
}

let myClass1Instance = MyClass1()
myClass1Instance.myClass1Function()

let myClass2Instance = MyClass2()
myClass2Instance.myClass1Function()
myClass2Instance.myClass2Function()
 
 

//MARK: Message dispatch(видна objc-runtime - swizzling, ,общение с помощью message forwarding, добавляем ключевое dynamic, обязательный наследник от NSObgect для KVC/KVO )

// Создаем класс с fake code
class SomeTestClass {
    
    @objc
    dynamic class func forTesting_SaveSomeThings(_ someThings: [String]) {
        print("forTesting_SaveReportCategories called")
    }
    
    // Перехватываем у каждого класса конкретный метод через #selector (swizzling)
    static let originalMethod = class_getClassMethod(SomeClass.self, #selector(SomeClass.SaveSomeThings(_:)))
    static let swizzledMethod = class_getClassMethod(SomeTestClass.self, #selector(SomeTestClass.forTesting_SaveSomeThings(_:)))
    
    // Заменяем реализации методов местами (real code на fake code)
    static func someTestMethod() {
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
    
    // Останавливаем замену реализаций методов (возвращает все обратно)
    static func stop() {
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}

// Создаем класс с real code
class SomeClass {
    
    @objc
    dynamic class func SaveSomeThings(_ someThings: [String]) {
        print("real code getting called")
    }
}

SomeTestClass.someTestMethod()
SomeClass.SaveSomeThings([])
SomeClass.SaveSomeThings([])
SomeClass.SaveSomeThings([])
SomeTestClass.stop()
SomeClass.SaveSomeThings([])

