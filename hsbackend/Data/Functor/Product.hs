-- |
-- Module      :  Data.Functor.Product
-- Copyright   :  (c) Ross Paterson 2010
-- License     :  BSD-style (see the file LICENSE)
--
-- Maintainer  :  ross@soi.city.ac.uk
-- Stability   :  experimental
-- Portability :  portable
--
-- Products, lifted to functors.

module Data.Functor.Product (
    Product(..),
  ) where

import Control.Applicative
import Control.Monad (MonadPlus(..))
import Control.Monad.Fix (MonadFix(..))
import Data.Foldable (Foldable(foldMap))
import Data.Functor.Classes
import Data.Monoid (mappend)
import Data.Traversable (Traversable(traverse))

-- | Lifted product of functors.
data Product f g a = Pair (f a) (g a)

instance (Eq1 f, Eq1 g, Eq a) => Eq (Product f g a) where
    Pair x1 y1 == Pair x2 y2 = eq1 x1 x2 && eq1 y1 y2

instance (Ord1 f, Ord1 g, Ord a) => Ord (Product f g a) where
    compare (Pair x1 y1) (Pair x2 y2) =
        compare1 x1 x2 `mappend` compare1 y1 y2

instance (Read1 f, Read1 g, Read a) => Read (Product f g a) where
    readsPrec = readsData $ readsBinary1 "Pair" Pair

instance (Show1 f, Show1 g, Show a) => Show (Product f g a) where
    showsPrec d (Pair x y) = showsBinary1 "Pair" d x y

instance (Eq1 f, Eq1 g) => Eq1 (Product f g) where eq1 = (==)
instance (Ord1 f, Ord1 g) => Ord1 (Product f g) where compare1 = compare
instance (Read1 f, Read1 g) => Read1 (Product f g) where readsPrec1 = readsPrec
instance (Show1 f, Show1 g) => Show1 (Product f g) where showsPrec1 = showsPrec

instance (Functor f, Functor g) => Functor (Product f g) where
    fmap f (Pair x y) = Pair (fmap f x) (fmap f y)

instance (Foldable f, Foldable g) => Foldable (Product f g) where
    foldMap f (Pair x y) = foldMap f x `mappend` foldMap f y

instance (Traversable f, Traversable g) => Traversable (Product f g) where
    traverse f (Pair x y) = Pair <$> traverse f x <*> traverse f y

instance (Applicative f, Applicative g) => Applicative (Product f g) where
    pure x = Pair (pure x) (pure x)
    Pair f g <*> Pair x y = Pair (f <*> x) (g <*> y)

instance (Alternative f, Alternative g) => Alternative (Product f g) where
    empty = Pair empty empty
    Pair x1 y1 <|> Pair x2 y2 = Pair (x1 <|> x2) (y1 <|> y2)

instance (Monad f, Monad g) => Monad (Product f g) where
    return x = Pair (return x) (return x)
    Pair m n >>= f = Pair (m >>= fstP . f) (n >>= sndP . f)
      where
        fstP (Pair a _) = a
        sndP (Pair _ b) = b

instance (MonadPlus f, MonadPlus g) => MonadPlus (Product f g) where
    mzero = Pair mzero mzero
    Pair x1 y1 `mplus` Pair x2 y2 = Pair (x1 `mplus` x2) (y1 `mplus` y2)

instance (MonadFix f, MonadFix g) => MonadFix (Product f g) where
    mfix f = Pair (mfix (fstP . f)) (mfix (sndP . f))
      where
        fstP (Pair a _) = a
        sndP (Pair _ b) = b
