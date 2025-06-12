CREATE PROGRAM bb_ref_get_code_set:dba
 RECORD reply(
   1 code_set[*]
     2 code_value = f8
     2 cdf_meaning = c12
     2 display = c40
     2 description = vc
     2 collation_seq = i4
     2 updt_cnt = i4
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ncnt = i2
 SET ncnt = 0
 SET serrormsg = fillstring(255," ")
 SET error_check = error(serrormsg,1)
 IF ((request->active_flag=2))
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE (c.code_set=request->code_set)
   DETAIL
    ncnt = (ncnt+ 1), stat = alterlist(reply->code_set,ncnt), reply->code_set[ncnt].code_value = c
    .code_value,
    reply->code_set[ncnt].cdf_meaning = c.cdf_meaning, reply->code_set[ncnt].display = c.display,
    reply->code_set[ncnt].description = c.description,
    reply->code_set[ncnt].collation_seq = c.collation_seq, reply->code_set[ncnt].updt_cnt = c
    .updt_cnt, reply->code_set[ncnt].active_ind = c.active_ind
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE (c.code_set=request->code_set)
    AND (c.active_ind=request->active_flag)
   DETAIL
    ncnt = (ncnt+ 1), stat = alterlist(reply->code_set,ncnt), reply->code_set[ncnt].code_value = c
    .code_value,
    reply->code_set[ncnt].cdf_meaning = c.cdf_meaning, reply->code_set[ncnt].display = c.display,
    reply->code_set[ncnt].description = c.description,
    reply->code_set[ncnt].collation_seq = c.collation_seq, reply->code_set[ncnt].updt_cnt = c
    .updt_cnt, reply->code_set[ncnt].active_ind = c.active_ind
   WITH nocounter
  ;end select
 ENDIF
 SET error_check = error(serrormsg,0)
 IF (error_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
#exit_script
END GO
