CREATE PROGRAM bed_get_pwr_related_results:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 event_sets[*]
      2 event_set_name = vc
      2 event_set_code_value = f8
      2 event_set_display = vc
      2 sequence = i4
      2 pw_evidence_reltn_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET ecnt = 0
 SELECT INTO "nl:"
  FROM pw_evidence_reltn p,
   v500_event_set_code v
  PLAN (p
   WHERE (p.pathway_catalog_id=request->powerplan_or_phase_id)
    AND p.type_mean="EVENTSET")
   JOIN (v
   WHERE v.event_set_name=p.evidence_locator)
  ORDER BY p.evidence_sequence
  DETAIL
   ecnt = (ecnt+ 1), stat = alterlist(reply->event_sets,ecnt), reply->event_sets[ecnt].event_set_name
    = p.evidence_locator,
   reply->event_sets[ecnt].event_set_code_value = v.event_set_cd, reply->event_sets[ecnt].
   event_set_display = v.event_set_cd_disp, reply->event_sets[ecnt].sequence = p.evidence_sequence,
   reply->event_sets[ecnt].pw_evidence_reltn_id = p.pw_evidence_reltn_id
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
