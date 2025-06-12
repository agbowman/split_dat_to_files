CREATE PROGRAM dcp_get_wv_event_cds
 RECORD reply(
   1 qual[*]
     2 task_assay_cd = f8
     2 event_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE ec_counter = i4 WITH noconstant(0)
 DECLARE dta_cnt = i2 WITH noconstant(size(request->qual,5))
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE expand_index = i4 WITH protect, noconstant(0)
 IF (((dta_cnt=0) OR (dta_cnt=null)) )
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  dta.task_assay_cd, dta.event_cd
  FROM discrete_task_assay dta
  PLAN (dta
   WHERE expand(expand_index,1,dta_cnt,dta.task_assay_cd,request->qual[expand_index].task_assay_cd)
    AND dta.active_ind=1)
  ORDER BY dta.task_assay_cd
  HEAD REPORT
   ec_counter = 1, stat = alterlist(reply->qual,dta_cnt)
  HEAD dta.task_assay_cd
   reply->qual[ec_counter].task_assay_cd = dta.task_assay_cd, reply->qual[ec_counter].event_cd = dta
   .event_cd, ec_counter = (ec_counter+ 1)
 ;end select
#exit_script
 IF (ec_counter > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
