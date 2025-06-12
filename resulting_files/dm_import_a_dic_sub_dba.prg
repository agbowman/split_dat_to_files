CREATE PROGRAM dm_import_a_dic_sub:dba
 FREE SET minidictionary
 SET minidictionary = "cer_install:dm_dict.dat"
 FREE DEFINE dicocd
 DEFINE dicocd value(minidictionary)
 SELECT INTO "NL:"
  dpocd.object, dpocd.object_name
  FROM dprotectocd dpocd,
   dprotect dp
  PLAN (dpocd
   WHERE dpocd.object_name=patstring(cnvtupper(objname)))
   JOIN (dp
   WHERE dpocd.platform=dp.platform
    AND dpocd.rcode=dp.rcode
    AND dpocd.object=dp.object
    AND dpocd.object_name=dp.object_name
    AND dpocd.group=dp.group)
  HEAD REPORT
   row + 0
  DETAIL
   allcnt = (allcnt+ 1)
   IF (dpocd.app_major_version=dp.app_major_version
    AND dpocd.app_minor_version=dp.app_minor_version
    AND dpocd.datestamp=dp.datestamp
    AND dpocd.timestamp=dp.timestamp)
    row + 1
   ELSE
    objcnt = (objcnt+ 1)
    IF (mod(objcnt,10)=1)
     stat = alterlist(object_list->qual,(objcnt+ 9))
    ENDIF
    object_list->qual[objcnt].object = dpocd.object, object_list->qual[objcnt].object_name = dpocd
    .object_name
   ENDIF
  FOOT REPORT
   stat = alterlist(object_list->qual,objcnt)
  WITH outerjoin = dpocd
 ;end select
 SELECT INTO "nl:"
  FROM dprotect dp,
   (dummyt d  WITH seq = value(objcnt))
  PLAN (d)
   JOIN (dp
   WHERE "P"=dp.object
    AND (object_list->qual[d.seq].object_name=dp.object_name))
  DETAIL
   object_list->qual[d.seq].drop_ind = "T"
  WITH nocounter
 ;end select
 FOR (forcnt = 1 TO objcnt)
  FREE SET com
  IF ((object_list->qual[forcnt].drop_ind="T"))
   SET com = concat("drop program ",trim(value(object_list->qual[forcnt].object_name))," go")
   CALL parser(com)
  ENDIF
 ENDFOR
 CALL echo("**********************************************************")
 CALL echo("Import new versions of scripts")
 CALL echo("**********************************************************")
 FREE DEFINE dicocd
 FREE SET minidictionary
 SET minidictionary = "cer_install:dm_dict.dat"
 DEFINE dicocd value(minidictionary)
 INSERT  FROM dprotect dp,
   dprotectocd dpocd,
   (dummyt d  WITH seq = value(objcnt))
  SET dp.datarec = dpocd.datarec
  PLAN (d)
   JOIN (dpocd
   WHERE "H0000"=dpocd.platform
    AND "5"=dpocd.rcode
    AND (object_list->qual[d.seq].object=dpocd.object)
    AND (object_list->qual[d.seq].object_name=dpocd.object_name)
    AND 0=dpocd.group)
   JOIN (dp
   WHERE dpocd.platform=dp.platform
    AND dpocd.rcode=dp.rcode
    AND dpocd.object=dp.object
    AND dpocd.object_name=dp.object_name
    AND dpocd.group=dp.group)
  WITH counter, outerjoin = dpocd, dontexist
 ;end insert
 INSERT  FROM dcompile dc,
   dcompileocd dcocd,
   (dummyt d  WITH seq = value(objcnt))
  SET dc.datarec = dcocd.datarec
  PLAN (d)
   JOIN (dcocd
   WHERE "H0000"=dcocd.platform
    AND "9"=dcocd.rcode
    AND (object_list->qual[d.seq].object=dcocd.object)
    AND (object_list->qual[d.seq].object_name=dcocd.object_name)
    AND 0=dcocd.group)
   JOIN (dc
   WHERE dcocd.platform=dc.platform
    AND dcocd.rcode=dc.rcode
    AND dcocd.object=dc.object
    AND dcocd.object_name=dc.object_name
    AND dcocd.group=dc.group
    AND dcocd.qual=dc.qual)
  WITH counter, outerjoin = dcocd, dontexist
 ;end insert
 FREE DEFINE request
 FREE DEFINE dicocd
 FREE SET minidictionary
 CALL echo("Finshed working on this letter")
 CALL echo(some_var)
 CALL echo("Starting next letter")
END GO
