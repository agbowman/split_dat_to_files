CREATE PROGRAM dcp_get_forms_activity_ids:dba
 IF ( NOT (validate(reply,0)))
  CALL echo("reply not defined")
  RECORD reply(
    1 qual[*]
      2 event_id = f8
      2 dcp_forms_activity_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET cnt = size(request->qual,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->qual,cnt)
 SET code_set = 18189
 SET code_value = 0
 SET cdf_meaning = "CLINCALEVENT"
 EXECUTE cpm_get_cd_for_cdf
 SET compcd_clincalevent = code_value
 SET code_value = 0
 SET cdf_meaning = "TEXTREND"
 EXECUTE cpm_get_cd_for_cdf
 SET compcd_textrend = code_value
 SET replycnt = 0
 RECORD query_ids(
   1 qual[*]
     2 event_id = f8
     2 comp_cd = f8
 )
 SET stat = alterlist(query_ids->qual,cnt)
 FOR (i = 1 TO cnt)
   SET query_ids->qual[i].event_id = request->qual[i].primary_event_id
   SET query_ids->qual[i].comp_cd = compcd_clincalevent
   IF ((query_ids->qual[i].event_id=0))
    SET query_ids->qual[i].event_id = request->qual[i].document_event_id
    SET query_ids->qual[i].comp_cd = compcd_textrend
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   dcp_forms_activity_comp c
  PLAN (d)
   JOIN (c
   WHERE (c.parent_entity_id=query_ids->qual[d.seq].event_id)
    AND (c.component_cd=query_ids->qual[d.seq].comp_cd))
  DETAIL
   reply->qual[d.seq].dcp_forms_activity_id = c.dcp_forms_activity_id, reply->qual[d.seq].event_id =
   query_ids->qual[d.seq].event_id, replycnt = (replycnt+ 1)
  WITH nocounter, maxqual(c,1)
 ;end select
 IF (replycnt != cnt)
  SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_get_form_activity_id"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Wrong Number of ActivityIds found"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 FREE RECORD query_ids
END GO
