CREATE PROGRAM cclocdselect:dba
 PAINT
 CALL video(r)
 CALL box(1,1,10,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,10,"CCL PROGRAM CCLOCDSELECT")
 CALL text(2,50,concat("MiniDic: ",trim(minidic)))
 CALL clear(3,2,78)
 CALL text(03,05,"Program to Display List of Objects for OCD Export")
 CALL video(n)
 SET v_output = fillstring(30," ")
 CALL text(7,5,"Enter an Output Device: ")
 CALL accept(7,29,"p(30);cu","MINE")
 SET v_output = curaccept
 FREE DEFINE dicocd
 FREE SET minidictionary
 SET minidictionary = concat("ocddir:",minidic)
 DEFINE dicocd value(minidictionary)
 EXECUTE cclocdselectrpt v_output, " ", " "
END GO
