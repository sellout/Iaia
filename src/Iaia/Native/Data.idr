||| Data structures that rely on Idris’ built-in recursion.
module Iaia.Native.Data

import Iaia
import Iaia.Control
import Iaia.Data

%access public export
%default total

mutual
  ||| A recursive structure at most `n` nodes deep.
  record BoundedFix (n : Nat) (f : Type -> Type) where
    constructor BFx
    out : boundedFixRec n f

  boundedFixRec : Nat -> (Type -> Type) -> Type
  boundedFixRec Z     _ = Void
  boundedFixRec (S n) f = f (BoundedFix n f)

implementation Uninhabited (BoundedFix Z f) where
  uninhabited (BFx f) impossible 

bunfix : BoundedFix (S n) f -> f (BoundedFix n f)
bunfix = out

-- TODO: Can we do this without explicit recursion?
weaken : Functor f => BoundedFix n f -> BoundedFix (S n) f
weaken {n=Z}   = absurd
weaken {n=S n} = BFx . map weaken . bunfix {n}

implementation Functor f => Steppable (BoundedFix (S n) f) f where
  project = map weaken . bunfix

implementation Functor f => Recursive (BoundedFix n f) f where
  cata {n=Z}   _ = absurd
  cata {n=S n} φ = φ . map (cata φ) . bunfix
  -- para {n=S n} φ = φ . map (it -> (it, para φ it)) . bunfix

Fin : Nat -> Type
Fin n = BoundedFix n Maybe

BoundedList : Nat -> Type -> Type
BoundedList n a = BoundedFix n (XNor a)
