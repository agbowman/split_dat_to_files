CREATE PROGRAM bbd_get_existing_proc_bagtypes:dba
 RECORD reply(
   1 qual[*]
     2 procedure_bag_type_id = f8
     2 procedure_cd = f8
     2 outcome_cd = f8
     2 bag_type_cd = f8
     2 bag_type_cd_disp = vc
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
 SELECT INTO "nl:"
  bdp.procedure_cd, bob.outcome_bag_type_id, bob.bag_type_cd,
  bob.updt_cnt
  FROM bbd_donation_procedure bdp,
   bbd_procedure_outcome bpo,
   bbd_outcome_bag_type bob
  PLAN (bdp
   WHERE (bdp.procedure_cd=request->procedure_cd)
    AND bdp.active_ind=1)
   JOIN (bpo
   WHERE bpo.procedure_id=bdp.procedure_id
    AND bpo.active_ind=1)
   JOIN (bob
   WHERE bob.procedure_outcome_id=bpo.procedure_outcome_id
    AND bob.active_ind=1)
  HEAD REPORT
   stat = alterlist(reply->qual,10), count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count != 1)
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].procedure_bag_type_id = bob.outcome_bag_type_id, reply->qual[count].
   procedure_cd = bdp.procedure_cd, reply->qual[count].outcome_cd = bpo.outcome_cd,
   reply->qual[count].bag_type_cd = bob.bag_type_cd, reply->qual[count].updt_cnt = bob.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->qual,count)
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
