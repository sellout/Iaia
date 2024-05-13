module Iaia.Zoo

import Control.Comonad
import Iaia
import Iaia.Control

%access public export
%default total

-- __TODO__: This should be in the comonad library
Comonad (Pair a) where
  duplicate (b, a) = (b, (b, a))
  extract (_, a) = a

gcata
  : (Recursive t f, Functor f, Comonad w)
  => DistributiveLaw f w
  -> GAlgebra w f a
  -> t
  -> a
gcata k φ = extract . cata (lowerAlgebra k φ)

zygo
  : (Recursive t f, Functor f)
  => Algebra f a
  -> GAlgebra (Pair a) f b
  -> t
  -> b
zygo φ' = gcata $ distZygo φ'

para
  : (Costeppable t f, Recursive t f, Functor f)
  => GAlgebra (Pair t) f a
  -> t
  -> a
para = zygo embed

apo
  : (Corecursive t f, Steppable t f, Functor f)
  => GCoalgebra (Either t) f a
  -> a
  -> t
apo = gana $ distGApo project
