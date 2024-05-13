||| The usual data types, but re-expressed in terms of fixed-points.
module Iaia.Applied

import Iaia
import Iaia.Control
import Iaia.Data

%access public export
%default total

infinity : (Corecursive t Maybe) => t
infinity = ana Just ()

List : Type -> Type
List a = Mu (XNor a)

Colist : Type -> Type
Colist a = Nu (XNor a)

Stream : Type -> Type
Stream a = Nu (Pair a)
