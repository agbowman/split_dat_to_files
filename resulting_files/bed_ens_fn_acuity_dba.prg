CREATE PROGRAM bed_ens_fn_acuity:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET acuity_code_value = 0.0
 SET tr_ref_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=16409
   AND cv.active_ind=1
   AND cv.cdf_meaning="ACUITY"
  DETAIL
   tr_ref_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET active_code_value = 0.0
 SET inactive_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.active_ind=1
   AND ((cv.cdf_meaning="ACTIVE") OR (cv.cdf_meaning="INACTIVE"))
  DETAIL
   IF (cv.cdf_meaning="ACTIVE")
    active_code_value = cv.code_value
   ELSE
    inactive_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET filter_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25631
   AND cv.cdf_meaning="TRACKGROUP"
   AND cv.active_ind=1
  DETAIL
   filter_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET group_cnt = size(request->trlist,5)
 SET acuity_cnt = size(request->alist,5)
 FOR (x = 1 TO acuity_cnt)
   IF ((request->alist[x].action_flag=1))
    FOR (i = 1 TO group_cnt)
      SET new_cv = 0.0
      SELECT INTO "NL:"
       j = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_cv = cnvtreal(j)
       WITH format, counter
      ;end select
      INSERT  FROM code_value cv
       SET cv.code_value = new_cv, cv.code_set = 16589, cv.active_ind = 1,
        cv.display = trim(substring(1,40,request->alist[x].display)), cv.display_key = trim(cnvtupper
         (cnvtalphanum(substring(1,40,request->alist[x].display)))), cv.description = trim(substring(
          1,60,request->alist[x].description)),
        cv.definition = trim(substring(1,100,request->trlist[i].display)), cv.active_type_cd =
        active_code_value, cv.active_dt_tm = cnvtdatetime(curdate,curtime3),
        cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task
         = reqinfo->updt_task,
        cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (curqual > 0)
       SET acuity_code_value = new_cv
      ELSE
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert into cs 16589 ",trim(request->alist[x].display))
       GO TO exit_script
      ENDIF
      INSERT  FROM track_reference tr
       SET tr.tracking_ref_id = seq(reference_seq,nextval), tr.tracking_group_cd = request->trlist[i]
        .code_value, tr.tracking_ref_type_cd = tr_ref_code_value,
        tr.assoc_code_value = acuity_code_value, tr.active_ind = 1, tr.description = request->alist[x
        ].description,
        tr.display = request->alist[x].display, tr.display_key = cnvtupper(cnvtalphanum(request->
          alist[x].display)), tr.ref_color = request->alist[x].color,
        tr.ref_icon = request->alist[x].icon, tr.overdue_interval = 0.0, tr.overdue_color =
        "255,255,255",
        tr.overdue_icon = 0.0, tr.critical_color = "255,255,255", tr.critical_icon = 0.0,
        tr.critical_interval = 0.0, tr.default_ind = 0.0, tr.complete_ind = 0.0,
        tr.critical_blink_ind = 0.0, tr.overdue_blink_ind = 0.0, tr.updt_dt_tm = cnvtdatetime(curdate,
         curtime3),
        tr.updt_id = reqinfo->updt_id, tr.updt_task = reqinfo->updt_task, tr.updt_cnt = 0,
        tr.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET code_value_filter_id = 0.0
      SELECT INTO "nl:"
       FROM code_value_filter cvf
       WHERE cvf.code_set=16589
        AND cvf.filter_type_cd=filter_type_cd
        AND cvf.filter_ind=0
        AND cvf.parent_entity_name1="CODE_VALUE"
        AND (cvf.flex1_id=request->trlist[i].code_value)
       DETAIL
        code_value_filter_id = cvf.code_value_filter_id
       WITH nocounter
      ;end select
      IF (code_value_filter_id=0)
       SET code_value_filter_id = 0.0
       SELECT INTO "NL:"
        j = seq(reference_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         code_value_filter_id = cnvtreal(j)
        WITH format, counter
       ;end select
       INSERT  FROM code_value_filter cvf
        SET cvf.code_value_filter_id = code_value_filter_id, cvf.code_set = 16589, cvf.filter_type_cd
          = filter_type_cd,
         cvf.filter_ind = 0, cvf.parent_entity_name1 = "CODE_VALUE", cvf.flex1_id = request->trlist[i
         ].code_value,
         cvf.updt_id = reqinfo->updt_id, cvf.updt_cnt = 0, cvf.updt_dt_tm = cnvtdatetime(curdate,
          curtime3),
         cvf.updt_task = reqinfo->updt_task, cvf.updt_applctx = reqinfo->updt_applctx, cvf.active_ind
          = 1,
         cvf.active_status_prsnl_id = reqinfo->updt_id, cvf.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3), cvf.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
         cvf.end_effective_dt_tm = cnvtdatetime("31-dec-2100 23:59:59")
        WITH nocounter
       ;end insert
      ENDIF
      INSERT  FROM code_value_filter_r cvfr
       SET cvfr.code_value_filter_id = code_value_filter_id, cvfr.code_value_cd = acuity_code_value,
        cvfr.updt_id = reqinfo->updt_id,
        cvfr.updt_cnt = 0, cvfr.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvfr.updt_task = reqinfo
        ->updt_task,
        cvfr.active_ind = 1, cvfr.updt_applctx = reqinfo->updt_applctx, cvfr.beg_effective_dt_tm =
        cnvtdatetime(curdate,curtime3),
        cvfr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
       WITH nocounter
      ;end insert
      INSERT  FROM code_value_group cvg
       SET cvg.parent_code_value = request->trlist[i].code_value, cvg.child_code_value =
        acuity_code_value, cvg.code_set = 16589,
        cvg.updt_id = reqinfo->updt_id, cvg.updt_cnt = 0, cvg.updt_dt_tm = cnvtdatetime(curdate,
         curtime3),
        cvg.updt_task = reqinfo->updt_task, cvg.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
    ENDFOR
   ELSEIF ((request->alist[x].action_flag=2))
    FOR (i = 1 TO group_cnt)
      UPDATE  FROM code_value cv
       SET cv.active_ind = 1, cv.display = trim(substring(1,40,request->alist[x].display)), cv
        .display_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->alist[x].display)))),
        cv.description = trim(substring(1,60,request->alist[x].description)), cv.definition = trim(
         substring(1,100,request->trlist[i].display)), cv.active_type_cd = active_code_value,
        cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task
         = reqinfo->updt_task,
        cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1)
       WHERE (cv.code_value=request->alist[x].code_value)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to update cs 16589 ",trim(request->alist[x].display))
       GO TO exit_script
      ENDIF
      UPDATE  FROM track_reference tr
       SET tr.active_ind = 1, tr.description = request->alist[x].description, tr.display = request->
        alist[x].display,
        tr.display_key = cnvtupper(cnvtalphanum(request->alist[x].display)), tr.ref_color = request->
        alist[x].color, tr.ref_icon = request->alist[x].icon,
        tr.updt_dt_tm = cnvtdatetime(curdate,curtime3), tr.updt_id = reqinfo->updt_id, tr.updt_task
         = reqinfo->updt_task,
        tr.updt_cnt = (tr.updt_cnt+ 1), tr.updt_applctx = reqinfo->updt_applctx
       WHERE (tr.tracking_group_cd=request->trlist[i].code_value)
        AND (tr.assoc_code_value=request->alist[x].code_value)
       WITH nocounter
      ;end update
    ENDFOR
   ELSEIF ((request->alist[x].action_flag=3))
    FOR (i = 1 TO group_cnt)
      UPDATE  FROM code_value cv
       SET cv.active_ind = 0, cv.active_type_cd = inactive_code_value, cv.inactive_dt_tm =
        cnvtdatetime(curdate,curtime3),
        cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task
         = reqinfo->updt_task,
        cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1)
       WHERE (cv.code_value=request->alist[x].code_value)
        AND cv.active_ind=1
       WITH nocounter
      ;end update
      UPDATE  FROM track_reference tr
       SET tr.active_ind = 0, tr.updt_dt_tm = cnvtdatetime(curdate,curtime3), tr.updt_id = reqinfo->
        updt_id,
        tr.updt_task = reqinfo->updt_task, tr.updt_cnt = (tr.updt_cnt+ 1), tr.updt_applctx = reqinfo
        ->updt_applctx
       WHERE (tr.tracking_group_cd=request->trlist[i].code_value)
        AND (tr.assoc_code_value=request->alist[x].code_value)
       WITH nocounter
      ;end update
      SET code_value_filter_id = 0.0
      SELECT INTO "nl:"
       FROM code_value_filter cvf
       WHERE cvf.code_set=16589
        AND cvf.filter_type_cd=filter_type_cd
        AND cvf.filter_ind=0
        AND cvf.parent_entity_name1="CODE_VALUE"
        AND (cvf.flex1_id=request->trlist[i].code_value)
       DETAIL
        code_value_filter_id = cvf.code_value_filter_id
       WITH nocounter
      ;end select
      IF (code_value_filter_id > 0)
       DELETE  FROM code_value_filter_r cvfr
        WHERE cvfr.code_value_filter_id=code_value_filter_id
         AND (cvfr.code_value_cd=request->alist[x].code_value)
        WITH nocounter
       ;end delete
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_FN_ACUITY","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
