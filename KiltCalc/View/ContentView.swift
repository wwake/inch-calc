import SwiftUI

struct ContentView: View {
  @ObservedObject var calculator: Calculator
  @State private var selectedUnitFormat: ImperialFormatter = .inches
  @State private var selectedRounding: Int = 8

  internal var didAppear: ((Self) -> Void)? // for ViewInspector

  var keypad = Keypad()

  let columns = Array(repeating: GridItem(.flexible()), count: 5)

  let roundingDenominators = [8, 16]

  var body: some View {
    ZStack {
      Image(decorative: "Background")
        .resizable()
        .ignoresSafeArea()

      VStack {
        Text(calculator.display)
          .accessibilityLabel("display")
          .padding(4)
          .frame(width: 330, alignment: .trailing)
          .background(Color.white)
          .border(Color.black)

        HStack {
          Picker("Unit Format", selection: $selectedUnitFormat) {
            ForEach(ImperialFormatter.allCases) {
              Text($0.rawValue)
            }
          }
          .onChange(of: selectedUnitFormat) {
            calculator.imperialFormat = $0
          }
          .accessibilityLabel("unitFormat")
          .pickerStyle(.menu)
        }

        LazyVGrid(columns: columns) {
          ForEach(keypad.contents, id: \.self) { row in
            Group { // GridRow {
              ForEach(row) { key in
                Button(key.name) {
                  calculator.enter(key.entry)
                }
                .frame(width: 60, height: 60)
                .background(Color("KeyColor"))
              }
            }
          }
        }
      }
      .onAppear { self.didAppear?(self) } // for ViewInspector
      .font(.largeTitle)
      .padding()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(calculator: Calculator())
  }
}
