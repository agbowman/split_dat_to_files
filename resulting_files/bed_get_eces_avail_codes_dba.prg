CREATE PROGRAM bed_get_eces_avail_codes:dba
 FREE SET reply
 RECORD reply(
   1 event_codes[*]
     2 code_value = f8
     2 display = vc
     2 event_set_code_value = f8
     2 definition = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_codes
 RECORD temp_codes(
   1 event_codes[*]
     2 code_value = f8
     2 display = vc
     2 event_set_code_value = f8
     2 used_ind = i2
     2 definition = vc
 )
 SET reply->status_data.status = "F"
 SET glb_cat_code_value = 0.0
 SET rad_cat_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning IN ("GENERAL LAB", "RADIOLOGY")
   AND cv.code_set=6000
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="GENERAL LAB")
    glb_cat_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="RADIOLOGY")
    rad_cat_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET ap_act_code_value = 0.0
 SET glb_act_code_value = 0.0
 SET micro_act_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cnvtupper(cv.definition)="GENERAL LAB"
   AND cv.cdf_meaning IN ("AP", "GLB", "MICROBIOLOGY")
   AND cv.code_set=106
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="AP")
    ap_act_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="GLB")
    glb_act_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="MICROBIOLOGY")
    micro_act_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET rad_act_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cnvtupper(cv.definition)="RADIOLOGY"
   AND cv.cdf_meaning="RADIOLOGY"
   AND cv.code_set=106
   AND cv.active_ind=1
  DETAIL
   rad_act_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET search_cnt = size(request->searches,5)
 FOR (x = 1 TO search_cnt)
   DECLARE vec_parse = vc
   DECLARE search_string = vc
   IF ((request->search_type_flag="S"))
    SET search_string = concat('"',trim(cnvtupper(cnvtalphanum(request->searches[x].search_string))),
     '*"')
    SET search_string = cnvtupper(search_string)
    SET vec_parse = concat("vec.event_cd_disp_key = ",search_string)
   ELSEIF ((request->search_type_flag="C"))
    SET search_string = concat('"*',trim(cnvtupper(cnvtalphanum(request->searches[x].search_string))),
     '*"')
    SET search_string = cnvtupper(search_string)
    SET vec_parse = concat("vec.event_cd_disp_key = ",search_string)
   ELSEIF ((request->search_type_flag="E"))
    SET search_string = concat('"',trim(cnvtupper(cnvtalphanum(request->searches[x].search_string))),
     '"')
    SET search_string = cnvtupper(search_string)
    SET vec_parse = concat("vec.event_cd_disp_key = ",search_string," and ",' vec.event_cd_disp = "',
     request->searches[x].search_string,
     '"')
   ENDIF
   SELECT INTO "nl:"
    FROM v500_event_code vec,
     code_value cv
    PLAN (vec
     WHERE parser(vec_parse))
     JOIN (cv
     WHERE cv.code_value=vec.event_cd
      AND cv.code_set=72
      AND cv.active_ind=1)
    HEAD REPORT
     cnt = 0, tot_cnt = size(temp_codes->event_codes,5), stat = alterlist(temp_codes->event_codes,(
      tot_cnt+ 100))
    DETAIL
     cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
     IF (cnt > 100)
      stat = alterlist(temp_codes->event_codes,(tot_cnt+ 100)), cnt = 1
     ENDIF
     temp_codes->event_codes[tot_cnt].code_value = vec.event_cd, temp_codes->event_codes[tot_cnt].
     display = vec.event_cd_disp, temp_codes->event_codes[tot_cnt].definition = vec
     .event_cd_definition
    FOOT REPORT
     stat = alterlist(temp_codes->event_codes,tot_cnt)
    WITH nocounter
   ;end select
 ENDFOR
 SET xcnt = size(temp_codes->event_codes,5)
 IF (xcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = xcnt),
    code_value_event_r cver
   PLAN (d
    WHERE (temp_codes->event_codes[d.seq].used_ind=0))
    JOIN (cver
    WHERE (cver.event_cd=temp_codes->event_codes[d.seq].code_value))
   ORDER BY d.seq
   DETAIL
    temp_codes->event_codes[d.seq].used_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = xcnt),
    discrete_task_assay dta
   PLAN (d
    WHERE (temp_codes->event_codes[d.seq].used_ind=0))
    JOIN (dta
    WHERE (dta.event_cd=temp_codes->event_codes[d.seq].code_value)
     AND dta.active_ind=1)
   ORDER BY d.seq
   DETAIL
    temp_codes->event_codes[d.seq].used_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = xcnt),
    dcp_forms_ref dfr
   PLAN (d
    WHERE (temp_codes->event_codes[d.seq].used_ind=0))
    JOIN (dfr
    WHERE (dfr.event_cd=temp_codes->event_codes[d.seq].code_value)
     AND dfr.active_ind=1)
   ORDER BY d.seq
   DETAIL
    temp_codes->event_codes[d.seq].used_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = xcnt),
    input_form_reference ifr
   PLAN (d
    WHERE (temp_codes->event_codes[d.seq].used_ind=0))
    JOIN (ifr
    WHERE (ifr.event_cd=temp_codes->event_codes[d.seq].code_value)
     AND ifr.active_ind=1)
   ORDER BY d.seq
   DETAIL
    temp_codes->event_codes[d.seq].used_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = xcnt),
    note_type nt
   PLAN (d
    WHERE (temp_codes->event_codes[d.seq].used_ind=0))
    JOIN (nt
    WHERE (nt.event_cd=temp_codes->event_codes[d.seq].code_value))
   ORDER BY d.seq
   DETAIL
    temp_codes->event_codes[d.seq].used_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = xcnt),
    name_value_prefs nvp
   PLAN (d
    WHERE (temp_codes->event_codes[d.seq].used_ind=0))
    JOIN (nvp
    WHERE nvp.pvc_name IN ("grid_event_cd", "row_event_cd")
     AND (nvp.merge_id=temp_codes->event_codes[d.seq].code_value)
     AND nvp.active_ind=1)
   ORDER BY d.seq
   DETAIL
    temp_codes->event_codes[d.seq].used_ind = 1
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->event_codes,xcnt)
  SET cnt = 0
  FOR (x = 1 TO xcnt)
    IF ((temp_codes->event_codes[x].used_ind=0))
     SET cnt = (cnt+ 1)
     SET reply->event_codes[cnt].code_value = temp_codes->event_codes[x].code_value
     SET reply->event_codes[cnt].display = temp_codes->event_codes[x].display
     SET reply->event_codes[cnt].definition = temp_codes->event_codes[x].definition
    ENDIF
  ENDFOR
  SET stat = alterlist(reply->event_codes,cnt)
 ENDIF
 SET rcnt = size(reply->event_codes,5)
 IF ((rcnt > request->max_reply)
  AND (request->max_reply > 0))
  GO TO exit_script
 ENDIF
 IF (rcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = rcnt),
    v500_event_set_explode ve
   PLAN (d)
    JOIN (ve
    WHERE (ve.event_cd=reply->event_codes[d.seq].code_value)
     AND ((ve.event_set_level+ 0)=0))
   ORDER BY d.seq
   DETAIL
    reply->event_codes[d.seq].event_set_code_value = ve.event_set_cd
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF ((rcnt > request->max_reply)
  AND (request->max_reply > 0))
  SET reply->too_many_results_ind = 1
  SET stat = alterlist(reply->event_codes,0)
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
