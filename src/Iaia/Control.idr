module Iaia.Control

import Iaia

%access public export
%default total

||| A generalization of interfaces like `Traversable` and `Distributive`, this
||| represents a sequencing operation. It can’t be encapsulated in an interface,
||| because some instances require additional parameters. As implied above,
||| `sequence` and `cosequence` are the most well-known values of this type.
DistributiveLaw : (Type -> Type) -> (Type -> Type) -> Type
DistributiveLaw f g = {a : Type} -> f (g a) -> g (f a)

||| In Idris, we have to separate `embed` and `project` into two type classes,
||| because dependent types can make it difficult to implement both in some
||| cases.
|||
||| This also brings up questions re: how to implement some operations that make
||| use of both, but don’t _need_ to. E.g., implementing `para` in terms of
||| `gcata` requires `embed`, but there is an alternative definition that could
||| be used for `Recursive (BoundedFix _ f) f`, which doesn’t require `embed` …
||| however, does that mean each other instance needs to explicitly adopt the
||| `gcata` version?
interface Steppable t (f : Type -> Type) | t where
  project : Coalgebra f t
  
interface Costeppable t (f : Type -> Type) | t where
  embed : Algebra f t
  
interface Recursive t (f : Type -> Type) | t where
  cata : Algebra f a -> t -> a
  -- ||| Types that have a `Costeppable` `implementation` can simply use `para'`
  -- ||| here.
  -- para : (f (t, a) -> a) -> t -> a

interface Corecursive t (f : Type -> Type) | t where
  ana : Coalgebra f a -> a -> t

lambek : (Costeppable t f, Recursive t f, Functor f) => Coalgebra f t
lambek {t=t} = cata $ map $ embed {t}

colambek : (Steppable t f, Corecursive t f, Functor f) => Algebra f t
colambek ft = ana (map project) ft

||| Makes it possible to provide a 'GCoalgebra' to 'ana'.
lowerCoalgebra
  : (Functor f, Monad m)
  => DistributiveLaw m f
  -> GCoalgebra m f a
  -> Coalgebra f (m a)
lowerCoalgebra k ψ = map join . k . map ψ

gana
  : (Corecursive t f, Functor f, Monad m)
  => DistributiveLaw m f
  -> GCoalgebra m f a
  -> a
  -> t
gana k ψ = ana (lowerCoalgebra k ψ) . pure

-- lowerAlgebra
--   : (Functor f, Comonad w)
--   => DistributiveLaw f w
--   -> GAlgebra w f a
--   -> Algebra f (w a)
-- lowerAlgebra k φ = fmap φ . k . fmap duplicate

-- gcata
--   : (Recursive t f, Functor f, Comonad w)
--   => DistributiveLaw f w
--   -> GAlgebra w f a
--   -> t
--   -> a
-- gcata k φ = extract . cata (lowerAlgebra k φ)

-- Arrow defined for functions
infixr 3 ***
infixr 3 &&&
infixr 3 \|/
public export first : (a -> c) -> (a, b) -> (c, b)
first f = \(a, b) => (f a, b)
public export second : (b -> d) -> (a, b) -> (a, d)
second f = \(a, b) => (a, f b)
public export (***) : (a -> c) -> (b -> d) -> (a, b) -> (c, d)
f *** g = \(a, b) => (f a, g b)
public export (&&&) : (a -> c) -> (a -> d) -> a -> (c, d)
f &&& g = \a => (f a, g a)
public export (\|/) : (a -> c) -> (b -> c) -> Either a b -> c
f \|/ g = \a => case a of
                  Left a => f a
                  Right a => g a

distZygo : Functor f => Algebra f a -> DistributiveLaw f (Pair a)
distZygo φ = φ . map fst &&& map snd

distGApo : Functor f => Coalgebra f a -> DistributiveLaw (Either a) f
distGApo ψ = map Left . ψ \|/ map Right
