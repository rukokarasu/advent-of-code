module Day10
    ( def
    , getKnot
    , main
    , pad
    , part1
    , part2
    , rev
    , reverseUpTo
    , shift
    ) where

import Data.Bits (xor)
import Data.Char (isSpace, ord)
import Data.List (foldl')
import Data.List.Split (chunksOf)
import Numeric (showHex)

shift :: Int -> [a] -> [a]
shift n xs
    | n < 0     = shift (length xs + n) xs
    | otherwise = zipWith const (drop n (cycle xs)) xs

reverseUpTo :: Int -> [a] -> [a]
reverseUpTo len xs = reverse (take len xs) ++ drop len xs

rev :: Int -> Int -> [a] -> [a]
rev index len = shift (-index) . reverseUpTo len . shift index

data State = State {
    knot :: [Int],
    skipSize :: Int,
    pos :: Int
} deriving Show

getKnot :: State -> [Int]
getKnot (State k s p) = k

def :: State
def = State [0..255] 0 0

part1 :: [Int] -> State -> State
part1 lengths initState = foldl' 
    (\(State knot skipSize pos) len -> let r = rev pos len knot in r `seq`
        State r (skipSize + 1) ((pos + len + skipSize) `mod` length knot))
    initState
    lengths

part2 :: String -> State -> String
part2 lengths initKnot =
    let lengths' = map ord lengths ++ [17, 31, 73, 47, 23]
        sparseHash = getKnot $ iterate (part1 lengths') initKnot !! 64
        foldXor = foldr xor 0
        denseHash = map foldXor $ chunksOf 16 sparseHash
    in  concat [pad 2 '0' $ showHex x "" | x <- denseHash]

pad :: Int -> Char -> String -> String
pad len c str = replicate (len - length str) c ++ str

main :: IO ()
main = do
    file <- filter (not . isSpace) <$> readFile "10.txt"
    let lengths = read $ "[" ++ file ++ "]"
    print . (\x -> x!!0 * x!!1) . getKnot $ part1 lengths def
    putStrLn $ part2 file def
