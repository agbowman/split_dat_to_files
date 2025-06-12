CREATE PROGRAM cpm_chk_ref_lab:dba
 RECORD reflab(
   1 details[1]
     2 found_match_ind = i2
     2 ref_lab_ind = i2
     2 ref_lab_description = vc
 )
 SET location_cd = 0.0
 SET organization_id = 0.0
 SET ref_lab_description = "NONE"
 SET ref_lab_flag = 0
 SET stat = alter(reflab->details,elcnt2)
 SET compression_cd = 0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SELECT INTO "nl:"
  e.organization_id
  FROM encounter e
  WHERE (e.encntr_id=requestin->request.orders[ordcnt].encntr_id)
  HEAD REPORT
   location_cd = e.loc_facility_cd, organization_id = e.organization_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("unable to find encounter for patient")
  GO TO exit_ref_lab
 ENDIF
 SELECT INTO "nl:"
  o.ref_lab_ind
  FROM organization_resource o,
   (dummyt d  WITH seq = value(elcnt2))
  PLAN (d)
   JOIN (o
   WHERE (o.service_resource_cd=requestin->request.orders[ordcnt].assays[d.seq].service_resource_cd)
    AND o.parent_entity_name="LOCATION"
    AND o.parent_entity_id=location_cd
    AND o.active_ind=1)
  DETAIL
   IF (ref_lab_flag != 2
    AND o.ref_lab_ind=1
    AND ((ref_lab_description="NONE") OR (ref_lab_description=o.ref_lab_description)) )
    ref_lab_flag = 1
   ELSEIF (ref_lab_flag != 2
    AND o.ref_lab_ind=1)
    ref_lab_flag = 2
   ENDIF
   ref_lab_description = o.ref_lab_description, reflab->details[d.seq].ref_lab_ind = o.ref_lab_ind,
   reflab->details[d.seq].ref_lab_description = o.ref_lab_description,
   reflab->details[d.seq].found_match_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  o.ref_lab_ind
  FROM organization_resource o,
   (dummyt d  WITH seq = value(elcnt2))
  PLAN (d
   WHERE (reflab->details[d.seq].found_match_ind != 1))
   JOIN (o
   WHERE (o.service_resource_cd=requestin->request.orders[ordcnt].assays[d.seq].service_resource_cd)
    AND o.parent_entity_name="ORGANIZATION"
    AND o.parent_entity_id=organization_id
    AND o.active_ind=1)
  DETAIL
   IF (ref_lab_flag != 2
    AND o.ref_lab_ind=1
    AND ((ref_lab_description="NONE") OR (ref_lab_description=o.ref_lab_description)) )
    ref_lab_flag = 1
   ELSEIF (ref_lab_flag != 2
    AND o.ref_lab_ind=1)
    ref_lab_flag = 2
   ENDIF
   ref_lab_description = o.ref_lab_description, reflab->details[d.seq].ref_lab_ind = o.ref_lab_ind,
   reflab->details[d.seq].ref_lab_description = o.ref_lab_description,
   reflab->details[d.seq].found_match_ind = 1
  WITH nocounter
 ;end select
#exit_ref_lab
 IF (ref_lab_flag=1)
  SET ref_lab_flag = 2
 ENDIF
 SET all_ref = "T"
 FOR (idx = 1 TO elcnt2)
   IF ((reflab->details[idx].ref_lab_ind != 1))
    SET all_ref = "F"
    GO TO chk_done
   ENDIF
 ENDFOR
