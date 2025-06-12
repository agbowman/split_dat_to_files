CREATE PROGRAM cclmodule:dba
 PAINT
#l1
 CALL box(01,1,15,80)
 CALL text(02,10,"CCLMODULE Program to build module out of sub/inc file")
 CALL line(03,1,80,xhor)
 CALL text(05,5,"Extension of text file")
 CALL text(07,5,"Directory")
 CALL text(09,5,"text file name")
 CALL text(11,5,"Repeat?")
 SET help = fix("SUB,INC")
 CALL accept(05,30,"X(3);CU","SUB"
  WHERE curaccept IN ("SUB", "INC"))
 SET p_ext = curaccept
 SET help = off
 CALL accept(07,30,"P(30);CU","CCLSOURCE")
 SET p_dir = curaccept
 CALL accept(09,30,"P(30);CU")
 SET p_filename = curaccept
 SET g_status = 0
 EXECUTE cclmodule2 p_ext, p_dir, p_filename
 CALL text(13,5,concat("Module build status for ",trim(p_ext),".",trim(p_filename)," = ",
   format(g_status,"#")))
 CALL accept(11,30,"P;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  GO TO l1
 ENDIF
 CALL clear(1,1)
END GO
