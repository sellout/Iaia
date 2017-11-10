module Iaia.Zoo

import Iaia
import Iaia.Control

%access public export
%default total

apo
  : (Corecursive t f, Steppable t f, Functor f)
  => GCoalgebra (Either t) f a
  -> a
  -> t
apo = gana $ distGApo project
