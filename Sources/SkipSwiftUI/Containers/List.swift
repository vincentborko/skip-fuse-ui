// Copyright 2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !ROBOLECTRIC && canImport(CoreGraphics)
import CoreGraphics
#endif
import SkipBridge
import SkipUI

public struct List<SelectionValue, Content> where SelectionValue : Hashable, Content : View {
    private let content: Content
    private let singleSelection: Binding<SelectionValue?>?
    private let multiSelection: Binding<Set<SelectionValue>>?

    // For data-based selection: closures to extract ID and look up element by ID
    private let getSelectionID: ((SelectionValue) -> SwiftHashable)?
    private let findElementByID: ((SwiftHashable) -> SelectionValue?)?
    private let getAllIDs: (([SelectionValue]) -> [SwiftHashable])?

    public init(selection: Binding<Set<SelectionValue>>?, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.multiSelection = selection
        self.singleSelection = nil
        self.getSelectionID = nil
        self.findElementByID = nil
        self.getAllIDs = nil
    }

    public init(selection: Binding<SelectionValue?>?, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.singleSelection = selection
        self.multiSelection = nil
        self.getSelectionID = nil
        self.findElementByID = nil
        self.getAllIDs = nil
    }

    // Internal init for data-based selection with ID mapping
    private init(content: Content, singleSelection: Binding<SelectionValue?>?, multiSelection: Binding<Set<SelectionValue>>?, getSelectionID: ((SelectionValue) -> SwiftHashable)?, findElementByID: ((SwiftHashable) -> SelectionValue?)?, getAllIDs: (([SelectionValue]) -> [SwiftHashable])?) {
        self.content = content
        self.singleSelection = singleSelection
        self.multiSelection = multiSelection
        self.getSelectionID = getSelectionID
        self.findElementByID = findElementByID
        self.getAllIDs = getAllIDs
    }
}

extension List : View {
    public typealias body = Never
}

extension List : SkipUIBridging {
    public var Java_view: any SkipUI.View {
        // If we have ID-based bridging (from data-based inits), use it
        if let getSelectionID = self.getSelectionID, let findElementByID = self.findElementByID {
            if let singleSelection = self.singleSelection {
                // Return Any? for bridging compatibility
                let getSingleSelection: () -> Any? = {
                    if let value = singleSelection.wrappedValue {
                        return getSelectionID(value)
                    }
                    return nil
                }
                // Accept Any? for bridging compatibility
                let setSingleSelection: (Any?) -> Void = { newID in
                    if let newID = newID as? SwiftHashable, let element = findElementByID(newID) {
                        singleSelection.wrappedValue = element
                    } else {
                        singleSelection.wrappedValue = nil
                    }
                }
                return SkipUI.List(
                    bridgedContent: content.Java_viewOrEmpty,
                    getSingleSelection: getSingleSelection,
                    setSingleSelection: setSingleSelection
                )
            } else if let multiSelection = self.multiSelection, let getAllIDs = self.getAllIDs {
                // SwiftHashable conforms to Hashable, so can be in Set<AnyHashable>
                let getMultiSelection: () -> Set<AnyHashable> = {
                    Set(getAllIDs(Array(multiSelection.wrappedValue)).map { $0 as AnyHashable })
                }
                let setMultiSelection: (Set<AnyHashable>) -> Void = { newIDs in
                    let elements = newIDs.compactMap { ($0 as? SwiftHashable).flatMap { findElementByID($0) } }
                    multiSelection.wrappedValue = Set(elements)
                }
                return SkipUI.List(
                    bridgedContent: content.Java_viewOrEmpty,
                    getMultiSelection: getMultiSelection,
                    setMultiSelection: setMultiSelection
                )
            }
        }

        // Fallback: no selection or content-only init
        return SkipUI.List(bridgedContent: content.Java_viewOrEmpty)
    }
}

