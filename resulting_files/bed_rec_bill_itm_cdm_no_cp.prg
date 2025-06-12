CREATE PROGRAM bed_rec_bill_itm_cdm_no_cp
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
 SET addgen_cd = get_code_value(106,"AFC ADD GEN")
 SET adddef_cd = get_code_value(106,"AFC ADD DEF")
 SET addspec_cd = get_code_value(106,"AFC ADD SPEC")
 SET chg_point_cd = get_code_value(13019,"CHARGE POINT")
 SET alpha_level_cd = get_code_value(13020,"ALPHA")
 SET group_level_cd = get_code_value(13020,"GROUP")
 SET both_level_cd = get_code_value(13020,"BOTH")
 SET clear_point_cd = get_code_value(13029,"CLEAR")
 SELECT INTO "nl:"
  FROM code_value cv,
   bill_item_modifier bim1,
   bill_item bi,
   (dummyt d  WITH seq = 1),
   bill_item_modifier bim2
  PLAN (cv
   WHERE cv.code_set=14002
    AND cv.cdf_meaning="CDM_SCHED"
    AND cv.active_ind=1)
   JOIN (bim1
   WHERE bim1.key1_id=cv.code_value
    AND bim1.active_ind=1
    AND bim1.beg_effective_dt_tm < cnvtdatetime(curdate,000000)
    AND bim1.end_effective_dt_tm > cnvtdatetime(curdate,235959))
   JOIN (bi
   WHERE bi.bill_item_id=bim1.bill_item_id
    AND  NOT (bi.ext_owner_cd IN (pharmacy_cd, addgen_cd, adddef_cd, addspec_cd))
    AND bi.active_ind=1)
   JOIN (d)
   JOIN (bim2
   WHERE bim2.bill_item_id=bi.bill_item_id
    AND bim2.bill_item_type_cd=chg_point_cd
    AND ((bim2.key4_id IN (group_level_cd, both_level_cd)) OR (bim2.key4_id=alpha_level_cd
    AND bim2.key2_id != clear_point_cd)) )
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
