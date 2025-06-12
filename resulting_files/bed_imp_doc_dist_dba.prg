CREATE PROGRAM bed_imp_doc_dist:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp
 RECORD temp(
   1 list_0[*]
     2 dist_name = vc
     2 distribution_id = f8
     2 transaction = vc
     2 error_string = vc
     2 action_flag = i2
     2 loc_count = i4
     2 loc[*]
       3 loc_cd = f8
       3 loc_disp = vc
       3 full_disp = vc
 )
 FREE SET str_data
 RECORD str_data(
   1 str_qual = c1
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH constant(cnvtdatetime("31-dec-2100 00:00:00"))
 SET write_mode = 0
 IF ((tempreq->insert_ind="Y"))
  SET write_mode = 1
 ENDIF
 SET active_cd = get_code_value(48,"ACTIVE")
 SET building_cd = get_code_value(222,"BUILDING")
 SET fac_cd = get_code_value(222,"FACILITY")
 SET numrows = size(requestin->list_0,5)
 IF (numrows=0)
  SET error_msg = "No rows to process"
  GO TO exit_script
 ENDIF
 SET title = validate(log_title_set,"ERM Document Distribution Import")
 SET name = validate(log_name_set,"bed_doc_dist.log")
 SET status = validate(log_col_set,"STATUS")
 SET alt_mode = validate(alt_mode_set,0)
 SET alt_detail = validate(alt_detail_set,0)
 CALL logstart(title,name)
 SET tempnum = 0
 FOR (i = 1 TO numrows)
   SET rec = 0
   FOR (ii = 1 TO tempnum)
     IF (cnvtupper(temp->list_0[ii].dist_name)=cnvtupper(requestin->list_0[i].dist_name))
      SET rec = ii
     ENDIF
   ENDFOR
   IF (rec=0)
    SET tempnum = (tempnum+ 1)
    SET stat = alterlist(temp->list_0,tempnum)
    SET rec = tempnum
    SET temp->list_0[rec].action_flag = 1
    SET temp->list_0[rec].dist_name = requestin->list_0[i].dist_name
    SET temp->list_0[rec].transaction = requestin->list_0[i].transaction_type
    SELECT INTO "NL:"
     FROM pm_doc_distribution p
     PLAN (p
      WHERE cnvtupper(p.distribution_name)=cnvtupper(temp->list_0[rec].dist_name)
       AND p.active_ind=1)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET temp->list_0[tempnum].error_string = "Dist Already Exists"
     SET temp->list_0[tempnum].action_flag = 0
    ENDIF
    SELECT INTO "NL:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=14763
       AND c.cdf_meaning=cnvtupper(temp->list_0[rec].transaction)
       AND c.active_ind=1)
     DETAIL
      temp->list_0[rec].transaction = c.cdf_meaning
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET temp->list_0[rec].error_string = "Invalid Transaction Type"
     SET temp->list_0[rec].action_flag = 0
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].location_disp > " "))
    SET temp->list_0[rec].loc_count = (temp->list_0[rec].loc_count+ 1)
    SET stat = alterlist(temp->list_0[rec].loc,temp->list_0[rec].loc_count)
    SET temp->list_0[rec].loc[temp->list_0[rec].loc_count].loc_disp = requestin->list_0[i].
    location_disp
    SELECT INTO "NL:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=220
       AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].location_disp)
       AND c.active_ind=1
       AND c.cdf_meaning IN ("AMBULATORY", "NURSEUNIT"))
     DETAIL
      temp->list_0[rec].loc[temp->list_0[rec].loc_count].loc_cd = c.code_value, temp->list_0[rec].
      loc[temp->list_0[rec].loc_count].loc_disp = c.display
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM location_group l1,
      code_value c1,
      location_group l2,
      code_value c2
     PLAN (l1
      WHERE l1.root_loc_cd=0
       AND (l1.child_loc_cd=temp->list_0[rec].loc[temp->list_0[rec].loc_count].loc_cd)
       AND l1.location_group_type_cd=building_cd
       AND l1.active_ind=1)
      JOIN (c1
      WHERE c1.code_value=l1.parent_loc_cd)
      JOIN (l2
      WHERE l2.root_loc_cd=0
       AND l2.child_loc_cd=c1.code_value
       AND l2.location_group_type_cd=fac_cd
       AND l2.active_ind=1)
      JOIN (c2
      WHERE c2.code_value=l2.parent_loc_cd)
     DETAIL
      temp->list_0[rec].loc[temp->list_0[rec].loc_count].full_disp = build(c2.display,"/",c1.display,
       "/",temp->list_0[rec].loc[temp->list_0[rec].loc_count].loc_disp)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET temp->list_0[rec].action_flag = 0
     SET temp->list_0[rec].error_string = concat("Invalid Location - ",temp->list_0[rec].loc[temp->
      list_0[rec].loc_count].loc_disp)
    ENDIF
   ENDIF
 ENDFOR
 IF (write_mode=1)
  FOR (i = 1 TO tempnum)
    IF ((temp->list_0[i].action_flag=1))
     SET distribution_id = 0.0
     SELECT INTO "nl:"
      y = seq(pm_document_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       distribution_id = cnvtreal(y)
      WITH format, counter
     ;end select
     SET temp->list_0[i].distribution_id = distribution_id
     INSERT  FROM pm_doc_distribution pdd
      SET pdd.distribution_id = temp->list_0[i].distribution_id, pdd.distribution_name = temp->
       list_0[i].dist_name, pdd.distribution_desc = temp->list_0[i].dist_name,
       pdd.active_ind = 1, pdd.active_status_cd = active_cd, pdd.active_status_prsnl_id = reqinfo->
       updt_id,
       pdd.active_status_dt_tm = cnvtdatetime(curdate,curtime), pdd.beg_effective_dt_tm =
       cnvtdatetime(curdate,curtime), pdd.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100 00:00:00.00"),
       pdd.updt_id = reqinfo->updt_id, pdd.updt_task = reqinfo->updt_task, pdd.updt_applctx = reqinfo
       ->updt_applctx,
       pdd.updt_dt_tm = cnvtdatetime(curdate,curtime), pdd.updt_cnt = 0
      WITH nocounter
     ;end insert
     INSERT  FROM pm_doc_dist_filter pddf
      SET pddf.dist_filter_id = seq(pm_document_seq,nextval), pddf.distribution_id = temp->list_0[i].
       distribution_id, pddf.filter_type = "TRN",
       pddf.value = temp->list_0[i].transaction, pddf.value_cd = 0, pddf.value_ind = 0,
       pddf.exclude_ind = 0, pddf.active_ind = 1, pddf.active_status_cd = active_cd,
       pddf.active_status_prsnl_id = reqinfo->updt_id, pddf.active_status_dt_tm = cnvtdatetime(
        curdate,curtime), pddf.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
       pddf.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pddf.updt_id = reqinfo->
       updt_id, pddf.updt_task = reqinfo->updt_task,
       pddf.updt_applctx = reqinfo->updt_applctx, pddf.updt_dt_tm = cnvtdatetime(curdate,curtime),
       pddf.updt_cnt = 0
      WITH nocounter
     ;end insert
     FOR (ii = 1 TO temp->list_0[i].loc_count)
       INSERT  FROM pm_doc_dist_filter pddf
        SET pddf.dist_filter_id = seq(pm_document_seq,nextval), pddf.distribution_id = temp->list_0[i
         ].distribution_id, pddf.filter_type = "NU",
         pddf.value = temp->list_0[i].loc[ii].full_disp, pddf.value_cd = temp->list_0[i].loc[ii].
         loc_cd, pddf.value_ind = 0,
         pddf.exclude_ind = 0, pddf.active_ind = 1, pddf.active_status_cd = active_cd,
         pddf.active_status_prsnl_id = reqinfo->updt_id, pddf.active_status_dt_tm = cnvtdatetime(
          curdate,curtime), pddf.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
         pddf.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pddf.updt_id = reqinfo->
         updt_id, pddf.updt_task = reqinfo->updt_task,
         pddf.updt_applctx = reqinfo->updt_applctx, pddf.updt_dt_tm = cnvtdatetime(curdate,curtime),
         pddf.updt_cnt = 0
        WITH nocounter
       ;end insert
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO value(name)
  FROM (dummyt d  WITH seq = tempnum)
  DETAIL
   col 8, d.seq"#####", col 20,
   temp->list_0[d.seq].dist_name, col 40, temp->list_0[d.seq].transaction
   IF ((temp->list_0[d.seq].action_flag=1))
    col 90, "Added"
   ELSE
    col 90, "Error"
   ENDIF
   col 100, temp->list_0[d.seq].error_string
   FOR (i = 1 TO temp->list_0[d.seq].loc_count)
     col 50, temp->list_0[d.seq].loc[i].full_disp, row + 1
   ENDFOR
   IF ((temp->list_0[d.seq].loc_count=0))
    row + 1
   ENDIF
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
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
    DETAIL
     row + 2, col 10, "ROW",
     col 20, "DISTRIBUTION NAME", col 40,
     "TYPE", col 50, "LOCATION NAME",
     col 90, "STATUS", col 100,
     "ERROR"
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
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
END GO
