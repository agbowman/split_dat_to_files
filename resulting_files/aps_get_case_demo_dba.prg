CREATE PROGRAM aps_get_case_demo:dba
 RECORD reply(
   1 case_id = f8
   1 accession_nbr = c25
   1 resp_pathologist_name = vc
   1 resp_resident_name = vc
   1 accessioned_by_name = vc
   1 accessioned_dt_tm = dq8
   1 case_collect_dt_tm = dq8
   1 case_received_dt_tm = dq8
   1 phys_qual[*]
     2 physician_name = vc
     2 requesting_ind = i2
   1 rpt_qual[*]
     2 short_description = c50
     2 report_sequence = i4
     2 reporting_sequence = i4
     2 status_cd = f8
     2 status_disp = c40
     2 priority_cd = f8
     2 priority_disp = c40
     2 responsible_resident_name = vc
     2 responsible_pathologist_name = vc
   1 spec_qual[*]
     2 specimen_description = vc
     2 specimen_tag_display = c7
     2 specimen_cd = f8
     2 specimen_disp = c40
     2 tag_sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  join_path = decode(cr.seq,"R",cs.seq,"S",cp.seq,
   "P"," "), rt_exists = decode(rt.seq,"Y"," ")
  FROM pathology_case pc,
   case_report cr,
   report_task rt,
   service_directory sd,
   case_specimen cs,
   case_provider cp,
   prsnl p,
   prsnl p1,
   prsnl p2,
   prsnl p3,
   prsnl p4,
   prsnl p5,
   prsnl p6,
   prefix_report_r prr,
   ap_tag t,
   (dummyt d1  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1),
   (dummyt d5  WITH seq = 1)
  PLAN (pc
   WHERE (request->case_id=pc.case_id))
   JOIN (p3
   WHERE pc.requesting_physician_id=p3.person_id)
   JOIN (p4
   WHERE pc.accession_prsnl_id=p4.person_id)
   JOIN (p5
   WHERE pc.responsible_pathologist_id=p5.person_id)
   JOIN (p6
   WHERE pc.responsible_resident_id=p6.person_id)
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (cr
   WHERE pc.case_id=cr.case_id)
   JOIN (sd
   WHERE cr.catalog_cd=sd.catalog_cd)
   JOIN (prr
   WHERE pc.prefix_id=prr.prefix_id
    AND cr.catalog_cd=prr.catalog_cd)
   JOIN (d3
   WHERE 1=d3.seq)
   JOIN (rt
   WHERE cr.report_id=rt.report_id)
   JOIN (p1
   WHERE rt.responsible_pathologist_id=p1.person_id)
   JOIN (p2
   WHERE rt.responsible_resident_id=p2.person_id)
   ) ORJOIN ((((d4
   WHERE 1=d4.seq)
   JOIN (cs
   WHERE pc.case_id=cs.case_id
    AND cs.cancel_cd IN (null, 0))
   JOIN (t
   WHERE cs.specimen_tag_id=t.tag_id)
   ) ORJOIN ((d5
   WHERE 1=d5.seq)
   JOIN (cp
   WHERE pc.case_id=cp.case_id)
   JOIN (p
   WHERE cp.physician_id=p.person_id)
   )) ))
  HEAD REPORT
   rpt_cnt = 0, spec_cnt = 0, phys_cnt = 0,
   reply->case_id = pc.case_id, reply->accessioned_dt_tm = cnvtdatetime(pc.accessioned_dt_tm), reply
   ->case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm),
   reply->case_received_dt_tm = cnvtdatetime(pc.case_received_dt_tm), pc_accession_nbr =
   uar_fmt_accession(pc.accession_nbr,size(pc.accession_nbr,1)), reply->accession_nbr =
   pc_accession_nbr,
   reply->accessioned_by_name = p4.name_full_formatted, reply->resp_pathologist_name = p5
   .name_full_formatted, reply->resp_resident_name = p6.name_full_formatted,
   stat = alterlist(reply->phys_qual,10), phys_cnt = (phys_cnt+ 1), reply->phys_qual[phys_cnt].
   physician_name = p3.name_full_formatted,
   reply->phys_qual[phys_cnt].requesting_ind = 1
  DETAIL
   CASE (join_path)
    OF "R":
     rpt_cnt = (rpt_cnt+ 1),
     IF (mod(rpt_cnt,10)=1)
      stat = alterlist(reply->rpt_qual,(rpt_cnt+ 9))
     ENDIF
     ,reply->rpt_qual[rpt_cnt].short_description = sd.short_description,reply->rpt_qual[rpt_cnt].
     report_sequence = cr.report_sequence,reply->rpt_qual[rpt_cnt].reporting_sequence = prr
     .reporting_sequence,
     reply->rpt_qual[rpt_cnt].status_cd = cr.status_cd,
     IF (rt_exists="Y")
      reply->rpt_qual[rpt_cnt].priority_cd = rt.priority_cd, reply->rpt_qual[rpt_cnt].
      responsible_resident_name = p2.name_full_formatted, reply->rpt_qual[rpt_cnt].
      responsible_pathologist_name = p1.name_full_formatted
     ENDIF
    OF "S":
     spec_cnt = (spec_cnt+ 1),
     IF (mod(spec_cnt,10)=1)
      stat = alterlist(reply->spec_qual,(spec_cnt+ 9))
     ENDIF
     ,reply->spec_qual[spec_cnt].specimen_description = cs.specimen_description,reply->spec_qual[
     spec_cnt].specimen_tag_display = t.tag_disp,reply->spec_qual[spec_cnt].specimen_cd = cs
     .specimen_cd,
     reply->spec_qual[spec_cnt].tag_sequence = t.tag_sequence
    OF "P":
     phys_cnt = (phys_cnt+ 1),
     IF (mod(phys_cnt,10)=1)
      stat = alterlist(reply->phys_qual,(phys_cnt+ 9))
     ENDIF
     ,reply->phys_qual[phys_cnt].physician_name = p.name_full_formatted,reply->phys_qual[phys_cnt].
     requesting_ind = 0
   ENDCASE
  FOOT REPORT
   stat = alterlist(reply->phys_qual,phys_cnt), stat = alterlist(reply->spec_qual,spec_cnt), stat =
   alterlist(reply->rpt_qual,rpt_cnt)
  WITH nocounter, outerjoin = d3
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
