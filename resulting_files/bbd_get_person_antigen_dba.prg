CREATE PROGRAM bbd_get_person_antigen:dba
 RECORD reply(
   1 qual[*]
     2 person_antigen_id = f8
     2 encntr_id = f8
     2 antigen_cd = f8
     2 antigen_cd_disp = vc
     2 result_id = f8
     2 bb_result_id = f8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT DISTINCT INTO "nl:"
  da.antigen_cd
  FROM encounter e,
   donor_antigen da
  PLAN (e
   WHERE (e.person_id=request->person_id))
   JOIN (da
   WHERE da.encntr_id=e.encntr_id
    AND da.active_ind=1)
  ORDER BY da.antigen_cd, 0
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].person_antigen_id = da
   .donor_antigen_id,
   reply->qual[count].encntr_id = da.encntr_id, reply->qual[count].antigen_cd = da.antigen_cd, reply
   ->qual[count].result_id = da.result_id,
   reply->qual[count].bb_result_id = da.bb_result_nbr, reply->qual[count].updt_cnt = da.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
