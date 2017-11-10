module Iaia.Native.Control

import Iaia

%access public export
%default total

partial
hylo : Functor f => Algebra f b -> Coalgebra f a -> a -> b
hylo φ ψ = φ . map (hylo φ ψ) . ψ
