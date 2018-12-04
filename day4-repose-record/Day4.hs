module Main where

import Data.Map (Map)
import Data.List (sort, lines)
import System.IO

substring :: Int -> Int -> String -> String
substring start end text = take (end - start) (drop start text)


getGuardName :: String -> String
getGuardName line = head (drop 3 (words line))

getMinute :: String -> Int
getMinute line = read (substring 3 5 (head (drop 1 (words line)))) :: Int

sortRecords :: [String] -> [String]
sortRecords records = sort records

loadInput :: String -> [String]
loadInput contents = do
    sortRecords (lines contents)

part1 :: String -> String
part1 input = do
    head (loadInput input)

main = do
    s <- readFile "input"
    putStrLn ( part1 s)