CREATE PROGRAM bed_get_pwrform_forms:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 forms[*]
      2 dcp_forms_ref_id = f8
      2 description = vc
      2 name = vc
      2 display = vc
      2 enforce_required_ind = i2
      2 done_charting_ind = i2
      2 event_set_name = vc
      2 event_cd = f8
      2 event_cd_display = vc
      2 text_rendition_event_cd = f8
      2 note_type_display = vc
      2 event_cd_meaning = vc
      2 note_type_meaning = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET cnt = 0
 DECLARE parse_txt = vc
 SET max_rep = 0
 IF (validate(request->max_reply))
  SET max_rep = request->max_reply
 ENDIF
 IF ((request->description > " "))
  SET parse_txt = concat(parse_txt,' cnvtupper(f.definition) = "',cnvtupper(request->description),
   '" and ')
 ENDIF
 IF (validate(request->search_type_flag))
  IF (cnvtupper(request->search_type_flag)="S"
   AND (request->description > " "))
   SET parse_txt = concat(' cnvtupper(f.definition) = "',cnvtupper(request->description),'*" and ')
  ELSEIF (cnvtupper(request->search_type_flag)="C"
   AND (request->description > " "))
   SET parse_txt = concat(' cnvtupper(f.definition) = "*',cnvtupper(request->description),'*" and ')
  ENDIF
 ENDIF
 SET parse_txt = concat(parse_txt," f.active_ind = 1")
 SELECT INTO "nl:"
  FROM dcp_forms_ref f
  WHERE parser(parse_txt)
  ORDER BY f.definition
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->forms,cnt), reply->forms[cnt].dcp_forms_ref_id = f
   .dcp_forms_ref_id,
   reply->forms[cnt].description = f.definition, reply->forms[cnt].name = f.description, reply->
   forms[cnt].display = f.definition
   IF (((f.flags=1) OR (f.flags=3)) )
    reply->forms[cnt].enforce_required_ind = 1
   ELSE
    reply->forms[cnt].enforce_required_ind = 0
   ENDIF
   IF (((f.flags=2) OR (f.flags=3)) )
    reply->forms[cnt].done_charting_ind = 1
   ELSE
    reply->forms[cnt].done_charting_ind = 0
   ENDIF
   reply->forms[cnt].event_set_name = f.event_set_name, reply->forms[cnt].event_cd = f.event_cd,
   reply->forms[cnt].event_cd_display = uar_get_code_display(f.event_cd),
   reply->forms[cnt].text_rendition_event_cd = f.text_rendition_event_cd, reply->forms[cnt].
   note_type_display = uar_get_code_display(f.text_rendition_event_cd), reply->forms[cnt].
   event_cd_meaning = uar_get_code_meaning(f.event_cd),
   reply->forms[cnt].note_type_meaning = uar_get_code_meaning(f.text_rendition_event_cd)
  WITH nocounter
 ;end select
 IF (cnt > max_rep
  AND max_rep > 0)
  SET stat = alterlist(reply->forms,0)
  SET reply->too_many_results_ind = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
 CALL echo(parse_txt)
END GO
