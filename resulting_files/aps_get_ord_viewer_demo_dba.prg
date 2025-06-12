CREATE PROGRAM aps_get_ord_viewer_demo:dba
 RECORD reply(
   1 case_id = f8
   1 encntr_id = f8
   1 accession_nbr = c21
   1 case_collect_dt_tm = dq8
   1 requesting_physician_id = f8
   1 requesting_physician_name = vc
   1 person_id = f8
   1 person_name = vc
   1 person_num = vc
   1 rpt_qual[*]
     2 report_id = f8
     2 report_sequence = i4
     2 event_id = f8
     2 catalog_cd = f8
     2 long_description = vc
     2 status_cd = f8
     2 status_disp = c40
     2 status_desc = c60
     2 status_mean = c12
     2 cancel_cd = f8
     2 cancel_disp = c40
   1 spec_qual[*]
     2 case_specimen_id = f8
     2 specimen_cd = f8
     2 specimen_disp = vc
     2 specimen_tag_display = c7
     2 specimen_description = vc
     2 cancel_cd = f8
     2 cancel_disp = c40
   1 phys_qual[*]
     2 physician_name = vc
     2 physician_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET prefix_cd = 0.0
 SET stat = alterlist(reply->spec_qual,1)
 SET stat = alterlist(reply->phys_qual,1)
 SET code_value = 0.0
 SET cdf_meaning = fillstring(10," ")
 SET mrn_alias_type_cd = 0.0
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SELECT INTO "nl:"
  join_path = decode(cr.seq,"R",cs.seq,"S",cp.seq,
   "P"," "), pc.case_id
  FROM pathology_case pc,
   person p,
   prsnl p5,
   (dummyt d1  WITH seq = 1),
   case_report cr,
   report_task rt,
   service_directory sd,
   (dummyt d2  WITH seq = 1),
   case_specimen cs,
   ap_tag t,
   (dummyt d3  WITH seq = 1),
   case_provider cp,
   prsnl pr
  PLAN (pc
   WHERE (request->accession_nbr=pc.accession_nbr)
    AND pc.origin_flag=0
    AND pc.cancel_cd IN (null, 0))
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (p5
   WHERE pc.requesting_physician_id=p5.person_id)
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (rt
   WHERE (request->order_id=rt.order_id))
   JOIN (cr
   WHERE rt.report_id=cr.report_id
    AND pc.case_id=cr.case_id)
   JOIN (sd
   WHERE cr.catalog_cd=sd.catalog_cd)
   ) ORJOIN ((((d2
   WHERE 1=d2.seq)
   JOIN (cs
   WHERE pc.case_id=cs.case_id
    AND cs.cancel_cd IN (null, 0.0))
   JOIN (t
   WHERE cs.specimen_tag_id=t.tag_id)
   ) ORJOIN ((d3
   WHERE 1=d3.seq)
   JOIN (cp
   WHERE pc.case_id=cp.case_id)
   JOIN (pr
   WHERE cp.physician_id=pr.person_id)
   )) ))
  ORDER BY t.tag_group_id, t.tag_sequence
  HEAD REPORT
   rpt_cnt = 0, spec_cnt = 0, phys_cnt = 0,
   reply->case_id = pc.case_id, reply->encntr_id = pc.encntr_id, reply->accession_nbr = pc
   .accession_nbr,
   prefix_cd = pc.prefix_id, reply->case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm), reply->
   requesting_physician_id = pc.requesting_physician_id,
   reply->person_name = p.name_full_formatted, reply->requesting_physician_name = trim(p5
    .name_full_formatted), reply->person_id = pc.person_id
  DETAIL
   CASE (join_path)
    OF "R":
     rpt_cnt = (rpt_cnt+ 1),stat = alterlist(reply->rpt_qual,rpt_cnt),reply->rpt_qual[rpt_cnt].
     report_id = cr.report_id,
     reply->rpt_qual[rpt_cnt].report_sequence = cr.report_sequence,reply->rpt_qual[rpt_cnt].event_id
      = cr.event_id,reply->rpt_qual[rpt_cnt].catalog_cd = cr.catalog_cd,
     reply->rpt_qual[rpt_cnt].status_cd = cr.status_cd,reply->rpt_qual[rpt_cnt].cancel_cd = cr
     .cancel_cd,reply->rpt_qual[rpt_cnt].long_description = sd.description
    OF "S":
     spec_cnt = (spec_cnt+ 1),stat = alterlist(reply->spec_qual,spec_cnt),reply->spec_qual[spec_cnt].
     specimen_cd = cs.specimen_cd,
     reply->spec_qual[spec_cnt].specimen_tag_display = t.tag_disp,reply->spec_qual[spec_cnt].
     case_specimen_id = cs.case_specimen_id,reply->spec_qual[spec_cnt].specimen_description = trim(cs
      .specimen_description)
    OF "P":
     phys_cnt = (phys_cnt+ 1),stat = alterlist(reply->phys_qual,phys_cnt),reply->phys_qual[phys_cnt].
     physician_name = trim(pr.name_full_formatted),
     reply->phys_qual[phys_cnt].physician_id = cp.physician_id
   ENDCASE
  FOOT REPORT
   stat = alterlist(reply->spec_qual,spec_cnt), stat = alterlist(reply->phys_qual,phys_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SELECT INTO "nl:"
   ea.encntr_id, frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
   FROM encntr_alias ea,
    encounter e
   PLAN (e
    WHERE (reply->encntr_id=e.encntr_id)
     AND e.active_ind=1
     AND e.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND ((e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (e.end_effective_dt_tm=null)) )
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=mrn_alias_type_cd
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    reply->person_num = frmt_mrn
   WITH nocounter
  ;end select
  SET reply->status_data.status = "S"
 ENDIF
 IF (size(reply->rpt_qual,5)=0)
  SELECT INTO "nl:"
   cr.event_id
   FROM code_value cv,
    clinical_event ce,
    case_report cr,
    service_directory sd
   PLAN (cv
    WHERE cv.code_set=53
     AND cv.cdf_meaning="MDOC"
     AND cv.active_ind=1)
    JOIN (ce
    WHERE (request->accession_nbr=ce.accession_nbr)
     AND (request->order_id=ce.order_id)
     AND ce.event_class_cd=cv.code_value
     AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
    JOIN (cr
    WHERE cnvtreal(trim(substring(3,97,ce.reference_nbr)))=cr.report_id)
    JOIN (sd
    WHERE cr.catalog_cd=sd.catalog_cd)
   DETAIL
    IF (size(reply->rpt_qual,5)=0)
     stat = alterlist(reply->rpt_qual,1), reply->rpt_qual[1].report_id = cr.report_id, reply->
     rpt_qual[1].report_sequence = cr.report_sequence,
     reply->rpt_qual[1].event_id = cr.event_id, reply->rpt_qual[1].catalog_cd = cr.catalog_cd, reply
     ->rpt_qual[1].status_cd = cr.status_cd,
     reply->rpt_qual[1].cancel_cd = cr.cancel_cd, reply->rpt_qual[1].long_description = sd
     .description
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CLINICAL_EVENT"
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#exit_script
END GO
