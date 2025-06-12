CREATE PROGRAM cclocddicnew:dba
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
    SET com = concat("mv ",trim(logical("cer_ocd")),"/",ocdnumstring,"/dicocdtmp.dat",
     " ",trim(logical("cer_ocd")),"/",ocdnumstring,"/dicocd.dat")
    CALL dcl(com,100,0)
    FREE SET com
    SET com = concat("mv ",trim(logical("cer_ocd")),"/",ocdnumstring,"/dicocdtmp.idx",
     " ",trim(logical("cer_ocd")),"/",ocdnumstring,"/dicocd.idx")
    CALL dcl(com,100,0)
   OF "WIN":
    CALL dcl("copy $ocddir\dicocdtmp.dat $ocddir\dicocd.dat",100,0)
    CALL dcl("copy $ocddir\dicocdtmp.idx $ocddir\dicocd.idx",100,0)
  ENDCASE
 ENDIF
END GO
