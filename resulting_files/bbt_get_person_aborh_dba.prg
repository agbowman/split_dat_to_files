CREATE PROGRAM bbt_get_person_aborh:dba
 RECORD reply(
   1 person_id = f8
   1 abo_cd = f8
   1 abo_disp = c15
   1 rh_cd = f8
   1 rh_disp = c15
   1 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  p.*
  FROM person_aborh p
  WHERE (p.person_id=request->person_id)
   AND p.active_ind=1
  DETAIL
   reply->person_id = p.person_id, reply->abo_cd = p.abo_cd, reply->rh_cd = p.rh_cd,
   reply->updt_cnt = p.updt_cnt
  WITH counter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
