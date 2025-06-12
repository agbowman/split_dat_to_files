CREATE PROGRAM dm2_get_purge_token_history:dba
 DECLARE dphc_active_flag = vc WITH protect, constant("ACTIVE_FLAG")
 DECLARE dphc_purge_flag = vc WITH protect, constant("PURGE_FLAG")
 DECLARE dphc_max_rows = vc WITH protect, constant("MAX_ROWS")
 DECLARE dphc_jobname = vc WITH protect, constant("JOBNAME")
 DECLARE dphc_new_token = vc WITH protect, constant("NEW TOKEN")
 DECLARE dphc_del_token = vc WITH protect, constant("DEL TOKEN")
 DECLARE dphc_token_change = vc WITH protect, constant("TOKEN")
 IF ((validate(request->job_id,- (1))=- (1)))
  RECORD request(
    1 job_id = f8
  )
 ENDIF
 IF ((validate(reply->qual_cnt,- (1))=- (1)))
  RECORD reply(
    1 qual_cnt = i4
    1 qual[*]
      2 change_type = vc
      2 property_name = vc
      2 old_value = vc
      2 new_value = vc
      2 username = vc
      2 updt_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE dgaxt_errmsg = vc WITH protect, noconstant("")
 DECLARE dgaxt_max_job_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  has_name = negate(nullind(p.username))
  FROM dm_purge_history dph,
   prsnl p
  PLAN (dph
   WHERE (dph.job_id=request->job_id))
   JOIN (p
   WHERE p.person_id=outerjoin(dph.updt_id))
  DETAIL
   reply->qual_cnt = (reply->qual_cnt+ 1), stat = alterlist(reply->qual,reply->qual_cnt)
   IF (dph.token_str=dphc_jobname)
    reply->qual[reply->qual_cnt].change_type = dphc_jobname
   ELSE
    reply->qual[reply->qual_cnt].change_type = dph.change_type, reply->qual[reply->qual_cnt].
    property_name = dph.token_str
   ENDIF
   IF (dph.old_token_string_value > " ")
    reply->qual[reply->qual_cnt].old_value = dph.old_token_string_value
   ELSE
    reply->qual[reply->qual_cnt].old_value = cnvtstring(dph.old_value,12,2)
   ENDIF
   IF (dph.new_token_string_value > " ")
    reply->qual[reply->qual_cnt].new_value = dph.new_token_string_value
   ELSE
    reply->qual[reply->qual_cnt].new_value = cnvtstring(dph.new_value,12,2)
   ENDIF
   IF (has_name=1)
    reply->qual[reply->qual_cnt].username = p.username
   ELSE
    reply->qual[reply->qual_cnt].username = "Unavailable"
   ENDIF
   reply->qual[reply->qual_cnt].updt_dt_tm = dph.updt_dt_tm
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
