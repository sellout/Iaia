module Iaia

%access public export
%default total

Algebra : (Type -> Type) -> Type -> Type
Algebra f a = f a -> a

GAlgebra : (Type -> Type) -> (Type -> Type) -> Type -> Type
GAlgebra w f a = f (w a) -> a

Coalgebra : (Type -> Type) -> Type -> Type
Coalgebra f a = a -> f a

GCoalgebra : (Type -> Type) -> (Type -> Type) -> Type -> Type
GCoalgebra m f a = a -> f (m a)
