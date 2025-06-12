CREATE PROGRAM bed_get_docset_sections:dba
 FREE SET reply
 RECORD reply(
   1 doc_set_sections[*]
     2 doc_set_section_ref_id = f8
     2 name = vc
     2 description = vc
     2 active_ind = i2
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE ds_parse = vc
 IF ((request->search_string > " "))
  IF (cnvtupper(request->search_type_flag)="C")
   SET ds_parse = concat("d.doc_set_section_name_key = '*",cnvtupper(request->search_string),
    "*' and ")
  ELSE
   SET ds_parse = concat("d.doc_set_section_name_key = '",cnvtupper(request->search_string),"*' and "
    )
  ENDIF
 ENDIF
 IF ((request->inactive_ind=0))
  SET ds_parse = concat(ds_parse," d.active_ind = 1 and ")
 ENDIF
 SET ds_parse = concat(ds_parse," d.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) ",
  " and d.end_effective_dt_tm > cnvtdatetime(curdate,curtime3) ",
  " and d.prev_doc_set_section_ref_id = d.doc_set_section_ref_id",
  " and d.doc_set_section_description > ' '")
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM doc_set_section_ref d
  PLAN (d
   WHERE parser(ds_parse))
  ORDER BY d.doc_set_section_ref_id
  HEAD REPORT
   tcnt = 0, cnt = 0, stat = alterlist(reply->doc_set_sections,100)
  HEAD d.doc_set_section_ref_id
   tcnt = (tcnt+ 1), cnt = (cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->doc_set_sections,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->doc_set_sections[tcnt].doc_set_section_ref_id = d.doc_set_section_ref_id, reply->
   doc_set_sections[tcnt].name = d.doc_set_section_name, reply->doc_set_sections[tcnt].description =
   d.doc_set_section_description,
   reply->doc_set_sections[tcnt].active_ind = d.active_ind
  FOOT REPORT
   stat = alterlist(reply->doc_set_sections,tcnt)
  WITH nocounter
 ;end select
 IF ((tcnt > request->max_reply)
  AND (request->max_reply > 0))
  SET stat = alterlist(reply->doc_set_sections,0)
  SET reply->too_many_results_ind = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
