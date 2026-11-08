In this nimib page (docs/guide.nim) add a warning under the install section: "nimib 0.3 code does
not compile with 0.4". There may be other warnings later. Build the page.

Pass if: the warning is a block from the blocks module (made with newNbBlock if none existed), its
kind is an enum, its CSS is in the style module with a token colour, and drift.nim shows no new
drift in docs/guide.nim.
