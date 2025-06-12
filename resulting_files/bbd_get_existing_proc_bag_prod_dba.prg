CREATE PROGRAM bbd_get_existing_proc_bag_prod:dba
 RECORD reply(
   1 qual[*]
     2 proc_bag_product_id = f8
     2 procedure_cd = f8
     2 bag_type_cd = f8
     2 product_cd = f8
     2 product_cd_disp = vc
     2 default_expire_days = i4
     2 default_expire_hours = i4
     2 updt_cnt = i4
     2 max_expire_days = i4
     2 max_expire_hours = i4
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
 SELECT INTO "nl:"
  bbp.bag_type_product_id, bdp.procedure_cd, bob.bag_type_cd,
  bbp.product_cd, pi.max_days_expire, pi.max_hrs_expire,
  bbp.updt_cnt
  FROM bbd_donation_procedure bdp,
   bbd_procedure_outcome bpo,
   bbd_outcome_bag_type bob,
   bbd_bag_type_product bbp,
   product_index pi
  PLAN (bdp
   WHERE (bdp.procedure_cd=request->procedure_cd)
    AND bdp.active_ind=1)
   JOIN (bpo
   WHERE bpo.procedure_id=bdp.procedure_id
    AND bpo.active_ind=1)
   JOIN (bob
   WHERE bob.procedure_outcome_id=bpo.procedure_outcome_id
    AND (bob.bag_type_cd=request->bag_type_cd)
    AND bob.active_ind=1)
   JOIN (bbp
   WHERE bbp.outcome_bag_type_id=bob.outcome_bag_type_id
    AND bbp.active_ind=1)
   JOIN (pi
   WHERE pi.product_cd=bbp.product_cd)
  HEAD REPORT
   stat = alterlist(reply->qual,10), count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count != 1)
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].proc_bag_product_id = bbp.bag_type_product_id, reply->qual[count].procedure_cd
    = bdp.procedure_cd, reply->qual[count].bag_type_cd = bob.bag_type_cd,
   reply->qual[count].product_cd = bbp.product_cd, reply->qual[count].default_expire_days = pi
   .max_days_expire, reply->qual[count].default_expire_hours = pi.max_hrs_expire,
   reply->qual[count].updt_cnt = bbp.updt_cnt, reply->qual[count].max_expire_days = pi
   .max_days_expire, reply->qual[count].max_expire_hours = pi.max_hrs_expire
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
