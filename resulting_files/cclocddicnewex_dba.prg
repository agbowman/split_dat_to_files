CREATE PROGRAM cclocddicnewex:dba
 IF (findfile("ocddir:dicocd.dat")=0)
  SELECT INTO TABLE "ocddir:dicocdtmp"
   ky1 = fillstring(40," "), data = fillstring(810," ")
   FROM dummyt
   WHERE 1=0
   ORDER BY ky1
   WITH nocounter, organization = indexed
  ;end select
  DROP DATABASE dicocdtmp WITH deps_deleted
  CASE (cursys)
   OF "AXP":
    CALL dcl("$ren ocddir:dicocdtmp.dat ocddir:dicocd.dat",100,0)
   OF "AIX":
    FREE SET com
    SET com = concat("mv ",trim(logical("cer_ocd")),"/",trim(ocdnumstring,3),"/dicocdtmp.dat",
     " ",trim(logical("cer_ocd")),"/",trim(ocdnumstring,3),"/dicocd.dat")
    SET len = size(trim(com))
    CALL dcl(com,len,0)
    FREE SET com
    SET com = concat("mv ",trim(logical("cer_ocd")),"/",trim(ocdnumstring,3),"/dicocdtmp.idx",
     " ",trim(logical("cer_ocd")),"/",trim(ocdnumstring,3),"/dicocd.idx")
    SET len = size(trim(com))
    CALL dcl(com,len,0)
   OF "WIN":
    CALL dcl(concat("move ",trim(logical("ocddir")),"\dicocdtmp.dat ",trim(logical("ocddir")),
      "\dicocd.dat"),256,0)
    CALL dcl(concat("move ",trim(logical("ocddir")),"\dicocdtmp.idx ",trim(logical("ocddir")),
      "\dicocd.idx"),256,0)
  ENDCASE
 ENDIF
END GO
