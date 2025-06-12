CREATE PROGRAM cp_get_header_page:dba
 RECORD reply(
   1 name_full_formatted = vc
   1 birth_dt_tm = dq8
   1 birth_tz = i4
   1 dest_ind = i2
   1 dest_id = f8
   1 destination = vc
   1 reason_cd = f8
   1 reason_disp = vc
   1 reason_desc = vc
   1 requestor_ind = i2
   1 requestor_id = f8
   1 requestor = vc
   1 printed_by = vc
   1 device = vc
   1 encntr_list[*]
     2 encntr_id = f8
     2 mrn = vc
     2 fin_nbr = vc
     2 reg_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 encntr_type_cd = f8
     2 encntr_type_disp = vc
     2 encntr_type_desc = vc
     2 loc_facility_cd = f8
     2 loc_facility_disp = vc
     2 loc_facility_desc = vc
     2 loc_building_cd = f8
     2 loc_building_disp = vc
     2 loc_building_desc = vc
     2 loc_nurse_unit_cd = f8
     2 loc_nurse_unit_disp = vc
     2 loc_nurse_unit_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE mrn_cd = f8
 DECLARE fin_nbr_cd = f8
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,mrn_cd)
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_nbr_cd)
 IF ((request->scope_flag=1))
  SELECT DISTINCT INTO "nl:"
   e.encntr_id
   FROM chart_request cr,
    encounter e
   PLAN (cr
    WHERE (cr.chart_request_id=request->request_id))
    JOIN (e
    WHERE e.person_id=cr.person_id
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1)
    IF (mod(count,5)=1)
     stat = alterlist(request->encntr_list,(count+ 4))
    ENDIF
    request->encntr_list[count].encntr_id = e.encntr_id
   FOOT REPORT
    stat = alterlist(request->encntr_list,count)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->scope_flag=6))
  SELECT DISTINCT INTO "nl:"
   ce.encntr_id
   FROM chart_request_event cre,
    clinical_event ce,
    encounter e
   PLAN (cre
    WHERE (cre.chart_request_id=request->request_id))
    JOIN (ce
    WHERE ce.event_id=cre.event_id
     AND ce.encntr_id > 0)
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1)
    IF (mod(count,5)=1)
     stat = alterlist(request->encntr_list,(count+ 4))
    ENDIF
    request->encntr_list[count].encntr_id = ce.encntr_id
   FOOT REPORT
    stat = alterlist(request->encntr_list,count)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM person p
  WHERE (p.person_id=request->person_id)
   AND p.active_ind=1
  DETAIL
   reply->name_full_formatted = p.name_full_formatted, reply->birth_dt_tm = p.birth_dt_tm, reply->
   birth_tz = validate(p.birth_tz,0)
  WITH nocounter
 ;end select
 IF ((request->request_type=8))
  SELECT INTO "nl:"
   FROM chart_request_audit cra
   WHERE (cra.chart_request_id=request->request_id)
   DETAIL
    reply->reason_cd = cra.reason_cd, reply->dest_ind =
    IF (cra.dest_pe_name="PERSON") 0
    ELSEIF (cra.dest_pe_name="ORGANIZATION") 1
    ELSEIF (cra.dest_pe_name="CODE_VALUE") 3
    ELSEIF (cra.dest_pe_name="FREETEXT") 2
    ENDIF
    , reply->dest_id = cra.dest_pe_id,
    reply->requestor_ind =
    IF (cra.requestor_pe_name="PERSON") 0
    ELSEIF (cra.requestor_pe_name="ORGANIZATION") 1
    ELSEIF (cra.requestor_pe_name="CODE_VALUE") 3
    ELSEIF (cra.dest_pe_name="FREETEXT") 2
    ENDIF
    , reply->requestor_id = cra.requestor_pe_id, reply->destination =
    IF ((reply->dest_ind=2)) cra.dest_txt
    ELSEIF ((reply->dest_ind=3)) uar_get_code_display(cra.dest_pe_id)
    ENDIF
    ,
    reply->requestor =
    IF ((reply->requestor_ind=2)) cra.requestor_txt
    ELSEIF ((reply->requestor_ind=3)) uar_get_code_display(cra.requestor_pe_id)
    ENDIF
   WITH nocounter
  ;end select
  IF ((reply->dest_ind=0))
   SELECT INTO "nl:"
    FROM person p
    WHERE (p.person_id=reply->dest_id)
     AND p.active_ind=1
    DETAIL
     reply->destination = p.name_full_formatted
    WITH nocounter
   ;end select
  ELSEIF ((reply->dest_ind=1))
   SELECT INTO "nl:"
    FROM organization o
    WHERE (o.organization_id=reply->dest_id)
     AND o.active_ind=1
    DETAIL
     reply->destination = o.org_name
    WITH nocounter
   ;end select
  ENDIF
  IF ((reply->requestor_ind=0))
   SELECT INTO "nl:"
    FROM person p
    WHERE (p.person_id=reply->requestor_id)
     AND p.active_ind=1
    DETAIL
     reply->requestor = p.name_full_formatted
    WITH nocounter
   ;end select
  ELSEIF ((reply->requestor_ind=1))
   SELECT INTO "nl:"
    FROM organization o
    WHERE (o.organization_id=reply->requestor_id)
     AND o.active_ind=1
    DETAIL
     reply->requestor = o.org_name
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM chart_request cr,
   prsnl p
  WHERE (cr.chart_request_id=request->request_id)
   AND p.person_id=cr.request_prsnl_id
   AND p.active_ind=1
  DETAIL
   reply->printed_by = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM output_dest od
  WHERE (od.output_dest_cd=request->output_dest_cd)
  DETAIL
   reply->device = od.name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  e.encntr_id
  FROM encounter e,
   encntr_alias ea1,
   encntr_alias ea2,
   (dummyt d  WITH seq = value(size(request->encntr_list,5))),
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=request->encntr_list[d.seq].encntr_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d2)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.encntr_alias_type_cd=fin_nbr_cd
    AND ea2.active_ind=1
    AND ea2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d1)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.encntr_alias_type_cd=mrn_cd
    AND ea1.active_ind=1
    AND ea1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY e.reg_dt_tm DESC
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1), stat = alterlist(reply->encntr_list,count), reply->encntr_list[count].
   encntr_id = e.encntr_id,
   reply->encntr_list[count].reg_dt_tm = e.reg_dt_tm, reply->encntr_list[count].disch_dt_tm = e
   .disch_dt_tm, reply->encntr_list[count].encntr_type_cd = e.encntr_type_cd,
   reply->encntr_list[count].loc_facility_cd = e.loc_facility_cd, reply->encntr_list[count].
   loc_building_cd = e.loc_building_cd, reply->encntr_list[count].loc_nurse_unit_cd = e
   .loc_nurse_unit_cd,
   reply->encntr_list[count].mrn = cnvtalias(ea1.alias,ea1.alias_pool_cd), reply->encntr_list[count].
   fin_nbr = cnvtalias(ea2.alias,ea2.alias_pool_cd)
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   dontcare = ea2
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "Select"
  SET reply->status_data.operationstatus = "F"
  SET errorcode = error(errmsg,0)
  IF (errorcode != 0)
   SET reply->status_data.targetobjectname = "ErrorMessage"
   SET reply->status_data.targetobjectvalue = errmsg
  ELSE
   SET reply->status_data.targetobjectname = "Qualifications"
   SET reply->status_data.targetobjectvalue = "No matching records"
  ENDIF
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
