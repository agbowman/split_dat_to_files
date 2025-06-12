CREATE PROGRAM bed_get_eces_hier_by_act:dba
 FREE SET reply
 RECORD reply(
   1 parents[*]
     2 code_value = f8
     2 display = vc
     2 level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_hier
 RECORD temp_hier(
   1 event_hier[*]
     2 code_value = f8
     2 child_code = f8
     2 display = vc
 )
 SET reply->status_data.status = "F"
 DECLARE parse_txt = vc
 SET cnt = 0
 SET event_set_code_value = 0.0
 IF ((request->activity_type_mean IN ("GLB", "AP", "HLA", "BB", "MICROBIOLOGY")))
  SET parse_txt = "v.event_set_name_key = 'LABORATORY'"
 ELSEIF ((request->activity_type_mean IN ("RADIOLOGY")))
  SET parse_txt = "v.event_set_name_key = 'RADIOLOGY'"
 ELSEIF ((request->activity_type_mean IN ("NURS")))
  SET parse_txt = "v.event_set_name_key = 'ALLSERVICESECTIONS'"
 ELSEIF ((request->activity_type_mean IN ("NURS2")))
  SET parse_txt = "v.event_set_name_key = 'ALLDOCUMENTSECTIONS'"
 ENDIF
 IF ((request->event_set_code_value > 0))
  SET event_set_code_value = request->event_set_code_value
 ENDIF
 IF (event_set_code_value=0)
  SELECT INTO "nl:"
   FROM v500_event_set_code v
   WHERE parser(parse_txt)
   DETAIL
    event_set_code_value = v.event_set_cd
   WITH nocounter
  ;end select
 ENDIF
 SET hier_code_value = 0.0
 SELECT INTO "nl:"
  FROM v500_event_set_code vec
  WHERE vec.event_set_name="ALL RESULT SECTIONS"
  DETAIL
   hier_code_value = vec.event_set_cd
  WITH nocounter
 ;end select
 IF (event_set_code_value > 0)
  DECLARE eset_parse = vc
  SET stat = alterlist(temp_hier->event_hier,10)
  SET temp_hier->event_hier[1].code_value = event_set_code_value
  SET eset_parse = build("vec.event_set_cd IN (",event_set_code_value,")")
  SET parent_ind = 1
  SET list_cnt = 1
  SET tot_cnt = 1
  WHILE (parent_ind=1)
    SET parent_ind = 0
    SELECT INTO "nl:"
     FROM v500_event_set_canon vec,
      v500_event_set_code vsc
     PLAN (vec
      WHERE parser(eset_parse))
      JOIN (vsc
      WHERE vsc.event_set_cd=vec.event_set_cd)
     ORDER BY vec.parent_event_set_cd
     HEAD REPORT
      eset_parse = "vec.event_set_cd IN (", comma_ind = 0
     DETAIL
      list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (tot_cnt > 10)
       stat = alterlist(temp_hier->event_hier,(list_cnt+ 10)), tot_cnt = 1
      ENDIF
      temp_hier->event_hier[list_cnt].code_value = vec.parent_event_set_cd, temp_hier->event_hier[
      list_cnt].child_code = vec.event_set_cd
      IF (vsc.event_set_name IN ("ALL OCF EVENT SETS", "ALL RESULT SECTIONS",
      "ALL SPECIALTY SECTIONS", "ALL SERVICE SECTIONS", "ALL DOCUMENT SECTIONS",
      "OTHER RESULTS", "OTHER DOCUMENTS"))
       temp_hier->event_hier[list_cnt].display = vsc.event_set_name
      ELSE
       temp_hier->event_hier[list_cnt].display = vsc.event_set_cd_disp
      ENDIF
      IF (comma_ind=0)
       eset_parse = build(eset_parse,vec.parent_event_set_cd), comma_ind = 1
      ELSE
       eset_parse = build(eset_parse,",",vec.parent_event_set_cd)
      ENDIF
      parent_ind = 1
     WITH nocounter
    ;end select
    SET eset_parse = concat(eset_parse,")")
  ENDWHILE
  SET stat = alterlist(temp_hier->event_hier,list_cnt)
  IF (size(temp_hier->event_hier,5) > 0)
   SET cnt = 0
   SET level = 0
   SET parent_ind = 1
   WHILE (hier_code_value != event_set_code_value
    AND parent_ind=1)
     SET level = (level+ 1)
     SET parent_ind = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = size(temp_hier->event_hier,5)),
       v500_event_set_code vc
      PLAN (d
       WHERE (temp_hier->event_hier[d.seq].code_value=hier_code_value))
       JOIN (vc
       WHERE (vc.event_set_cd=temp_hier->event_hier[d.seq].code_value))
      ORDER BY d.seq
      HEAD REPORT
       cnt = size(reply->parents,5), tot_cnt = 0, stat = alterlist(reply->parents,(list_cnt+ 10))
      DETAIL
       cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
       IF (tot_cnt > 10)
        stat = alterlist(reply->parents,(cnt+ 10)), tot_cnt = 1
       ENDIF
       reply->parents[cnt].code_value = temp_hier->event_hier[d.seq].child_code, reply->parents[cnt].
       level = level, reply->parents[cnt].display = temp_hier->event_hier[d.seq].display,
       parent_ind = 1, hier_code_value = temp_hier->event_hier[d.seq].child_code
      FOOT REPORT
       stat = alterlist(reply->parents,cnt)
      WITH nocounter
     ;end select
   ENDWHILE
  ENDIF
 ENDIF
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
