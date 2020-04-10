//
//  TabBar.swift
//  TabBar
//
//  Created by Gesen on 2020/2/23.
//  https://github.com/wxxsw/TabBar
//

import SwiftUI

public struct TabBar<SelectionValue, Content>: View where SelectionValue: Hashable, Content: View {

    private let model: TabBarModel<SelectionValue>
    private let content: Content

    public init(selection: Binding<SelectionValue>, @ViewBuilder content: () -> Content) {
        self.model = TabBarModel(selection: selection)
        self.content = content()
    }
    @State private var tabSize: CGSize = .zero
    public var body: some View {
//        GeometryReader { proxy in

            VStack(spacing: 0) {
                Text(self.tabSize.height.description)
                TabBarPlaceholder()

                    .frame(height: self.tabSize.height)
                    
                ZStack {
                    self.content
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .environmentObject(self.model)
                }
            }
            .overlayPreferenceValue(TabBarItemPreferenceKey.self, { preferences in

                        HStack(spacing: 4) {
                            Spacer()
                            ForEach(preferences) { preference in
                                preference.label
                                    .onTapGesture {
                                        if let i = preference.index as? SelectionValue {
                                            self.model.selection = i
                                        }
                                }
                            }
                            Spacer()
                        }
                        .frame(height: 44)


            }).modifier(SizeModifier())
                .onPreferenceChange(TabBarSizePreferenceKey.self) {
                    if self.tabSize != $0 { self.tabSize = $0 }
        }
//        }
    }
}

struct SizeModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: TabBarSizePreferenceKey.self, value: geometry.size)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}
extension TabBar where SelectionValue == Int {

    public init(@ViewBuilder content: () -> Content) {
        self.model = TabBarModel(selection: .constant(0))
        self.content = content()
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
            .opacity(isSelected ? 1 : 0.7)
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

    struct Item: Identifiable {
        let id = UUID()
        let index: Any
        let label: AnyView

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
            .frame(height: 44)
    }
}
