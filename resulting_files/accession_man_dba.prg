CREATE PROGRAM accession_man:dba
 RECORD reply(
   1 accession = c20
   1 accession_id = f8
   1 accession_status = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD acc(
   1 accession = c20
   1 accession_id = f8
   1 assignment_ind = i2
 )
 SET acc_ok = 0
 SET unk_error = 5
 SET dup_accession = 10
 SET upd_accession = 15
 SET unk_assign_status = 20
 SET acc_sequence = 25
 SET ins_accession = 30
 SET accession_yes = 35
 SET accession_preassign = 40
 SET accession_no = 45
 SET dup_to_accession = 50
 SET inv_from_accession = 55
 SET inv_accession_seq = 60
 SET inv_quantity = 65
 SET julian_sequence_length = 6
 SET prefix_sequence_length = 7
 SET reply->status_data.status = "Z"
 SET reqinfo->commit_ind = 0
 SET reply->accession_status = unk_error
#accession_man_begin
 SELECT INTO "nl:"
  a.accession_id, a.accession, a.accession_nbr_check,
  a.assignment_ind
  FROM accession a
  WHERE (a.accession_nbr_check=request->accession_nbr_check)
  DETAIL
   acc->accession = a.accession, acc->accession_id = a.accession_id, acc->assignment_ind = a
   .assignment_ind
  WITH nocounter
 ;end select
 IF ((request->validate_flag=1))
  IF ((acc->accession_id > 0))
   IF ((acc->assignment_ind=1))
    SET reply->accession_status = accession_preassign
   ELSE
    SELECT INTO "nl:"
     aor.accession_id, aor.accession
     FROM accession_order_r aor
     WHERE (aor.accession_id=acc->accession_id)
     WITH nocounter, maxqual(a,1)
    ;end select
    IF (curqual > 0)
     SET reply->accession_status = accession_yes_order
    ELSE
     SET reply->accession_status = accession_yes
    ENDIF
   ENDIF
  ELSE
   SET reply->accession_status = accession_no
  ENDIF
  GO TO accession_man_exit
 ENDIF
 IF ((acc->accession_id > 0))
  CASE (acc->assignment_ind)
   OF 0:
    SET reply->accession_status = dup_accession
   OF 1:
    SET reply->accession_status = upd_accession
    SET count = 0
    SELECT INTO "nl:"
     a.accession_id
     FROM accession a
     WHERE (a.accession_id=acc->accession_id)
     DETAIL
      count = (count+ 1)
     WITH nocounter, forupdate(a)
    ;end select
    IF (count=1)
     UPDATE  FROM accession a
      SET a.assignment_ind = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->
       updt_id,
       a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = (a
       .updt_cnt+ 1)
      WHERE (a.accession_id=acc->accession_id)
     ;end update
     IF (curqual=1)
      SET reply->accession_status = acc_ok
     ENDIF
    ENDIF
   ELSE
    SET reply->accession_status = unk_assign_status
  ENDCASE
 ELSE
  SET acc->accession = request->accession
  SELECT INTO "nl:"
   nextsequence = seq(accession_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    acc->accession_id = cnvtint(nextsequence)
   WITH format, counter
  ;end select
  IF ((acc->accession_id > 0))
   INSERT  FROM accession a
    SET a.accession_id = acc->accession_id, a.accession = acc->accession, a.accession_nbr_check =
     trim(request->accession_nbr_check),
     a.site_prefix_cd = request->site_prefix_cd, a.accession_year = request->accession_year, a
     .accession_day = request->accession_day,
     a.accession_format_cd = request->accession_format_cd, a.alpha_prefix = request->alpha_prefix, a
     .accession_sequence_nbr = request->accession_sequence_nbr,
     a.accession_class_cd = 0, a.accession_pool_id = request->accession_pool_id, a.preactive_ind =
     request->preactive_ind,
     a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id, a.updt_task =
     reqinfo->updt_task,
     a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=1)
    SET reply->accession_status = acc_ok
   ELSE
    SET reply->accession_status = ins_accession
   ENDIF
  ELSE
   SET reply->accession_status = acc_sequence
  ENDIF
 ENDIF
#accession_man_exit
 SET reply->accession = acc->accession
 SET reply->accession_id = acc->accession_id
 IF ((request->validate_flag=1))
  SET reply->status_data.status = "S"
 ELSE
  IF ((reply->accession_status=acc_ok))
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ELSE
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
  ENDIF
 ENDIF
END GO
