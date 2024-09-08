||| This example is borrowed from the ncurses-idris project because the fact that
||| it requires ncurses-idris makes it a fine example of using the nix pacakgeset.
module Main

import System
import System.Signal
import Control.NCurses
import Control.NCurses.Pretty
import Data.Nat

instructions : String
instructions = "Ctrl+C to quit. Up/Down arrows to adjust ticker.\n"

displayTicker : IsActive s => InWindow "ticker" s => HasColor "green" s => HasColor "white" s => Nat -> NCurses () s s
displayTicker k =
  let mid = (cast $ length instructions) `div` 2
      centered = mid - ((cast $ (length (show k)) + 4) `div` 2)
  in
  printDoc $ indent centered $
    hsep [ dash
         , color "green" (bold $ pretty k)
         , dash
         ]
  where
    dash : Doc (Attribute s)
    dash = color "white" $ pretty "-"

loop : IsActive s => InWindow "ticker" s => HasColor "green" s => HasColor "white" s => YesDelay s => YesKeypad s => Nat -> NCurses () s s
loop n = do
  keyOrCh <- getKeyOrChar
  tally keyOrCh
    where
      loopOrExit : Nat -> NCurses () s s
      loopOrExit n' = 
        case !(liftIO handleNextCollectedSignal) of
             (Just SigINT) => pure ()
             _ => loop n'

      tally : Either Char Key -> NCurses () s s
      tally x = do
        erase
        let n' = case x of Right Up => (pred n); Right Down => (S n); _ => n
        displayTicker n'
        refresh
        loopOrExit n'

run : NCurses () Inactive Inactive
run = Indexed.do
  init
  (MkSize rows cols) <- getWindowSize True
  let centerX = (cols `div` 2) `minus` ((length instructions) `div` 2)
  let centerY = (rows `div` 2)
  addColor "green" Green Black
  addColor "white" White Black
  setCursor CInvisible
  addWindow "header" (MkPosition centerY     centerX) (MkSize 1 (length instructions)) Nothing
  addWindow "ticker" (MkPosition (S centerY) centerX) (MkSize 1 (length instructions)) Nothing
  clear
  addWindow "box"    (MkPosition (centerY `minus` 1) (centerX `minus` 2)) (MkSize 4 ((length instructions) + 3)) (defaultBorder "white")
  setWindow "header"
  putStrLn instructions
  refresh
  setWindow "ticker"
  let n = 25
  displayTicker n
  loop n
  deinit

main : IO ()
main = do
  ignore $ collectSignal SigINT
  withNCurses run


