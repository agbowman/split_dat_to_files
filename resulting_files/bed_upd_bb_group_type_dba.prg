CREATE PROGRAM bed_upd_bb_group_type:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 dup_barcode_ind = i2
    1 dup_isbt_ind = i2
  )
 ENDIF
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 RECORD temprequest(
   1 qual[*]
     2 aborh_code_value = f8
     2 display = vc
     2 description = vc
     2 bar_code = vc
     2 meaning = vc
     2 standard_code_value = f8
     2 active_ind = i2
     2 isbt = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET cnt = size(request->qual,5)
 SET stat = alterlist(temprequest->qual,cnt)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = cnt)
  PLAN (d)
  ORDER BY request->qual[d.seq].active_ind
  HEAD REPORT
   cntr = 0
  DETAIL
   cntr = (cntr+ 1), temprequest->qual[cntr].aborh_code_value = request->qual[d.seq].aborh_code_value,
   temprequest->qual[cntr].display = request->qual[d.seq].display,
   temprequest->qual[cntr].description = request->qual[d.seq].description, temprequest->qual[cntr].
   bar_code = request->qual[d.seq].bar_code, temprequest->qual[cntr].meaning = request->qual[d.seq].
   meaning,
   temprequest->qual[cntr].standard_code_value = request->qual[d.seq].standard_code_value,
   temprequest->qual[cntr].active_ind = request->qual[d.seq].active_ind, temprequest->qual[cntr].isbt
    = request->qual[d.seq].isbt
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   IF ((temprequest->qual[x].bar_code != ""))
    SELECT INTO "nl:"
     FROM code_value_extension cve,
      code_value cv
     PLAN (cve
      WHERE (cve.field_value=temprequest->qual[x].bar_code)
       AND (cve.code_value != temprequest->qual[x].aborh_code_value)
       AND cve.code_set=1640
       AND cve.field_name="Barcode"
       AND (temprequest->qual[x].active_ind=1))
      JOIN (cv
      WHERE cv.code_value=cve.code_value
       AND cv.active_ind=1)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET reply->dup_barcode_ind = 1
     SET failed = "N"
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((temprequest->qual[x].isbt != ""))
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE (cv.cdf_meaning=temprequest->qual[x].isbt)
      AND (cv.code_value != temprequest->qual[x].aborh_code_value)
      AND cv.active_ind=1
      AND (temprequest->qual[x].active_ind=1)
      AND cv.code_set=1640
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET reply->dup_isbt_ind = 1
     SET failed = "N"
     GO TO exit_script
    ENDIF
   ENDIF
   SET request_cv->cd_value_list[1].action_flag = 2
   SET request_cv->cd_value_list[1].code_value = temprequest->qual[x].aborh_code_value
   SET request_cv->cd_value_list[1].code_set = 1640
   SET request_cv->cd_value_list[1].display = temprequest->qual[x].display
   SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(temprequest->qual[x].display
     ))
   SET request_cv->cd_value_list[1].description = temprequest->qual[x].description
   SET request_cv->cd_value_list[1].definition = temprequest->qual[x].description
   SET request_cv->cd_value_list[1].active_ind = temprequest->qual[x].active_ind
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status != "S"))
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   UPDATE  FROM code_value cv
    SET cv.cdf_meaning = temprequest->qual[x].isbt
    PLAN (cv
     WHERE (cv.code_value=temprequest->qual[x].aborh_code_value))
    WITH nocounter
   ;end update
   SET ierrcode = 0
   UPDATE  FROM code_value_extension cve
    SET cve.field_value = temprequest->qual[x].bar_code, cve.updt_dt_tm = cnvtdatetime(curdate,
      curtime), cve.updt_id = reqinfo->updt_id,
     cve.updt_cnt = (cve.updt_cnt+ 1), cve.updt_task = reqinfo->updt_task, cve.updt_applctx = reqinfo
     ->updt_applctx
    PLAN (cve
     WHERE cve.code_set=1640
      AND (cve.code_value=temprequest->qual[x].aborh_code_value)
      AND cve.field_name="Barcode")
    WITH nocounter
   ;end update
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
