CREATE PROGRAM cclocdminidic:dba
 PAINT
 FREE SET com
 SET p_file = fillstring(16," ")
 SET p_type = fillstring(30," ")
 SET file_num = fillstring(6," ")
 CALL video(r)
 CALL box(1,1,10,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,10,"CCL PROGRAM CCLOCDMINIDIC")
 CALL text(2,50,concat("MiniDic: ",trim(minidic)))
 CALL clear(3,2,78)
 CALL text(03,05,"Program to Select an Existing or Create a New Mini Dictionary ")
 CALL video(n)
 CALL text(5,5,"Mini Dictionary Type            (OCD)")
 SET help = fix("OCD,REV")
 CALL accept(5,26,"p(3);cu","OCD")
 SET p_type = curaccept
 IF (ocdnum != 0
  AND ocdnumchange != 0)
  CALL text(08,05,"OCD Number For Export")
  CALL accept(08,45,"N(7)",ocdnumparam)
  SET ocdnum = curaccept
 ENDIF
 SET ocdnumchange = 1
 SET ocdnumstring = format(ocdnum,"######;rp0")
 SET p_file = cnvtlower(concat("dic",trim(p_type),ocdnumstring,".dat"))
 IF (cnvtlower(trim(p_file)) IN ("dicocd.dat", "dic.dat"))
  CALL text(9,10,"Invalid File Name!  Press Enter to continue.")
  CALL accept(9,55,"p"," ")
  GO TO exit_script
 ENDIF
 FREE SET stat
 FREE SET dfile
 IF (cursys="AIX")
  SET logical ocddir value(concat(trim(logical("cer_ocd")),"/",ocdnumstring))
 ELSE
  SET cerocd = logical("cer_ocd")
  SET len = findstring("]",cerocd)
  SET line = concat(substring(1,(len - 1),cerocd),ocdnumstring,"]")
  SET logical ocddir line
 ENDIF
 SET dfile = concat("ocddir:",trim(p_file))
 SET stat = findfile(dfile)
 IF (stat=0)
  EXECUTE cclocddicnew
  CALL text(20,5,"Creating Mini Dictionary.")
  IF (cursys="AIX")
   SET p_file = cnvtlower(concat("dic",trim(p_type),ocdnumstring,".idx"))
   FREE SET com
   SET com = concat("cp ",trim(logical("cer_ocd")),"/",ocdnumstring,"/dicocd.idx",
    " ",trim(logical("cer_ocd")),"/",ocdnumstring,"/",
    trim(cnvtlower(p_file)))
   CALL dcl(com,size(trim(com)),0)
   FREE SET com
   SET com = concat("rm ",trim(logical("cer_ocd")),"/",ocdnumstring,"/dicocd.idx")
   CALL dcl(com,size(trim(com)),0)
   SET p_file = cnvtlower(concat("dic",trim(p_type),ocdnumstring,".dat"))
   SET com = concat("cp ",trim(logical("cer_ocd")),"/",ocdnumstring,"/dicocd.dat",
    " ",trim(logical("cer_ocd")),"/",ocdnumstring,"/",
    trim(cnvtlower(p_file)))
   CALL dcl(com,size(trim(com)),0)
   FREE SET com
   SET com = concat("rm ",trim(logical("cer_ocd")),"/",ocdnumstring,"/dicocd.dat")
   CALL dcl(com,size(trim(com)),0)
  ELSE
   FREE SET com
   SET com = concat("copy ","OCDDIR:dicocd.dat"," OCDDIR:",trim(cnvtlower(p_file)))
   CALL dcl(com,size(trim(com)),0)
   FREE SET com
   SET com = concat("del ","OCDDIR:dicocd.dat;*")
   CALL dcl(com,size(trim(com)),0)
  ENDIF
 ELSE
  SET p_file = cnvtlower(concat("dic",trim(p_type),ocdnumstring,".dat"))
 ENDIF
 IF (cnvtlower(trim(p_file)) IN ("dicocd.dat", "dic.dat"))
  SET minidic = fillstring(30," ")
  CALL text(9,10,"Invalid File Name!  Press Enter to continue.")
  CALL accept(9,55,"p"," ")
 ELSE
  SET minidic = p_file
 ENDIF
#exit_script
 FREE DEFINE dicocd
 FREE DEFINE rtl
END GO
