CREATE PROGRAM bhs_athn_updt_crossing_cmt
 RECORD t_record(
   1 beg_dt_tm = dq8
   1 event_set_cnt = i4
   1 event_sets[*]
     2 event_set = vc
     2 group = vc
   1 group_cnt = i4
   1 group[*]
     2 group_name = vc
     2 long_text = vc
   1 element_cnt = i4
   1 elements[*]
     2 type = vc
     2 tag_key = vc
     2 event_id = f8
     2 event_end_dt_tm = dq8
     2 title = vc
     2 when = vc
     2 author = vc
     2 include = i2
     2 comment = vc
     2 last_updated = vc
     2 last_updated_by = vc
   1 t_element_cnt = i4
   1 t_elements[*]
     2 type = vc
     2 tag_key = vc
     2 event_id = f8
     2 event_end_dt_tm = dq8
     2 title = vc
     2 when = vc
     2 author = vc
     2 include = i2
     2 comment = vc
     2 last_updated = vc
     2 last_updated_by = vc
 )
 RECORD e_request(
   1 blob = vc
   1 url_source_ind = i2
 )
 RECORD e_reply(
   1 blob = vc
 )
 RECORD t_request(
   1 param = vc
 )
 RECORD t_reply(
   1 param = vc
 )
 RECORD out_rec(
   1 elements[*]
     2 type = vc
     2 tag_key = vc
     2 event_id = vc
     2 event_end_dt_tm = vc
     2 title = vc
     2 when = vc
     2 author = vc
     2 include = vc
     2 comment = vc
     2 last_updated = vc
     2 last_updated_by = vc
   1 consult_string = vc
   1 image_string = vc
   1 micro_string = vc
   1 procedure_string = vc
 )
 RECORD oreply(
   1 status = vc
 )
 DECLARE e_cnt = i4
 DECLARE t_line = vc
 DECLARE t_line1 = vc
 DECLARE str = vc
 DECLARE not_found = vc
 SET not_found = "<not_found>"
 DECLARE num = i4
 DECLARE data = vc
 DECLARE pos = i4
 DECLARE pos1 = i4
 DECLARE cmt_tag = vc
 DECLARE json_string = vc
 DECLARE indx = i4
 DECLARE prsnl_string = vc
 DECLARE c_line = vc
 DECLARE i_line = vc
 DECLARE m_line = vc
 DECLARE p_line = vc
 DECLARE c_found_ind = i2
 DECLARE i_found_ind = i2
 DECLARE m_found_ind = i2
 DECLARE p_found_ind = i2
 DECLARE username = vc
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id= $3)
    AND p.active_ind=1)
  HEAD p.person_id
   username = p.username, prsnl_string = p.name_full_formatted
  WITH nocounter, time = 30
 ;end select
 SET namelen = (textlen(username)+ 1)
 SET domainnamelen = (textlen(curdomain)+ 2)
 SET statval = memalloc(name,1,build("C",namelen))
 SET statval = memalloc(domainname,1,build("C",domainnamelen))
 SET name = username
 SET domainname = curdomain
 SET setcntxt = uar_secimpersonate(nullterm(username),nullterm(domainname))
 DECLARE t_file = vc
 DECLARE t_blob = vc
 DECLARE dclcom = vc
 IF (( $7=1))
  SET t_blob =  $10
 ELSE
  IF (( $6 !=  $7))
   EXECUTE bhs_athn_add_doc_segment "mine",  $8,  $6,
    $10, "", ""
   GO TO exit_script
  ENDIF
  IF (( $6= $7))
   SELECT INTO "nl:"
    FROM bhs_athn_doc_segment ds
    PLAN (ds
     WHERE (ds.uuid= $8))
    ORDER BY ds.segment_seq
    HEAD ds.segment_seq
     t_blob = concat(t_blob,trim(ds.segment_text,3))
    WITH nocounter, separator = " ", format,
     time = 10
   ;end select
   SET t_blob = concat(t_blob,trim( $10,3))
  ENDIF
 ENDIF
 IF (( $4=1))
  SELECT INTO "nl:"
   FROM encounter e
   PLAN (e
    WHERE (e.encntr_id= $2))
   HEAD REPORT
    t_record->beg_dt_tm = e.beg_effective_dt_tm
   WITH nocounter, time = 30
  ;end select
 ELSEIF (( $4=2))
  SET t_record->beg_dt_tm = cnvtdatetime((curdate - 7),curtime)
 ELSEIF (( $4=3))
  SET t_record->beg_dt_tm = cnvtdatetime((curdate - 31),curtime)
 ELSEIF (( $4=4))
  SET t_record->beg_dt_tm = cnvtdatetime((curdate - 365),curtime)
 ELSEIF (( $4=5))
  SET t_record->beg_dt_tm = cnvtdatetime((curdate - (365 * 3)),curtime)
 ENDIF
 SELECT INTO "nl:"
  FROM cust_mpg_config cmc
  PLAN (cmc
   WHERE cmc.component_name="configurator.uhspa.rounding"
    AND cmc.config_key="PIC"
    AND cmc.end_effective_dt_tm > sysdate)
  HEAD REPORT
   json_string = cmc.json, json_string = replace(json_string,"{FNORD}","")
  WITH nocounter, time = 30
 ;end select
 SET jrec = cnvtjsontorec(json_string)
 FOR (i = 1 TO size(rconfig->card,5))
   SET rconfig->card[i].object.row[1].display_rule[1].action[1].param = replace(rconfig->card[i].
    object.row[1].display_rule[1].action[1].param,'"EVENT_SET_NAME":',char(3))
   SET num = 1
   SET str = "zzz"
   SET data = rconfig->card[i].object.row[1].display_rule[1].action[1].param
   WHILE (str != not_found)
     SET str = piece(data,char(3),num,not_found)
     IF (str != "<not_found>")
      SET t_line = str
      SET t_record->event_set_cnt += 1
      SET stat = alterlist(t_record->event_sets,t_record->event_set_cnt)
      SET pos = findstring('"',t_line)
      SET pos1 = findstring('"}',t_line,(pos+ 1))
      SET t_line1 = substring((pos+ 1),((pos1 - 1) - pos),t_line)
      SET t_record->event_sets[t_record->event_set_cnt].event_set = t_line1
      SET t_record->event_sets[t_record->event_set_cnt].group = rconfig->card[i].keyname
     ENDIF
     SET num += 1
   ENDWHILE
 ENDFOR
 SELECT INTO "nl:"
  group = t_record->event_sets[d.seq].group
  FROM encounter e,
   (dummyt d  WITH seq = t_record->event_set_cnt),
   v500_event_set_code vesc,
   v500_event_set_explode vese,
   clinical_event ce,
   prsnl p,
   scd_story ss,
   cust_mpg_tag cmt,
   cust_mpg_long_text cmlt,
   dd_ref_template drt
  PLAN (e
   WHERE (e.encntr_id= $2))
   JOIN (d)
   JOIN (vesc
   WHERE (vesc.event_set_name=t_record->event_sets[d.seq].event_set))
   JOIN (vese
   WHERE vese.event_set_cd=vesc.event_set_cd)
   JOIN (ce
   WHERE ((ce.person_id=e.person_id
    AND ( $4 != 1)) OR (ce.encntr_id=e.encntr_id
    AND ( $4=1)))
    AND ce.event_cd=vese.event_cd
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.event_end_dt_tm >= cnvtdatetime(t_record->beg_dt_tm)
    AND ce.event_end_dt_tm <= cnvtdatetime(sysdate)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.result_status_cd IN (value(uar_get_code_by("MEANING",8,"AUTH")), value(uar_get_code_by(
     "MEANING",8,"IN PROGRESS")), value(uar_get_code_by("MEANING",8,"ALTERED")), value(
    uar_get_code_by("MEANING",8,"MODIFIED")), value(uar_get_code_by("MEANING",8,"TRANSCRIBED"))))
   JOIN (p
   WHERE p.person_id=ce.verified_prsnl_id)
   JOIN (ss
   WHERE (ss.event_id= Outerjoin(ce.event_id))
    AND (ss.story_type_cd= Outerjoin(value(uar_get_code_by("DISPLAY_KEY",15749,"DOCUMENT")))) )
   JOIN (cmt
   WHERE (cmt.parent_entity_id= Outerjoin(ce.event_id))
    AND (cmt.parent_entity_name= Outerjoin("CLINICAL_EVENT"))
    AND (cmt.tag= Outerjoin("DCNOTEINCLUDED"))
    AND (cmt.prsnl_id= Outerjoin( $3)) )
   JOIN (cmlt
   WHERE (cmlt.parent_entity_id= Outerjoin(ce.event_id))
    AND (cmlt.parent_entity_name= Outerjoin("CE_DC_COMMENT"))
    AND (cmlt.active_ind= Outerjoin(1))
    AND (cmlt.updt_id= Outerjoin( $3)) )
   JOIN (drt
   WHERE (drt.title_txt= Outerjoin(ce.event_title_text)) )
  ORDER BY group, ce.collating_seq, ce.event_cd,
   ce.event_end_dt_tm DESC, ce.event_id, cmlt.updt_dt_tm DESC
  HEAD group
   null
  HEAD ce.event_id
   t_record->element_cnt += 1, stat = alterlist(t_record->elements,t_record->element_cnt), e_cnt =
   t_record->element_cnt,
   t_record->elements[e_cnt].type = t_record->event_sets[d.seq].group, t_record->elements[e_cnt].
   tag_key = concat("CE_",trim(cnvtstring(ce.event_id))), t_record->elements[e_cnt].event_id = ce
   .event_id,
   t_record->elements[e_cnt].event_end_dt_tm = ce.event_end_dt_tm, t_record->elements[e_cnt].title =
   trim(uar_get_code_display(ce.event_cd)), t_record->elements[e_cnt].when = format(ce
    .event_end_dt_tm,"mm/dd/yyyy hh:mm;;q"),
   t_record->elements[e_cnt].author = trim(p.name_full_formatted)
  FOOT  group
   t_record->element_cnt += 1, stat = alterlist(t_record->elements,t_record->element_cnt), e_cnt =
   t_record->element_cnt,
   t_record->elements[e_cnt].type = t_record->event_sets[d.seq].group
   IF ((t_record->event_sets[d.seq].group="CONSULT"))
    t_record->elements[e_cnt].tag_key = "OTHERCONSULT", t_record->elements[e_cnt].title =
    "Other Consult"
   ELSEIF ((t_record->event_sets[d.seq].group="IMAGE"))
    t_record->elements[e_cnt].tag_key = "OTHERIMAGES", t_record->elements[e_cnt].title =
    "Other Image"
   ELSEIF ((t_record->event_sets[d.seq].group="MICROBIOLOGY"))
    t_record->elements[e_cnt].tag_key = "OTHERMICROBIOLOGY", t_record->elements[e_cnt].title =
    "Other Microbiology"
   ELSEIF ((t_record->event_sets[d.seq].group="PROCEDURE"))
    t_record->elements[e_cnt].tag_key = "OTHERPROCEDURE", t_record->elements[e_cnt].title =
    "Other Procedure"
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SET stat = alterlist(t_record->event_sets,0)
 FOR (i = 1 TO t_record->element_cnt)
   IF ((t_record->elements[i].tag_key="OTHERCONSULT"))
    SET c_found_ind = 1
   ENDIF
   IF ((t_record->elements[i].tag_key="OTHERIMAGES"))
    SET i_found_ind = 1
   ENDIF
   IF ((t_record->elements[i].tag_key="OTHERMICROBIOLOGY"))
    SET m_found_ind = 1
   ENDIF
   IF ((t_record->elements[i].tag_key="OTHERPROCEDURE"))
    SET p_found_ind = 1
   ENDIF
 ENDFOR
 IF (c_found_ind=0)
  SET t_record->element_cnt += 1
  SET stat = alterlist(t_record->elements,t_record->element_cnt)
  SET t_record->elements[t_record->element_cnt].type = "CONSULT"
  SET t_record->elements[t_record->element_cnt].tag_key = "OTHERCONSULT"
  SET t_record->elements[t_record->element_cnt].title = "Other Consult"
 ENDIF
 IF (i_found_ind=0)
  SET t_record->element_cnt += 1
  SET stat = alterlist(t_record->elements,t_record->element_cnt)
  SET t_record->elements[t_record->element_cnt].type = "IMAGE"
  SET t_record->elements[t_record->element_cnt].tag_key = "OTHERIMAGES"
  SET t_record->elements[t_record->element_cnt].title = "Other Image"
 ENDIF
 IF (m_found_ind=0)
  SET t_record->element_cnt += 1
  SET stat = alterlist(t_record->elements,t_record->element_cnt)
  SET t_record->elements[t_record->element_cnt].type = "MICROBIOLOGY"
  SET t_record->elements[t_record->element_cnt].tag_key = "OTHERMICROBIOLOGY"
  SET t_record->elements[t_record->element_cnt].title = "Other Microbiology"
 ENDIF
 IF (p_found_ind=0)
  SET t_record->element_cnt += 1
  SET stat = alterlist(t_record->elements,t_record->element_cnt)
  SET t_record->elements[t_record->element_cnt].type = "PROCEDURE"
  SET t_record->elements[t_record->element_cnt].tag_key = "OTHERPROCEDURE"
  SET t_record->elements[t_record->element_cnt].title = "Other Procedure"
 ENDIF
 SELECT INTO "nl:"
  FROM cust_mpg_rounding_sum cmrs
  PLAN (cmrs
   WHERE (cmrs.encntr_id= $2)
    AND cmrs.group_name IN ("PROCEDURE", "IMAGE", "MICROBIOLOGY", "CONSULT"))
  ORDER BY cmrs.group_name, cmrs.key_seq
  HEAD cmrs.group_name
   t_record->group_cnt += 1, stat = alterlist(t_record->group,t_record->group_cnt), t_record->group[
   t_record->group_cnt].group_name = cmrs.group_name
  DETAIL
   t_record->group[t_record->group_cnt].long_text = concat(t_record->group[t_record->group_cnt].
    long_text,replace(cmrs.long_text,'{"KEY_NAME":',char(3)))
  WITH nocounter, time = 30
 ;end select
 FOR (i = 1 TO t_record->group_cnt)
   SET num = 1
   SET str = "zzz"
   SET data = t_record->group[i].long_text
   WHILE (str != not_found)
     SET str = piece(data,char(3),num,not_found)
     IF (num > 1
      AND str != "<not_found>")
      SET t_line = str
      SET t_record->t_element_cnt += 1
      SET stat = alterlist(t_record->t_elements,t_record->t_element_cnt)
      SET t_record->t_elements[t_record->t_element_cnt].type = t_record->group[i].group_name
      SET pos = findstring("CE",t_line)
      SET pos1 = findstring("CONTENTIDX",t_line,(pos+ 15))
      SET t_line1 = substring(pos,((pos1 - 3) - pos),t_line)
      SET t_record->t_elements[t_record->t_element_cnt].tag_key = t_line1
      SET pos = findstring("LABEL",t_line)
      SET pos1 = findstring("CLICKFN",t_line,(pos+ 27))
      IF (pos1=0)
       SET pos1 = findstring("INCLUDE",t_line,(pos+ 27))
       SET t_line1 = substring((pos+ 27),((pos1 - 5) - (pos+ 27)),t_line)
      ELSE
       SET t_line1 = substring((pos+ 27),((pos1 - 3) - (pos+ 27)),t_line)
      ENDIF
      SET t_record->t_elements[t_record->t_element_cnt].title = t_line1
      SET pos = findstring("EVENT_ID",t_line)
      SET pos1 = findstring("}}",t_line,(pos+ 11))
      SET t_line1 = substring((pos+ 11),((pos1 - 1) - (pos+ 11)),t_line)
      SET t_record->t_elements[t_record->t_element_cnt].event_id = cnvtreal(t_line1)
      SET pos = findstring("WHEN",t_line,pos1)
      IF (pos > 0)
       SET pos1 = findstring("AUTHOR",t_line,(pos+ 27))
       SET t_line1 = substring((pos+ 26),((pos1 - 5) - (pos+ 26)),t_line)
       SET t_record->t_elements[t_record->t_element_cnt].when = t_line1
      ENDIF
      SET pos = findstring("AUTHOR",t_line)
      IF (pos > 0)
       SET pos1 = findstring("INCLUDE",t_line,(pos+ 28))
       SET t_line1 = substring((pos+ 28),((pos1 - 5) - (pos+ 28)),t_line)
       SET t_record->t_elements[t_record->t_element_cnt].author = t_line1
      ENDIF
      SET pos = findstring("COMMENT",t_line)
      IF (pos > 0)
       SET pos1 = findstring('"SOURCE":',t_line,(pos+ 56))
       SET t_line1 = substring((pos+ 56),((pos1 - 3) - (pos+ 55)),t_line)
       IF (pos1=0)
        SET pos1 = findstring("LAST_UPDATED",t_line,(pos+ 56))
        SET t_line1 = substring((pos+ 56),((pos1 - 3) - (pos+ 56)),t_line)
       ENDIF
       SET t_record->t_elements[t_record->t_element_cnt].comment = t_line1
      ENDIF
      SET pos = findstring("LAST_UPDATED",t_line,(pos+ 56))
      IF (pos > 0)
       SET pos1 = findstring("USER_DEFINED",t_line,(pos+ 14))
       SET t_line1 = substring((pos+ 14),((pos1 - 2) - (pos+ 14)),t_line)
       SET t_record->t_elements[t_record->t_element_cnt].last_updated = t_line1
      ENDIF
      SET pos = findstring("LAST_UPDATED_BY",t_line,pos1)
      IF (pos > 0)
       SET pos1 = findstring("}}",t_line,(pos+ 18))
       SET t_line1 = substring((pos+ 18),((pos1 - 1) - (pos+ 18)),t_line)
       SET t_record->t_elements[t_record->t_element_cnt].last_updated_by = t_line1
      ENDIF
     ENDIF
     SET num += 1
   ENDWHILE
 ENDFOR
 FOR (i = 1 TO t_record->t_element_cnt)
   IF ((t_record->t_elements[i].tag_key != "CE*"))
    IF ((t_record->t_elements[i].type="CONSULT"))
     SET t_record->t_elements[i].tag_key = "OTHERCONSULT"
    ELSEIF ((t_record->t_elements[i].type="IMAGE"))
     SET t_record->t_elements[i].tag_key = "OTHERIMAGES"
    ELSEIF ((t_record->t_elements[i].type="MICROBIOLOGY"))
     SET t_record->t_elements[i].tag_key = "OTHERMICROBIOLOGY"
    ELSEIF ((t_record->t_elements[i].type="PROCEDURE"))
     SET t_record->t_elements[i].tag_key = "OTHERPROCEDURE"
    ENDIF
   ENDIF
 ENDFOR
 FOR (i = 1 TO t_record->element_cnt)
   FOR (j = 1 TO t_record->t_element_cnt)
    IF ((t_record->elements[i].event_id=t_record->t_elements[j].event_id)
     AND (t_record->elements[i].event_id > 0))
     SET t_record->elements[i].comment = t_record->t_elements[j].comment
     SET t_record->elements[i].last_updated = t_record->t_elements[j].last_updated
     SET t_record->elements[i].last_updated_by = t_record->t_elements[j].last_updated_by
    ENDIF
    IF ((t_record->elements[i].tag_key=t_record->t_elements[j].tag_key)
     AND (t_record->elements[i].event_id=0))
     SET t_record->elements[i].comment = t_record->t_elements[j].comment
     SET t_record->elements[i].last_updated = t_record->t_elements[j].last_updated
     SET t_record->elements[i].last_updated_by = t_record->t_elements[j].last_updated_by
    ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->element_cnt),
   cust_mpg_tag cmt
  PLAN (d)
   JOIN (cmt
   WHERE (cmt.parent_entity_name=t_record->elements[d.seq].tag_key)
    AND (cmt.prsnl_id= $3)
    AND cmt.tag=cmt_tag)
  ORDER BY d.seq
  HEAD d.seq
   t_record->elements[d.seq].include = 1
  WITH nocounter, time = 30
 ;end select
 SET e_cnt = 0
 FOR (i = 1 TO t_record->element_cnt)
   SET e_cnt += 1
   SET stat = alterlist(out_rec->elements,e_cnt)
   SET out_rec->elements[e_cnt].author = t_record->elements[i].author
   SET out_rec->elements[e_cnt].tag_key = t_record->elements[i].tag_key
   SET out_rec->elements[e_cnt].comment = t_record->elements[i].comment
   SET out_rec->elements[e_cnt].event_id = cnvtstring(t_record->elements[i].event_id)
   SET out_rec->elements[e_cnt].event_end_dt_tm = datetimezoneformat(t_record->elements[i].
    event_end_dt_tm,curtimezoneapp,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
   SET out_rec->elements[e_cnt].include = cnvtstring(t_record->elements[i].include)
   SET out_rec->elements[e_cnt].last_updated = t_record->elements[i].last_updated
   SET out_rec->elements[e_cnt].last_updated_by = t_record->elements[i].last_updated_by
   SET out_rec->elements[e_cnt].title = t_record->elements[i].title
   SET out_rec->elements[e_cnt].type = t_record->elements[i].type
   SET out_rec->elements[e_cnt].when = t_record->elements[i].when
 ENDFOR
 SET e_request->blob = t_blob
 SET e_request->url_source_ind = 1
 EXECUTE bhs_athn_base64_decode  WITH replace("REQUEST",e_request), replace("REPLY",e_reply)
 SET t_blob = e_reply->blob
 SET t_blob = replace(t_blob,"\","\\")
 SET t_blob = replace(t_blob,'"','\"')
 SET t_blob = replace(t_blob,"/","\/")
 FOR (i = 1 TO size(out_rec->elements,5))
   IF ((out_rec->elements[i].tag_key= $5))
    SET out_rec->elements[i].comment = t_blob
    SET out_rec->elements[i].last_updated =  $9
    SET out_rec->elements[i].last_updated_by = prsnl_string
   ENDIF
 ENDFOR
 SET c_line = "["
 SET i_line = "["
 SET m_line = "["
 SET p_line = "["
 FOR (i = 1 TO size(out_rec->elements,5))
   IF ((out_rec->elements[i].type="CONSULT"))
    IF (cnvtreal(out_rec->elements[i].event_id) > 0)
     SET c_line = concat(c_line,'{"KEY_NAME":"CE_',out_rec->elements[i].event_id,
      '","CONTENTIDX":{"LABEL":{"PROPIDX":{"TEXT":"')
     SET c_line = concat(c_line,out_rec->elements[i].title,
      '","CLICKFN":"openDocumentViewer","EVENT_ID":"')
     SET c_line = concat(c_line,out_rec->elements[i].event_id,'"}},"WHEN":{"PROPIDX":{"TEXT":"',
      out_rec->elements[i].when)
     SET c_line = concat(c_line,'"}},"AUTHOR":{"PROPIDX":{"TEXT":"',out_rec->elements[i].author,
      '"}},')
     SET c_line = concat(c_line,
      '"INCLUDE":{"PROPIDX":{"FUNCTIONNAME":"renderIncludeInNote","CLEAR_ON_SIGN":"true",')
     SET c_line = concat(c_line,
      '"USER_SPECIFIC":"true","TEXT":""}},"COMMENT":{"PROPIDX":{"SHOW_LAST_UPDATED":"true","TEXT":')
     IF ((out_rec->elements[i].comment > " "))
      SET c_line = concat(c_line,'"',out_rec->elements[i].comment,'","LAST_UPDATED":',out_rec->
       elements[i].last_updated)
      SET c_line = concat(c_line,',"USER_DEFINED":1,"LAST_UPDATED_BY":"',out_rec->elements[i].
       last_updated_by,'"}}}')
     ELSE
      SET c_line = concat(c_line,'""}}}')
     ENDIF
     SET c_line = concat(c_line,',"REMOVABLE_IND":0},')
    ELSE
     SET c_line = concat(c_line,
      '{"KEY_NAME":"OTHERCONSULT","CONTENTIDX":{"LABEL":{"PROPIDX":{"TEXT":"Other Consult"}},')
     SET c_line = concat(c_line,
      '"INCLUDE":{"PROPIDX":{"FUNCTIONNAME":"renderIncludeInNote","CLEAR_ON_SIGN":"true",')
     SET c_line = concat(c_line,
      '"USER_SPECIFIC":"true","TEXT":""}},"COMMENT":{"PROPIDX":{"SHOW_LAST_UPDATED":"true","TEXT":')
     IF ((out_rec->elements[i].comment > " "))
      SET c_line = concat(c_line,'"',out_rec->elements[i].comment,'","LAST_UPDATED":',out_rec->
       elements[i].last_updated)
      SET c_line = concat(c_line,',"USER_DEFINED":1,"LAST_UPDATED_BY":"',out_rec->elements[i].
       last_updated_by,'"}}')
     ELSE
      SET c_line = concat(c_line,'""}}')
     ENDIF
     SET c_line = concat(c_line,
      ',"WHEN":{"PROPIDX":{"TEXT":""}},"AUTHOR":{"PROPIDX":{"TEXT":""}}},"HIDDEN_IND":0,')
     SET c_line = concat(c_line,'"REMOVABLE_IND":""}]')
    ENDIF
   ENDIF
   IF ((out_rec->elements[i].type="IMAGE"))
    IF (cnvtreal(out_rec->elements[i].event_id) > 0)
     SET i_line = concat(i_line,'{"KEY_NAME":"CE_',out_rec->elements[i].event_id,
      '","CONTENTIDX":{"LABEL":{"PROPIDX":{"TEXT":"')
     SET i_line = concat(i_line,out_rec->elements[i].title,
      '","CLICKFN":"openDocumentViewer","EVENT_ID":"')
     SET i_line = concat(i_line,out_rec->elements[i].event_id,'"}},"WHEN":{"PROPIDX":{"TEXT":"',
      out_rec->elements[i].when)
     SET i_line = concat(i_line,'"}},"AUTHOR":{"PROPIDX":{"TEXT":"',out_rec->elements[i].author,
      '"}},')
     SET i_line = concat(i_line,
      '"INCLUDE":{"PROPIDX":{"FUNCTIONNAME":"renderIncludeInNote","CLEAR_ON_SIGN":"true",')
     SET i_line = concat(i_line,
      '"USER_SPECIFIC":"true","TEXT":""}},"COMMENT":{"PROPIDX":{"SHOW_LAST_UPDATED":"true","TEXT":')
     IF ((out_rec->elements[i].comment > " "))
      SET i_line = concat(i_line,'"',out_rec->elements[i].comment,'","LAST_UPDATED":',out_rec->
       elements[i].last_updated)
      SET i_line = concat(i_line,',"USER_DEFINED":1,"LAST_UPDATED_BY":"',out_rec->elements[i].
       last_updated_by,'"}}}')
     ELSE
      SET i_line = concat(i_line,'""}}}')
     ENDIF
     SET i_line = concat(i_line,',"REMOVABLE_IND":0},')
    ELSE
     SET i_line = concat(i_line,
      '{"KEY_NAME":"OTHERIMAGES","CONTENTIDX":{"LABEL":{"PROPIDX":{"TEXT":"Other Image"}},')
     SET i_line = concat(i_line,
      '"INCLUDE":{"PROPIDX":{"FUNCTIONNAME":"renderIncludeInNote","CLEAR_ON_SIGN":"true",')
     SET i_line = concat(i_line,
      '"USER_SPECIFIC":"true","TEXT":""}},"COMMENT":{"PROPIDX":{"SHOW_LAST_UPDATED":"true","TEXT":')
     IF ((out_rec->elements[i].comment > " "))
      SET i_line = concat(i_line,'"',out_rec->elements[i].comment,'","LAST_UPDATED":',out_rec->
       elements[i].last_updated)
      SET i_line = concat(i_line,',"USER_DEFINED":1,"LAST_UPDATED_BY":"',out_rec->elements[i].
       last_updated_by,'"}}')
     ELSE
      SET i_line = concat(i_line,'""}}')
     ENDIF
     SET i_line = concat(i_line,
      ',"WHEN":{"PROPIDX":{"TEXT":""}},"AUTHOR":{"PROPIDX":{"TEXT":""}}},"HIDDEN_IND":0,')
     SET i_line = concat(i_line,'"REMOVABLE_IND":""}]')
    ENDIF
   ENDIF
   IF ((out_rec->elements[i].type="MICROBIOLOGY"))
    IF (cnvtreal(out_rec->elements[i].event_id) > 0)
     SET m_line = concat(m_line,'{"KEY_NAME":"CE_',out_rec->elements[i].event_id,
      '","CONTENTIDX":{"LABEL":{"PROPIDX":{"TEXT":"')
     SET m_line = concat(m_line,out_rec->elements[i].title,
      '","CLICKFN":"openDocumentViewer","EVENT_ID":"')
     SET m_line = concat(m_line,out_rec->elements[i].event_id,'"}},"WHEN":{"PROPIDX":{"TEXT":"',
      out_rec->elements[i].when)
     SET m_line = concat(m_line,'"}},"AUTHOR":{"PROPIDX":{"TEXT":"',out_rec->elements[i].author,
      '"}},')
     SET m_line = concat(m_line,
      '"INCLUDE":{"PROPIDX":{"FUNCTIONNAME":"renderIncludeInNote","CLEAR_ON_SIGN":"true",')
     SET m_line = concat(m_line,
      '"USER_SPECIFIC":"true","TEXT":""}},"COMMENT":{"PROPIDX":{"SHOW_LAST_UPDATED":"true","TEXT":')
     IF ((out_rec->elements[i].comment > " "))
      SET m_line = concat(m_line,'"',out_rec->elements[i].comment,'","LAST_UPDATED":',out_rec->
       elements[i].last_updated)
      SET m_line = concat(m_line,',"USER_DEFINED":1,"LAST_UPDATED_BY":"',out_rec->elements[i].
       last_updated_by,'"}}}')
     ELSE
      SET m_line = concat(m_line,'""}}}')
     ENDIF
     SET m_line = concat(m_line,',"REMOVABLE_IND":0},')
    ELSE
     SET m_line = concat(m_line,'{"KEY_NAME":"OTHERMICROBIOLOGY","CONTENTIDX":')
     SET m_line = concat(m_line,'{"LABEL":{"PROPIDX":{"TEXT":"Other Microbiology"}},')
     SET m_line = concat(m_line,
      '"INCLUDE":{"PROPIDX":{"FUNCTIONNAME":"renderIncludeInNote","CLEAR_ON_SIGN":"true",')
     SET m_line = concat(m_line,
      '"USER_SPECIFIC":"true","TEXT":""}},"COMMENT":{"PROPIDX":{"SHOW_LAST_UPDATED":"true","TEXT":')
     IF ((out_rec->elements[i].comment > " "))
      SET m_line = concat(m_line,'"',out_rec->elements[i].comment,'","LAST_UPDATED":',out_rec->
       elements[i].last_updated)
      SET m_line = concat(m_line,',"USER_DEFINED":1,"LAST_UPDATED_BY":"',out_rec->elements[i].
       last_updated_by,'"}}')
     ELSE
      SET m_line = concat(m_line,'""}}')
     ENDIF
     SET m_line = concat(m_line,
      ',"WHEN":{"PROPIDX":{"TEXT":""}},"AUTHOR":{"PROPIDX":{"TEXT":""}}},"HIDDEN_IND":0,')
     SET m_line = concat(m_line,'"REMOVABLE_IND":""}]')
    ENDIF
   ENDIF
   IF ((out_rec->elements[i].type="PROCEDURE"))
    IF (cnvtreal(out_rec->elements[i].event_id) > 0)
     SET p_line = concat(p_line,'{"KEY_NAME":"CE_',out_rec->elements[i].event_id,
      '","CONTENTIDX":{"LABEL":{"PROPIDX":{"TEXT":"')
     SET p_line = concat(p_line,out_rec->elements[i].title,
      '","CLICKFN":"openDocumentViewer","EVENT_ID":"')
     SET p_line = concat(p_line,out_rec->elements[i].event_id,'"}},"WHEN":{"PROPIDX":{"TEXT":"',
      out_rec->elements[i].when)
     SET p_line = concat(p_line,'"}},"AUTHOR":{"PROPIDX":{"TEXT":"',out_rec->elements[i].author,
      '"}},')
     SET p_line = concat(p_line,
      '"INCLUDE":{"PROPIDX":{"FUNCTIONNAME":"renderIncludeInNote","CLEAR_ON_SIGN":"true",')
     SET p_line = concat(p_line,
      '"USER_SPECIFIC":"true","TEXT":""}},"COMMENT":{"PROPIDX":{"SHOW_LAST_UPDATED":"true","TEXT":')
     IF ((out_rec->elements[i].comment > " "))
      SET p_line = concat(p_line,'"',out_rec->elements[i].comment,'","LAST_UPDATED":',out_rec->
       elements[i].last_updated)
      SET p_line = concat(p_line,',"USER_DEFINED":1,"LAST_UPDATED_BY":"',out_rec->elements[i].
       last_updated_by,'"}}}')
     ELSE
      SET p_line = concat(p_line,'""}}}')
     ENDIF
     SET p_line = concat(p_line,',"REMOVABLE_IND":0},')
    ELSE
     SET p_line = concat(p_line,
      '{"KEY_NAME":"OTHERPROCEDURE","CONTENTIDX":{"LABEL":{"PROPIDX":{"TEXT":"Other Procedure"}},')
     SET p_line = concat(p_line,
      '"INCLUDE":{"PROPIDX":{"FUNCTIONNAME":"renderIncludeInNote","CLEAR_ON_SIGN":"true",')
     SET p_line = concat(p_line,
      '"USER_SPECIFIC":"true","TEXT":""}},"COMMENT":{"PROPIDX":{"SHOW_LAST_UPDATED":"true","TEXT":')
     IF ((out_rec->elements[i].comment > " "))
      SET p_line = concat(p_line,'"',out_rec->elements[i].comment,'","LAST_UPDATED":',out_rec->
       elements[i].last_updated)
      SET p_line = concat(p_line,',"USER_DEFINED":1,"LAST_UPDATED_BY":"',out_rec->elements[i].
       last_updated_by,'"}}')
     ELSE
      SET p_line = concat(p_line,'""}}')
     ENDIF
     SET p_line = concat(p_line,
      ',"WHEN":{"PROPIDX":{"TEXT":""}},"AUTHOR":{"PROPIDX":{"TEXT":""}}},"HIDDEN_IND":0,')
     SET p_line = concat(p_line,'"REMOVABLE_IND":""}]')
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (( $7=1))
  EXECUTE uhs_mpg_upd_rounding_sum "mine",  $2, "CONSULT",
  "", "", c_line,
  "0"
  EXECUTE uhs_mpg_upd_rounding_sum "mine",  $2, "IMAGE",
  "", "", i_line,
  "0"
  EXECUTE uhs_mpg_upd_rounding_sum "mine",  $2, "MICROBIOLOGY",
  "", "", m_line,
  "0"
  EXECUTE uhs_mpg_upd_rounding_sum "mine",  $2, "PROCEDURE",
  "", "", p_line,
  "0"
 ENDIF
 IF (( $7 > 1))
  IF (( $6 !=  $7))
   SET oreply->status = concat("Successfully Sent Part ",trim(cnvtstring( $6))," of ",trim(cnvtstring
     ( $7)))
   SET _memory_reply_string = cnvtrectojson(oreply,5)
  ENDIF
  IF (( $6= $7))
   EXECUTE uhs_mpg_upd_rounding_sum "mine",  $2, "CONSULT",
   "", "", c_line,
   "0"
   EXECUTE uhs_mpg_upd_rounding_sum "mine",  $2, "IMAGE",
   "", "", i_line,
   "0"
   EXECUTE uhs_mpg_upd_rounding_sum "mine",  $2, "MICROBIOLOGY",
   "", "", m_line,
   "0"
   EXECUTE uhs_mpg_upd_rounding_sum "mine",  $2, "PROCEDURE",
   "", "", p_line,
   "0"
  ENDIF
 ENDIF
END GO
