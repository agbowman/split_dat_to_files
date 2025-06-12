CREATE PROGRAM dcp_mu_patient_list_lab:dba
 IF (validate(reply)=0)
  RECORD reply(
    1 cnt = i4
    1 qual[*]
      2 person_id = f8
      2 encntr_id = f8
      2 item_id = f8
      2 item_display = vc
      2 item_id2 = f8
      2 item_display2 = vc
      2 item_id3 = f8
      2 item_display3 = vc
  )
 ENDIF
 DECLARE sign_greater = i2 WITH protect, constant(1)
 DECLARE sign_greater_equal = i2 WITH protect, constant(2)
 DECLARE sign_equal = i2 WITH protect, constant(3)
 DECLARE sign_less_equal = i2 WITH protect, constant(4)
 DECLARE sign_less = i2 WITH protect, constant(5)
 DECLARE event_type_verif_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3019"))
 DECLARE event_type_auto_verif_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!10193"))
 DECLARE inpatient_class_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17006"))
 DECLARE outpatient_class_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17007"))
 DECLARE exp_idx = i4 WITH protect, noconstant(0)
 DECLARE parser_loc = vc WITH protect, noconstant("1=1")
 DECLARE parser_result_val = vc WITH protect, noconstant("1=1")
 DECLARE parser_encntr_type = vc WITH protect, noconstant("1=1")
 IF (request->loc_nurse_unit_cd)
  SET parser_loc = build("e.loc_nurse_unit_cd = ",request->loc_nurse_unit_cd)
  SET parser_encntr_type = build("e.encntr_type_class_cd = ",outpatient_class_cd)
 ELSEIF (request->loc_facility_cd)
  SET parser_loc = build("e.loc_facility_cd = ",request->loc_facility_cd)
  SET parser_encntr_type = build("e.encntr_type_class_cd = ",inpatient_class_cd)
 ENDIF
 CASE (request->result_sign)
  OF sign_greater:
   SET parser_result_val = build("pr.result_value_numeric > ",request->result_value_numeric)
  OF sign_greater_equal:
   SET parser_result_val = build("pr.result_value_numeric >= ",request->result_value_numeric)
  OF sign_equal:
   SET parser_result_val = build("pr.result_value_numeric = ",request->result_value_numeric)
  OF sign_less_equal:
   SET parser_result_val = build("pr.result_value_numeric <= ",request->result_value_numeric)
  OF sign_less:
   SET parser_result_val = build("pr.result_value_numeric < ",request->result_value_numeric)
 ENDCASE
 CALL echo(concat("parser_result_val = ",parser_result_val))
 SELECT
  IF ((request->cnt > 0)
   AND size(request->qual,5))
   PLAN (re
    WHERE re.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm
     )
     AND re.event_type_cd IN (event_type_verif_cd, event_type_auto_verif_cd))
    JOIN (r
    WHERE r.result_id=re.result_id
     AND (r.task_assay_cd=request->task_assay_cd))
    JOIN (pr
    WHERE pr.perform_result_id=re.perform_result_id
     AND parser(parser_result_val))
    JOIN (o
    WHERE o.order_id=r.order_id)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id
     AND parser(parser_loc)
     AND parser(parser_encntr_type)
     AND expand(exp_idx,1,request->cnt,e.encntr_id,request->qual[exp_idx].encntr_id))
  ELSE
   PLAN (re
    WHERE re.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm
     )
     AND re.event_type_cd IN (event_type_verif_cd, event_type_auto_verif_cd))
    JOIN (r
    WHERE r.result_id=re.result_id
     AND (r.task_assay_cd=request->task_assay_cd))
    JOIN (pr
    WHERE pr.perform_result_id=re.perform_result_id
     AND parser(parser_result_val))
    JOIN (o
    WHERE o.order_id=r.order_id)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id
     AND parser(parser_loc)
     AND parser(parser_encntr_type))
  ENDIF
  FROM result_event re,
   result r,
   perform_result pr,
   orders o,
   encounter e
  ORDER BY e.encntr_id, re.result_id, re.event_sequence DESC
  HEAD e.encntr_id
   reply->cnt = (reply->cnt+ 1)
   IF ((reply->cnt > size(reply->qual,5)))
    stat = alterlist(reply->qual,(reply->cnt+ 19))
   ENDIF
   reply->qual[reply->cnt].person_id = e.person_id, reply->qual[reply->cnt].encntr_id = e.encntr_id,
   reply->qual[reply->cnt].item_id2 = pr.result_value_numeric
  HEAD re.result_id
   IF (textlen(trim(reply->qual[reply->cnt].item_display,3)) > 0)
    reply->qual[reply->cnt].item_display = notrim(concat(reply->qual[reply->cnt].item_display,", "))
   ENDIF
   reply->qual[reply->cnt].item_display = concat(reply->qual[reply->cnt].item_display,build(
     uar_get_code_display(r.task_assay_cd)),": ",build(cnvtstring(pr.result_value_numeric,11,2))," ",
    build(uar_get_code_display(pr.units_cd)))
  FOOT REPORT
   stat = alterlist(reply->qual,reply->cnt)
  WITH nocounter, expand = 1
 ;end select
 CALL echo("last mod: 352272  03/25/2013  Chris Jolley")
END GO
