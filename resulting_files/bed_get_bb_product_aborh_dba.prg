CREATE PROGRAM bed_get_bb_product_aborh:dba
 FREE SET reply
 RECORD reply(
   1 diff_list[*]
     2 new_ind = i2
     2 crossmatch_dispense_flag = i2
     2 auto_direct_flag = i2
     2 aborh_ind = i2
     2 prsn_list[*]
       3 prsn_group_type_code_value = f8
       3 prsn_group_type_disp = vc
       3 aborh_flag = i2
     2 dispense_curr_aborh_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET dcnt = 0
 SET dcnt = size(request->dlist,5)
 SET stat = alterlist(reply->diff_list,dcnt)
 FOR (x = 1 TO dcnt)
  SELECT INTO "nl:"
   FROM product_aborh pa,
    code_value cv
   PLAN (pa
    WHERE (pa.product_cd=request->dlist[x].plist[1].product_code_value)
     AND (pa.product_aborh_cd=request->group_type_code_value)
     AND pa.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=pa.product_aborh_cd
     AND cv.active_ind=1)
   DETAIL
    reply->diff_list[x].aborh_ind = pa.aborh_option_flag, reply->diff_list[x].
    crossmatch_dispense_flag = pa.no_gt_on_prsn_flag, reply->diff_list[x].auto_direct_flag = pa
    .no_gt_autodir_prsn_flag,
    reply->diff_list[x].dispense_curr_aborh_flag = pa.disp_no_curraborh_prsn_flag
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->diff_list[x].new_ind = 1
   SET reply->diff_list[x].aborh_ind = 1
  ELSE
   SELECT INTO "nl:"
    FROM product_patient_aborh ppa,
     code_value cv,
     code_value cv2
    PLAN (ppa
     WHERE (ppa.product_cd=request->dlist[x].plist[1].product_code_value)
      AND (ppa.prod_aborh_cd=request->group_type_code_value)
      AND ppa.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=ppa.prsn_aborh_cd
      AND cv.active_ind=1)
     JOIN (cv2
     WHERE cv2.code_value=ppa.prod_aborh_cd
      AND cv2.active_ind=1)
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(reply->diff_list[x].prsn_list,cnt), reply->diff_list[x].
     prsn_list[cnt].prsn_group_type_code_value = ppa.prsn_aborh_cd,
     reply->diff_list[x].prsn_list[cnt].prsn_group_type_disp = cv.display
     IF (ppa.warn_ind=0)
      reply->diff_list[x].prsn_list[cnt].aborh_flag = 1
     ELSEIF (ppa.warn_ind=1)
      reply->diff_list[x].prsn_list[cnt].aborh_flag = 2
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
