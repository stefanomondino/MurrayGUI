//
//  TabBar.swift
//  TabBar
//
//  Created by Gesen on 2020/2/23.
//  https://github.com/wxxsw/TabBar
//

import SwiftUI

public struct TabBar<SelectionValue, Content>: View where SelectionValue: Hashable, Content: View {
    public enum Position {
        case top
        case bottom
    }
    private let model: TabBarModel<SelectionValue>
    private let content: Content

    public init(position: Position = .top, selection: Binding<SelectionValue>, @ViewBuilder content: () -> Content) {
        self.model = TabBarModel(selection: selection)
        self.content = content()
        self.position = position
    }
    let position: Position
    @State private var items: [TabBarItemPreferenceKey.Item] = []
    public var body: some View {
        VStack(spacing: 0) {
            if position == .bottom {
                ZStack {
                    self.content
                        .environmentObject(self.model)
                }
                Divider()
            }
            HStack(spacing: 4) {
                Spacer()
                ForEach(self.items, id:\.self) { item in
                    item.label
                        .onTapGesture {
                            if let i = item.index as? SelectionValue {
                                self.model.selection = i
                            }
                    }
                }.padding(4)
                Spacer()
            }
            if position == .top {
                Divider()
                ZStack {
                    self.content
                        .environmentObject(self.model)
                }
            }


        }
        .overlayPreferenceValue(TabBarItemPreferenceKey.self) { p in
            { () -> Color in
                DispatchQueue.main.async {
                    self.items = p
                }
                return Color.clear
            }()
        }
    }
}

extension TabBar where SelectionValue == Int {

    public init(position: Position = .top, @ViewBuilder content: () -> Content) {
        self.model = TabBarModel(selection: .constant(0))
        self.content = content()
        self.position = position
    }

}

class TabBarModel<SelectionValue: Hashable>: ObservableObject {

    @Binding var selection: SelectionValue {
        didSet { objectWillChange.send() }
    }

    init(selection: Binding<SelectionValue>) {
        self._selection = selection
    }
}

extension View {

    public func tabBarItem<I: Hashable, V: View>(_ index: I, @ViewBuilder _ label: () -> V) -> some View {
        modifier(TabBarItemModifier(index: index, label: label()))
    }

    fileprivate func isSelected(_ isSelected: Bool) -> some View {
        modifier(TabBarItemSelectedModifier(isSelected: isSelected))
    }
}


struct TabBarItemModifier<SelectionValue: Hashable, Label: View>: ViewModifier {
    var index: SelectionValue
    var label: Label

    func body(content: Content) -> some View {
        Group {
            if index == model.selection {
                content
            } else {
                Color.clear
            }
        }
        .preference(key: TabBarItemPreferenceKey.self,
                    value: [.init(index: index, label: label.isSelected(model.selection == index))])
    }
    @EnvironmentObject var model: TabBarModel<SelectionValue>
}
struct TabBarItemSelectedModifier: ViewModifier {
    var isSelected: Bool


    func body(content: Content) -> some View {
        content
            .foregroundColor(isSelected ? Color("accent") : .secondary)
//            .opacity(isSelected ? 1 : 0.7)
    }
}

struct TabBarSizePreferenceKey: PreferenceKey {
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }

    typealias Value = CGSize
    static var defaultValue: CGSize = .zero
}

struct TabBarItemPreferenceKey: PreferenceKey {

    struct Item: Identifiable, Hashable {
        static func == (lhs: TabBarItemPreferenceKey.Item, rhs: TabBarItemPreferenceKey.Item) -> Bool {
            lhs.id == rhs.id
        }

        let id = UUID()
        let index: Any
        let label: AnyView

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        init<V: View>(index: Any, label: V) {
            self.index = index
            self.label = AnyView(label)
        }
    }

    typealias Value = [Item]

    static var defaultValue: [Item] = []

    static func reduce(value: inout [Item], nextValue: () -> [Item]) {
        value.append(contentsOf: nextValue())
    }
}

public struct TabBarPlaceholder: View {

    public var body: some View {
        Color.clear
        //            .frame(height: 44)
    }
}
