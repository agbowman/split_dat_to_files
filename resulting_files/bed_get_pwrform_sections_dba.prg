CREATE PROGRAM bed_get_pwrform_sections:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 sections[*]
      2 dcp_section_ref_id = f8
      2 description = vc
      2 width = i4
      2 height = i4
      2 sequence = i4
      2 name = vc
      2 display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
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
  SET parse_txt = concat(parse_txt,' cnvtupper(s.definition) = "',cnvtupper(request->description),
   '" and ')
 ENDIF
 IF (validate(request->search_type_flag))
  IF (cnvtupper(request->search_type_flag)="S"
   AND (request->description > " "))
   SET parse_txt = concat(' cnvtupper(s.definition) = "',cnvtupper(request->description),'*" and ')
  ELSEIF (cnvtupper(request->search_type_flag)="C"
   AND (request->description > " "))
   SET parse_txt = concat(' cnvtupper(s.definition) = "*',cnvtupper(request->description),'*" and ')
  ENDIF
 ENDIF
 SET parse_txt = concat(parse_txt," s.active_ind = 1")
 IF ((request->dcp_forms_ref_id > 0))
  SELECT INTO "nl:"
   FROM dcp_forms_ref f,
    dcp_forms_def d,
    dcp_section_ref s
   PLAN (f
    WHERE (f.dcp_forms_ref_id=request->dcp_forms_ref_id)
     AND f.active_ind=1)
    JOIN (d
    WHERE d.dcp_form_instance_id=f.dcp_form_instance_id
     AND d.active_ind=1)
    JOIN (s
    WHERE s.dcp_section_ref_id=d.dcp_section_ref_id
     AND s.active_ind=1)
   ORDER BY d.section_seq
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->sections,cnt), reply->sections[cnt].dcp_section_ref_id =
    s.dcp_section_ref_id,
    reply->sections[cnt].description = s.definition, reply->sections[cnt].width = s.width, reply->
    sections[cnt].height = s.height,
    reply->sections[cnt].sequence = d.section_seq, reply->sections[cnt].name = s.description, reply->
    sections[cnt].display = s.definition
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM dcp_section_ref s
   PLAN (s
    WHERE parser(parse_txt))
   ORDER BY s.definition
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->sections,cnt), reply->sections[cnt].dcp_section_ref_id =
    s.dcp_section_ref_id,
    reply->sections[cnt].description = s.definition, reply->sections[cnt].width = s.width, reply->
    sections[cnt].height = s.height,
    reply->sections[cnt].name = s.description, reply->sections[cnt].display = s.definition
   WITH nocounter
  ;end select
 ENDIF
 IF (cnt > max_rep
  AND max_rep > 0)
  SET stat = alterlist(reply->sections,0)
  SET reply->too_many_results_ind = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
