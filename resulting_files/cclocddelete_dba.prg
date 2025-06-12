CREATE PROGRAM cclocddelete:dba
 PAINT
 FREE DEFINE dicocd
 FREE SET minidictionary
 SET minidictionary = concat("ocddir:",minidic)
 DEFINE dicocd value(minidictionary)  WITH modify
 FREE RECORD object_list
 RECORD object_list(
   1 qual[*]
     2 object = c1
     2 object_name = c30
 )
 SET delall = "N"
 SET delmore = "Y"
 SET delcnt = 0
 CALL video(r)
 CALL box(1,1,15,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,10,"CCL PROGRAM CCLOCDDELETE")
 CALL text(2,50,concat("MiniDic: ",trim(minidic)))
 CALL clear(3,2,78)
 CALL text(03,05,"Program to Remove Objects from the OCD Export")
 CALL video(n)
 CALL text(6,5,"You can remove all Objects from the OCD Export")
 CALL text(7,5,"or remove selected Objects.")
 CALL text(9,5,"Remove all Objects from the OCD Export?")
 CALL accept(9,45,"P;CU","N")
 SET delall = curaccept
 SET deletenum = 0
 IF (delall="Y")
  CALL video("R")
  CALL text(10,5,"You have used a wild card.  This may delete more than one object.     ")
  CALL text(11,5,"Do you want to continue with this delete [YES/NO]                     ")
  CALL video("N")
  CALL accept(11,60,"p(3);cu"
   WHERE curaccept IN ("YES", "NO"))
  IF (curaccept="YES")
   DELETE  FROM dprotectocd dpocd
    WHERE 1=1
   ;end delete
   SET deletenum = curqual
   DELETE  FROM dcompileocd dcocd
    WHERE 1=1
   ;end delete
  ENDIF
  CALL clear(10,2,78)
  CALL clear(11,2,78)
 ELSE
  WHILE (delmore="Y")
    SET skip = 0
    CALL clear(6,2,78)
    CALL clear(7,2,78)
    CALL clear(9,2,78)
    CALL text(08,05,"OBJECT NAME TYPE(P=PROGRAM E=EKMODULE)")
    CALL text(10,05,"OBJECT NAME")
    CALL text(11,05,"REMOVE ANOTHER OBJECT? Y/N")
    CALL accept(08,45,"P;CU","P")
    SET object_type = curaccept
    SET accept = nopatcheck
    CALL accept(10,45,"P(30);CU","*")
    SET tempacc = curaccept
    SET accept = patcheck
    IF (findstring(char(42),tempacc) > 0)
     CALL video("R")
     CALL text(10,5,"You have used a wild card.  This may delete more than one object.     ")
     CALL text(11,5,"Do you want to continue with this delete [YES/NO]                     ")
     CALL video("N")
     CALL accept(11,60,"p(3);cu"
      WHERE curaccept IN ("YES", "NO"))
     IF (curaccept="NO")
      SET skip = 1
     ENDIF
     CALL clear(10,2,78)
     CALL clear(11,2,78)
    ENDIF
    IF (skip=0)
     SELECT INTO "nl:"
      dp.object, dp.object_name
      FROM dprotectocd dp
      WHERE dp.platform="H0000"
       AND dp.rcode="5"
       AND dp.object=object_type
       AND dp.object_name=patstring(cnvtupper(tempacc))
      DETAIL
       delcnt = (delcnt+ 1)
       IF (mod(delcnt,10)=1)
        stat = alterlist(object_list->qual,(delcnt+ 9))
       ENDIF
       object_list->qual[delcnt].object_name = dp.object_name, object_list->qual[delcnt].object = dp
       .object
      WITH nocounter
     ;end select
    ENDIF
    CALL accept(11,45,"P;CU","N")
    SET delmore = curaccept
  ENDWHILE
  SET stat = alterlist(object_list->qual,delcnt)
  DELETE  FROM dprotectocd dpocd,
    (dummyt d  WITH seq = value(delcnt))
   SET dpocd.seq = dpocd.seq
   PLAN (d)
    JOIN (dpocd
    WHERE "H0000"=dpocd.platform
     AND "5"=dpocd.rcode
     AND (object_list->qual[d.seq].object=dpocd.object)
     AND (object_list->qual[d.seq].object_name=dpocd.object_name)
     AND 0=dpocd.group)
   WITH nocounter
  ;end delete
  DELETE  FROM dcompileocd dcocd,
    (dummyt d  WITH seq = value(delcnt))
   SET dcocd.seq = dcocd.seq
   PLAN (d)
    JOIN (dcocd
    WHERE "H0000"=dcocd.platform
     AND "9"=dcocd.rcode
     AND (object_list->qual[d.seq].object=dcocd.object)
     AND (object_list->qual[d.seq].object_name=dcocd.object_name)
     AND 0=dcocd.group)
   WITH nocounter
  ;end delete
  SET deletenum = delcnt
 ENDIF
 IF (deletenum > 0)
  SET textfile = cnvtlower(minidictionary)
  SET lpos = findstring(".dat",textfile)
  SET lpos = (lpos - 1)
  SET textfile2 = substring(1,lpos,textfile)
  SET textfile3 = concat(trim(textfile2),"txt")
  EXECUTE cclocdselectrpt textfile3, "/", ";"
  SET textfile4 = concat(trim(textfile3),".dat")
  CASE (cursys)
   OF "AXP":
    FREE SET com
    SET com = concat("$ren ",trim(textfile4)," ",trim(textfile2),".txt")
    CALL dcl(com,size(trim(com)),0)
   OF "AIX":
    SET textfile2s = replace(textfile2,"ocddir:"," ",0)
    SET textfile4s = replace(textfile4,"ocddir:"," ",0)
    CALL echo(textfile2s)
    CALL echo(textfile4s)
    FREE SET com
    SET com = concat("mv ",trim(logical("cer_ocd")),"/",ocdnumstring,"/",
     trim(textfile4s,3)," ",trim(logical("cer_ocd")),"/",ocdnumstring,
     "/",trim(textfile2s,3),".txt")
    CALL echo(com)
    CALL dcl(com,size(trim(com)),0)
  ENDCASE
 ENDIF
END GO
