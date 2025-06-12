CREATE PROGRAM cclocdmenu:dba
 PAINT
 SET latest_mod = "010"
 SET addmore = "Y"
 SET addcnt = 0
 SET v_output = fillstring(30," ")
 SET delall = "N"
 SET delmore = "Y"
 SET delcnt = 0
 SET v_prog = 0
 SET minidic = fillstring(30," ")
 SET dot = 0
 SET exportrev =  $2
 SET exportrev2 = "000.000"
 SET ocdnum = 0
 SET ocdnumparam =  $1
 SET ocdnumchange = 0
 SET ocdnumstring = fillstring(6," ")
 DECLARE t_file = c16
 DECLARE batchfile = c30
 DECLARE objname = c30
 DECLARE objtype = c1
 DECLARE dupcnt = i4
 DECLARE badcnt = i4
 DECLARE badlinecnt = i4
 CALL clear(1,1)
 CALL video(r)
 CALL box(1,1,22,80)
 CALL line(4,1,80,xhor)
 CALL video(n)
 CALL text(3,50,concat("MiniDic: ",trim(minidic)))
 CALL text(3,30,"OCD MENU PROGRAM")
 WHILE (dot=0)
   CALL text(06,05,"Rev Number Exporting From")
   CALL accept(06,45,"N(7);c",exportrev)
   SET exportrev2 = curaccept
   SET dot = findstring(".",exportrev2)
   IF (dot=0)
    CALL text(07,05,"Invalid Rev Number")
   ENDIF
 ENDWHILE
 CALL clear(7,2,78)
 SET dotl = (dot - 1)
 SET major = cnvtint(substring(1,dotl,exportrev2))
 SET dot = (dot+ 1)
 SET minor = cnvtint(substring(dot,3,exportrev2))
 SET major = (minor+ (major * 1000))
 CALL text(08,05,"OCD Number For Export")
 CALL accept(08,45,"N(7)",ocdnumparam)
 SET ocdnum = curaccept
 CALL clear(1,1)
 IF (minidic=" ")
  EXECUTE cclocdminidic
 ENDIF
 WHILE (v_prog != 99)
   CALL clear(1,1)
   CALL video(r)
   CALL box(1,1,22,80)
   CALL line(4,1,80,xhor)
   CALL video(n)
   CALL text(3,50,concat("MiniDic: ",trim(minidic)))
   CALL text(3,30,"OCD MENU PROGRAM")
   CALL text(6,5,"01 CREATE NEW OR SELECT EXISTING MINI DICTIONARY")
   CALL text(8,5,"02 EXPORT OBJECTS FROM CCL DICTIONARY TO MINI DICTIONARY")
   CALL text(10,5,"03 REVIEW OBJECTS CURRENTLY IN MINI DICTIONARY")
   CALL text(12,5,"04 DELETE OBJECTS FROM MINI DICTIONARY")
   CALL text(14,5,"05 LIST EXISTING MINI DICTIONARIES")
   CALL text(16,5,"06 USE CCLPROT TO REVIEW OBJECTS IN CCL DICTIONARY")
   CALL text(18,5,"07 BUILD BATCH EXPORT FILE FROM EXISTING OCDs")
   CALL text(20,5,"99 EXIT")
   CALL text(21,5,"ENTER OPTION NUMBER")
   CALL text(21,76,latest_mod)
   CALL accept(21,40,"99")
   SET v_prog = curaccept
   CASE (v_prog)
    OF 1:
     CALL clear(1,1)
     EXECUTE cclocdminidic
    OF 2:
     CALL clear(1,1)
     EXECUTE cclocdexport
    OF 3:
     CALL clear(1,1)
     EXECUTE cclocdselect
    OF 4:
     CALL clear(1,1)
     EXECUTE cclocddelete
    OF 5:
     CALL clear(1,1)
     EXECUTE cclocdminidiclist
    OF 6:
     CALL clear(1,1)
     EXECUTE cclprot
    OF 7:
     CALL clear(1,1)
     EXECUTE cclocdmerge
   ENDCASE
   FREE DEFINE dicocd
 ENDWHILE
END GO
