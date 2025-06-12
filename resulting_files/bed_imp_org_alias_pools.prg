CREATE PROGRAM bed_imp_org_alias_pools
 FREE SET org
 RECORD org(
   1 org[*]
     2 org_name = vc
     2 org_id = f8
     2 alias_type = vc
     2 alias_type_cd = f8
     2 alias_cat = vc
     2 alias_cat_cd = f8
     2 alias_pool = vc
     2 alias_pool_cd = f8
     2 action_flag = i2
     2 error_string = vc
 )
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET str_data
 RECORD str_data(
   1 str_qual = c1
 )
#1000_initialize
 SET write_mode = 0
 IF ((tempreq->insert_ind="Y"))
  SET write_mode = 1
 ENDIF
 SET reply->status_data.status = "F"
 SET error_flag = "Y"
 DECLARE error_msg = vc
 DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH constant(cnvtdatetime("31-dec-2100 00:00:00"))
 SET active_cd = get_code_value(48,"ACTIVE")
 SET auth_cd = get_code_value(8,"AUTH")
 SET title = validate(log_title_set,"Organization Alias Pool Load Log")
 SET name = validate(log_name_set,"bed_org_alias_pools.log")
 SET status = validate(log_col_set,"STATUS")
 SET alt_mode = validate(alt_mode_set,0)
 SET alt_detail = validate(alt_detail_set,0)
 CALL logstart(title,name)
 SET numrows = size(requestin->list_0,5)
 IF (numrows=0)
  SET error_msg = "No rows to process"
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO numrows)
   SET stat = alterlist(org->org,i)
   SET org->org[i].org_name = requestin->list_0[i].org_name
   SET org->org[i].alias_cat = requestin->list_0[i].alias_cat
   SET org->org[i].alias_pool = requestin->list_0[i].alias_pool
   SET org->org[i].alias_type = requestin->list_0[i].alias_type
   SET org->org[i].action_flag = 1
 ENDFOR
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = numrows),
   organization o
  PLAN (d)
   JOIN (o
   WHERE cnvtupper(org->org[d.seq].org_name)=cnvtupper(o.org_name)
    AND o.active_ind=1)
  DETAIL
   org->org[d.seq].org_id = o.organization_id
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = numrows),
   code_value cv
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=263
    AND cnvtupper(cv.display)=cnvtupper(org->org[d.seq].alias_pool)
    AND cv.active_ind=1)
  DETAIL
   org->org[d.seq].alias_pool_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (i = 1 TO numrows)
   IF (cnvtupper(org->org[i].alias_cat)="PERSON_ALIAS")
    SET org->org[i].alias_cat_cd = 4
    SET org->org[i].alias_cat = "PERSON_ALIAS"
   ELSEIF (cnvtupper(org->org[i].alias_cat)="ENCNTR_ALIAS")
    SET org->org[i].alias_cat_cd = 319
    SET org->org[i].alias_cat = "ENCNTR_ALIAS"
   ELSEIF (cnvtupper(org->org[i].alias_cat)="PRSNL_ALIAS")
    SET org->org[i].alias_cat_cd = 320
    SET org->org[i].alias_cat = "PRSNL_ALIAS"
   ELSEIF (cnvtupper(org->org[i].alias_cat)="ORDER_ALIAS")
    SET org->org[i].alias_cat_cd = 754
    SET org->org[i].alias_cat = "ORDER_ALIAS"
   ELSEIF (cnvtupper(org->org[i].alias_cat)="ORGANIZATION_ALIAS")
    SET org->org[i].alias_cat_cd = 334
    SET org->org[i].alias_cat = "ORGANIZATION_ALIAS"
   ELSEIF (cnvtupper(org->org[i].alias_cat)="MEDIA ALIAS")
    SET org->org[i].alias_cat_cd = 3542
    SET org->org[i].alias_cat = "Media Alias"
   ELSEIF (cnvtupper(org->org[i].alias_cat)="PROFIT BILL ALIAS")
    SET org->org[i].alias_cat_cd = 28200
    SET org->org[i].alias_cat = "ProFit Bill Alias"
   ELSEIF (cnvtupper(org->org[i].alias_cat)="HEALTH PLAN ALIAS")
    SET org->org[i].alias_cat_cd = 27121
    SET org->org[i].alias_cat = "HEALTH_PLAN_ALIAS"
   ELSEIF (cnvtupper(org->org[i].alias_cat)="SCH EVENT ALIAS")
    SET org->org[i].alias_cat_cd = 26881
    SET org->org[i].alias_cat = "SCH_EVENT_ALIAS"
   ELSE
    SET org->org[i].action_flag = 0
    SET org->org[i].error_string = "Invalid Alias Catagory"
   ENDIF
 ENDFOR
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = numrows),
   code_value c
  PLAN (d
   WHERE (org->org[d.seq].action_flag=1))
   JOIN (c
   WHERE (c.code_set=org->org[d.seq].alias_cat_cd)
    AND cnvtupper(c.display)=cnvtupper(org->org[d.seq].alias_type)
    AND c.active_ind=1)
  DETAIL
   org->org[d.seq].alias_type_cd = c.code_value
  WITH nocounter
 ;end select
 FOR (i = 1 TO numrows)
   IF ((org->org[i].org_id=0))
    SET org->org[i].action_flag = 0
    SET org->org[i].error_string = "Invalid Organization"
   ELSEIF ((org->org[i].alias_pool_cd=0))
    SET org->org[i].action_flag = 0
    SET org->org[i].error_string = "Invalid Alias Pool"
   ELSEIF ((org->org[i].alias_type_cd=0))
    SET org->org[i].action_flag = 0
    SET org->org[i].error_string = "Invalid Alias Type"
   ENDIF
 ENDFOR
 SELECT INTO "NL:"
  FROM org_alias_pool_reltn o,
   (dummyt d  WITH seq = numrows)
  PLAN (d
   WHERE (org->org[d.seq].action_flag != 0))
   JOIN (o
   WHERE (o.organization_id=org->org[d.seq].org_id)
    AND (o.alias_entity_name=org->org[d.seq].alias_cat)
    AND (o.alias_pool_cd=org->org[d.seq].alias_pool_cd)
    AND o.active_ind=1)
  DETAIL
   org->org[d.seq].action_flag = 0, org->org[d.seq].error_string = "Alias Relation Exists"
  WITH nocounter
 ;end select
 IF (write_mode=1)
  FOR (i = 1 TO numrows)
    IF ((org->org[i].action_flag=1))
     INSERT  FROM org_alias_pool_reltn o
      SET o.seq = 1, o.organization_id = org->org[i].org_id, o.alias_entity_name = org->org[i].
       alias_cat,
       o.alias_entity_alias_type_cd = org->org[i].alias_type_cd, o.alias_pool_cd = org->org[i].
       alias_pool_cd, o.active_ind = 1,
       o.active_status_cd = active_cd, o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o
       .active_status_prsnl_id = reqinfo->updt_id,
       o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), o.end_effective_dt_tm = cnvtdatetime(
        "31-dec-2100 00:00:00"), o.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->
       updt_applctx,
       o.updt_cnt = 0
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO value(name)
  FROM (dummyt d  WITH seq = numrows)
  DETAIL
   row + 1, col 1, d.seq"#####",
   col 10, org->org[d.seq].org_name, col 40,
   org->org[d.seq].alias_cat, col 60, org->org[d.seq].alias_type,
   col 80, org->org[d.seq].alias_pool
   IF ((org->org[d.seq].action_flag=1))
    col 100, "ADDED"
   ELSE
    col 100, "ERROR"
   ENDIF
   col 110, org->org[d.seq].error_string
  WITH nocounter, append
 ;end select
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 RETURN
 SUBROUTINE logstart(xtitle,xname)
   DECLARE dir_name = vc
   SET dir_name = "ccluserdir:"
   SET log_name = concat(trim(dir_name),xname)
   SET logvar = 0
   SELECT INTO value(log_name)
    logvar
    HEAD REPORT
     begin_dt_tm"dd-mmm-yyyy;;d", "-", begin_dt_tm"hh:mm:ss;;m",
     col + 1, xtitle, row + 1
     IF (write_mode=0)
      col 30, "AUDIT MODE: NO CHANGES HAVE BEEN MADE TO THE DATABASE"
     ELSE
      col 30, "COMMIT MODE: CHANGES HAVE BEEN MADE TO THE DATABASE"
     ENDIF
    DETAIL
     row + 2, col 2, "ROW",
     col 10, "ORGANIZATION NAME", col 40,
     "ALIAS ENTITY", col 60, "ALIAS TYPE",
     col 80, "ALIAS POOL", col 100,
     "STATUS", col 110, "ERROR"
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
   RETURN
 END ;Subroutine
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 SUBROUTINE get_cv_by_disp(xcodeset,xdisp)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND cnvtupper(c.display)=trim(cnvtupper(xdisp)))
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
END GO
