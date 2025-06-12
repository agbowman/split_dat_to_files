CREATE PROGRAM bb_ref_get_prod_pat_comp:dba
 RECORD reply(
   1 product_aborh[*]
     2 product_type_cd = f8
     2 product_aborh_cd = f8
     2 no_gt_on_prsn_flag = i2
     2 no_ad_on_prsn_flag = i2
     2 aborh_option_flag = i2
     2 patient_aborh[*]
       3 prsn_aborh_cd = f8
       3 warn_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET nproductaborhcnt = 0
 SET npatientaborhcnt = 0
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 SET stat = alterlist(reply->product_aborh,10)
 SELECT
  IF ((request->product_type_cd=0))
   PLAN (pa
    WHERE pa.active_ind=1)
    JOIN (ppa
    WHERE ppa.product_cd=outerjoin(pa.product_cd)
     AND ppa.prod_aborh_cd=outerjoin(pa.product_aborh_cd)
     AND ppa.active_ind=outerjoin(1))
  ELSE
   PLAN (pa
    WHERE (pa.product_cd=request->product_type_cd)
     AND pa.active_ind=1)
    JOIN (ppa
    WHERE ppa.product_cd=outerjoin(pa.product_cd)
     AND ppa.prod_aborh_cd=outerjoin(pa.product_aborh_cd)
     AND ppa.active_ind=outerjoin(1))
  ENDIF
  INTO "nl:"
  parent_record_combination = build(pa.product_cd,pa.product_aborh_cd)
  FROM product_aborh pa,
   product_patient_aborh ppa
  ORDER BY parent_record_combination
  HEAD parent_record_combination
   IF (nproductaborhcnt > 0)
    stat = alterlist(reply->product_aborh[nproductaborhcnt].patient_aborh,npatientaborhcnt)
   ENDIF
   nproductaborhcnt = (nproductaborhcnt+ 1)
   IF (mod(nproductaborhcnt,10)=1
    AND nproductaborhcnt != 1)
    stat = alterlist(reply->product_aborh,(nproductaborhcnt+ 9))
   ENDIF
   reply->product_aborh[nproductaborhcnt].product_type_cd = pa.product_cd, reply->product_aborh[
   nproductaborhcnt].product_aborh_cd = pa.product_aborh_cd, reply->product_aborh[nproductaborhcnt].
   no_gt_on_prsn_flag = pa.no_gt_on_prsn_flag,
   reply->product_aborh[nproductaborhcnt].no_ad_on_prsn_flag = pa.no_gt_autodir_prsn_flag, reply->
   product_aborh[nproductaborhcnt].aborh_option_flag = pa.aborh_option_flag, stat = alterlist(reply->
    product_aborh[nproductaborhcnt].patient_aborh,5),
   npatientaborhcnt = 0
  DETAIL
   npatientaborhcnt = (npatientaborhcnt+ 1)
   IF (mod(npatientaborhcnt,5)=1
    AND npatientaborhcnt != 1)
    stat = alterlist(reply->product_aborh[nproductaborhcnt].patient_aborh,(npatientaborhcnt+ 4))
   ENDIF
   reply->product_aborh[nproductaborhcnt].patient_aborh[npatientaborhcnt].prsn_aborh_cd = ppa
   .prsn_aborh_cd, reply->product_aborh[nproductaborhcnt].patient_aborh[npatientaborhcnt].warn_ind =
   ppa.warn_ind
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->product_aborh[nproductaborhcnt].patient_aborh,npatientaborhcnt)
 SET stat = alterlist(reply->product_aborh,nproductaborhcnt)
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (nproductaborhcnt > 0)
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
