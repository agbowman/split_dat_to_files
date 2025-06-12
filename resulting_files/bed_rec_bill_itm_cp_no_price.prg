CREATE PROGRAM bed_rec_bill_itm_cp_no_price
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->run_status_flag = 1
 SET pharmacy_cd = get_code_value(106,"PHARMACY")
 SET chg_point_cd = get_code_value(13019,"CHARGE POINT")
 SET alpha_level_cd = get_code_value(13020,"ALPHA")
 SET group_level_cd = get_code_value(13020,"GROUP")
 SET both_level_cd = get_code_value(13020,"BOTH")
 SET clear_point_cd = get_code_value(13029,"CLEAR")
 SELECT INTO "nl:"
  FROM bill_item bi,
   bill_item_modifier bim,
   (dummyt d  WITH seq = 1),
   price_sched_items psi
  PLAN (bi
   WHERE bi.active_ind=1
    AND bi.ext_owner_cd != pharmacy_cd)
   JOIN (bim
   WHERE bim.bill_item_id=bi.bill_item_id
    AND bim.bill_item_type_cd=chg_point_cd
    AND bim.active_ind=1
    AND ((bim.key4_id IN (group_level_cd, both_level_cd)) OR (bim.key4_id=alpha_level_cd
    AND bim.key2_id != clear_point_cd)) )
   JOIN (d)
   JOIN (psi
   WHERE psi.bill_item_id=bi.bill_item_id
    AND psi.active_ind=1
    AND psi.beg_effective_dt_tm < cnvtdatetime(curdate,000000)
    AND psi.end_effective_dt_tm > cnvtdatetime(curdate,235959))
  DETAIL
   reply->run_status_flag = 3
  WITH outerjoin = d, dontexist
 ;end select
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