#chk_done
 IF (all_ref="T")
  SET cd->expedite_ind = 0
 ENDIF
 IF (ref_lab_flag != 0)
  SET code_set = 14
  SET cdf_meaning = "REF LAB"
  EXECUTE cpm_get_cd_for_cdf
  SET note_type_cd = code_value
  SET code_set = 120
  SET cdf_meaning = "NOCOMP"
  EXECUTE cpm_get_cd_for_cdf
  SET compression_cd = code_value
 ENDIF
 IF (ref_lab_flag=1)
  SET rfcnt = (requestin->request.orders[ordcnt].assays[elcnt].result_comment_cnt+ 1)
  SET stat = alterlist(replyout->clin_event.event_note_list,rfcnt)
  SET replyout->clin_event.subtable_bit_map = bor(replyout->clin_event.subtable_bit_map,2)
  SET replyout->clin_event.event_note_list[rfcnt].valid_until_dt_tm = cnvtdatetime("31-dec-2100")
  SET replyout->clin_event.event_note_list[rfcnt].valid_until_dt_tm_ind = 0
  SET replyout->clin_event.event_note_list[rfcnt].note_type_cd = note_type_cd
  SET replyout->clin_event.event_note_list[rfcnt].valid_from_dt_tm = cnvtdatetime(curdate,curtime3)
  SET replyout->clin_event.event_note_list[rfcnt].valid_from_dt_tm_ind = 0
  SET replyout->clin_event.event_note_list[rfcnt].long_blob = ref_lab_description
  SET replyout->clin_event.event_note_list[rfcnt].note_dt_tm = cnvtdatetime(curdate,curtime3)
  SET replyout->clin_event.event_note_list[rfcnt].note_dt_tm_ind = 0
  SET replyout->clin_event.event_note_list[rfcnt].note_prsnl_id = requestin->request.orders[ordcnt].
  assays[1].perform_personnel_id
  SET replyout->clin_event.event_note_list[rfcnt].record_status_cd = reqdata->active_status_cd
  SET replyout->clin_event.event_note_list[rfcnt].entry_method_cd = cd->entry_method_cd
  SET replyout->clin_event.event_note_list[rfcnt].note_format_cd = cd->blob_format_cd
  SET replyout->clin_event.event_note_list[rfcnt].checksum_ind = 1
  SET replyout->clin_event.event_note_list[rfcnt].compression_cd = compression_cd
  SET replyout->clin_event.event_note_list[rfcnt].checksum = 111
 ELSEIF (ref_lab_flag=2)
  FOR (rfidx = 1 TO elcnt2)
    IF ((reflab->details[rfidx].ref_lab_ind=1))
     SET rfcnt = (requestin->request.orders[ordcnt].assays[rfidx].result_comment_cnt+ 1)
     SET stat = alterlist(replyout->clin_event.child_event_list[rfidx].event_note_list,rfcnt)
     SET replyout->clin_event.child_event_list[rfidx].subtable_bit_map = bor(replyout->clin_event.
      child_event_list[rfidx].subtable_bit_map,2)
     SET replyout->clin_event.child_event_list[rfidx].event_note_list[rfcnt].valid_until_dt_tm =
     cnvtdatetime("31-dec-2100")
     SET replyout->clin_event.child_event_list[rfidx].event_note_list[rfcnt].valid_until_dt_tm_ind =
     0
     SET replyout->clin_event.child_event_list[rfidx].event_note_list[rfcnt].note_type_cd =
     note_type_cd
     SET replyout->clin_event.child_event_list[rfidx].event_note_list[rfcnt].valid_from_dt_tm =
     cnvtdatetime(curdate,curtime3)
     SET replyout->clin_event.child_event_list[rfidx].event_note_list[rfcnt].valid_from_dt_tm_ind = 0
     SET replyout->clin_event.child_event_list[rfidx].event_note_list[rfcnt].long_blob = reflab->
     details[rfcnt].ref_lab_description
     SET replyout->clin_event.child_event_list[rfidx].event_note_list[rfcnt].note_dt_tm =
     cnvtdatetime(curdate,curtime3)
     SET replyout->clin_event.child_event_list[rfidx].event_note_list[rfcnt].note_dt_tm_ind = 0
     SET replyout->clin_event.child_event_list[rfidx].event_note_list[rfcnt].note_prsnl_id =
     requestin->request.orders[ordcnt].assays[elcnt].perform_personnel_id
     SET replyout->clin_event.child_event_list[rfidx].event_note_list[rfcnt].record_status_cd =
     reqdata->active_status_cd
     SET replyout->clin_event.child_event_list[rfidx].event_note_list[rfcnt].entry_method_cd = cd->
     entry_method_cd
     SET replyout->clin_event.child_event_list[rfidx].event_note_list[rfcnt].note_format_cd = cd->
     blob_format_cd
     SET replyout->clin_event.child_event_list[rfidx].event_note_list[rfcnt].checksum_ind = 1
     SET replyout->clin_event.child_event_list[rfidx].event_note_list[rfcnt].compression_cd =
     compression_cd
    ENDIF
  ENDFOR
 ENDIF
END GO
