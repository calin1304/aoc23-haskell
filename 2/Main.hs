{-# LANGUAGE CPP              #-}
{-# LANGUAGE LambdaCase       #-}
{-# LANGUAGE TypeApplications #-}

module Main where

import           Control.Arrow
import           Data.Char                  (isDigit)
import           Data.Functor               ((<&>))
import           Data.Maybe                 (fromJust)
import           Data.Tuple                 (swap)
import           Data.Void
import           Debug.Trace
import           System.Environment         (getArgs)
import           Test.Hspec
import           Text.Megaparsec
import qualified Text.Megaparsec.Char       as MP
import           Text.Megaparsec.Char.Lexer

data Color = R | G | B deriving (Eq, Show)

maxR = 12
maxG = 13
maxB = 14

------------
-- Part 1 --
------------

solve1 :: String -> Int
solve1 =
    sum
        . map (uncurry check . (parseGameId *** (concat . parseCubes . tail)) . breakAt ':')
        . lines
  where
    breakAt :: Char -> String -> (String, String)
    breakAt c = break (== c)

check :: Int -> [(Color, Int)] -> Int
check gid cubes =
    case any (\(c, n) -> maxByColor c < n) cubes of
        True -> 0
        _    -> gid
  where
    maxByColor :: Color -> Int
    maxByColor = \case R -> maxR; G -> maxG; B -> maxB

parseGameId :: String -> Int
parseGameId = read . filter isDigit

type Parser = Parsec Void String

parseCubes :: String -> [[(Color, Int)]]
parseCubes = fromJust . parseMaybe parseEntry
  where
    parseEntry :: Parser [[(Color, Int)]]
    parseEntry = sepBy entries (satisfy (== ';'))

    entries :: Parser [(Color, Int)]
    entries = sepBy entry (satisfy (== ','))

    entry :: Parser (Color, Int)
    entry = (,) <$> (tok decimal) <*> (tok color) <&> swap

    color :: Parser Color
    color = (R <$ chunk "red") <|> (G <$ chunk "green") <|> (B <$ chunk "blue")

    tok :: Parser a -> Parser a
    tok p = MP.space *> p

------------
-- Part 2 --
------------

-- solve2 :: String -> _
-- solve2 = undefined

------------
-- Driver --
------------

main :: IO ()
main =
#ifdef TEST
    test
#else
    readFile "input" >>= putStrLn . show . solve1
#endif

test :: IO ()
test = hspec $ do
    describe "part 1" $ do
        it "works with sample" $ do
            d <- readFile "sample_1.txt"
            solve1 d `shouldBe` 8
        describe "cubes parser" $ do
            it "works for case where too man blue cubes" $ do
                let s = "1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red"
                parseCubes s `shouldBe`
                        [ [(G, 1), (R, 3), (B, 6)]
                        , [(G, 3), (R, 6)]
                        , [(G, 3), (B, 15), (R, 14)]
                        ]
        describe "check" $ do
            it "works for case where too many blue cubes" $ do
                let inp = concat $ [ [(G, 1), (R, 3), (B, 6)]
                          , [(G, 3), (R, 6)]
                          , [(G, 3), (B, 15), (R, 14)]
                          ]
                check 4 inp `shouldBe` 0
    -- describe "part 2" $ do
    --     it "works with sample" $ do
    --         d <- readFile "sample_2.txt"
    --         solve2 d `shouldBe` undefined
