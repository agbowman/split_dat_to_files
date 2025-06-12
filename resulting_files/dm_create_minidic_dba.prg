CREATE PROGRAM dm_create_minidic:dba
 CALL echo("**********************************************************")
 CALL echo("Starting creation of mini dictionary.")
 CALL echo("This should be ran in the source domain after the single")
 CALL echo("installs are complete")
 CALL echo("**********************************************************")
 SELECT INTO "NL:"
  d.object_name
  FROM dprotect d
  WHERE d.object="T"
   AND object_name="OCD_README_COMPONENT"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "dm_create_minidic.log"
   FROM dummyt
   HEAD REPORT
    col 0, curdate"mm/dd/yyyy;;d", col + 5,
    curtime, row + 1, "While attempting to create the cer_install:dm_minidic.dat file",
    row + 1, "the table OCD_REAME_COMPONENT was not found in the ccl dictionary"
   WITH nocounter
  ;end select
  CALL echo("**********************************************************")
  CALL echo("While attempting to create the cer_install:dm_minidic.dat file")
  CALL echo("the table OCD_REAME_COMPONENT was not found in the ccl dictionary")
  CALL echo("Exiting script")
  CALL echo("**********************************************************")
  GO TO exit_script
 ENDIF
 CALL echo("**********************************************************")
 CALL echo("creating cer_install:dm_minidic.dat file.")
 CALL echo("**********************************************************")
 SELECT INTO TABLE "cer_install:dm_minidic.dat"
  ky1 = fillstring(40," "), data = fillstring(810," ")
  FROM dummyt
  WHERE 1=0
  ORDER BY ky1
  WITH nocounter, organization = indexed
 ;end select
 FREE DEFINE dicocd
 DEFINE dicocd "cer_install:dm_minidic.dat"  WITH modify
 SET addcnt = 0
 FREE RECORD object_list
 RECORD object_list(
   1 qual[*]
     2 object = c1
     2 object_name = c30
     2 insert_ind = c1
 )
 SELECT DISTINCT INTO "NL:"
  orc.end_state
  FROM ocd_readme_component orc
  WHERE orc.component_type="SCRIPT"
  ORDER BY orc.end_state
  HEAD REPORT
   addcnt = 0
  DETAIL
   addcnt = (addcnt+ 1)
   IF (mod(addcnt,10)=1)
    stat = alterlist(object_list->qual,(addcnt+ 9))
   ENDIF
   object_list->qual[addcnt].object = "P", object_list->qual[addcnt].object_name = orc.end_state
  WITH nocounter
 ;end select
 SET stat = alterlist(object_list->qual,addcnt)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(addcnt)),
   dm_info di
  PLAN (d)
   JOIN (di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_char="Do not include in mini-dictionary during mass move"
    AND (di.info_name=object_list->qual[d.seq].object_name))
  DETAIL
   object_list->qual[d.seq].insert_ind = "F"
  WITH nocounter
 ;end select
 INSERT  FROM dprotect dp,
   dprotectocd dpocd,
   (dummyt d  WITH seq = value(addcnt))
  SET dpocd.datarec = dp.datarec
  PLAN (d
   WHERE (object_list->qual[d.seq].insert_ind != "F"))
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
  PLAN (d
   WHERE (object_list->qual[d.seq].insert_ind != "F"))
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
  WITH outerjoin = dc, dontexist
 ;end insert
 IF (curqual=0)
  SELECT INTO "dm_create_minidic.log"
   FROM dummyt
   HEAD REPORT
    col 0, curdate"mm/dd/yyyy;;d", col + 5,
    curtime, row + 1, "No rows where inserted from the dictionary into cer_install:dm_minidic.dat.",
    row + 1, "Either this program has already been ran, or there are no matches."
   WITH nocounter
  ;end select
  CALL echo("**********************************************************")
  CALL echo("No rows where inserted from the dictionary. Either the program has")
  CALL echo("already been ran, or there are no readme for this mass move.")
  CALL echo("**********************************************************")
 ENDIF
 FREE DEFINE dicocd
 FREE RECORD object_list
#exit_script
END GO
