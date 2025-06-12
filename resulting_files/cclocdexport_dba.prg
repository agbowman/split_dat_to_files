CREATE PROGRAM cclocdexport:dba
 PAINT
 FREE RECORD object_list
 RECORD object_list(
   1 qual[*]
     2 object = c1
     2 object_name = c30
 )
 FREE RECORD dup_object_list
 RECORD dup_object_list(
   1 qual[*]
     2 object = c1
     2 object_name = c30
 )
 FREE RECORD bad_object_list
 RECORD bad_object_list(
   1 qual[*]
     2 object = c1
     2 object_name = c30
 )
 FREE RECORD bad_lines_list
 RECORD bad_lines_list(
   1 qual[*]
     2 line = vc
 )
 SET addmore = "Y"
 SET addcnt = 0
 SET ojbect_type = " "
 CALL video(r)
 CALL box(1,1,19,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,10,"CCL PROGRAM CCLOCDEXPORT")
 CALL text(2,50,concat("MiniDic: ",trim(minidic)))
 CALL clear(3,2,78)
 CALL text(03,05,"Program to Create List of Objects for OCD Export")
 CALL video(n)
 WHILE (addmore="Y")
   CALL text(8,05,"OBJECT NAME TYPE(P=PROGRAM E=EKMODULE B=BATCH)")
   CALL text(10,05,"OBJECT NAME")
   CALL text(11,05,"EXPORT ANOTHER OBJECT? Y/N")
   CALL accept(8,52,"P;CU","P"
    WHERE curaccept IN ("P", "E", "B"))
   SET object_type = curaccept
   IF (object_type="B")
    SET addmore = "N"
    SET t_file = cnvtlower(concat("ocdobj",ocdnumstring,".txt"))
    CALL text(13,05,concat("Preparing to import using ",t_file,"."))
    CALL text(14,05,"Objects that currently exist in the mini-dictionary")
    CALL text(15,05,"will be replaced with objects from CCL dictionary")
    CALL text(16,05,concat("if the object name is listed in ",t_file))
    CALL text(17,05,"Do you want to continue? ")
    CALL accept(17,30,"P;CU","Y")
    IF (curaccept != "Y")
     GO TO exit_export
    ENDIF
    CALL clear(14,05,78)
    CALL clear(15,05,78)
    CALL clear(16,05,78)
    CALL clear(17,05,78)
    SET batchfile = concat("ocddir:",t_file)
    SET stat = findfile(batchfile)
    IF (stat=0)
     CALL text(13,05,substring(1,73,concat(trim(logical("ocddir")),trim(t_file))))
     CALL text(14,05,"Input file not found.  Press Enter:")
     CALL accept(14,40,"P;CU"," ")
     GO TO exit_export
    ENDIF
    FREE DEFINE rtl
    DEFINE rtl value(batchfile)
    SET badlinecnt = 0
    SELECT INTO "NL:"
     r.line
     FROM rtlt r
     DETAIL
      dot = findstring(".",r.line), objname = substring(1,(dot - 1),r.line), objtype = substring((dot
       + 1),1,r.line),
      comm = substring(1,1,r.line)
      IF ( NOT (comm IN (";", "!"))
       AND dot > 0
       AND cnvtupper(objtype) IN ("P", "E"))
       addcnt = (addcnt+ 1)
       IF (mod(addcnt,10)=1)
        stat = alterlist(object_list->qual,(addcnt+ 9))
       ENDIF
       object_list->qual[addcnt].object = cnvtupper(objtype), object_list->qual[addcnt].object_name
        = cnvtupper(objname)
      ELSEIF ( NOT (comm IN (";", "!")))
       badlinecnt = (badlinecnt+ 1)
       IF (mod(badlinecnt,10)=1)
        stat = alterlist(bad_lines_list->qual,(badlinecnt+ 9))
       ENDIF
       bad_lines_list->qual[badlinecnt].line = r.line
      ENDIF
     WITH counter
    ;end select
    FREE DEFINE rtl
    IF (badlinecnt > 0)
     SELECT INTO mine
      FROM (dummyt d  WITH seq = value(badlinecnt))
      HEAD REPORT
       row 1,
       CALL center("The following lines listed in the",0,79), row + 1,
       CALL center(concat("input file ",trim(t_file)),0,79), row + 1,
       CALL center("are incorrectly formatted.",0,79),
       row + 2
      DETAIL
       col 0, bad_lines_list->qual[d.seq].line, row + 1
      WITH maxcol = 150
     ;end select
    ENDIF
    SELECT INTO "nl:"
     object = object_list->qual[d.seq].object, object_name = object_list->qual[d.seq].object_name
     FROM dprotect dp,
      (dummyt d  WITH seq = value(addcnt))
     PLAN (d)
      JOIN (dp
      WHERE "H0000"=dp.platform
       AND "5"=dp.rcode
       AND (object_list->qual[d.seq].object=dp.object)
       AND (object_list->qual[d.seq].object_name=dp.object_name)
       AND dp.group=0)
     HEAD REPORT
      badcnt = 0
     DETAIL
      badcnt = (badcnt+ 1)
      IF (mod(badcnt,10)=1)
       stat = alterlist(bad_object_list->qual,(badcnt+ 9))
      ENDIF
      bad_object_list->qual[badcnt].object = object, bad_object_list->qual[badcnt].object_name =
      object_name
     FOOT REPORT
      stat = alterlist(bad_object_list->qual,badcnt)
     WITH nocounter, outerjoin = d, dontexist
    ;end select
    IF (curqual > 0)
     SELECT INTO mine
      object = bad_object_list->qual[d.seq].object, object_name = bad_object_list->qual[d.seq].
      object_name
      FROM (dummyt d  WITH seq = value(badcnt))
      HEAD REPORT
       row 1,
       CALL center("The following object names listed in the",0,79), row + 1,
       CALL center(concat("input file ",trim(t_file)),0,79), row + 1,
       CALL center("DO NOT EXIST in the CCL Dictionary",0,79),
       row + 1,
       CALL center("and can not be exported.",0,79), row + 2,
       col 10, "Object Type:", col 25,
       "Object Name:", row + 2
      DETAIL
       col 10, object, col 25,
       object_name, row + 1
     ;end select
    ENDIF
   ELSE
    SET validate = required
    SET validate = 2
    SET validate =
    SELECT INTO "nl:"
     dp.object_name
     FROM dprotect dp
     WHERE dp.platform="H0000"
      AND dp.rcode="5"
      AND dp.object=object_type
      AND dp.object_name=patstring(curaccept)
      AND dp.group=0
     WITH nocounter
    ;end select
    SET accept = nopatcheck
    CALL accept(10,35,"P(30);CU")
    SET accept = patcheck
    SET validate = off
    SELECT INTO "nl:"
     dp.object_name
     FROM dprotect dp
     WHERE dp.platform="H0000"
      AND dp.rcode="5"
      AND dp.object=object_type
      AND dp.object_name=patstring(curaccept)
      AND dp.group=0
     DETAIL
      addcnt = (addcnt+ 1)
      IF (mod(addcnt,10)=1)
       stat = alterlist(object_list->qual,(addcnt+ 9))
      ENDIF
      object_list->qual[addcnt].object = object_type, object_list->qual[addcnt].object_name = dp
      .object_name
     WITH nocounter
    ;end select
    CALL accept(11,35,"P;CU","N")
    SET addmore = curaccept
   ENDIF
 ENDWHILE
 SET stat = alterlist(object_list->qual,addcnt)
 FREE DEFINE dicocd
 FREE SET minidictionary
 SET minidictionary = concat("ocddir:",minidic)
 DEFINE dicocd value(minidictionary)  WITH modify
 SELECT INTO "nl:"
  dp.object, dp.object_name, dp.app_major_version,
  dp.app_minor_version, dp.datestamp, dp.timestamp
  FROM dprotectocd dp,
   (dummyt d  WITH seq = value(addcnt))
  PLAN (d)
   JOIN (dp
   WHERE "H0000"=dp.platform
    AND "5"=dp.rcode
    AND (object_list->qual[d.seq].object=dp.object)
    AND (object_list->qual[d.seq].object_name=dp.object_name)
    AND 0=dp.group)
  ORDER BY dp.object, dp.object_name
  HEAD REPORT
   dupcnt = 0
  DETAIL
   dupcnt = (dupcnt+ 1)
   IF (mod(dupcnt,10)=1)
    stat = alterlist(dup_object_list->qual,(dupcnt+ 9))
   ENDIF
   dup_object_list->qual[dupcnt].object = object_list->qual[d.seq].object, dup_object_list->qual[
   dupcnt].object_name = object_list->qual[d.seq].object_name
  FOOT REPORT
   stat = alterlist(dup_object_list->qual,dupcnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  IF (object_type != "B")
   SELECT INTO mine
    object = dup_object_list->qual[d.seq].object, object_name = dup_object_list->qual[d.seq].
    object_name
    FROM (dummyt d  WITH seq = value(dupcnt))
    HEAD REPORT
     row 1,
     CALL center("The following objects already exist in the",0,79), row + 1,
     CALL center("current mini-dictionary and",0,79), row + 1,
     CALL center("WILL NOT BE REPLACED",0,79),
     row + 2,
     CALL center("If you have modified these objects",0,79), row + 1,
     CALL center("and would like to export the changes",0,79), row + 1,
     CALL center("you must first delete the objects from the",0,79),
     row + 1,
     CALL center("current mini-dictionary.",0,79), row + 2,
     col 10, "Object Type:", col 25,
     "Object Name:", row + 2
    DETAIL
     col 10, object, col 25,
     object_name, row + 1
   ;end select
  ELSE
   DELETE  FROM dprotectocd dpocd,
     (dummyt d  WITH seq = value(dupcnt))
    SET dpocd.seq = dpocd.seq
    PLAN (d)
     JOIN (dpocd
     WHERE "H0000"=dpocd.platform
      AND "5"=dpocd.rcode
      AND (dup_object_list->qual[d.seq].object=dpocd.object)
      AND (dup_object_list->qual[d.seq].object_name=dpocd.object_name)
      AND 0=dpocd.group)
    WITH nocounter
   ;end delete
   DELETE  FROM dcompileocd dcocd,
     (dummyt d  WITH seq = value(dupcnt))
    SET dcocd.seq = dcocd.seq
    PLAN (d)
     JOIN (dcocd
     WHERE "H0000"=dcocd.platform
      AND "9"=dcocd.rcode
      AND (dup_object_list->qual[d.seq].object=dcocd.object)
      AND (dup_object_list->qual[d.seq].object_name=dcocd.object_name)
      AND 0=dcocd.group)
    WITH nocounter
   ;end delete
  ENDIF
 ENDIF
 INSERT  FROM dprotect dp,
   dprotectocd dpocd,
   (dummyt d  WITH seq = value(addcnt))
  SET dpocd.datarec = dp.datarec
  PLAN (d)
   JOIN (dp
   WHERE "H0000"=dp.platform
    AND "5"=dp.rcode
    AND (object_list->qual[d.seq].object=dp.object)
    AND (object_list->qual[d.seq].object_name=dp.object_name)
    AND 0=dp.group)
   JOIN (dpocd
   WHERE dp.platform=dpocd.platform
    AND dp.rcode=dpocd.rcode
    AND dp.object=dpocd.object
    AND dp.object_name=dpocd.object_name
    AND dp.group=dpocd.group)
  WITH outerjoin = dp, dontexist
 ;end insert
 INSERT  FROM dcompile dc,
   dcompileocd dcocd,
   (dummyt d  WITH seq = value(addcnt))
  SET dcocd.datarec = dc.datarec
  PLAN (d)
   JOIN (dc
   WHERE "H0000"=dc.platform
    AND "9"=dc.rcode
    AND (object_list->qual[d.seq].object=dc.object)
    AND (object_list->qual[d.seq].object_name=dc.object_name)
    AND 0=dc.group)
   JOIN (dcocd
   WHERE dc.platform=dcocd.platform
    AND dc.rcode=dcocd.rcode
    AND dc.object=dcocd.object
    AND dc.object_name=dcocd.object_name
    AND dc.group=dcocd.group
    AND dc.qual=dcocd.qual)
  WITH counter, outerjoin = dc, dontexist
 ;end insert
 UPDATE  FROM dprotectocd dpocd,
   (dummyt d  WITH seq = value(addcnt))
  SET dpocd.app_major_version = major, dpocd.app_minor_version = ocdnum
  PLAN (d)
   JOIN (dpocd
   WHERE "H0000"=dpocd.platform
    AND "5"=dpocd.rcode
    AND (object_list->qual[d.seq].object=dpocd.object)
    AND (object_list->qual[d.seq].object_name=dpocd.object_name)
    AND 0=dpocd.group)
  WITH counter
 ;end update
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
   CALL echo(com)
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
#exit_export
END GO
