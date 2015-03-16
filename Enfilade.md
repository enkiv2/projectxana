# Introduction #

The enfilade, along with other xanalogical entities, forms the cornerstone of the XANA idea. The enfilade is an address, of sorts, and also serves as a non-binding hierarchical structure for use in a simulation of directory structures.


# Details #

An enfilade is defined in BNF as this:
```
  Tumbler =: (([0-9]+)".")*([0-9]+)

  Enfilade =: (<Tumbler>".0.")*<Tumbler>"v"([0-9]+)
```
To be specific, a tumbler is a series of 64-bit numbers between 1 and (2^64)-1 separated by dots, and an enfilade is a series of tumblers separated by zeros, followed by a version number (also 64-bit). All these numbers are positive integers.

Enfilades are addresses which specify a particular document, or a span of documents. They are versioned, and no versions are deleted. A version of 0 specifies the newest version.

Enfilades which do not specify a document specify the span of documents within the subenfilade that is discluded. For example, if there were 12 documents, numbered 1.0.1 through 1.0.12, specifying the enfilade 1 would span all of them.

Please note that in the current implementation a tumbler can contain up to 2<sup>64 digits, and an enfilade can contain up to 2</sup>64 tumblers.