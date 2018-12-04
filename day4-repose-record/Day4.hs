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

sleepMinutes :: String -> String -> Int -> Map String Int -> [String] -> String -> Map String Int
sleepMinutes prevType prevGuard prevMinute state records line 
        | (null records) = state
        | (line == "Guard") = 
            case prevType of 
                "Guard" -> do
                    let guardName = getGuardName line
                    let guardMinutes = Map.findWithDefault 0 guardName state
                    let minute = getMinute line
                    sleepMinutes "Guard" guardName minute (Map.insert guardName guardMinutes state) (drop 1 records) (head records)
                "falls" -> do
                    let guardName = getGuardName line
                    let guardMinutes = Map.findWithDefault 0 guardName state
                    let prevGuardMinutes = Map.findWithDefault 0 prevGuard state
                    let minute = getMinute line
                    let nextState = Map.insert prevGuard (prevGuardMinutes + 60 - minute) state
                    sleepMinutes "falls" guardName minute (Map.insert guardName guardMinutes state) (drop 1 records) (head records)
                "wakes" -> do
                    let guardName = getGuardName line
                    let guardMinutes = Map.findWithDefault 0 guardName state
                    let minute = getMinute line
                    let additionalMinutes = minute - prevMinute
                    sleepMinutes "wakes" guardName minute (Map.insert guardName (guardMinutes + additionalMinutes) state) (drop 1 records) (head records)

        | (line == "falls") = sleepMinutes prevType prevGuard prevMinute state (drop 1 records) (head records)
        | (line == "wakes") = sleepMinutes prevType prevGuard prevMinute state (drop 1 records) (head records)



part1 :: String -> String
part1 input = do
    head (loadInput input)

main = do
    s <- readFile "input"
    putStrLn ( part1 s)