extension List {
    public init<Data, RowContent>(_ data: Data, selection: Binding<Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Content == ForEach<Data, Data.Element.ID, RowContent>, Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable, SelectionValue == Data.Element {
        let dataArray = Array(data)
        self.init(
            content: ForEach(data, content: rowContent),
            singleSelection: nil,
            multiSelection: selection,
            getSelectionID: { element in Java_swiftHashable(for: element.id) },
            findElementByID: { id in dataArray.first { Java_swiftHashable(for: $0.id) == id } },
            getAllIDs: { elements in elements.map { Java_swiftHashable(for: $0.id) } }
        )
    }

    @available(*, unavailable)
    public init<Data, RowContent>(_ data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where /* Content == OutlineGroup<Data, Data.Element.ID, RowContent, RowContent, DisclosureGroup<RowContent, OutlineSubgroupChildren>>, */ Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable {
        fatalError()
    }

    public init<Data, ID, RowContent>(_ data: Data, id: KeyPath<Data.Element, ID>, selection: Binding<Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Content == ForEach<Data, ID, RowContent>, Data : RandomAccessCollection, ID : Hashable, RowContent : View, SelectionValue == Data.Element {
        let dataArray = Array(data)
        self.init(
            content: ForEach(data, id: id, content: rowContent),
            singleSelection: nil,
            multiSelection: selection,
            getSelectionID: { element in Java_swiftHashable(for: element[keyPath: id]) },
            findElementByID: { swiftHashableID in dataArray.first { Java_swiftHashable(for: $0[keyPath: id]) == swiftHashableID } },
            getAllIDs: { elements in elements.map { Java_swiftHashable(for: $0[keyPath: id]) } }
        )
    }

    @available(*, unavailable)
    public init<Data, ID, RowContent>(_ data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where /* Content == OutlineGroup<Data, ID, RowContent, RowContent, DisclosureGroup<RowContent, OutlineSubgroupChildren>>, */ Data : RandomAccessCollection, ID : Hashable, RowContent : View {
        fatalError()
    }

    @available(*, unavailable)
    public init<RowContent>(_ data: Range<Int>, selection: Binding<Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Int) -> RowContent) where Content == ForEach<Range<Int>, Int, HStack<RowContent>>, RowContent : View {
        fatalError()
    }

    public init<Data, RowContent>(_ data: Data, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Content == ForEach<Data, Data.Element.ID, RowContent>, Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable, SelectionValue == Data.Element {
        let dataArray = Array(data)
        self.init(
            content: ForEach(data, content: rowContent),
            singleSelection: selection,
            multiSelection: nil,
            getSelectionID: { element in Java_swiftHashable(for: element.id) },
            findElementByID: { id in dataArray.first { Java_swiftHashable(for: $0.id) == id } },
            getAllIDs: nil
        )
    }

    @available(*, unavailable)
    public init<Data, RowContent>(_ data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where /* Content == OutlineGroup<Data, Data.Element.ID, RowContent, RowContent, DisclosureGroup<RowContent, OutlineSubgroupChildren>>, */ Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable {
        fatalError()
    }

    public init<Data, ID, RowContent>(_ data: Data, id: KeyPath<Data.Element, ID>, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Content == ForEach<Data, ID, RowContent>, Data : RandomAccessCollection, ID : Hashable, RowContent : View, SelectionValue == Data.Element {
        let dataArray = Array(data)
        self.init(
            content: ForEach(data, id: id, content: rowContent),
            singleSelection: selection,
            multiSelection: nil,
            getSelectionID: { element in Java_swiftHashable(for: element[keyPath: id]) },
            findElementByID: { swiftHashableID in dataArray.first { Java_swiftHashable(for: $0[keyPath: id]) == swiftHashableID } },
            getAllIDs: nil
        )
    }

    @available(*, unavailable)
    public init<Data, ID, RowContent>(_ data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where /* Content == OutlineGroup<Data, ID, RowContent, RowContent, DisclosureGroup<RowContent, OutlineSubgroupChildren>>, */ Data : RandomAccessCollection, ID : Hashable, RowContent : View {
        fatalError()
    }

    @available(*, unavailable)
    public init<RowContent>(_ data: Range<Int>, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Int) -> RowContent) where Content == ForEach<Range<Int>, Int, RowContent>, RowContent : View {
        fatalError()
    }
}

extension List where SelectionValue == Never {
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
        self.singleSelection = nil
        self.multiSelection = nil
        self.getSelectionID = nil
        self.findElementByID = nil
        self.getAllIDs = nil
    }

    public init<Data, RowContent>(_ data: Data, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Content == ForEach<Data, Data.Element.ID, RowContent>, Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable {
        self.content = ForEach(data, content: rowContent)
        self.singleSelection = nil
        self.multiSelection = nil
        self.getSelectionID = nil
        self.findElementByID = nil
        self.getAllIDs = nil
    }

    @available(*, unavailable)
    public init<Data, RowContent>(_ data: Data, children: KeyPath<Data.Element, Data?>, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where /* Content == OutlineGroup<Data, Data.Element.ID, RowContent, RowContent, DisclosureGroup<RowContent, OutlineSubgroupChildren>>, */ Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable {
        fatalError()
    }

    public init<Data, ID, RowContent>(_ data: Data, id: KeyPath<Data.Element, ID>, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Content == ForEach<Data, ID, RowContent>, Data : RandomAccessCollection, ID : Hashable, RowContent : View {
        self.content = ForEach(data, id: id, content: rowContent)
        self.singleSelection = nil
        self.multiSelection = nil
        self.getSelectionID = nil
        self.findElementByID = nil
        self.getAllIDs = nil
    }

    @available(*, unavailable)
    public init<Data, ID, RowContent>(_ data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where /* Content == OutlineGroup<Data, ID, RowContent, RowContent, DisclosureGroup<RowContent, OutlineSubgroupChildren>>, */ Data : RandomAccessCollection, ID : Hashable, RowContent : View {
        fatalError()
    }

    public init<RowContent>(_ data: Range<Int>, @ViewBuilder rowContent: @escaping (Int) -> RowContent) where Content == ForEach<Range<Int>, Int, RowContent>, RowContent : View {
        self.content = ForEach(data, content: rowContent)
        self.singleSelection = nil
        self.multiSelection = nil
        self.getSelectionID = nil
        self.findElementByID = nil
        self.getAllIDs = nil
    }
}

extension List {
    @available(*, unavailable)
    public init<Data, RowContent>(_ data: Binding<Data>, selection: Binding<Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where Content == ForEach<LazyMapSequence<Data.Indices, (Data.Index, Data.Element.ID)>, Data.Element.ID, RowContent>, Data : MutableCollection, Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable, Data.Index : Hashable {
        fatalError()
    }

    @available(*, unavailable)
    public init<Data, ID, RowContent>(_ data: Binding<Data>, id: KeyPath<Data.Element, ID>, selection: Binding<Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where Content == ForEach<LazyMapSequence<Data.Indices, (Data.Index, ID)>, ID, RowContent>, Data : MutableCollection, Data : RandomAccessCollection, ID : Hashable, RowContent : View, Data.Index : Hashable {
        fatalError()
    }

    @available(*, unavailable)
    public init<Data, RowContent>(_ data: Binding<Data>, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where Content == ForEach<LazyMapSequence<Data.Indices, (Data.Index, Data.Element.ID)>, Data.Element.ID, RowContent>, Data : MutableCollection, Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable, Data.Index : Hashable {
        fatalError()
    }

    @available(*, unavailable)
    public init<Data, ID, RowContent>(_ data: Binding<Data>, id: KeyPath<Data.Element, ID>, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where Content == ForEach<LazyMapSequence<Data.Indices, (Data.Index, ID)>, ID, RowContent>, Data : MutableCollection, Data : RandomAccessCollection, ID : Hashable, RowContent : View, Data.Index : Hashable {
        fatalError()
    }
}

extension List where SelectionValue == Never {
    public init<Data, RowContent>(_ data: Binding<Data>, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where Content == ForEach<LazyMapSequence<Data.Indices, (Data.Index, Data.Element.ID)>, Data.Element.ID, RowContent>, Data : MutableCollection, Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable, Data.Index : Hashable {
        self.content = ForEach(data, content: rowContent)
        self.singleSelection = nil
        self.multiSelection = nil
        self.getSelectionID = nil
        self.findElementByID = nil
        self.getAllIDs = nil
    }

    public init<Data, ID, RowContent>(_ data: Binding<Data>, id: KeyPath<Data.Element, ID>, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where Content == ForEach<LazyMapSequence<Data.Indices, (Data.Index, ID)>, ID, RowContent>, Data : MutableCollection, Data : RandomAccessCollection, ID : Hashable, RowContent : View, Data.Index : Hashable {
        self.content = ForEach(data, id: id, content: rowContent)
        self.singleSelection = nil
        self.multiSelection = nil
        self.getSelectionID = nil
        self.findElementByID = nil
        self.getAllIDs = nil
    }
}

extension List {
    @available(*, unavailable)
    public init<Data, RowContent>(_ data: Binding<Data>, children: WritableKeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where /* Content == OutlineGroup<Binding<Data>, Data.Element.ID, RowContent, RowContent, DisclosureGroup<RowContent, OutlineSubgroupChildren>>, */ Data : MutableCollection, Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable {
        fatalError()
    }

    @available(*, unavailable)
    public init<Data, ID, RowContent>(_ data: Binding<Data>, id: KeyPath<Data.Element, ID>, children: WritableKeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where /* Content == OutlineGroup<Binding<Data>, ID, RowContent, RowContent, DisclosureGroup<RowContent, OutlineSubgroupChildren>>, */ Data : MutableCollection, Data : RandomAccessCollection, ID : Hashable, RowContent : View {
        fatalError()
    }

    @available(*, unavailable)
    public init<Data, RowContent>(_ data: Binding<Data>, children: WritableKeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where /* Content == OutlineGroup<Binding<Data>, Data.Element.ID, RowContent, RowContent, DisclosureGroup<RowContent, OutlineSubgroupChildren>>, */ Data : MutableCollection, Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable {
        fatalError()
    }

    @available(*, unavailable)
    public init<Data, ID, RowContent>(_ data: Binding<Data>, id: KeyPath<Data.Element, ID>, children: WritableKeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where /* Content == OutlineGroup<Binding<Data>, ID, RowContent, RowContent, DisclosureGroup<RowContent, OutlineSubgroupChildren>>, */ Data : MutableCollection, Data : RandomAccessCollection, ID : Hashable, RowContent : View {
        fatalError()
    }
}

extension List where SelectionValue == Never {
    @available(*, unavailable)
    public init<Data, RowContent>(_ data: Binding<Data>, children: WritableKeyPath<Data.Element, Data?>, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where /* Content == OutlineGroup<Binding<Data>, Data.Element.ID, RowContent, RowContent, DisclosureGroup<RowContent, OutlineSubgroupChildren>>, */ Data : MutableCollection, Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable {
        fatalError()
    }

    @available(*, unavailable)
    public init<Data, ID, RowContent>(_ data: Binding<Data>, id: KeyPath<Data.Element, ID>, children: WritableKeyPath<Data.Element, Data?>, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where /* Content == OutlineGroup<Binding<Data>, ID, RowContent, RowContent, DisclosureGroup<RowContent, OutlineSubgroupChildren>>, */ Data : MutableCollection, Data : RandomAccessCollection, ID : Hashable, RowContent : View {
        fatalError()
    }
}

extension List {
    @available(*, unavailable)
    public init<Data, RowContent>(_ data: Binding<Data>, editActions: Any /* EditActions<Data> */, selection: Binding<Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where /* Content == ForEach<IndexedIdentifierCollection<Data, Data.Element.ID>, Data.Element.ID, EditableCollectionContent<RowContent, Data>>, */ Data : MutableCollection, Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable, Data.Index : Hashable {
        fatalError()
    }

    @available(*, unavailable)
    public init<Data, ID, RowContent>(_ data: Binding<Data>, id: KeyPath<Data.Element, ID>, editActions: Any /* EditActions<Data> */, selection: Binding<Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where /* Content == ForEach<IndexedIdentifierCollection<Data, ID>, ID, EditableCollectionContent<RowContent, Data>>, */ Data : MutableCollection, Data : RandomAccessCollection, ID : Hashable, RowContent : View, Data.Index : Hashable {
        fatalError()
    }
}

extension List {
    @available(*, unavailable)
    public init<Data, RowContent>(_ data: Binding<Data>, editActions: Any /* EditActions<Data> */, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where /* Content == ForEach<IndexedIdentifierCollection<Data, Data.Element.ID>, Data.Element.ID, EditableCollectionContent<RowContent, Data>>, Data : MutableCollection, */ Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable, Data.Index : Hashable {
        fatalError()
    }

    @available(*, unavailable)
    public init<Data, ID, RowContent>(_ data: Binding<Data>, id: KeyPath<Data.Element, ID>, editActions: Any /* EditActions<Data> */, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where /* Content == ForEach<IndexedIdentifierCollection<Data, ID>, ID, EditableCollectionContent<RowContent, Data>>, */ Data : MutableCollection, Data : RandomAccessCollection, ID : Hashable, RowContent : View, Data.Index : Hashable {
        fatalError()
    }
}

extension List where SelectionValue == Never {
//    public init<Data, RowContent>(_ data: Binding<Data>, editActions: EditActions<Data>, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where Content == ForEach<IndexedIdentifierCollection<Data, Data.Element.ID>, Data.Element.ID, EditableCollectionContent<RowContent, Data>>, Data : MutableCollection, Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable, Data.Index : Hashable
    public init<Data, RowContent>(_ data: Binding<Data>, editActions: EditActions<Data>, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where Content == ForEach<IndexedIdentifierCollection<Data, Data.Element.ID>, Data.Element.ID, RowContent>, Data : MutableCollection, Data : RandomAccessCollection, Data : RangeReplaceableCollection, RowContent : View, Data.Element : Identifiable, Data.Index : Hashable {
        self.content = ForEach(data, editActions: editActions, content: rowContent)
        self.singleSelection = nil
        self.multiSelection = nil
        self.getSelectionID = nil
        self.findElementByID = nil
        self.getAllIDs = nil
    }

//    public init<Data, ID, RowContent>(_ data: Binding<Data>, id: KeyPath<Data.Element, ID>, editActions: EditActions<Data>, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where Content == ForEach<IndexedIdentifierCollection<Data, ID>, ID, EditableCollectionContent<RowContent, Data>>, Data : MutableCollection, Data : RandomAccessCollection, ID : Hashable, RowContent : View, Data.Index : Hashable
    public init<Data, ID, RowContent>(_ data: Binding<Data>, id: KeyPath<Data.Element, ID>, editActions: EditActions<Data>, @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent) where Content == ForEach<IndexedIdentifierCollection<Data, ID>, ID, RowContent>, Data : MutableCollection, Data : RandomAccessCollection, Data : RangeReplaceableCollection, RowContent : View, Data.Index : Hashable {
        self.content = ForEach(data, id: id, editActions: editActions, content: rowContent)
        self.singleSelection = nil
        self.multiSelection = nil
        self.getSelectionID = nil
        self.findElementByID = nil
        self.getAllIDs = nil
    }
}

public struct ListSectionSpacing : Sendable {
    public static let `default` = ListSectionSpacing()

    public static let compact = ListSectionSpacing()

    public static func custom(_ spacing: CGFloat) -> ListSectionSpacing {
        return ListSectionSpacing()
    }
}

public struct ListItemTint : Sendable {
    public static func fixed(_ tint: Color) -> ListItemTint {
        return ListItemTint()
    }

    public static func preferred(_ tint: Color) -> ListItemTint {
        return ListItemTint()
    }

    public static let monochrome = ListItemTint()
}

public protocol ListStyle {
    nonisolated var identifier: Int { get } // For bridging
}

extension ListStyle {
    nonisolated public var identifier: Int {
        return -1
    }
}

public struct DefaultListStyle : ListStyle {
    public init() {
    }

    public let identifier = 0 // For bridging
}

extension ListStyle where Self == DefaultListStyle {
    public static var automatic: DefaultListStyle {
        return DefaultListStyle()
    }
}

public struct SidebarListStyle : ListStyle {
    @available(*, unavailable)
    public init() {
        fatalError()
    }
}

extension ListStyle where Self == SidebarListStyle {
    @available(*, unavailable)
    public static var sidebar: SidebarListStyle {
        fatalError()
    }
}

public struct InsetListStyle : ListStyle {
    @available(*, unavailable)
    public init() {
        fatalError()
    }

    @available(*, unavailable)
    public init(alternatesRowBackgrounds: Bool) {
        fatalError()
    }
}

extension ListStyle where Self == InsetListStyle {
    @available(*, unavailable)
    public static var inset: InsetListStyle {
        fatalError()
    }

    @available(*, unavailable)
    public static func inset(alternatesRowBackgrounds: Bool) -> InsetListStyle {
        fatalError()
    }
}

public struct PlainListStyle : ListStyle {
    public init() {
    }

    public let identifier = 5 // For bridging
}

extension ListStyle where Self == PlainListStyle {
    public static var plain: PlainListStyle {
        return PlainListStyle()
    }
}

public struct BorderedListStyle : ListStyle {
    @available(*, unavailable)
    public init() {
        fatalError()
    }

    @available(*, unavailable)
    public init(alternatesRowBackgrounds: Bool) {
        fatalError()
    }
}

extension ListStyle where Self == BorderedListStyle {
    @available(*, unavailable)
    public static var bordered: BorderedListStyle {
        fatalError()
    }

    @available(*, unavailable)
    public static func bordered(alternatesRowBackgrounds: Bool) -> BorderedListStyle {
        fatalError()
    }
}

extension View {
    /* @inlinable */ nonisolated public func listRowBackground<V>(_ view: V?) -> some View where V : View {
        return ModifierView(target: self) {
            $0.Java_viewOrEmpty.listRowBackground(view?.Java_viewOrEmpty)
        }
    }

    nonisolated public func listRowSeparator(_ visibility: Visibility, edges: VerticalEdge.Set = .all) -> some View {
        return ModifierView(target: self) {
            $0.Java_viewOrEmpty.listRowSeparator(bridgedVisibility: visibility.rawValue, bridgedEdges: Int(edges.rawValue))
        }
    }

    @available(*, unavailable)
    nonisolated public func listRowSeparatorTint(_ color: Color?, edges: VerticalEdge.Set = .all) -> some View {
        stubView()
    }

    @available(*, unavailable)
    nonisolated public func listSectionSeparator(_ visibility: Visibility, edges: VerticalEdge.Set = .all) -> some View {
        stubView()
    }

    @available(*, unavailable)
    nonisolated public func listSectionSeparatorTint(_ color: Color?, edges: VerticalEdge.Set = .all) -> some View {
        stubView()
    }

    nonisolated public func listStyle<S>(_ style: S) -> some View where S : ListStyle {
        return ModifierView(target: self) {
            $0.Java_viewOrEmpty.listStyle(bridgedStyle: style.identifier)
        }
    }

    @available(*, unavailable)
    /* @inlinable */ nonisolated public func listItemTint(_ tint: ListItemTint?) -> some View {
        stubView()
    }

    /* @inlinable */ nonisolated public func listItemTint(_ tint: Color?) -> some View {
        return ModifierView(target: self) {
            $0.Java_viewOrEmpty.listItemTint(tint?.Java_view as? SkipUI.Color)
        }
    }

    @available(*, unavailable)
    /* @inlinable */ nonisolated public func listRowInsets(_ insets: EdgeInsets?) -> some View {
        stubView()
    }

    @available(*, unavailable)
    /* @inlinable */ nonisolated public func listRowSpacing(_ spacing: CGFloat?) -> some View {
        stubView()
    }

    @available(*, unavailable)
    /* @inlinable */ nonisolated public func listSectionSpacing(_ spacing: ListSectionSpacing) -> some View {
        stubView()
    }

    @available(*, unavailable)
    /* @inlinable */ nonisolated public func listSectionSpacing(_ spacing: CGFloat) -> some View {
        stubView()
    }

    @available(*, unavailable)
    nonisolated public func swipeActions<T>(edge: HorizontalEdge = .trailing, allowsFullSwipe: Bool = true, @ViewBuilder content: () -> T) -> some View where T : View {
        stubView()
    }
}
