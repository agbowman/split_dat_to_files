CREATE PROGRAM dm_create_a_dictionary:dba
 SET objcnt = 0
 SET run_drop = "F"
 SET drop_attempts = 0
 SET my_debug_flag = validate(dm2_debug_flag,0)
 FREE RECORD object_list
 RECORD object_list(
   1 qual[*]
     2 platform = c5
     2 object = c1
     2 object_name = c30
     2 group = i1
     2 drop_ind = c1
 )
 CALL echo("**********************************************************")
 CALL echo("Starting creation of dictionary, version 2.")
 CALL echo("**********************************************************")
 CALL echo("**********************************************************")
 CALL echo("creating cer_install:dm_dict.dat file.")
 CALL echo("**********************************************************")
 SELECT INTO TABLE "cer_install:dm_dict.dat"
  ky1 = fillstring(40," "), data = fillstring(810," ")
  FROM dummyt
  WHERE 1=0
  ORDER BY ky1
  WITH nocounter, organization = indexed
 ;end select
 CALL echo("**********************************************************")
 CALL echo("check and create subdic table definition if needed.")
 CALL echo("**********************************************************")
 SELECT INTO "nl:"
  FROM dtable
  WHERE table_name="SUBDIC"
  WITH nocounter
 ;end select
 IF (curqual=0)
  DROP DATABASE subdic WITH deps_deleted
  CREATE DATABASE subdic
  ORGANIZATION(indexed)
  FORMAT(fixed)
  SIZE(850)
  UNIQUE KEY 1(0,40)
  DROP DDLRECORD subdic FROM DATABASE subdic WITH deps_deleted
  CREATE DDLRECORD subdic FROM DATABASE subdic
 TABLE subdic WITH null = none
  1 dic1_key
    2 platform  = c5 CCL(platform)
    2 rcode  = ac1 CCL(rcode)
    2 rest  = c34 CCL(rest)
  1 data  = c810 CCL(data)
 END TABLE subdic
  WITH access_code = none
  DROP DDLRECORD subprot FROM DATABASE subdic WITH deps_deleted
  CREATE DDLRECORD subprot FROM DATABASE subdic
 TABLE subprot WITH null = none
  1 dicsubprot_key
    2 platform  = c5 CCL(platform)
    2 rcode  = ac1 CCL(rcode)
    2 object  = c1 CCL(object)
    2 object_name  = c30 CCL(object_name)
    2 group  = ui1 CCL(group)
    2 filler  = c2
 TABLE dsubprotmode WITH null = skip_zero
  1 groups (100)
    2 permit_info  = ui1 CCL(permit_info)
 END TABLE dsubprotmode
  1 user_name  = c12 CCL(user_name)
  1 source_name  = c80 CCL(source_name)
  1 datestamp  = di4 CCL(datestamp)
  1 timestamp  = ti4 CCL(timestamp)
  1 binary_cnt  = i4 CCL(binary_cnt)
  1 app_major_version  = i4 CCL(app_major_version)
  1 app_minor_version  = i4 CCL(app_minor_version)
  1 ccl_version  = i4 CCL(ccl_version)
  1 updt_task  = i4 CCL(updt_task)
  1 updt_applctx  = i4 CCL(updt_applctx)
  1 updt_id  = f8 CCL(updt_id)
  1 prcname  = c15 CCL(prcname)
 END TABLE subprot
  WITH access_code = 5
  DROP DDLRECORD subpile FROM DATABASE subdic WITH deps_deleted
  CREATE DDLRECORD subpile FROM DATABASE subdic
 TABLE subpile WITH null = none
  1 dicsubpile_key
    2 platform  = c5 CCL(platform)
    2 rcode  = ac1 CCL(rcode)
    2 object  = c1 CCL(object)
    2 object_name  = c30 CCL(object_name)
    2 group  = ui1 CCL(group)
    2 qual  = ui2 CCL(qual)
  1 source_name  = uc800
 END TABLE subpile
  WITH access_code = 9
 ENDIF
 CALL echo("**********************************************************")
 CALL echo("Define dictionary and begin inserting data.")
 CALL echo("**********************************************************")
 FREE DEFINE dicocd
 DEFINE subdic "cer_install:dm_dict.dat"  WITH modify
 DEFINE dicocd "ccldir:dic.dat"
