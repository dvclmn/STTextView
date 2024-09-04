//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import Foundation
import SwiftUI

public typealias EditorHeightUpdate = (_ height: CGFloat) -> Void

public struct TextViewRepresentable: NSViewRepresentable {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.font) private var font
    @Environment(\.lineSpacing) private var lineSpacing

    @Binding private var text: AttributedString
    @Binding private var selection: NSRange?
    private var plugins: [any STPlugin]
    var editorHeight: (CGFloat) -> Void

    public init(
        text: Binding<AttributedString>,
        selection: Binding<NSRange?>,
        plugins: [any STPlugin] = [],
        height: @escaping EditorHeightUpdate = { _ in }
    ) {
        self._text = text
        self._selection = selection
        self.plugins = plugins
        self.editorHeight = height
    }

    public func makeNSView(context: Context) -> NSScrollView {
        let scrollView = STTextView.scrollableTextView()
        let textView = scrollView.documentView as! STTextView
        textView.textDelegate = context.coordinator
        textView.highlightSelectedLine = false
        textView.isHorizontallyResizable = false
        textView.showsLineNumbers = false
        textView.textSelection = NSRange()
        textView.textContainer.lineFragmentPadding = 30
        
        
        context.coordinator.isUpdating = true
        textView.attributedText = NSAttributedString(styledAttributedString(textView.typingAttributes))
        context.coordinator.isUpdating = false

        for plugin in plugins {
            textView.addPlugin(plugin)
        }
        
        textView.onHeightUpdate = { height in
            DispatchQueue.main.async { self.editorHeight(height) }
        }

        return scrollView
    }

    public func updateNSView(_ scrollView: NSScrollView, context: Context) {
        context.coordinator.parent = self

        let textView = scrollView.documentView as! STTextView

        do {
            context.coordinator.isUpdating = true
            if context.coordinator.isDidChangeText == false {
                textView.attributedText = NSAttributedString(styledAttributedString(textView.typingAttributes))
            }
            context.coordinator.isUpdating = false
            context.coordinator.isDidChangeText = false
        }

        if textView.textSelection != selection, let selection {
            textView.textSelection = selection
        }

        if textView.isEditable != isEnabled {
            textView.isEditable = isEnabled
        }

        if textView.isSelectable != isEnabled {
            textView.isSelectable = isEnabled
        }

        if textView.font != font {
            textView.font = font
        }

        textView.needsLayout = true
        textView.needsDisplay = true
    }

    public func makeCoordinator() -> TextCoordinator {
        TextCoordinator(parent: self)
    }

    private func styledAttributedString(_ typingAttributes: [NSAttributedString.Key: Any]) -> AttributedString {
        let paragraph = (typingAttributes[.paragraphStyle] as! NSParagraphStyle).mutableCopy() as! NSMutableParagraphStyle
        if paragraph.lineSpacing != lineSpacing {
            paragraph.lineSpacing = lineSpacing
            var typingAttributes = typingAttributes
            typingAttributes[.paragraphStyle] = paragraph

            let attributeContainer = AttributeContainer(typingAttributes)
            var styledText = text
            styledText.mergeAttributes(attributeContainer, mergePolicy: .keepNew)
            return styledText
        }

        return text
    }

    public class TextCoordinator: STTextViewDelegate {
        var parent: TextViewRepresentable
        var isUpdating: Bool = false
        var isDidChangeText: Bool = false
        var enqueuedValue: AttributedString?

        init(parent: TextViewRepresentable) {
            self.parent = parent
        }

        public func textViewDidChangeText(_ notification: Notification) {
            guard let textView = notification.object as? STTextView else {
                return
            }

            if !isUpdating {
                let newTextValue = AttributedString(textView.attributedText ?? NSAttributedString())
                DispatchQueue.main.async {
                    self.isDidChangeText = true
                    self.parent.text = newTextValue
                    
                    self.parent.editorHeight(textView.editorHeight)
                }
            }
        }

        public func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? STTextView else {
                return
            }

            Task { @MainActor in
                self.isDidChangeText = true
                self.parent.selection = textView.selectedRange()
            }
        }

    }
}

