CREATE PROGRAM bed_get_eces_hier:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 event_sets[*]
      2 code_value = f8
      2 display = vc
      2 sequence = i4
      2 required_set_ind = i2
      2 all_results_ind = i2
      2 primitive_ind = i2
      2 display_association_ind = i2
      2 event_set_name = vc
      2 concept_cki = vc
      2 description = vc
    1 event_codes[*]
      2 code_value = f8
      2 display = vc
      2 inbound_aliases[*]
        3 alias = vc
      2 outbound_alias = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD tempreply(
   1 event_sets[*]
     2 code_value = f8
     2 display = vc
     2 sequence = i4
     2 required_set_ind = i2
     2 all_results_ind = i2
     2 primitive_ind = i2
     2 display_association_ind = i2
     2 event_set_name = vc
     2 concept_cki = vc
     2 description = vc
 ) WITH protect
 SET reply->status_data.status = "F"
 DECLARE parse_txt = vc
 DECLARE cnt = i4 WITH protect
 DECLARE all_result_sections = vc WITH protect, constant("ALL RESULT SECTIONS")
 DECLARE parent_ind = i2 WITH protect, noconstant(0)
 DECLARE is_in_hierarchy = i2 WITH protect, noconstant(0)
 DECLARE eset_parse = vc
 DECLARE comma_ind = i4 WITH protect, noconstant(0)
 SET cnt = 0
 DECLARE skip_all_results_ind = i4 WITH protect, noconstant(0)
 IF (validate(request->skip_all_results_ind))
  SET skip_all_results_ind = request->skip_all_results_ind
 ENDIF
 IF ((request->event_set_code_value > 0))
  SET parse_txt = build("v1.parent_event_set_cd = ",request->event_set_code_value)
 ELSE
  SELECT INTO "nl:"
   FROM v500_event_set_code ve
   WHERE ve.event_set_name_key="ALLOCFEVENTSETS"
    AND cnvtupper(ve.event_set_name)="ALL OCF EVENT SETS"
   DETAIL
    parse_txt = build("v1.parent_event_set_cd = ",ve.event_set_cd)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parse_txt = concat("not exists(select v2.parent_event_set_cd"," from v500_event_set_canon v2",
    " where v2.event_set_cd = v1.parent_event_set_cd)")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM v500_event_set_canon v1,
   v500_event_set_code ve,
   code_value cv
  PLAN (v1
   WHERE parser(parse_txt))
   JOIN (ve
   WHERE ve.event_set_cd=v1.event_set_cd)
   JOIN (cv
   WHERE cv.code_value=ve.event_set_cd)
  ORDER BY v1.event_set_cd
  HEAD REPORT
   cnt = 0, list_cnt = 0, stat = alterlist(tempreply->event_sets,10)
  HEAD v1.event_set_cd
   cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
   IF (list_cnt > 10)
    stat = alterlist(tempreply->event_sets,(cnt+ 10)), list_cnt = 1
   ENDIF
   tempreply->event_sets[cnt].code_value = v1.event_set_cd, tempreply->event_sets[cnt].display = ve
   .event_set_cd_disp, tempreply->event_sets[cnt].sequence = v1.event_set_collating_seq
   IF (ve.event_set_name IN ("ALL OCF EVENT SETS", "ALL RESULT SECTIONS", "ALL SPECIALTY SECTIONS",
   "ALL SERVICE SECTIONS", "ALL DOCUMENT SECTIONS",
   "OTHER RESULTS", "OTHER DOCUMENTS"))
    tempreply->event_sets[cnt].required_set_ind = 1, tempreply->event_sets[cnt].display = ve
    .event_set_name
   ELSE
    tempreply->event_sets[cnt].required_set_ind = 0, tempreply->event_sets[cnt].display = ve
    .event_set_cd_disp
   ENDIF
   tempreply->event_sets[cnt].display_association_ind = ve.display_association_ind, tempreply->
   event_sets[cnt].event_set_name = ve.event_set_name, tempreply->event_sets[cnt].concept_cki = cv
   .concept_cki,
   tempreply->event_sets[cnt].description = cv.description
  FOOT REPORT
   stat = alterlist(tempreply->event_sets,cnt)
  WITH nocounter, expand = 2
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt))
   PLAN (d)
   ORDER BY tempreply->event_sets[d.seq].sequence
   HEAD REPORT
    cnt = 0, stat = alterlist(reply->event_sets,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->event_sets,(cnt+ 9))
    ENDIF
    reply->event_sets[cnt].code_value = tempreply->event_sets[d.seq].code_value, reply->event_sets[
    cnt].display = tempreply->event_sets[d.seq].display, reply->event_sets[cnt].sequence = tempreply
    ->event_sets[d.seq].sequence,
    reply->event_sets[cnt].required_set_ind = tempreply->event_sets[d.seq].required_set_ind, reply->
    event_sets[cnt].display = tempreply->event_sets[d.seq].display, reply->event_sets[cnt].
    required_set_ind = tempreply->event_sets[d.seq].required_set_ind,
    reply->event_sets[cnt].display = tempreply->event_sets[d.seq].display, reply->event_sets[cnt].
    display_association_ind = tempreply->event_sets[d.seq].display_association_ind, reply->
    event_sets[cnt].event_set_name = tempreply->event_sets[d.seq].event_set_name,
    reply->event_sets[cnt].concept_cki = tempreply->event_sets[d.seq].concept_cki, reply->event_sets[
    cnt].description = tempreply->event_sets[d.seq].description
   FOOT REPORT
    stat = alterlist(reply->event_sets,cnt)
   WITH nocounter, expand = 2
  ;end select
 ENDIF
 IF (cnt=0)
  SELECT INTO "nl:"
   FROM v500_event_set_explode ves,
    v500_event_code vec
   PLAN (ves
    WHERE (ves.event_set_cd=request->event_set_code_value)
     AND ves.event_set_level=0)
    JOIN (vec
    WHERE vec.event_cd=ves.event_cd)
   HEAD REPORT
    cnt = 0, list_cnt = 0, stat = alterlist(reply->event_codes,10)
   DETAIL
    cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
    IF (list_cnt > 10)
     stat = alterlist(reply->event_codes,(cnt+ 10)), list_cnt = 1
    ENDIF
    reply->event_codes[cnt].code_value = ves.event_cd, reply->event_codes[cnt].display = vec
    .event_cd_disp
   FOOT REPORT
    stat = alterlist(reply->event_codes,cnt)
  ;end select
  DECLARE contributor_source_cd = f8 WITH protect, noconstant(0)
  IF (validate(request->contributor_source_code_value))
   SET contributor_source_cd = request->contributor_source_code_value
  ENDIF
  IF (contributor_source_cd > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = cnt),
     code_value_outbound cvo
    PLAN (d)
     JOIN (cvo
     WHERE (cvo.code_value=reply->event_codes[d.seq].code_value)
      AND cvo.contributor_source_cd=contributor_source_cd)
    DETAIL
     IF (cvo.alias > " ")
      reply->event_codes[d.seq].outbound_alias = cvo.alias
     ELSE
      reply->event_codes[d.seq].outbound_alias = "<space>"
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = cnt),
     code_value_alias cva
    PLAN (d)
     JOIN (cva
     WHERE (cva.code_value=reply->event_codes[d.seq].code_value)
      AND cva.contributor_source_cd=contributor_source_cd)
    ORDER BY d.seq
    HEAD d.seq
     in_cnt = 0
    DETAIL
     in_cnt = (in_cnt+ 1), stat = alterlist(reply->event_codes[d.seq].inbound_aliases,in_cnt), reply
     ->event_codes[d.seq].inbound_aliases[in_cnt].alias = cva.alias
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  IF (skip_all_results_ind=0)
   IF ((request->event_set_code_value=0.0))
    FOR (cnt = 1 TO size(reply->event_sets,5))
      IF (cnvtupper(reply->event_sets[cnt].display)=all_result_sections)
       SET reply->event_sets[cnt].all_results_ind = 1
       SET cnt = size(reply->event_sets,5)
      ENDIF
    ENDFOR
   ELSE
    SET parent_ind = 1
    SET eset_parse = build("vec.event_set_cd IN (",request->event_set_code_value,")")
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
        parent_ind = 1
        IF (comma_ind=0)
         eset_parse = build(eset_parse,vec.parent_event_set_cd), comma_ind = 1
        ELSE
         eset_parse = build(eset_parse,",",vec.parent_event_set_cd)
        ENDIF
        IF (vsc.event_set_name=all_result_sections)
         parent_ind = 0, is_in_hierarchy = 1
        ENDIF
       WITH nocounter
      ;end select
      SET eset_parse = concat(eset_parse,")")
    ENDWHILE
   ENDIF
  ENDIF
  IF (is_in_hierarchy=1)
   FOR (x = 1 TO size(reply->event_sets,5))
     SET reply->event_sets[x].all_results_ind = 1
   ENDFOR
  ENDIF
  SELECT INTO "nl:"
   FROM v500_event_set_explode ve,
    (dummyt d  WITH seq = value(size(reply->event_sets,5)))
   PLAN (d)
    JOIN (ve
    WHERE (ve.event_set_cd=reply->event_sets[d.seq].code_value)
     AND ve.event_set_level=0)
   ORDER BY d.seq
   HEAD d.seq
    reply->event_sets[d.seq].primitive_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
