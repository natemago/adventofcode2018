module Main where

import Data.Map (Map)
import qualified Data.Map as Map
import Data.List (sort, lines, null)
import System.IO

substring :: Int -> Int -> String -> String
substring start end text = take (end - start) (drop start text)


getGuardName :: String -> String
getGuardName line = head (drop 3 (words line))

lineType :: String -> String
lineType line = head (drop 2(words line))

getMinute :: String -> Int
getMinute line = read (substring 3 5 (head (drop 1 (words line)))) :: Int

sortRecords :: [String] -> [String]
sortRecords records = sort records

loadInput :: String -> [String]
loadInput contents = do
    sortRecords (lines contents)

-- variant of map that passes each element's index as a second argument to f
mapInd :: (a -> Int -> b) -> [a] -> [b]
mapInd f l = zipWith f l [0..]

markAsAsleep :: [Int] -> Int -> Int -> [Int]
markAsAsleep minutes start end =
    mapInd (\m i -> if (i >= start) && (i < end) then m+1 else m ) minutes

-- 
nextState :: Map String [Int] -> String -> String -> Int -> String-> ((Map String [Int]), String, Int, String)
nextState state line currGuard lastMinute lastType = do
    let entryType = (lineType line)
    let minute = getMinute line
    let guardMinutes = Map.findWithDefault (take 60 (repeat 0)) currGuard state
    
    if entryType == "falls" then
        (state, currGuard, minute, entryType)
    else if entryType == "wakes" then 
        ( (Map.insert currGuard (markAsAsleep guardMinutes lastMinute minute) state), currGuard, minute, entryType)
    else -- guard
        if lastType == "falls" then
            ( (Map.insert (getGuardName line) (markAsAsleep guardMinutes lastMinute minute) state), currGuard, minute, entryType)
        else
            (state, (getGuardName line), minute, entryType)


getNextState :: ((Map String [Int]), String, Int, String) -> String -> ((Map String [Int]), String, Int, String)
getNextState a line = do
    let (state, currGuard, lastMinute, lastType) = a
    nextState state line currGuard lastMinute lastType

solve :: String -> ([Int] -> Int) -> Int
solve input f = do
    let (state, _, _, _) = foldl getNextState (Map.empty, "", -1, "") (loadInput input)
    let (guard, minutes) = Map.foldlWithKey (\(guard, a) k v -> if (f v) > a then (k, (f v)) else (guard, a)) ("", 0) state
    let sleepHabits =  state Map.! guard
    let (mostAsleepAt, sleptFor, _) = foldl (\(ma, sf, c) m ->  if sf < m then (c, m, c+1) else (ma, sf, c+1)) (0, 0, 0) sleepHabits
    ((read (drop 1 guard)) :: Int) * mostAsleepAt


maximum' :: [Int] -> Int
maximum' [x] = x
maximum' (x:xs)
    | (maximum' xs) > x = maximum' xs
    | otherwise         = x

part1 :: String -> String
part1 input = do
    let solution = solve input sum
    show solution

part2 :: String -> String
part2 input = do
    let solution = solve input maximum'
    show solution

main = do
    s <- readFile "input"
    putStrLn ("Part 1: " ++ (part1 s) ++ "\nPart 2: " ++ (part2 s) ++ "\n")