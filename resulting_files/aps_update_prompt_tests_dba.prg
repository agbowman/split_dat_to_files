CREATE PROGRAM aps_update_prompt_tests:dba
 PAINT
 CALL clear(1,1)
 CALL video(i)
 CALL box(7,1,18,80)
 CALL line(9,1,80,xhor)
 CALL video(l)
 CALL text(8,3,"UPDATE PROMPT TESTS")
 CALL video(i)
 CALL text(10,2,"This program is no longer available; please use DB Order Prompts Tool")
 CALL text(11,2,"instead.")
 CALL text(20,2," ")
END GO
