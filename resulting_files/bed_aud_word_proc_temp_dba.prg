CREATE PROGRAM bed_aud_word_proc_temp:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 organizations[*]
      2 org_id = f8
    1 show_all_templates = i2
    1 search_type_flag = vc
    1 search_string = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD templates
 RECORD templates(
   1 qual[*]
     2 template_id = f8
     2 short_desc = vc
     2 long_desc = vc
     2 template_type = vc
     2 long_text_id = f8
     2 long_text = vc
     2 orgs = vc
     2 font = vc
     2 font_size = i2
     2 person_id = f8
     2 pdisp = vc
 )
 FREE RECORD templates2
 RECORD templates2(
   1 qual[*]
     2 template_id = f8
     2 short_desc = vc
     2 long_desc = vc
     2 template_type = vc
     2 long_text_id = f8
     2 long_text = vc
     2 orgs = vc
     2 font = vc
     2 font_size = i2
     2 person_id = f8
     2 pdisp = vc
 )
 DECLARE inbuffer = vc
 DECLARE inbuflen = i4
 DECLARE outbuffer = c1000 WITH noconstant("")
 DECLARE outbuflen = i4 WITH noconstant(1000)
 DECLARE retbuflen = i4 WITH noconstant(0)
 DECLARE bflag = i4 WITH noconstant(0)
 DECLARE orgs = vc
 DECLARE colnum = i4 WITH constant(8)
 DECLARE activity_code_value = f8 WITH protect, noconstant(uar_get_code_by("MEANING",106,"GLB"))
 DECLARE template_type_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",1303,"TEMPLATE"))
 DECLARE letter_type_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",1303,"LETTER"))
 DECLARE searchstring = vc WITH private
 DECLARE where1 = vc WITH private
 DECLARE req_cnt = i4 WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE size_of_templates = i4 WITH protect
 DECLARE maxlist = i4 WITH protect
 DECLARE max_reply1 = i4 WITH constant(1750)
 DECLARE max_reply2 = i4 WITH constant(2500)
 DECLARE max_org = i4 WITH constant(250)
 DECLARE high_volume_cnt = i4 WITH noconstant(0)
 DECLARE max_org_cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  wt.template_id, org_cnt = count(org.organization_id)
  FROM wp_template wt,
   filter_entity_reltn fer,
   organization org
  PLAN (wt
   WHERE wt.template_type_cd IN (template_type_cd, letter_type_cd)
    AND wt.activity_type_cd=activity_code_value
    AND wt.active_ind=1)
   JOIN (fer
   WHERE fer.parent_entity_id=outerjoin(wt.template_id))
   JOIN (org
   WHERE org.organization_id=outerjoin(fer.filter_entity1_id)
    AND org.active_ind=outerjoin(1))
  GROUP BY wt.template_id
  DETAIL
   high_volume_cnt = (high_volume_cnt+ 1)
   IF (org_cnt > max_org_cnt)
    max_org_cnt = org_cnt
   ENDIF
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (((max_org_cnt > max_org) OR (high_volume_cnt > max_reply2)) )
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > max_reply1)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,colnum)
 SET reply->collist[1].header_text = "template_id"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Description"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Letter or Template"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "long_text_id"
 SET reply->collist[5].data_type = 2
 SET reply->collist[5].hide_ind = 1
 SET reply->collist[6].header_text = "Template Text"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Associated Facilities"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "User"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET searchstring = cnvtupper(trim(request->search_string))
 SET where1 = "wt.active_ind = 1"
 IF (size(searchstring,1) > 0)
  IF (cnvtupper(request->search_type_flag)="S")
   SET where1 = concat(where1,' and wt.short_desc = "',searchstring,'*"')
  ELSE
   SET where1 = concat(where1,' and wt.short_desc = "*',searchstring,'*"')
  ENDIF
 ENDIF
 SET req_cnt = size(request->organizations,5)
 IF (req_cnt > 0)
  SELECT INTO "NL:"
   FROM wp_template wt,
    long_text lt
   PLAN (wt
    WHERE wt.template_type_cd IN (template_type_cd, letter_type_cd)
     AND wt.activity_type_cd=activity_code_value
     AND parser(where1)
     AND  NOT ( EXISTS (
    (SELECT
     fer.filter_entity1_id
     FROM filter_entity_reltn fer
     WHERE fer.parent_entity_name="WP_TEMPLATE"
      AND fer.filter_entity1_name="ORGANIZATION"
      AND fer.parent_entity_id=wt.template_id))))
    JOIN (lt
    WHERE lt.parent_entity_id=wt.template_id
     AND lt.active_ind=1
     AND lt.parent_entity_name="WP_TEMPLATE_TEXT")
   HEAD REPORT
    cnt = size(templates2->qual,5)
   HEAD wt.short_desc
    orgs = "", cnt = (cnt+ 1), stat = alterlist(templates2->qual,cnt),
    templates2->qual[cnt].long_text = lt.long_text, templates2->qual[cnt].long_desc = wt.description,
    templates2->qual[cnt].long_text_id = lt.long_text_id,
    templates2->qual[cnt].short_desc = wt.short_desc, templates2->qual[cnt].template_id = wt
    .template_id
    IF (wt.template_type_cd=template_type_cd)
     templates2->qual[cnt].template_type = "Template"
    ELSEIF (wt.template_type_cd=letter_type_cd)
     templates2->qual[cnt].template_type = "Letter"
    ENDIF
    templates2->qual[cnt].person_id = wt.person_id
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   wt.short_desc, org.org_name
   FROM wp_template wt,
    long_text lt,
    filter_entity_reltn fer,
    filter_entity_reltn fer2,
    organization org,
    (dummyt d  WITH seq = value(req_cnt))
   PLAN (d)
    JOIN (fer
    WHERE fer.parent_entity_name="WP_TEMPLATE"
     AND fer.filter_entity1_name="ORGANIZATION"
     AND (request->organizations[d.seq].org_id=fer.filter_entity1_id))
    JOIN (fer2
    WHERE fer2.parent_entity_name="WP_TEMPLATE"
     AND fer2.filter_entity1_name="ORGANIZATION"
     AND fer2.parent_entity_id=fer.parent_entity_id)
    JOIN (wt
    WHERE wt.template_id=fer.parent_entity_id
     AND wt.template_type_cd IN (template_type_cd, letter_type_cd)
     AND wt.activity_type_cd=activity_code_value
     AND parser(where1))
    JOIN (lt
    WHERE lt.parent_entity_id=wt.template_id
     AND lt.active_ind=1
     AND lt.parent_entity_name="WP_TEMPLATE_TEXT")
    JOIN (org
    WHERE org.organization_id=fer2.filter_entity1_id
     AND org.active_ind=1)
   ORDER BY wt.short_desc
   HEAD REPORT
    cnt = size(templates2->qual,5)
   HEAD wt.short_desc
    orgs = "", cnt = (cnt+ 1), stat = alterlist(templates2->qual,cnt),
    templates2->qual[cnt].long_text = lt.long_text, templates2->qual[cnt].long_desc = wt.description,
    templates2->qual[cnt].long_text_id = lt.long_text_id,
    templates2->qual[cnt].short_desc = wt.short_desc, templates2->qual[cnt].template_id = wt
    .template_id
    IF (wt.template_type_cd=template_type_cd)
     templates2->qual[cnt].template_type = "Template"
    ELSEIF (wt.template_type_cd=letter_type_cd)
     templates2->qual[cnt].template_type = "Letter"
    ENDIF
    templates2->qual[cnt].person_id = wt.person_id
   DETAIL
    IF (orgs="")
     orgs = org.org_name
    ELSE
     orgs = build2(orgs,", ",org.org_name)
    ENDIF
   FOOT  wt.short_desc
    templates2->qual[cnt].orgs = orgs
   WITH nocounter
  ;end select
  SET size_of_templates = size(templates2->qual,5)
  IF (size_of_templates > 0)
   SET stat = alterlist(templates->qual,size(templates2->qual,5))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size_of_templates),
     wp_template wt
    PLAN (d)
     JOIN (wt
     WHERE (wt.template_id=templates2->qual[d.seq].template_id))
    ORDER BY wt.short_desc
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), templates->qual[cnt].long_text = templates2->qual[d.seq].long_text, templates->
     qual[cnt].long_desc = templates2->qual[d.seq].long_desc,
     templates->qual[cnt].long_text_id = templates2->qual[d.seq].long_text_id, templates->qual[cnt].
     short_desc = templates2->qual[d.seq].short_desc, templates->qual[cnt].template_id = templates2->
     qual[d.seq].template_id,
     templates->qual[cnt].person_id = templates2->qual[d.seq].person_id, templates->qual[cnt].orgs =
     templates2->qual[d.seq].orgs, templates->qual[cnt].template_type = templates2->qual[d.seq].
     template_type
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SELECT INTO "NL:"
   wt.short_desc, org.org_name
   FROM wp_template wt,
    long_text lt,
    filter_entity_reltn fer,
    organization org
   PLAN (wt
    WHERE wt.template_type_cd IN (template_type_cd, letter_type_cd)
     AND wt.activity_type_cd=activity_code_value
     AND wt.active_ind=1
     AND parser(where1))
    JOIN (lt
    WHERE lt.parent_entity_id=wt.template_id
     AND lt.active_ind=1
     AND lt.parent_entity_name="WP_TEMPLATE_TEXT")
    JOIN (fer
    WHERE fer.parent_entity_id=outerjoin(wt.template_id))
    JOIN (org
    WHERE org.organization_id=outerjoin(fer.filter_entity1_id)
     AND org.active_ind=outerjoin(1))
   ORDER BY wt.short_desc
   HEAD REPORT
    cnt = 0
   HEAD wt.short_desc
    orgs = "", cnt = (cnt+ 1), stat = alterlist(templates->qual,cnt),
    templates->qual[cnt].long_text = lt.long_text, templates->qual[cnt].long_desc = wt.description,
    templates->qual[cnt].long_text_id = lt.long_text_id,
    templates->qual[cnt].short_desc = wt.short_desc, templates->qual[cnt].template_id = wt
    .template_id
    IF (wt.template_type_cd=template_type_cd)
     templates->qual[cnt].template_type = "Template"
    ELSEIF (wt.template_type_cd=letter_type_cd)
     templates->qual[cnt].template_type = "Letter"
    ENDIF
    templates->qual[cnt].person_id = wt.person_id
   DETAIL
    IF (orgs="")
     orgs = org.org_name
    ELSE
     orgs = build2(orgs,", ",org.org_name)
    ENDIF
   FOOT  wt.short_desc
    templates->qual[cnt].orgs = orgs
   WITH nocounter
  ;end select
 ENDIF
 IF (size(templates->qual,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(templates->qual,5)),
    prsnl p
   PLAN (d
    WHERE (templates->qual[d.seq].person_id > 0))
    JOIN (p
    WHERE (p.person_id=templates->qual[d.seq].person_id)
     AND p.active_ind=1)
   ORDER BY d.seq
   DETAIL
    templates->qual[d.seq].pdisp = concat(trim(p.name_last_key),",",trim(p.name_first_key))
   WITH nocounter
  ;end select
 ENDIF
 SET maxlist = size(templates->qual,5)
 SET cnt = 0
 SET stat = alterlist(reply->rowlist,maxlist)
 WHILE (cnt < maxlist)
   SET cnt = (cnt+ 1)
   SET stat = alterlist(reply->rowlist[cnt].celllist,colnum)
   SET outbuffer = ""
   SET retbuflen = 0
   SET bflag = 1
   SET outbuflen = 1000
   CALL uar_rtf(templates->qual[cnt].long_text,size(templates->qual[cnt].long_text),outbuffer,
    outbuflen,retbuflen,
    bflag)
   SET reply->rowlist[cnt].celllist[1].double_value = templates->qual[cnt].template_id
   SET reply->rowlist[cnt].celllist[2].string_value = templates->qual[cnt].short_desc
   SET reply->rowlist[cnt].celllist[3].string_value = templates->qual[cnt].long_desc
   SET reply->rowlist[cnt].celllist[4].string_value = templates->qual[cnt].template_type
   SET reply->rowlist[cnt].celllist[5].double_value = templates->qual[cnt].long_text_id
   SET reply->rowlist[cnt].celllist[6].string_value = outbuffer
   IF ((templates->qual[cnt].orgs=" "))
    SET reply->rowlist[cnt].celllist[7].string_value = "All Facilities"
   ELSE
    SET reply->rowlist[cnt].celllist[7].string_value = templates->qual[cnt].orgs
   ENDIF
   SET reply->rowlist[cnt].celllist[8].string_value = templates->qual[cnt].pdisp
 ENDWHILE
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("word_process_templates_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO
