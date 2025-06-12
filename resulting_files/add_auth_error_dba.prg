CREATE PROGRAM add_auth_error:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET nbr_of_details = cnvtint(value(size(request->detail_qual,5)))
 SET auth_error_id = 0.0
 SET x = 0
 SELECT INTO "nl:"
  seq_nbr = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   auth_error_id = seq_nbr
  WITH format, counter
 ;end select
 IF (curqual=0)
  GO TO seq_failed
 ENDIF
 INSERT  FROM auth_error ae
  SET ae.auth_error_id = auth_error_id, ae.application_number = request->application_number, ae
   .task_number = request->task_number,
   ae.person_id = request->person_id, ae.error_dt_tm = cnvtdatetime(curdate,curtime3), ae.updt_dt_tm
    = cnvtdatetime(curdate,curtime3),
   ae.updt_id = reqinfo->updt_id, ae.updt_task = reqinfo->updt_task, ae.updt_applctx = reqinfo->
   updt_applctx,
   ae.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual != 1)
  GO TO ae_ins_failed
 ENDIF
 IF (nbr_of_details > 0)
  INSERT  FROM auth_error_detail aed,
    (dummyt d  WITH seq = value(nbr_of_details))
   SET aed.auth_error_id = auth_error_id, aed.sequence = d.seq, aed.display_label = request->
    detail_qual[d.seq].display_label,
    aed.display_value = request->detail_qual[d.seq].display_value, aed.updt_dt_tm = cnvtdatetime(
     curdate,curtime3), aed.updt_id = reqinfo->updt_id,
    aed.updt_task = reqinfo->updt_task, aed.updt_applctx = reqinfo->updt_applctx, aed.updt_cnt = 0
   PLAN (d)
    JOIN (aed
    WHERE aed.auth_error_id=auth_error_id
     AND aed.sequence=d.seq)
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != nbr_of_details)
   GO TO aed_ins_failed
  ENDIF
 ENDIF
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "reference_seq"
 SET failed = "T"
 GO TO exit_script
#ae_ins_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AUTH_ERROR"
 SET failed = "T"
 GO TO exit_script
#aed_ins_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AUTH_ERROR_DETAIL"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
