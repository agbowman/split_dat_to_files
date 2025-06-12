CREATE PROGRAM cv_get_cvregevents:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 data[*]
      2 person_id = f8
      2 encntr_id = f8
      2 regis_dt_tm = dq8
      2 disch_dt_tm = dq8
      2 event_cd = f8
      2 loc_facility_cd = f8
      2 result_val = vc
      2 result_status_cd = f8
      2 event_tag = vc
      2 event_id = f8
      2 topmost_parent_event_id = f8
      2 new_topmost_parent_event_id = f8
      2 nomenclature_id = f8
      2 parents[*]
        3 parent_event_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET internal
 RECORD internal(
   1 data[*]
     2 person_id = f8
     2 encntr_id = f8
     2 regis_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 event_cd = f8
     2 loc_facility_cd = f8
     2 result_val = vc
     2 result_status_cd = f8
     2 event_tag = vc
     2 event_id = f8
     2 topmost_parent_event_id = f8
     2 nomenclature_id = f8
     2 new_topmost_parent_event_id = f8
     2 parents[*]
       3 parent_event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET needtop
 RECORD needtop(
   1 rec[*]
     2 topmost_parent_event_id = f8
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET parent_event_id = 0
 SET event_cd = 0
 SET event_id = 0
 SET dataset_id = 0
 SET rec_cnt = 0
 SET prnt_cnt = 0
 SET start_dt = 0
 SET stop_dt = 0
 SET select_ind = 0
 CALL echorecord(request,"cvHarvRec")
 SELECT
  IF ((request->dataset_mode_num=0))
   PLAN (ref
    WHERE (ref.dataset_id=request->dataset_id)
     AND ref.active_ind=1)
    JOIN (reg
    WHERE ref.xref_id=reg.xref_id
     AND reg.active_ind=1)
    JOIN (d)
    JOIN (encn
    WHERE (encn.organization_id=request->organization_id)
     AND reg.encntr_id=encn.encntr_id
     AND encn.disch_dt_tm BETWEEN cnvtdatetime(cnvtdate(request->start_dt),0) AND cnvtdatetime(
     cnvtdate(request->stop_dt),235959))
    JOIN (ce
    WHERE reg.event_id=ce.event_id
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ELSEIF ((request->dataset_mode_num=1))
   PLAN (ref
    WHERE (ref.dataset_id=request->dataset_id)
     AND ref.active_ind=1)
    JOIN (reg
    WHERE ref.xref_id=reg.xref_id
     AND reg.active_ind=1)
    JOIN (d)
    JOIN (encn
    WHERE reg.encntr_id=encn.encntr_id
     AND cnvtdatetime(cnvtdate(request->start_dt),0) >= encn.reg_dt_tm
     AND cnvtdatetime(cnvtdate(request->stop_dt),235959) <= encn.disch_dt_tm
     AND encn.reg_dt_tm <= encn.disch_dt_tm)
    JOIN (ce
    WHERE reg.event_id=ce.event_id
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ELSEIF ((request->dataset_mode_num=100))
   PLAN (ref
    WHERE (ref.dataset_id=request->dataset_id)
     AND ref.active_ind=1)
    JOIN (reg
    WHERE ref.xref_id=reg.xref_id)
    JOIN (d)
    JOIN (encn
    WHERE reg.encntr_id=encn.encntr_id)
    JOIN (ce
    WHERE reg.event_id=ce.event_id
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ELSEIF ((request->dataset_mode_num=200))
   PLAN (ref
    WHERE (ref.dataset_id=request->dataset_id)
     AND ref.active_ind=1)
    JOIN (reg
    WHERE ref.xref_id=reg.xref_id
     AND reg.active_ind=1)
    JOIN (d)
    JOIN (encn
    WHERE (encn.organization_id=request->organization_id)
     AND reg.encntr_id=encn.encntr_id)
    JOIN (ce
    WHERE reg.event_id=ce.event_id
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ELSEIF ((request->dataset_mode_num=101))
   PLAN (ref
    WHERE (ref.dataset_id=request->dataset_id)
     AND ref.active_ind=1)
    JOIN (reg
    WHERE ref.xref_id=reg.xref_id
     AND reg.active_ind=1)
    JOIN (d)
    JOIN (encn
    WHERE reg.encntr_id=encn.encntr_id)
    JOIN (ce
    WHERE reg.event_id=ce.event_id
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ELSE
  ENDIF
  INTO "NL:"
  reg.parent_event_id
  FROM cv_xref ref,
   cv_registry_event reg,
   clinical_event ce,
   dummyt d,
   encounter encn
  ORDER BY reg.event_id
  DETAIL
   IF ((request->dataset_mode_num=0))
    rec_cnt = (rec_cnt+ 1), rec_arr = alterlist(reply->data,rec_cnt), reply->data[rec_cnt].person_id
     = reg.person_id,
    reply->data[rec_cnt].encntr_id = reg.encntr_id, reply->data[rec_cnt].event_cd = ref.event_cd,
    reply->data[rec_cnt].result_val = ce.result_val,
    reply->data[rec_cnt].result_status_cd = ce.result_status_cd, reply->data[rec_cnt].event_tag = ce
    .event_tag, reply->data[rec_cnt].event_id = reg.event_id,
    reply->data[rec_cnt].regis_dt_tm = encn.reg_dt_tm, reply->data[rec_cnt].disch_dt_tm = encn
    .disch_dt_tm, reply->data[rec_cnt].loc_facility_cd = encn.loc_facility_cd,
    stat = alterlist(reply->data[rec_cnt].parents,1), reply->data[rec_cnt].parents[1].parent_event_id
     = reg.parent_event_id, reply->data[rec_cnt].new_topmost_parent_event_id = reg.parent_event_id
   ELSEIF ((request->dataset_mode_num=1))
    rec_cnt = (rec_cnt+ 1), rec_arr = alterlist(internal->data,rec_cnt), internal->data[rec_cnt].
    person_id = reg.person_id,
    internal->data[rec_cnt].encntr_id = reg.encntr_id, internal->data[rec_cnt].event_cd = ref
    .event_cd, internal->data[rec_cnt].result_val = ce.result_val,
    internal->data[rec_cnt].result_status_cd = ce.result_status_cd, internal->data[rec_cnt].event_tag
     = ce.event_tag, internal->data[rec_cnt].event_id = reg.event_id,
    internal->data[rec_cnt].regis_dt_tm = encn.reg_dt_tm, internal->data[rec_cnt].disch_dt_tm = encn
    .disch_dt_tm, internal->data[rec_cnt].loc_facility_cd = encn.loc_facility_cd,
    stat = alterlist(internal->data[rec_cnt].parents,1), internal->data[rec_cnt].parents[1].
    parent_event_id = reg.parent_event_id, internal->data[rec_cnt].topmost_parent_event_id = reg
    .parent_event_id,
    rec_arr = alterlist(reply->data,rec_cnt), reply->data[rec_cnt].person_id = reg.person_id, reply->
    data[rec_cnt].encntr_id = reg.encntr_id,
    reply->data[rec_cnt].event_cd = ref.event_cd, reply->data[rec_cnt].result_val = ce.result_val,
    reply->data[rec_cnt].result_status_cd = ce.result_status_cd,
    reply->data[rec_cnt].event_tag = ce.event_tag, reply->data[rec_cnt].event_id = reg.event_id,
    reply->data[rec_cnt].regis_dt_tm = encn.reg_dt_tm,
    reply->data[rec_cnt].disch_dt_tm = encn.disch_dt_tm, reply->data[rec_cnt].loc_facility_cd = encn
    .loc_facility_cd, stat = alterlist(reply->data[rec_cnt].parents,1),
    reply->data[rec_cnt].parents[1].parent_event_id = reg.parent_event_id, reply->data[rec_cnt].
    new_topmost_parent_event_id = reg.parent_event_id
   ELSEIF ((request->dataset_mode_num=100))
    rec_cnt = (rec_cnt+ 1), rec_arr = alterlist(reply->data,rec_cnt), reply->data[rec_cnt].person_id
     = reg.person_id,
    reply->data[rec_cnt].encntr_id = reg.encntr_id, reply->data[rec_cnt].event_cd = ref.event_cd,
    reply->data[rec_cnt].result_val = ce.result_val,
    reply->data[rec_cnt].result_status_cd = ce.result_status_cd, reply->data[rec_cnt].event_tag = ce
    .event_tag, reply->data[rec_cnt].event_id = reg.event_id,
    reply->data[rec_cnt].regis_dt_tm = encn.reg_dt_tm, reply->data[rec_cnt].disch_dt_tm = encn
    .disch_dt_tm, reply->data[rec_cnt].loc_facility_cd = encn.loc_facility_cd,
    stat = alterlist(reply->data[rec_cnt].parents,1), reply->data[rec_cnt].parents[1].parent_event_id
     = reg.parent_event_id, reply->data[rec_cnt].new_topmost_parent_event_id = reg.parent_event_id
   ELSEIF ((request->dataset_mode_num=200))
    rec_cnt = (rec_cnt+ 1), rec_arr = alterlist(reply->data,rec_cnt), reply->data[rec_cnt].person_id
     = reg.person_id,
    reply->data[rec_cnt].encntr_id = reg.encntr_id, reply->data[rec_cnt].event_cd = ref.event_cd,
    reply->data[rec_cnt].result_val = ce.result_val,
    reply->data[rec_cnt].result_status_cd = ce.result_status_cd, reply->data[rec_cnt].event_tag = ce
    .event_tag, reply->data[rec_cnt].event_id = reg.event_id,
    reply->data[rec_cnt].regis_dt_tm = encn.reg_dt_tm, reply->data[rec_cnt].disch_dt_tm = encn
    .disch_dt_tm, reply->data[rec_cnt].loc_facility_cd = encn.loc_facility_cd,
    stat = alterlist(reply->data[rec_cnt].parents,1), reply->data[rec_cnt].parents[1].parent_event_id
     = reg.parent_event_id, reply->data[rec_cnt].new_topmost_parent_event_id = ce.parent_event_id
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("The nbr of Rec is ",rec_cnt))
 CALL echo("After Select")
 IF (rec_cnt=0)
  GO TO error_check
 ENDIF
 SET numloops = 0
 SET top_parent_cnt = 0
 WHILE (top_parent_cnt < size(reply->data,5))
   SELECT INTO "nl:"
    reg.event_id, reg.parent_event_id
    FROM cv_registry_event reg,
     (dummyt d  WITH seq = value(rec_cnt))
    PLAN (d
     WHERE (reply->data[d.seq].new_topmost_parent_event_id != reply->data[d.seq].
     topmost_parent_event_id))
     JOIN (reg
     WHERE (reg.event_id=reply->data[d.seq].new_topmost_parent_event_id))
    DETAIL
     IF ((reply->data[d.seq].new_topmost_parent_event_id=reg.parent_event_id))
      top_parent_cnt = (top_parent_cnt+ 1), reply->data[d.seq].topmost_parent_event_id = reply->data[
      d.seq].new_topmost_parent_event_id, reply->data[d.seq].new_topmost_parent_event_id = reg
      .parent_event_id
     ELSE
      reply->data[d.seq].topmost_parent_event_id = reply->data[d.seq].new_topmost_parent_event_id,
      reply->data[d.seq].new_topmost_parent_event_id = reg.parent_event_id, numparents = (size(reply
       ->data[d.seq].parents,5)+ 1),
      stat = alterlist(reply->data[d.seq].parents,numparents), reply->data[d.seq].parents[numparents]
      .parent_event_id = reg.parent_event_id
     ENDIF
    WITH nocounter
   ;end select
   CALL echo(build("The number of parents found::",top_parent_cnt))
   SET numloops = (numloops+ 1)
   IF (numloops > 10)
    SET top_parent_cnt = (size(reply->data,5)+ 1)
   ENDIF
 ENDWHILE
 IF ((request->dataset_mode_num=1))
  SET n = 0
  SET m = 0
  FOR (n = 1 TO rec_cnt)
    SET reply->data[n].person_id = internal->data[n].person_id
    SET reply->data[n].encntr_id = internal->data[n].encntr_id
    SET reply->data[n].event_cd = internal->data[n].event_cd
    SET reply->data[n].result_val = internal->data[n].result_val
    SET reply->data[n].result_status_cd = internal->data[n].result_status_cd
    SET reply->data[n].event_tag = internal->data[n].event_tag
    SET reply->data[n].event_id = internal->data[n].event_id
    SET reply->data[n].regis_dt_tm = internal->data[n].regis_dt_tm
    SET reply->data[n].disch_dt_tm = internal->data[n].disch_dt_tm
    SET reply->data[n].loc_facility_cd = internal->data[n].loc_facility_cd
    SET reply->data[n].nomenclature_id = internal->data[n].nomenclature_id
    SET reply->data[n].topmost_parent_event_id = internal->data[n].topmost_parent_event_id
    SET reply->data[n].topmost_parent_event_id = internal->data[n].new_topmost_parent_event_id
    FOR (m = 1 TO numparents)
      SET reply->data[n].parents[m].parent_event_id = internal->data[n].parents[m].parent_event_id
    ENDFOR
  ENDFOR
 ENDIF
#error_check
 IF (rec_cnt=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname =
  "Select data records from cv_xref/cv_registry_event/clinical_event"
  SET reply->status_data.subeventstatus[1].operationstatus = "A"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "REF_REG_ENCNTR_CLIN"
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 0
  GO TO end_of_prog
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  GO TO end_of_prog
 ENDIF
#select_check
 IF (select_ind=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT_TO_GET_HIERACHY"
  SET reply->status_data.subeventstatus[1].operationstatus = "C"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CV_REGISTRY_EVENT"
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 0
  GO TO end_of_prog
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#end_of_prog
 CALL echo(build("OperationStatus: ",reply->status_data.subeventstatus[1].operationstatus))
 CALL echo(build("status: ",reply->status_data.status))
END GO
