# Iaia

A total recursion scheme library for Idris

## Overview

Recursion schemes allow you to separate _any_ recursion from your business logic, writing step-wise operations that can be applied in a way that guarantees termination (or, dually, progress).

How’s this possible? You can’t have totality _and_ Turing-completeness, can you? Oh, but [you can](https://pdfs.semanticscholar.org/e291/5b546b9039a8cf8f28e0b814f6502630239f.pdf) – there is a particular type, `Partial a` (encoded with a fixed-point) that handles potential non-termination, akin to the way that `Maybe a` handles exceptional cases. It can be folded into `IO` in your main function, so that the runtime can execute a Turing-complete program that was modeled totally.

## Some (hopefully) helpful guidelines

Greek characters (and names) for things can often add confusion, however, there are some that we’ve kept here because I think (with the right mnemonic) they’re actually clarifying.

<!-- vale Vale.Spelling = NO -->

- `φ` – an algebra – “phi” (pronounced [/faɪ/](http://ipa-reader.xyz/?text=fa%C9%AA) or [[fi]](http://ipa-reader.xyz/?text=fi))
<!-- vale Vale.Spelling = YES -->
- `ψ` – a coalgebra – “psi” (pronounced [/ˈ(p)saɪ/](<http://ipa-reader.xyz/?text=%CB%88(p)sa%C9%AA>) or [[ˈpsi]](http://ipa-reader.xyz/?text=%CB%88psi))

These are the symbols used in “the literature”, but I think they also offer a good visual mnemonic – φ, like an algebra, is folded inward, while ψ, like a coalgebra, opens up. So, I find these symbols more evocative than `f` and `g` or `algebra` and `coalgebra`, or any other pair of names I’ve come across for these concepts.

There are two other names, `Mu` and `Nu` (for the inductive and coinductive fixed-point operators), that I _don’t_ think have earned their place, but I just haven’t come up with something more helpful yet.

## type classes

```
        Embeddable  Projectable
         /      \    /       \
Corecursive    Steppable    Recursive
           \               /
            \             /
             \           /
              Birecursive
```

## sister libraries

This is part of a family of recursion scheme libraries, alongside [Yaya](https://github.com/sellout/yaya) in Haskell and [Turtles](https://github.com/sellout/turtles) in Scala. They all have the same general approach and goal, which is providing _total_ alternatives to general recursion to help eliminate non-termination from your software.

However, each of these libraries, being implemented in different languages, is necessarily a bit different.

|                                               | `Fix`              | “unsafe” operations                         | `Steppable` superclasses       | `Zoo`       |
| --------------------------------------------- | ------------------ | ------------------------------------------- | ------------------------------ | ----------- |
| [Caca](https://github.com/sellout/caca)       | inductive          | `unsafe` namespace in `unsafe` library      | `Projectable`                  | encouraged  |
| [Dada](https://github.com/sellout/dada)       | N/A                | N/A                                         | `Embeddable` and `Projectable` | encouraged  |
| Iaia                                          | inductive, bounded | `Native` (because they’re tagged `partial`) | `Embeddable` and `Projectable` | discouraged |
| [Turtles](https://github.com/sellout/turtles) | inductive          | `Unsafe` package in `unsafe` library        | `Projectable`                  | encouraged  |
| [Yaya](https://github.com/sellout/yaya)       | inductive          | `Unsafe` module in `unsafe` package         | `Projectable`                  | discouraged |

## encouraging totality

- Haskell: Use [LiquidHaskell](https://github.com/ucsd-progsys/liquidhaskell)
- Idris: Use `%default total` in every file
- Scala: Use [WartRemover](http://www.wartremover.org/), specifically the `Recursion` wart. However, be careful as `@tailrec` silences the warning even though it only ensures stack safety, not termination.
