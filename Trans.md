# Introduction #

Transpointing and transclusion, along with [Enfilade](Enfilade.md)s, form the basis of the xanalogical paradigm, and also the XANA system's structure. Transpointing and transclusion are types of links, designed (along with various incarnations of the enfilade) by Project Xanadu.


# Details #

Transpointing is effectively a hyperlink between two spans. The spans can be enfilade spans, byte spans (within an enfilade), or both. Transpointers can overlap each other, and are stored outside of the document itself (instead of in markup). The target is called the "forward span" and the document that is referring to it is called the "back span". The transpointer also contains what is known as a "threespan", which is a span that references a program that is used to view or manipulate the data that is linked to. All documents in both the forward span and the back span contain the information on the transpointer.

Transclusions are similar to transpointers, except they contain only the back span and the threespan, and one location (half of a span) for the forward. They are essentially quotes. The backspan is processed by the threespan, and inserted into the forward location. This is done by the client or viewer, and is not processed by the backend or filesystem directly. Transclusions are used between versions as follows: new versions transclude all of the data that is the same as the old version from the old version, and the actual document contains only the new data (and chunks of old data that are smaller than the actual transclusion data structure size).

Transclusions and transpointers are defined in BNF as follows:

```
  Halfspan =: <Enfilade>"c"([0-9]+)
  Span =: <Halfspan>"-"<Halfspan>
  Backspan =: <Span>
  Forwardspan =: <Span>
  Threespan =: <Span>
  Forwardloc =: <Halfspan>
  Transpointer =: "P"<Backspan>"~"<Forwardspan>"~"<Threespan>"~\n"
  Transclusion => "C"<Backspan>"~"<Threespan>"~"<Forwardloc>"~\n"
```

The number after the "c" in the halfspan is the byte index. Note that these are the stringified representations.