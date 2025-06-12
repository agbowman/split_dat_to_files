CREATE PROGRAM cclocdminidiclist:dba
 PAINT
 FREE SET com
 SET p_file = fillstring(16," ")
 SET p_type = fillstring(30," ")
 CALL video(r)
 CALL box(1,1,10,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,10,"CCL PROGRAM CCLOCDMINIDICLIST")
 CALL text(2,50,concat("MiniDic: ",trim(minidic)))
 CALL clear(3,2,78)
 CALL text(03,05,"Program to Display Existing Mini Dictionaries ")
 CALL video(n)
 CALL text(5,5,"Not implemented at this time.  Press Enter to continue.")
 CALL accept(6,26,"P"," ")
END GO
