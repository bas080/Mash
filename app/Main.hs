module Main where

import Data.ByteString.Lazy.Char8 (unpack)
import Data.List (insert, isPrefixOf, stripPrefix)
import MashArgs
import Network.HTTP.Conduit
import System.Console.CmdArgs
import System.Environment (getArgs)
import System.IO (hGetContents)
import System.Process

data Line
  = Statement String
  | RequireStatement FilePath
  | RequireRunStatment String

contentToLine :: String -> Line
contentToLine line
  | "require " `isPrefixOf` line = RequireStatement rest
  | "require-run " `isPrefixOf` line = RequireRunStatment rest
  | otherwise = Statement line
  where
    rest = unwords $ tail $ words line

contentToLines :: String -> [Line]
contentToLines = map contentToLine . lines

append :: [a] -> [a] -> [a]
append a b = b ++ a

isUrl :: String -> Bool
isUrl = isPrefixOf "http"

readContents :: String -> IO String
readContents item
  | isUrl item = fmap unpack (simpleHttp item)
  | otherwise = readFile item

commandStdout :: String -> IO String
commandStdout command = do
  (_, Just hout, Just herr, jHandle)
        -- Replace with some other command on Windows
     <-
    createProcess
      (shell command)
      {cwd = Just ".", std_out = CreatePipe, std_err = CreatePipe}
  hGetContents hout

printScript :: Bool -> [FilePath] -> [Line] -> IO ()
printScript o fp [] = putStrLn ""
printScript o fp (Statement a:b) = do
  putStrLn a
  printScript o fp b
printScript o fp (RequireRunStatment a:b) =
  printScript o fp . append b . contentToLines =<< commandStdout a
printScript o fp (RequireStatement a:b) =
  if o && a `elem` fp
    then printScript o fp b
    else (printScript o (insert a fp) . append b . contentToLines) =<<
         readContents a

input :: [String] -> IO String
input ["-"] = getContents
input [x] = readContents x

main :: IO ()
main = do
  mash <- cmdArgs mashArgs
  (printScript (once mash) [] . contentToLines) =<< input (files mash)