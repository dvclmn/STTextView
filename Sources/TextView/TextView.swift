//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import Foundation
import SwiftUI
import STTextView

public struct TextView: SwiftUI.View {
    @Environment(\.colorScheme) private var colorScheme

    @Binding private var text: AttributedString
    private var font: NSFont
    private var wrapLines: Bool

    public init(
        text: Binding<AttributedString>,
        font: NSFont = .preferredFont(forTextStyle: .body),
        wrapLines: Bool = true
    ) {
        _text = text
        self.font = font
        self.wrapLines = wrapLines
    }

    public init(
        text: Binding<String>,
        font: NSFont = .preferredFont(forTextStyle: .body),
        wrapLines: Bool = true
    ) {
        self = TextView(
            text: Binding(
                get: {
                    var container = AttributeContainer()
                    container[AttributeScopes.AppKitAttributes.FontAttribute.self] = font
                    return AttributedString(text.wrappedValue, attributes: container)
                },
                set: { attributedString in
                    text.wrappedValue = String(attributedString.characters[...])
                }
            ),
            font: font,
            wrapLines: wrapLines
        )
    }

    public var body: some View {
        TextViewRepresentable(
            text: $text,
            font: font,
            wrapLines: wrapLines
        )
        .background(.background)
    }
}

private struct TextViewRepresentable: NSViewRepresentable {
    @Environment(\.isEnabled) private var isEnabled

    @Binding var text: AttributedString
    var font: NSFont
    var wrapLines: Bool

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = STTextView.scrollableTextView()
        let textView = scrollView.documentView as! STTextView
        textView.font = font
        textView.attributedString = NSAttributedString(text)
        textView.delegate = context.coordinator
        textView.widthTracksTextView = wrapLines
        textView.selectedRange = .init()
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        context.coordinator.parent = self

        let textView = scrollView.documentView as! STTextView
        textView.isEditable = isEnabled
        textView.isSelectable = isEnabled
        textView.widthTracksTextView = wrapLines
    }

    func makeCoordinator() -> TextCoordinator {
        TextCoordinator(parent: self)
    }

    class TextCoordinator: STTextViewDelegate {
        var parent: TextViewRepresentable

        init(parent: TextViewRepresentable) {
            self.parent = parent
        }

        func textViewDidChangeText(_ notification: Notification) {
            guard let textView = notification.object as? STTextView else {
                return
            }

            parent.text = AttributedString(textView.attributedString)
        }

    }
}
