# `CodingKeyPath`

* Authors: [Cal Stephens](https://twitter.com/calstephens98)
* Prototype implementation: [`calda/swift cal--coding-key-path`](https://github.com/calda/swift/tree/cal--coding-key-path)
* Status: Pitch in-progress

## Introduction

Today, encoding and decoding `Codable` objects using the compiler's synthesized implementation requires that your object graph has a one-to-one mapping to the object graph of the target payload. This decreases the control that authors have over their `Codable` models.

I propose that we add a new `CodingKeyPath` type that allows consumers to key into nested objects using [dot notation](https://www.w3schools.com/js/js_json_objects.asp).

## Motivation

Application authors often have little to no control over the structure of the encoded payloads they receive. It is often desirable to rename or reorganize fields of the payload at the time of deocoding.

Here is a theoretical JSON payload representing a Swift Evolution proposal ([SE-0274](https://github.com/apple/swift-evolution/blob/master/proposals/0274-magic-file.md)):

```json
{
    "id": "SE-0274",
    "title": "Concise magic file names",
    "metadata": {
        "review_start_date": "2020-01-08T00:00:00Z",
        "review_end_date": "2020-01-16T00:00:00Z"
    }
}
```

The consumer of this object may desire to hoist fields from the `metadata` object to the root level:

```swift
struct EvolutionProposal: Codable {
    var id: String
    var title: String
    var reviewStartDate: Date
    var reviewEndDate: Date
}
```

Today, this would require writing a fair amount of boilerplate. The consumer would need to either [write a custom encoding and decoding implementation](https://github.com/calda/CodingKeyPath/blob/master/Playgrounds/NestedCodingKeys_WithCustomCodingImplementation.playground/Contents.swift) or [proxy to Codable subtypes](https://github.com/calda/CodingKeyPath/blob/master/Playgrounds/NestedCodingKeys_ProxyingToCodableSubtypes.playground/Contents.swift).

## Proposed solution

I propose that we add a new `CodingKeyPath` type that allows consumers to key into nested objects using [dot notation](https://www.w3schools.com/js/js_json_objects.asp).

```swift
struct EvolutionProposal: Codable {
    var id: String
    var title: String
    var reviewStartDate: Date
    var reviewEndDate: Date
    
    enum CodingKeyPaths: String, CodingKeyPaths {
        case id
        case title
        case reviewStartDate = "metadata.review_start_date"
        case reviewEndDate = "metadata.review_end_date"
    }
}
```

### Prior art

[`NSDictionary.value(forKeyPath:)`](https://developer.apple.com/documentation/objectivec/nsobject/1416468-value) supports retrieving nested values using dot notation.

Many existing model parsing frameworks support dot notation for decoding nested keys. Some examples include:
 - **[Mantle](https://github.com/Mantle/Mantle#mtlmodel)**, _"Model framework for Cocoa and Cocoa Touch"_
 - **[Unbox](https://github.com/JohnSundell/Unbox#key-path-support)**, _"The easy to use Swift JSON decoder"_
 - **[ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper#easy-mapping-of-nested-objects)**, _"Simple JSON Object mapping written in Swift"_

## Detailed design

// TODO

## Source compatibility

This proposal is purely additive, so it has no effect on source compatibility.

## Effect on ABI stability

This proposal is purely additive, so it has no effect on ABI stability.

## Effect on API resilience

This proposal is purely additive to the public API of `Foundation.JSONEncoder` and `Foundation.JSONDecoder`. If this proposal was adopted and implemented, it would not be able to be removed resiliently.

## Alternatives considered

### Make this the default behavior

Valid JSON keys may contain dots:

```
{
    "id": "SE-0274",
    "title": "Concise magic file names",
    "metadata.review_start_date": "2020-01-08T00:00:00Z",
    "metadata.review_end_date": "2020-01-16T00:00:00Z"
}
```

It's very likely that there are existing `Codable` models that rely on this behavior, so we must continue supporting it by default.

// TODO: update for the new pitch

We could potentially make `NestedKeyDecodingStrategy.useDotNotation` the default behavior of `JSONDecoder` by preferring the flat key when present. This (probably) wouldn't break any existing models.

We wouldn't be able to support both nested and flat keys in `JSONEncoder`, since encoding is a one-to-one mapping (unlike decoding, which can potentially be a many-to-one mapping).

### Support indexing into arrays or other advanced operations

This design could potentially support advanced operations like indexing into arrays (`metadata.authors[0].email`, etc). Objective-C Key-Value Coding paths, for example, has a [very complex and sophisticated](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueCoding/CollectionOperators.html#//apple_ref/doc/uid/20002176-BAJEAIEE) DSL. The author believes that there isn't enough need or existing precident to warrant a more complex design.

### Enable this behavior by setting a flag on individual encoders

// TODO, reference the previous proposal

