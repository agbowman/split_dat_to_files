CREATE PROGRAM dcp_mu_patient_list_prob_diag:dba
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
 DECLARE inpatient_class_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17006"))
 DECLARE outpatient_class_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17007"))
 DECLARE exp_idx = i4 WITH protect, noconstant(0)
 DECLARE parser_loc = vc WITH protect, noconstant("1=1")
 DECLARE parser_encntr_type = vc WITH protect, noconstant("1=1")
 DECLARE parser_nomenclature_id = vc WITH protect, noconstant("d.nomenclature_id in (")
 DECLARE encpos = i4 WITH protect, noconstant(0)
 IF ((request->nomenclature_id > 0))
  SET parser_nomenclature_id = build2(parser_nomenclature_id,request->nomenclature_id)
  IF ((((request->nomenclature_id2 > 0)) OR ((request->nomenclature_id3 > 0))) )
   SET parser_nomenclature_id = build2(parser_nomenclature_id,", ")
  ENDIF
 ENDIF
 IF ((request->nomenclature_id2 > 0))
  SET parser_nomenclature_id = build2(parser_nomenclature_id,request->nomenclature_id2)
  IF ((request->nomenclature_id3 > 0))
   SET parser_nomenclature_id = build2(parser_nomenclature_id,", ")
  ENDIF
 ENDIF
 IF ((request->nomenclature_id3 > 0))
  SET parser_nomenclature_id = build2(parser_nomenclature_id,request->nomenclature_id3)
 ENDIF
 SET parser_nomenclature_id = build2(parser_nomenclature_id,")")
 IF (request->loc_nurse_unit_cd)
  SET parser_loc = build("e.loc_nurse_unit_cd = ",request->loc_nurse_unit_cd)
  SET parser_encntr_type = build("e.encntr_type_class_cd = ",outpatient_class_cd)
 ELSEIF (request->loc_facility_cd)
  SET parser_loc = build("e.loc_facility_cd = ",request->loc_facility_cd)
  SET parser_encntr_type = build("e.encntr_type_class_cd = ",inpatient_class_cd)
 ENDIF
 SELECT
  IF ((request->cnt > 0)
   AND size(request->qual,5))
   PLAN (d
    WHERE expand(exp_idx,1,request->cnt,d.encntr_id,request->qual[exp_idx].encntr_id)
     AND parser(parser_nomenclature_id)
     AND d.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=d.encntr_id)
    JOIN (n
    WHERE n.nomenclature_id=d.nomenclature_id)
  ELSE
   PLAN (e
    WHERE e.reg_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
     AND parser(parser_loc)
     AND parser(parser_encntr_type)
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND e.active_ind=1)
    JOIN (d
    WHERE d.encntr_id=e.encntr_id
     AND parser(parser_nomenclature_id)
     AND d.active_ind=1)
    JOIN (n
    WHERE n.nomenclature_id=d.nomenclature_id)
  ENDIF
  FROM diagnosis d,
   encounter e,
   nomenclature n
  ORDER BY e.encntr_id, d.nomenclature_id
  HEAD e.encntr_id
   reply->cnt = (reply->cnt+ 1)
   IF ((reply->cnt > size(reply->qual,5)))
    stat = alterlist(reply->qual,(reply->cnt+ 19))
   ENDIF
   reply->qual[reply->cnt].person_id = e.person_id, reply->qual[reply->cnt].encntr_id = e.encntr_id
  HEAD d.nomenclature_id
   encpos = locateval(exp_idx,1,reply->cnt,e.encntr_id,reply->qual[exp_idx].encntr_id)
   IF (encpos > 0)
    IF ((d.nomenclature_id=request->nomenclature_id))
     reply->qual[encpos].item_id = d.diagnosis_id, reply->qual[encpos].item_display = concat(trim(n
       .source_string,3)," (",trim(n.source_identifier,3),")")
    ELSEIF ((d.nomenclature_id=request->nomenclature_id2))
     reply->qual[encpos].item_id2 = d.diagnosis_id, reply->qual[encpos].item_display2 = concat(trim(n
       .source_string,3)," (",trim(n.source_identifier,3),")")
    ELSEIF ((d.nomenclature_id=request->nomenclature_id3))
     reply->qual[encpos].item_id3 = d.diagnosis_id, reply->qual[encpos].item_display3 = concat(trim(n
       .source_string,3)," (",trim(n.source_identifier,3),")")
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SET parser_nomenclature_id = replace(parser_nomenclature_id,"d.","p.")
 SELECT
  IF ((request->cnt > 0)
   AND size(request->qual,5))
   PLAN (e
    WHERE expand(exp_idx,1,request->cnt,e.encntr_id,request->qual[exp_idx].encntr_id))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND parser(parser_nomenclature_id)
     AND p.active_ind=1)
    JOIN (n
    WHERE n.nomenclature_id=p.nomenclature_id)
  ELSE
   PLAN (e
    WHERE e.reg_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
     AND parser(parser_loc)
     AND parser(parser_encntr_type)
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND e.active_ind=1)
    JOIN (p
    WHERE p.person_id=e.person_id
     AND parser(parser_nomenclature_id)
     AND p.active_ind=1)
    JOIN (n
    WHERE n.nomenclature_id=p.nomenclature_id)
  ENDIF
  FROM problem p,
   encounter e,
   nomenclature n
  ORDER BY e.encntr_id, p.nomenclature_id
  HEAD e.encntr_id
   IF (locateval(exp_idx,1,reply->cnt,e.encntr_id,reply->qual[exp_idx].encntr_id)=0)
    reply->cnt = (reply->cnt+ 1)
    IF ((reply->cnt > size(reply->qual,5)))
     stat = alterlist(reply->qual,(reply->cnt+ 19))
    ENDIF
    reply->qual[reply->cnt].person_id = e.person_id, reply->qual[reply->cnt].encntr_id = e.encntr_id
   ENDIF
  HEAD p.nomenclature_id
   encpos = locateval(exp_idx,1,reply->cnt,e.encntr_id,reply->qual[exp_idx].encntr_id)
   IF (encpos > 0)
    IF ((p.nomenclature_id=request->nomenclature_id))
     reply->qual[encpos].item_id = p.problem_instance_id, reply->qual[encpos].item_display = concat(
      trim(n.source_string,3)," (",trim(n.source_identifier,3),")")
    ELSEIF ((p.nomenclature_id=request->nomenclature_id2))
     reply->qual[encpos].item_id2 = p.problem_instance_id, reply->qual[encpos].item_display2 = concat
     (trim(n.source_string,3)," (",trim(n.source_identifier,3),")")
    ELSEIF ((p.nomenclature_id=request->nomenclature_id3))
     reply->qual[encpos].item_id3 = p.problem_instance_id, reply->qual[encpos].item_display3 = concat
     (trim(n.source_string,3)," (",trim(n.source_identifier,3),")")
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SET stat = alterlist(reply->qual,reply->cnt)
 CALL echo("last mod: 352272  03/25/2013  Chris Jolley")
END GO
