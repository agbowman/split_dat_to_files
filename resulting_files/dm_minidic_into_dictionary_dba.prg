CREATE PROGRAM dm_minidic_into_dictionary:dba
 CALL echo("***************************************")
 CALL echo("This should be ran in the target domain.")
 CALL echo("***************************************")
 SET errmsg = fillstring(132," ")
 SET error_check = error(errmsg,1)
 SET errorcode = 0
 SET dm_mode = fillstring(10," ")
 FREE RECORD object_list
 RECORD object_list(
   1 qual[*]
     2 object = c1
     2 object_name = c30
     2 drop_ind = c1
 )
 SET dclstatus = 0
 SET objcnt = 0
 SET forcnt = 0
 SET allcnt = 0
 FREE SET com
 SET com = fillstring(50," ")
 SET minidic = fillstring(16," ")
 SET objname =  $1
 SET dm_mode = cnvtupper( $2)
 IF (dm_mode != "INSTALL"
  AND dm_mode != "UNINSTALL")
  CALL echo("***************************************")
  CALL echo("This program should only be ran as ")
  CALL echo('DM_MINIDIC_INTO_DICTIONARY "INSTALL" go')
  CALL echo("to move readme components to the target dictionary of ")
  CALL echo('DM_MINIDIC_INTO_DICTIONARY "UNINSTALL" go')
  CALL echo("to return readme components to there original state before the install")
  CALL echo("***************************************")
  GO TO exit_script
 ENDIF
 FREE SET minidictionary
 SET minidictionary = "cer_install:dm_minidic.dat"
 FREE SET fstat
 SET fstat = findfile(minidictionary)
 IF (fstat=0)
  CALL echo("***********************")
  CALL echo("File dm_minidic.dat is not in the cer_install directory")
  CALL echo("***********************")
  GO TO exit_script
 ENDIF
 IF (dm_mode="UNINSTALL")
  FREE SET minidictionary
  SET minidictionary = "cer_install:dm_minibac.dat"
  FREE SET fstat
  SET fstat = findfile(minidictionary)
  IF (fstat=0)
   CALL echo("***********************")
   CALL echo("File dm_minibac.dat is not in the cer_install directory")
   CALL echo("***********************")
   GO TO exit_script
  ENDIF
 ENDIF
 FREE SET minidictionary
 SET minidictionary = "cer_install:dm_minidic.dat"
 FREE DEFINE dicocd
 DEFINE dicocd value(minidictionary)
 IF (dm_mode="INSTALL")
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
  CALL echo("**********************************************************")
  CALL echo("Creating backup of dictionary objects in cer_install:dm_minibac.dat")
  CALL echo("**********************************************************")
  SELECT INTO TABLE "cer_install:dm_minibac.dat"
   ky1 = fillstring(40," "), data = fillstring(810," ")
   FROM dummyt
   WHERE 1=0
   ORDER BY ky1
   WITH nocounter, organization = indexed
  ;end select
  CALL echo("**********************************************************")
  CALL echo("Put objects into cer_install:dm_minibac.dat ")
  CALL echo("**********************************************************")
  FREE DEFINE dicocd
  FREE SET minidictionary
  SET minidictionary = "cer_install:dm_minibac.dat"
  DEFINE dicocd value(minidictionary)  WITH modify
  INSERT  FROM dprotectocd dpocd,
    dprotect dp,
    (dummyt d  WITH seq = value(objcnt))
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
   WITH counter, outerjoin = dp, dontexist
  ;end insert
  INSERT  FROM dcompile dc,
    dcompileocd dcocd,
    (dummyt d  WITH seq = value(objcnt))
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
  SET minidictionary = "cer_install:dm_minidic.dat"
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
  CALL echo("*************************")
  CALL echo("Put objects that were not in dictionary before into backup")
  CALL echo("*************************")
  FREE DEFINE dicocd
  FREE SET minidictionary
  SET minidictionary = "cer_install:dm_minibac.dat"
  DEFINE dicocd value(minidictionary)  WITH modify
  INSERT  FROM dprotectocd dpocd,
    dprotect dp,
    (dummyt d  WITH seq = value(objcnt))
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
   WITH counter, outerjoin = dp, dontexist
  ;end insert
  INSERT  FROM dcompile dc,
    dcompileocd dcocd,
    (dummyt d  WITH seq = value(objcnt))
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
  CALL echo("*************************")
  CALL echo("End install")
  CALL echo("*************************")
 ELSE
  CALL echo("*************************")
  CALL echo("Begin the unistall")
  CALL echo("*************************")
  FREE DEFINE dicocd
  FREE SET minidictionary
  SET minidictionary = "cer_install:dm_minibac.dat"
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
    objcnt = (objcnt+ 1)
    IF (mod(objcnt,10)=1)
     stat = alterlist(object_list->qual,(objcnt+ 9))
    ENDIF
    object_list->qual[objcnt].object = dpocd.object, object_list->qual[objcnt].object_name = dpocd
    .object_name
    IF (dpocd.app_major_version=dp.app_major_version
     AND dpocd.app_minor_version=dp.app_minor_version
     AND dpocd.datestamp=dp.datestamp
     AND dpocd.timestamp=dp.timestamp)
     object_list->qual[objcnt].drop_ind = "Y"
    ENDIF
   FOOT REPORT
    stat = alterlist(object_list->qual,objcnt)
   WITH nocounter
  ;end select
  IF (objcnt=0)
   CALL echo("****************")
   CALL echo("All scripts are currently uninstalled in CCL")
   CALL echo("****************")
   GO TO exit_script
  ENDIF
  CALL echo("****************")
  CALL echo("Deleting installed scripts from dictionary")
  CALL echo("****************")
  FOR (forcnt = 1 TO objcnt)
    FREE SET com
    SET com = concat("drop program ",trim(value(object_list->qual[forcnt].object_name))," go")
    CALL parser(com)
  ENDFOR
  CALL echo("****************")
  CALL echo("Restoring old scripts from backup")
  CALL echo("****************")
  FREE DEFINE dicocd
  FREE SET minidictionary
  SET minidictionary = "cer_install:dm_minibac.dat"
  DEFINE dicocd value(minidictionary)
  INSERT  FROM dprotect dp,
    dprotectocd dpocd,
    (dummyt d  WITH seq = value(objcnt))
   SET dp.datarec = dpocd.datarec
   PLAN (d
    WHERE (object_list->qual[d.seq].drop_ind != "Y"))
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
   PLAN (d
    WHERE (object_list->qual[d.seq].drop_ind != "Y"))
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
 ENDIF
#exit_script
 FREE RECORD request
 FREE DEFINE dicocd
 FREE SET minidictionary
END GO
