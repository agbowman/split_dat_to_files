CREATE PROGRAM bed_get_bbt_tc_assay_dtls:dba
 FREE SET reply
 RECORD reply(
   1 assays[*]
     2 code_value = f8
     2 pre_hours = i4
     2 post_hours = i4
   1 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 DECLARE tc_parse = vc
 IF ((request->owner_area_code_value=0))
  SET tc_parse = concat(tc_parse," tc.owner_cd IN (0,null) and ")
 ELSE
  SET tc_parse = concat(tc_parse," tc.owner_cd = request->owner_area_code_value and ")
 ENDIF
 IF ((request->inventory_area_code_value=0))
  SET tc_parse = concat(tc_parse," tc.inv_area_cd IN (0, null) and ")
 ELSE
  SET tc_parse = concat(tc_parse," tc.inv_area_cd = request->inventory_area_code_value and ")
 ENDIF
 SET tc_parse = concat(tc_parse," tc.product_cd = request->product_code_value")
 SET reply->active_ind = 1
 SELECT INTO "nl:"
  FROM transfusion_committee tc,
   trans_commit_assay tca
  PLAN (tc
   WHERE parser(tc_parse))
   JOIN (tca
   WHERE tca.trans_commit_id=outerjoin(tc.trans_commit_id)
    AND tca.active_ind=outerjoin(1))
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->assays,100)
  DETAIL
   IF (tca.trans_commit_assay_id > 0)
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->assays,(tot_cnt+ 100)), cnt = 1
    ENDIF
    reply->assays[tot_cnt].code_value = tca.task_assay_cd, reply->assays[tot_cnt].post_hours = tca
    .post_hours, reply->assays[tot_cnt].pre_hours = tca.pre_hours
   ENDIF
   reply->active_ind = tc.active_ind
  FOOT REPORT
   stat = alterlist(reply->assays,tot_cnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
