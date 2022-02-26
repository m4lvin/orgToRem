module Main where

import Control.Monad
import Data.Csv
import Data.Time
import Data.Time.Calendar.Month
import qualified Data.ByteString.Lazy as BL
import Data.ByteString.Lazy.UTF8 (toString)
import qualified Data.Vector as V

data OrgEntry = OE { oCategory :: String -- category of the item (usually the file)
                   , oHead  :: String -- headline, without TODO keyword, TAGS and PRIORITY
                   , oType :: OrgType
                   , oTodo :: String -- TODO keyword, if any
                   , oTags :: [String] -- All tags including inherited ones, separated by colons
                   , oDate :: String -- like ‘2007-2-14’ -- NOTE: no leading zeros!
                   , oTime :: String -- time, like ‘15:00-16:50’
                   , oExtra :: String -- extra planning info
                   } deriving (Eq,Ord,Show)

data OrgType = Todo -- selected in TODO match
             | Tagsmatch -- selected in tags match
             | Diary -- imported from diary
             | Deadline -- a deadline
             | Scheduled -- scheduled
             | Timestamp -- appointment, selected by timestamp
             | Closed -- entry was closed on date
             | Upcoming -- deadline warning about nearing deadline
             | Past -- forwarded scheduled item
             | Block -- entry has date block including date
             deriving (Eq,Ord,Show)

parseLine :: [String] -> OrgEntry
parseLine [theCat, theHead,             oTypeStr, theTodo, tagsStr, theDate, theTime, theExtra , _, _, _ ] =
  OE       theCat  theHead (readOrgType oTypeStr) theTodo [tagsStr] theDate  theTime  theExtra
parseLine s = error $ "Line with wrong length: " ++ show s

readOrgType :: String -> OrgType
readOrgType s = case s of
  "todo" -> Todo
  "tagsmatch" -> Tagsmatch
  "diary" -> Diary
  "deadline" -> Deadline
  "scheduled" -> Scheduled
  "timestamp" -> Timestamp
  "closed" -> Closed
  "upcoming-deadline" -> Upcoming
  "past-scheduled" -> Past
  "block" -> Block
  _ -> error "unknown type"

entriesFor :: Day -> [OrgEntry] -> [OrgEntry]
entriesFor d = filter (\oe -> oDate oe == formatTime defaultTimeLocale "%Y-%-m-%-e" d)

entryTextLimit :: Int
entryTextLimit = 25

maxNumEntriesPerDay :: Int
maxNumEntriesPerDay = 5

printEntry :: OrgEntry -> IO ()
printEntry oe = do
  putStrLn "\\newline  "
  when (oTodo oe == "TODO") (putStr " $\\Box$ ")
  when (oTodo oe == "WAITING") (putStr " $\\hourglass$ ")
  when (oTodo oe == "DONE") (putStr " $\\checkmark$ ")
  putStrLn $ take 5 (oTime oe) ++ " " ++ take (entryTextLimit - length (take 5 $ oTime oe)) (oHead oe)

printDay :: [OrgEntry] -> Day -> IO ()
printDay entries d = do
  let (_, _, dStr) = toGregorian d
  putStr $ " \\textcolor{gray}{" ++ show dStr ++ " \\ " ++ take 3 (show $ dayOfWeek d)
  when (length (entriesFor d entries) > maxNumEntriesPerDay) (putStr " \\hfill $\\ast$\n")
  putStr "} "
  mapM_ printEntry $ take maxNumEntriesPerDay $ entriesFor d entries

printMonth :: [OrgEntry] -> Year -> Int -> IO ()
printMonth entries year month = do
  putStrLn "\\newpage"
  putStr "{ \\Large  \\phantom{Jyg}"
  putStrLn $ " \\textbf{ " ++ formatTime defaultTimeLocale "%B \\hspace{1em} %Y" (YearMonth year month) ++ "}"
  putStr "\\phantom{Jyg} }\n\n"
  putStrLn "\n\\smallskip\n"
  putStrLn "\\begin{tabularx}{0.99\\linewidth}{Y@{\\hspace{1mm}}Y@{\\hspace{1mm}}Y@{\\hspace{1mm}}Y@{\\hspace{1mm}}Y@{\\hspace{1mm}}Y@{\\hspace{1mm}}Y}"
  putStrLn "\\toprule"
  let k = fromEnum $ dayOfWeek $ head (periodAllDays (YearMonth year month))
  mapM_ (\ _ -> putStrLn " & ") [1..(k-1)]
  mapM_ (\d -> do
            printDay entries d
            if dayOfWeek d == Sunday
              then putStrLn " \\tabularnewline[28mm] \n\\midrule"
              else putStr " & "
        ) (periodAllDays (YearMonth year month))
  putStrLn "\\tabularnewline[28mm] \n \\midrule \\end{tabularx} "

main :: IO ()
main = do
  c <- BL.readFile "tex/org.csv"
  case decode NoHeader c of
    Left e -> error $ "could not parse the csv file:" ++ show e
    Right csv -> do
      let entries = map (parseLine . map toString) $ V.toList (csv :: V.Vector [BL.ByteString])
      now <- getCurrentTime
      let (year, _, _) = toGregorian . utctDay $ now
      mapM_ (printMonth entries year) [1..12]
      putStrLn "\\phantom{XXX}"
