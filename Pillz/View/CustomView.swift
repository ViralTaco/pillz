//
//   CustomView.swift
//   pillz
//
//   Created by viraltaco_ on 20200102.
//   Copyright © 2020 viraltaco_. All rights reserved.
//


/**
 * • The view begins with creating a DrugList and LogList
 *    using the DrugListDecoder and LogListDecoder
 *
 * • The view will show and edit the DrugList and LogList
 *
 * • The view ends with writing the changes to file
 *    using the DrugListEncoder and LogListEncoder
 */

import Foundation
import Rainbow

class CustomView {
  private let app: App
  private var current: CurrentView = .main
  private var drug: Drug? = nil
  
// MARK: init
  required init() {
    self.app = try! App()
  }

// MARK: public methods
  public func run() -> Never {
    _ = doAction(Action.back) // show main at start
    while let line = CustomView.prompt() {
      if let action = try? app.command(line) {
        if doAction(action) == App.stop { break }
        save() // MARK: save
      }
    }
    return exit(EXIT_SUCCESS)
  }
  
  public func last(_ max: Int) -> Void {
    if self.drug != nil {
      LogView.print(self.app.logs.last(for: self.drug, max))
    } else {
      LogView.print(self.app.logs.last(max))
    }
  }
  
  public func printLogs() -> Void {
    LogView.print(self.app.logs.list)
  }
  
  public func printVersion() -> Void {
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      print("pillz \(version)\n"
          + "Copyright © 2019-\(DateView().year) Anthony Capobianco")
    }
  }
  
  public func printLicense() -> Void {
    printVersion()
    print(ViewConstants.license)
  }
  
// MARK: public static methods
  public static func confirm() -> Bool {
    print(ViewConstants.confirm)
    if let answer = readLine() {
      if answer == "YES" { return true }
    }
    return false
  }
  
// MARK: private methods
  private func doAction(_ action: Action) -> Bool {
    switch action {
    case .clear, .back:
      drawMain()
    case .last(let selection):
      self.last(selection)
      setCurrent(.last)
    case .logs(let logs):
      LogView.print(logs)
      setCurrent(.logs)
    case .help:
      setCurrent(.help)
    case .select(let selection):
      select(selection)
    case .error(let error):
      setCurrent(.error(error.localizedDescription))
    case .rm(let select):
      remove(select)
      
    case .exit:
      save()
      return App.stop
    }
    
    return true
  }
  
  private func remove(_ item: ID) -> Void {
    if self.current == .main {
      _ = self.app.drugs.pop(at: Int(item))
    } else if self.current == .drug { // MARK:  dose selection
      _ = self.drug?.pop(at: Int(item))
    }
  }
  
  private func save() -> Void {
    try? self.app.save()
  }
  
  private func setCurrent(_ new: CurrentView = .main) -> Void {
    self.current = new
    self.current.draw()
  }
  
  private func drawMain() -> Void {
    self.setCurrent()
    LogView.print(self.app.logs.last(5))
    DrugView.list(self.app.drugList)
  }
  
  private func select(_ selection: String) -> Void {
    if let index = ID(selection) {
      if self.current != CurrentView.drug {
        self.drug = app.drugList.at(Int(index))
        
        if self.drug?.doseCount == 1 {
            app.addLog(for: self.drug, selection: 0)
            self.drug = nil // goto guard
        }
        
        guard self.drug != nil else {
          drawMain()
          return
        }
        
        setCurrent(.drug)
        LogView.print(app.logs.last(for: self.drug))
        DrugView.print(self.drug)
      } else {
        app.addLog(for: self.drug, selection: Int(index))
        self.drug = nil
        drawMain()
      }
    }
  }
  
  private static func prompt() -> String? {
    return Standard.in.read()
  }
}
