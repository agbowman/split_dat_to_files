CREATE PROGRAM code_conv
 PAINT
 SET width = 132
 SET modify = system
#0100_start
 CALL video(n)
 CALL clear(1,1)
 CALL box(3,1,23,132)
 CALL text(2,1,"V400 to V500 Code Conversion",w)
 CALL text(6,5," 1  Export V400 Code Tables")
 CALL text(8,5," 2  Export V400 Location Tables")
 CALL text(10,5," 3  Import V500 Code Tables")
 CALL text(12,5," 4  Import V500 Location Tables")
 CALL text(14,5," 5  Help")
 CALL text(16,5," 6  Exit")
 CALL text(24,1,"Select Option ? ")
 CALL accept(24,17,"9;",6
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6))
 CALL clear(24,1)
 SET choice = curaccept
 CASE (choice)
  OF 1:
   EXECUTE code_out
  OF 2:
   EXECUTE loc_out
  OF 3:
   EXECUTE code_in
  OF 4:
   EXECUTE loc_in
  OF 5:
   EXECUTE rtlview value("MINE"), value("CER_SCRIPT:CODE_CONV.DAT")
  OF 6:
   GO TO 9999_end
 ENDCASE
 GO TO 0100_start
#0199_start_exit
#9999_end
END GO