#start_insert
 SET objcnt = 0
 SET run_drop = "F"
 INSERT  FROM (dgenericocd d  WITH access_code = none),
   (subdic dg  WITH access_code = none)
  SET dg.datarec = d.datarec
  PLAN (d)
   JOIN (dg
   WHERE d.key1=dg.key1)
  WITH outerjoin = d, dontexist
 ;end insert
 CALL echo("**********************************************************")
 CALL echo("Check for invalid inserts")
 CALL echo("**********************************************************")
 IF (my_debug_flag >= 5)
  SELECT
   wait_sum = "test"
   FROM dummyt
   DETAIL
    "for testing, fix broken scripts in source, should still be in next section", row + 1
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "NL:"
  brk = concat(p.object,p.object_name,format(p.group,"##;rp0")), p.object, p.object_name,
  p.binary_cnt, maxnum = (c.qual+ 1)
  FROM subprot p,
   subpile c
  PLAN (p
   WHERE p.object IN ("E", "P"))
   JOIN (c
   WHERE p.platform=c.platform
    AND "P"=c.object
    AND p.object_name=c.object_name
    AND p.group=c.group)
  ORDER BY brk, c.qual
  HEAD brk
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
  FOOT  brk
   IF (((p.binary_cnt != maxnum) OR (p.binary_cnt != cnt)) )
    objcnt = (objcnt+ 1)
    IF (mod(objcnt,10)=1)
     stat = alterlist(object_list->qual,(objcnt+ 9))
    ENDIF
    object_list->qual[objcnt].platform = p.platform, object_list->qual[objcnt].object = p.object,
    object_list->qual[objcnt].object_name = p.object_name,
    object_list->qual[objcnt].group = p.group, object_list->qual[objcnt].drop_ind = "T"
   ENDIF
  FOOT REPORT
   stat = alterlist(object_list->qual,objcnt)
  WITH counter, outerjoin = p
 ;end select
 IF (my_debug_flag >= 1)
  CALL echo("here is the list of objects that are invalid in dictionary")
  CALL echorecord(object_list)
 ENDIF
 IF (objcnt > 0)
  IF (my_debug_flag >= 5)
   SELECT
    t = "test"
    FROM dummyt
    DETAIL
     col 1, "This provides time to fix an invalid object in the source dictionary for testing"
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "NL:"
   brk = concat(p.object,p.object_name,format(p.group,"##;rp0")), p.object, p.object_name,
   p.binary_cnt, maxnum = (c.qual+ 1)
   FROM (dummyt d  WITH seq = value(objcnt)),
    dprotectocd p,
    dcompileocd c
   PLAN (d)
    JOIN (p
    WHERE (object_list->qual[d.seq].platform=p.platform)
     AND (object_list->qual[objcnt].object=p.object)
     AND (object_list->qual[d.seq].object_name=p.object_name)
     AND (object_list->qual[d.seq].group=p.group))
    JOIN (c
    WHERE p.platform=c.platform
     AND "P"=c.object
     AND p.object_name=c.object_name
     AND p.group=c.group)
   ORDER BY brk, c.qual
   HEAD brk
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
   FOOT  brk
    IF (((p.binary_cnt != maxnum) OR (p.binary_cnt != cnt)) )
     object_list->qual[d.seq].drop_ind = "F"
    ELSE
     run_drop = "T"
    ENDIF
   WITH counter, outerjoin = p
  ;end select
  IF (run_drop="T")
   IF (drop_attempts < 3)
    FOR (forcnt = 1 TO objcnt)
      DELETE  FROM subprot
       WHERE (object_name=object_list->qual[forcnt].object_name)
      ;end delete
      DELETE  FROM subpile
       WHERE (object_name=object_list->qual[forcnt].object_name)
      ;end delete
      SET drop_attempts = (drop_attempts+ 1)
    ENDFOR
    CALL echo("**********************************************************")
    CALL echo("cleaned up invalid objects... attempting to re-insert")
    CALL echo("**********************************************************")
    GO TO start_insert
   ELSE
    CALL echo("**********************************************************")
    CALL echo("clean up of invalid objects has failed... here is the list of objects")
    CALL echo("**********************************************************")
    CALL echorecord(object_list)
    CALL echo("**********************************************************")
    CALL echo("clean up of invalid objects has failed...above is the list of objects")
    CALL echo("**********************************************************")
   ENDIF
  ENDIF
 ENDIF
 CALL echo("**********************************************************")
 CALL echo("Clean up defs")
 CALL echo("**********************************************************")
 DELETE  FROM (subdic  WITH access_code = none)
  WHERE rest="SUBDIC *"
 ;end delete
 DELETE  FROM (subdic  WITH access_code = none)
  WHERE rest="DSUBPROTMODE *"
 ;end delete
 DELETE  FROM (subdic  WITH access_code = none)
  WHERE rest="SUBPILE *"
 ;end delete
 DELETE  FROM (subdic  WITH access_code = none)
  WHERE rest="SUBPROT *"
 ;end delete
 DELETE  FROM (subdic  WITH access_code = none)
  WHERE rest="DSUBDIC *"
 ;end delete
 DELETE  FROM (subdic  WITH access_code = none)
  WHERE rest="TDSUBPROTMODE *"
 ;end delete
 DELETE  FROM (subdic  WITH access_code = none)
  WHERE rest="TSUBPILE *"
 ;end delete
 DELETE  FROM (subdic  WITH access_code = none)
  WHERE rest="TSUBPROT *"
 ;end delete
 DELETE  FROM (subdic  WITH access_code = none)
  WHERE rest="TSUBDIC *"
 ;end delete
 FREE DEFINE subdic
 FREE DEFINE dicocd
 DROP TABLE subdic
 DROP TABLE subprot
 DROP TABLE subpile
 DROP DATABASE subdic WITH deps_deleted
 IF (run_drop="F")
  CALL echo("**********************************************************")
  CALL echo("program ran to completion successfully")
  CALL echo("**********************************************************")
 ENDIF
 IF (my_debug_flag >= 1)
  CALL echo("List of invalid objects in both dictionaries")
  CALL echorecord(object_list)
 ENDIF
#exit_script
END GO
