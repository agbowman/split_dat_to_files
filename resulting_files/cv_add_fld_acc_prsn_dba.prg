CREATE PROGRAM cv_add_fld_acc_prsn:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 cvnet_error
      2 cnt = i4
      2 data[*]
        3 code = i4
        3 severity_level = i4
        3 supp_err_txt = c32
        3 def_msg = vc
        3 row_data
          4 lvl_1_idx = i4
          4 lvl_2_idx = i4
          4 lvl_3_idx = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET cvnet_lock = 100
 SET cvnet_no_seq = 101
 SET cvnet_updt_cnt = 102
 SET cvnet_insuf_data = 103
 SET cvnet_update = 104
 SET cvnet_insert = 105
 SET cvnet_delete = 106
 SET cvnet_select = 107
 SET cvnet_auth = 108
 SET cvnet_inval_data = 109
 SET cvnet_lock_msg = "Failed to lock all requested rows"
 SET cvnet_no_seq_msg = "Failed to get next sequence number"
 SET cvnet_updt_cnt_msg = "Failed to match update count"
 SET cvnet_insuf_data_msg = "Request did not supply sufficient data"
 SET cvnet_update_msg = "Failed on update request"
 SET cvnet_insert_msg = "Failed on insert request"
 SET cvnet_delete_msg = "Failed on delete request"
 SET cvnet_select_msg = "Failed on select request"
 SET cvnet_auth_msg = "Failed on authorization of request"
 SET cvnet_inval_data_msg = "Request contained some invalid data"
 SET cvnet_success = 0
 SET cvnet_success_info = 1
 SET cvnet_success_warn = 2
 SET cvnet_deadlock = 3
 SET cvnet_script_fail = 4
 SET cvnet_sys_fail = 5
 SUBROUTINE cvnet_add_error(cvnet_errcode,severity_level,supp_err_txt,def_msg,idx1,idx2,idx3)
   SET reply->cvnet_error.cnt = (reply->cvnet_error.cnt+ 1)
   SET errcnt = reply->cvnet_error.cnt
   SET stat = alterlist(reply->cvnet_error.data,errcnt)
   SET reply->cvnet_error.data[errcnt].code = cvnet_errcode
   SET reply->cvnet_error.data[errcnt].severity_level = severity_level
   SET reply->cvnet_error.data[errcnt].supp_err_txt = supp_err_txt
   SET reply->cvnet_error.data[errcnt].def_msg = def_msg
   SET reply->cvnet_error.data[errcnt].row_data.lvl_1_idx = idx1
   SET reply->cvnet_error.data[errcnt].row_data.lvl_2_idx = idx2
   SET reply->cvnet_error.data[errcnt].row_data.lvl_3_idx = idx3
 END ;Subroutine
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET updt_cnt = 0
 SET arr_size = 0
 SELECT INTO "nl:"
  p.last_name, p.first_name, p.middle_init,
  p.birth_dt, p.ssn, p.gender,
  p.person_id, p.encntr_id
  FROM cv_acc_person p,
   (dummyt d  WITH seq = value(size(request->add_person_rec,5)))
  PLAN (d)
   JOIN (p
   WHERE (p.last_name=request->add_person_rec[d.seq].last_name)
    AND (p.first_name=request->add_person_rec[d.seq].first_name)
    AND (p.middle_init=request->add_person_rec[d.seq].middle_init)
    AND p.birth_dt=cnvtdatetime(request->add_person_rec[d.seq].birth_dt)
    AND (p.ssn=request->add_person_rec[d.seq].ssn)
    AND (p.gender=request->add_person_rec[d.seq].gender)
    AND (p.person_id=request->add_person_rec[d.seq].person_id)
    AND (p.encntr_id=request->add_person_rec[d.seq].encntr_id)
    AND p.active_ind=1)
  WITH nocounter
 ;end select
 IF (curqual >= 1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cap.person_id, cap.encntr_id
  FROM cv_acc_person cap,
   (dummyt x  WITH seq = value(size(request->add_person_rec,5)))
  PLAN (x
   WHERE x.seq > 0)
   JOIN (cap
   WHERE (cap.person_id=request->add_person_rec[x.seq].person_id)
    AND (cap.encntr_id=request->add_person_rec[x.seq].encntr_id))
 ;end select
 IF (curqual >= 1)
  SELECT INTO "nl:"
   c.person_id
   FROM cv_acc_person c,
    (dummyt d  WITH seq = value(size(request->add_person_rec,5)))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (c
    WHERE (c.person_id=request->add_person_rec[d.seq].person_id)
     AND c.active_ind=1)
  ;end select
  IF (curqual >= 1)
   UPDATE  FROM cv_acc_person p,
     (dummyt z  WITH seq = value(size(request->add_person_rec,5)))
    SET p.active_ind = 0
    PLAN (z)
     JOIN (p
     WHERE (p.person_id=request->add_person_rec[z.seq].person_id))
    WITH nocounter
   ;end update
  ENDIF
  UPDATE  FROM cv_acc_person cv,
    (dummyt y  WITH seq = value(size(request->add_person_rec,5)))
   SET y.seq = 1, cv.last_name = cnvtupper(request->add_person_rec[y.seq].last_name), cv.first_name
     = cnvtupper(request->add_person_rec[y.seq].first_name),
    cv.middle_init = cnvtupper(request->add_person_rec[y.seq].middle_init), cv.gender = request->
    add_person_rec[y.seq].gender, cv.birth_dt = cnvtdatetime(request->add_person_rec[y.seq].birth_dt),
    cv.ssn = request->add_person_rec[y.seq].ssn, cv.person_id = request->add_person_rec[y.seq].
    person_id, cv.encntr_id = request->add_person_rec[y.seq].encntr_id,
    cv.active_ind = 1, cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_task = reqinfo->
    updt_task,
    cv.updt_app = reqinfo->updt_app, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv
    .updt_cnt+ 1),
    cv.updt_id = reqinfo->updt_id
   PLAN (y)
    JOIN (cv
    WHERE (cv.person_id=request->add_person_rec[y.seq].person_id)
     AND (cv.encntr_id=request->add_person_rec[y.seq].encntr_id))
   WITH nocounter
  ;end update
 ELSE
  SELECT INTO "nl:"
   a.person_id
   FROM cv_acc_person a,
    (dummyt t  WITH seq = value(size(request->add_person_rec,5)))
   PLAN (t
    WHERE t.seq > 0)
    JOIN (a
    WHERE (a.person_id=request->add_person_rec[t.seq].person_id)
     AND a.active_ind=1)
   WITH nocounter
  ;end select
  IF (curqual >= 1)
   UPDATE  FROM cv_acc_person p,
     (dummyt z  WITH seq = value(size(request->add_person_rec,5)))
    SET p.active_ind = 0, p.updt_cnt = (p.updt_cnt+ 1)
    PLAN (z)
     JOIN (p
     WHERE (p.person_id=request->add_person_rec[z.seq].person_id))
    WITH nocounter
   ;end update
  ENDIF
  INSERT  FROM cv_acc_person ap,
    (dummyt t  WITH seq = value(size(request->add_person_rec,5)))
   SET t.seq = 1, ap.last_name = cnvtalphanum(cnvtupper(request->add_person_rec[t.seq].last_name)),
    ap.first_name = cnvtalphanum(cnvtupper(request->add_person_rec[t.seq].first_name)),
    ap.middle_init = request->add_person_rec[t.seq].middle_init, ap.birth_dt = cnvtdatetime(request->
     add_person_rec[t.seq].birth_dt), ap.gender = request->add_person_rec[t.seq].gender,
    ap.ssn = request->add_person_rec[t.seq].ssn, ap.person_id = request->add_person_rec[t.seq].
    person_id, ap.encntr_id = request->add_person_rec[t.seq].encntr_id,
    ap.active_ind = 1, ap.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ap.active_status_cd
     = reqdata->active_status_cd,
    ap.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ap.end_effective_dt_tm = cnvtdatetime(
     "31-Dec-2100 23:59:59.59"), ap.data_status_cd = reqdata->data_status_cd,
    ap.data_status_prsnl_id = reqinfo->updt_id, ap.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
    ap.updt_dt_tm = cnvtdatetime("curdate, curtime3"),
    ap.updt_task = reqinfo->updt_task, ap.updt_app = reqinfo->updt_app, ap.updt_applctx = reqinfo->
    updt_applctx,
    ap.updt_cnt = 0, ap.updt_id = reqinfo->updt_id
   PLAN (t)
    JOIN (ap)
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual=0)
  SET failed = "T"
  CALL cvnet_add_error(cvnet_insert,cvnet_script_fail,"Inserting dataset",cvnet_insert_msg,0,
   0,0)
  GO TO person_insert_failed
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
#person_insert_failed
 IF (failed="T")
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_ACC_Person"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CV_add_fld_acc_prsn"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ENDIF
 GO TO end_program
#end_program
END GO
