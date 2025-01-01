import Foundation

enum TransformerSetup {
    static func register() {
        ValueTransformer.setValueTransformer(
            StringArrayTransformer(),
            forName: NSValueTransformerName("StringArrayTransformer")
        )
    }
} 