CREATE PROGRAM bed_rec_bill_itm_cp_no_cdm
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
 SET chg_point_cd = get_code_value(13019,"CHARGE POINT")
 SET alpha_level_cd = get_code_value(13020,"ALPHA")
 SET group_level_cd = get_code_value(13020,"GROUP")
 SET both_level_cd = get_code_value(13020,"BOTH")
 SET clear_point_cd = get_code_value(13029,"CLEAR")
 SELECT INTO "nl:"
  FROM bill_item_modifier bim1,
   bill_item bi,
   (dummyt d  WITH seq = 1),
   bill_item_modifier bim2,
   code_value cv
  PLAN (bim1
   WHERE bim1.bill_item_type_cd=chg_point_cd
    AND bim1.active_ind=1
    AND ((bim1.key4_id IN (group_level_cd, both_level_cd)) OR (bim1.key4_id=alpha_level_cd
    AND bim1.key2_id != clear_point_cd)) )
   JOIN (bi
   WHERE bi.bill_item_id=bim1.bill_item_id
    AND bi.active_ind=1)
   JOIN (d)
   JOIN (bim2
   WHERE bim2.bill_item_id=bim1.bill_item_id
    AND bim2.active_ind=1
    AND bim2.beg_effective_dt_tm < cnvtdatetime(curdate,000000)
    AND bim2.end_effective_dt_tm > cnvtdatetime(curdate,235959))
   JOIN (cv
   WHERE cv.code_value=bim2.key1_id
    AND cv.code_set=14002
    AND cv.cdf_meaning="CDM_SCHED"
    AND cv.active_ind=1)
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
