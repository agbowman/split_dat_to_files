CREATE PROGRAM cp_get_org_from_event:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  FREE RECORD reply
  RECORD reply(
    1 org_qual[*]
      2 organization_id = f8
      2 chart_format_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD temp_orgs
 RECORD temp_orgs(
   1 qual[*]
     2 organization_id = f8
 )
 DECLARE nstart = i4 WITH constant(1)
 DECLARE idx = i4 WITH noconstant(1), protect
 DECLARE bind_cnt = i4 WITH noconstant(50)
 DECLARE temporgcnt = i4 WITH noconstant(0)
 DECLARE tempformatcnt = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 IF ((request->data_type_flag=1))
  SELECT INTO "nl:"
   e.organization_id
   FROM (dummyt d  WITH seq = value(size(request->qual,5))),
    clinical_event ce,
    encounter e
   PLAN (d)
    JOIN (ce
    WHERE (ce.event_id=request->qual[d.seq].data_id)
     AND ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   HEAD REPORT
    x = 0
   DETAIL
    x = (x+ 1)
    IF (x > size(reply->org_qual,5))
     stat = alterlist(reply->org_qual,(x+ 9))
    ENDIF
    reply->org_qual[x].organization_id = e.organization_id
   FOOT REPORT
    IF (x > 0)
     stat = alterlist(reply->org_qual,x)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->data_type_flag=2))
  SELECT INTO "nl:"
   e.organization_id
   FROM (dummyt d  WITH seq = value(size(request->qual,5))),
    clinical_event ce,
    encounter e
   PLAN (d)
    JOIN (ce
    WHERE (ce.accession_nbr=request->qual[d.seq].data_string)
     AND ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ce.accession_nbr
   HEAD REPORT
    x = 0
   HEAD ce.accession_nbr
    x = (x+ 1)
    IF (x > size(reply->org_qual,5))
     stat = alterlist(reply->org_qual,(x+ 9))
    ENDIF
    reply->org_qual[x].organization_id = e.organization_id
   FOOT REPORT
    IF (x > 0)
     stat = alterlist(reply->org_qual,x)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->data_type_flag=3))
  SELECT INTO "nl:"
   e.organization_id, f.chart_format_id
   FROM (dummyt d  WITH seq = value(size(request->qual,5))),
    encounter e,
    format_org_reltn f
   PLAN (d)
    JOIN (e
    WHERE (e.person_id=request->qual[1].data_id))
    JOIN (f
    WHERE f.organization_id=e.organization_id
     AND f.primary_format_ind=1)
   DETAIL
    temporgcnt = (temporgcnt+ 1),
    CALL echo(temporgcnt)
    IF (temporgcnt > size(temp_orgs->qual,5))
     stat = alterlist(temp_orgs->qual,temporgcnt)
    ENDIF
    temp_orgs->qual[temporgcnt].organization_id = e.organization_id
   WITH nocounter
  ;end select
  IF (temporgcnt > 0)
   SET stat = alterlist(temp_orgs->qual,temporgcnt)
  ENDIF
  SET temp = size(temp_orgs->qual,5)
  SELECT INTO "nl:"
   f.chart_format_id, f.organization_id
   FROM format_org_reltn f
   WHERE primary_format_ind=1
    AND expand(idx,nstart,temp,f.organization_id,temp_orgs->qual[idx].organization_id)
   HEAD REPORT
    tempformatcnt = 0
   DETAIL
    tempformatcnt = (tempformatcnt+ 1)
    IF (tempformatcnt > size(reply->org_qual,5))
     stat = alterlist(reply->org_qual,tempformatcnt)
    ENDIF
    reply->org_qual[tempformatcnt].organization_id = f.organization_id, reply->org_qual[tempformatcnt
    ].chart_format_id = f.chart_format_id
   FOOT REPORT
    IF (tempformatcnt > 0)
     stat = alterlist(reply->org_qual,tempformatcnt)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
