CREATE PROGRAM ce_ins_med_admin_ident_reltn:dba
 SUBROUTINE checkerrors(operation)
   DECLARE errormsg = c255 WITH noconstant("")
   DECLARE errorcode = i4 WITH noconstant(0)
   SET errorcode = error(errormsg,0)
   IF (errorcode != 0)
    SET reply->status_data.subeventstatus[1].operationname = substring(1,25,trim(operation))
    SET reply->status_data.subeventstatus[1].targetobjectname = cnvtstring(errorcode)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errormsg
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 RECORD reply(
   1 num_inserted = i4
   1 error_code = f8
   1 error_msg = vc
 )
 DECLARE request_size = i4 WITH constant(size(request->request_list,5))
 DECLARE current_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE cnt = i4 WITH noconstant(0)
 SET error_msg = fillstring(255," ")
 SET error_code = 0
 INSERT  FROM ce_med_admin_ident_reltn t,
   (dummyt d  WITH seq = value(request_size))
  SET t.ce_med_ident_reltn_id = request->request_list[d.seq].ce_med_admin_ident_rltn_id, t
   .prev_ce_med_ident_reltn_id = request->request_list[d.seq].prev_ce_med_admin_ident_rltn_id, t
   .event_id = request->request_list[d.seq].event_id,
   t.ce_med_admin_ident_id = request->request_list[d.seq].ce_med_admin_ident_id, t.valid_from_dt_tm
    = cnvtdatetimeutc(request->request_list[d.seq].valid_from_dt_tm), t.valid_until_dt_tm =
   cnvtdatetimeutc("31-DEC-2100 00:00:00"),
   t.updt_dt_tm = cnvtdatetimeutc(current_time), t.updt_task = reqinfo->updt_task, t.updt_id =
   reqinfo->updt_id,
   t.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (t)
  WITH counter
 ;end insert
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
