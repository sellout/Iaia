module Iaia.Data

import Iaia
import Iaia.Control

%access public export
%default total

||| A fixed-point operator for inductive / finite data structures.
data Mu : (Type -> Type) -> Type where
  MuF : ({a : Type} -> Algebra f a -> a) -> Mu f

mutual
  implementation Functor f => Costeppable (Mu f) f where
    embed fm = MuF (\φ => φ (map (cata φ) fm))

  implementation Functor f => Recursive (Mu f) f where
    cata φ (MuF f) = f φ
    -- para = para'

implementation Functor f => Steppable (Mu f) f where
  project = lambek

||| A fixed-point operator for coinductive / potentially-infinite data
||| structures.
data Nu : (Type -> Type) -> Type where
  NuF : Coalgebra f a -> a -> Nu f

implementation Functor f => Steppable (Nu f) f where
  project (NuF f a) = NuF f <$> f a

mutual
  implementation Functor f => Costeppable (Nu f) f where
    embed = colambek

  implementation Corecursive (Nu f) f where
    ana = NuF

||| A type that has either two values or none (isomorphic to `Maybe (a, b)`).
||| This is also the pattern functor for list-like structures.
data XNor : Type -> Type -> Type where
  Neither : XNor a b
  Both : a -> b -> XNor a b

||| A type that has either one value or two (isomorphic to `(a, Maybe b)`). This
||| is also the pattern functor for non-empty list-like structures.
data AndMaybe : Type -> Type -> Type where
  Only : a -> AndMaybe a b
  Indeed : a -> b -> AndMaybe a b

implementation Steppable Nat Maybe where
  project Z     = Nothing
  project (S n) = Just n

implementation Costeppable Nat Maybe where
  embed = maybe Z S
