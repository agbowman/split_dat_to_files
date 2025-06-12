CREATE PROGRAM bbt_get_product_patient_comp:dba
 RECORD reply(
   1 no_gt_on_prsn_flag = i4
   1 no_ad_on_prsn_flag = i4
   1 disp_no_curraborh_prsn_flag = i4
   1 prod_sequence_nbr = i4
   1 prod_active_ind = i2
   1 person_aborh_data[10]
     2 prsn_aborh_cd = f8
     2 prsn_sequence_nbr = i4
     2 warn_ind = i2
     2 active_ind = i2
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
 SET count1 = 0
 SELECT INTO "nl:"
  p.no_gt_on_prsn_flag, p.no_gt_autodir_prsn_flag, p.disp_no_curraborh_prsn_flag,
  p.sequence_nbr
  FROM product_aborh p
  WHERE (p.product_cd=request->product_cd)
   AND (p.product_aborh_cd=request->product_aborh_cd)
  DETAIL
   reply->no_gt_on_prsn_flag = p.no_gt_on_prsn_flag, reply->no_ad_on_prsn_flag = p
   .no_gt_autodir_prsn_flag, reply->disp_no_curraborh_prsn_flag = p.disp_no_curraborh_prsn_flag,
   reply->prod_sequence_nbr = p.sequence_nbr, reply->prod_active_ind = p.active_ind
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO stop
 ENDIF
 SET count1 = 0
 SELECT INTO "nl:"
  per.*
  FROM product_patient_aborh per
  WHERE (per.product_cd=request->product_cd)
   AND (per.prod_aborh_cd=request->product_aborh_cd)
   AND per.active_ind=1
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->person_aborh_data,(count1+ 9))
   ENDIF
   reply->person_aborh_data[count1].prsn_aborh_cd = per.prsn_aborh_cd, reply->person_aborh_data[
   count1].prsn_sequence_nbr = per.sequence_nbr, reply->person_aborh_data[count1].warn_ind = per
   .warn_ind,
   reply->person_aborh_data[count1].active_ind = per.active_ind, reply->person_aborh_data[count1].
   updt_cnt = per.updt_cnt
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "P"
 ENDIF
 SET stat = alter(reply->person_aborh_data,count1)
#stop
END GO
