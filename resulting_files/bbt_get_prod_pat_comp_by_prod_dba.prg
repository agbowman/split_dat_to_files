CREATE PROGRAM bbt_get_prod_pat_comp_by_prod:dba
 RECORD reply(
   1 qual[*]
     2 product_cd = f8
     2 product_aborh_cd = f8
     2 abo_only_cd = f8
     2 rh_only_cd = f8
     2 no_gt_on_prsn_flag = i4
     2 no_ad_on_prsn_flag = i4
     2 prod_sequence_nbr = i4
     2 prod_active_ind = i2
     2 aborh_option_flag = i2
     2 prsn_cnt = i4
     2 person_aborh_data[*]
       3 prsn_aborh_cd = f8
       3 prsn_abo_only_cd = f8
       3 prsn_rh_only_cd = f8
       3 prsn_sequence_nbr = i4
       3 warn_ind = i2
       3 active_ind = i2
       3 updt_cnt = i4
     2 disp_no_curraborh_prsn_flag = i4
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
  p.*, per.*
  FROM product_aborh p,
   product_patient_aborh per
  PLAN (p
   WHERE (p.product_cd=request->product_cd)
    AND p.active_ind=1)
   JOIN (per
   WHERE per.product_cd=p.product_cd
    AND per.prod_aborh_cd=p.product_aborh_cd
    AND per.active_ind=1)
  HEAD REPORT
   count1 = 0, count2 = 0, newcount1 = "N",
   prev_prsn_aborh_cd = 0
  HEAD p.product_cd
   IF (newcount1="N")
    count1 = (count1+ 1), count2 = 0, stat = alterlist(reply->qual,count1),
    stat = alterlist(reply->qual[count1].person_aborh_data,count2), reply->qual[count1].product_cd =
    p.product_cd, reply->qual[count1].product_aborh_cd = p.product_aborh_cd,
    reply->qual[count1].no_gt_on_prsn_flag = p.no_gt_on_prsn_flag, reply->qual[count1].
    no_ad_on_prsn_flag = p.no_gt_autodir_prsn_flag, reply->qual[count1].prod_sequence_nbr = p
    .sequence_nbr,
    reply->qual[count1].prod_active_ind = p.active_ind, reply->qual[count1].aborh_option_flag = p
    .aborh_option_flag, reply->qual[count1].prsn_cnt = 0,
    reply->qual[count1].disp_no_curraborh_prsn_flag = p.disp_no_curraborh_prsn_flag, newcount1 = "Y"
   ENDIF
  HEAD p.product_aborh_cd
   IF (newcount1="N")
    count1 = (count1+ 1), count2 = 0, stat = alterlist(reply->qual,count1),
    stat = alterlist(reply->qual[count1].person_aborh_data,count2), reply->qual[count1].product_cd =
    p.product_cd, reply->qual[count1].product_aborh_cd = p.product_aborh_cd,
    reply->qual[count1].no_gt_on_prsn_flag = p.no_gt_on_prsn_flag, reply->qual[count1].
    no_ad_on_prsn_flag = p.no_gt_autodir_prsn_flag, reply->qual[count1].prod_sequence_nbr = p
    .sequence_nbr,
    reply->qual[count1].prod_active_ind = p.active_ind, reply->qual[count1].aborh_option_flag = p
    .aborh_option_flag, reply->qual[count1].disp_no_curraborh_prsn_flag = p
    .disp_no_curraborh_prsn_flag,
    reply->qual[count1].prsn_cnt = 0, newcount1 = "Y"
   ENDIF
  DETAIL
   newcount1 = "N", count2 = (count2+ 1), stat = alterlist(reply->qual[count1].person_aborh_data,
    count2),
   reply->qual[count1].prsn_cnt = (reply->qual[count1].prsn_cnt+ 1), reply->qual[count1].
   person_aborh_data[count2].prsn_aborh_cd = per.prsn_aborh_cd, reply->qual[count1].
   person_aborh_data[count2].prsn_sequence_nbr = per.sequence_nbr,
   reply->qual[count1].person_aborh_data[count2].warn_ind = per.warn_ind, reply->qual[count1].
   person_aborh_data[count2].active_ind = per.active_ind, reply->qual[count1].person_aborh_data[
   count2].updt_cnt = per.updt_cnt
  FOOT  p.product_cd
   IF (newcount1="Y")
    newcount1 = "N"
   ENDIF
  FOOT  p.product_aborh_cd
   IF (newcount1="Y")
    newcount1 = "N"
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#stop
END GO
