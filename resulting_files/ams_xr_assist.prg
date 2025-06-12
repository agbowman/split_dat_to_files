CREATE PROGRAM ams_xr_assist
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select the Template" = 0,
  "Option" = 0,
  "Select Section(s) (optional)" = 0,
  "(If Option 3 Selected) Enter a Person_id" = 0,
  "Or Enter an Encounter_id" = 0,
  "Or Enter an Accession_nbr" = "",
  "Output to CSV file" = 0
  WITH outdev, templateid, option,
  sectionid, personid, encntrid,
  accessionnbr, csvcheck
 DECLARE amsuser(prsnl_id=f8) = i2
 DECLARE updtdminfo(prog_name=vc) = null
 DECLARE sprogramname = vc WITH protect, constant("AMS_XR_ASSIST")
 DECLARE run_ind = i2 WITH protect, noconstant(false)
 DECLARE template_id = f8
 DECLARE template_publish_dt_tm = q8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE h = i4 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE k = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE total_section_cnt = i4 WITH noconstant(0)
 DECLARE total_activity_cnt = i4 WITH noconstant(0)
 DECLARE activity_cnt = i4 WITH noconstant(0)
 DECLARE template_name = vc WITH noconstant("")
 DECLARE banysection = i4 WITH noconstant(0)
 DECLARE selected_section_cnt = i4 WITH noconstant(0)
 DECLARE allresultsect_cd = f8 WITH constant(uar_get_code_by("DISPLAY",93,"ALLRESLTSECT")), protect
 DECLARE event_set_level = i4 WITH noconstant
 DECLARE collation_seq = i4 WITH noconstant
 DECLARE max_collation_seq = i4 WITH noconstant
 DECLARE top_event_set_cd = f8 WITH noconstant
 DECLARE cur_event_set_cd = f8 WITH noconstant
 DECLARE cur_event = f8 WITH noconstant(1)
 FREE RECORD template_rec
 RECORD template_rec(
   1 cr_report_section[*]
     2 report_section_id = f8
     2 report_section_name = vc
     2 section_content_type = vc
     2 activity[*]
       3 procedure_type_flag = i2
       3 event_set_name = vc
       3 catalog_cd = f8
       3 event_cds[*]
         4 event_cd = f8
 )
 FREE RECORD flat_activity_rec_cd
 RECORD flat_activity_rec_cd(
   1 qual[*]
     2 event_cd = f8
     2 report_section_id = f8
     2 report_section_name = vc
     2 section_content_type = vc
 )
 FREE SET esh
 RECORD esh(
   1 event_sets[*]
     2 event_set_cd = f8
     2 event_set_disp = vc
     2 parent_event_set_cd = f8
     2 type_flag = i2
     2 event_set_level = i4
     2 collation_seq = i4
     2 coll_seq_key = c40
     2 missing = i4
     2 event_codes[*]
       3 event_cd = f8
       3 event_cd_disp = vc
       3 collation_seq = i4
 )
 FREE SET missing_event_cds
 RECORD missing_event_cds(
   1 qual[*]
     2 event_cd = f8
 )
 DECLARE get_template_info(null) = null
 DECLARE get_event_cds_on_template(null) = null
 DECLARE get_event_and_catalog_cds(null) = null
 DECLARE get_event_cds_not_on_template(null) = null
 DECLARE get_event_cds_not_on_template_new(null) = null
 DECLARE create_flat_rec(null) = null
 DECLARE create_esh(null) = null
 DECLARE mark_missing_event_sets(pos=i4) = null
 DECLARE check_template_against_ce(null) = null
 DECLARE get_event_cds_on_template_csv(null) = null
 DECLARE get_event_cds_not_on_template_csv(null) = null
 DECLARE check_template_against_ce_csv(null) = null
 CALL updtdminfo(sprogramname)
 CALL get_template_info(null)
 IF (( $CSVCHECK=1))
  IF (( $OPTION=1))
   CALL get_event_cds_on_template_csv(null)
  ENDIF
  IF (( $OPTION=2))
   CALL get_event_cds_not_on_template_csv(null)
  ENDIF
  IF (( $OPTION=3))
   CALL check_template_against_ce_csv(null)
  ENDIF
 ELSE
  IF (( $OPTION=1))
   CALL get_event_cds_on_template(null)
  ENDIF
  IF (( $OPTION=2))
   IF (currdbver < 11.2)
    CALL get_event_cds_not_on_template(null)
   ELSE
    CALL get_event_cds_not_on_template_new(null)
   ENDIF
  ENDIF
  IF (( $OPTION=3))
   CALL check_template_against_ce(null)
  ENDIF
 ENDIF
 SUBROUTINE amsuser(a_prsnl_id)
   DECLARE user_ind = i2 WITH protect, noconstant(false)
   DECLARE prsnl_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"PRSNL"))
   SELECT INTO "nl:"
    p.person_id
    FROM person_name p
    PLAN (p
     WHERE p.person_id=a_prsnl_id
      AND p.name_type_cd=prsnl_cd
      AND p.name_title="Cerner AMS"
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     IF (p.person_id > 0)
      user_ind = true
     ENDIF
    WITH nocounter
   ;end select
   RETURN(user_ind)
 END ;Subroutine
 SUBROUTINE updtdminfo(a_prog_name)
   DECLARE found = i2 WITH protect, noconstant(false)
   DECLARE info_nbr = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_info d
    PLAN (d
     WHERE d.info_domain="AMS_TOOLKIT"
      AND d.info_name=a_prog_name)
    DETAIL
     found = true, info_nbr = (d.info_number+ 1)
    WITH nocounter
   ;end select
   IF (found=false)
    INSERT  FROM dm_info d
     SET d.info_domain = "AMS_TOOLKIT", d.info_name = a_prog_name, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = info_nbr
     WHERE d.info_domain="AMS_TOOLKIT"
      AND d.info_name=a_prog_name
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE get_template_info(null)
   SET template_id =  $TEMPLATEID
   SELECT INTO "nl:"
    crt.template_name
    FROM cr_report_template crt
    WHERE crt.template_id=template_id
     AND active_ind=1
    HEAD crt.template_id
     template_name = crt.template_name
   ;end select
   FREE RECORD activity_rec
   RECORD activity_rec(
     1 cr_report_section[*]
       2 report_section_id = f8
       2 report_section_name = vc
       2 section_content_type = vc
       2 activity[*]
         3 procedure_type_flag = i2
         3 event_set_name = vc
         3 catalog_cd = f8
         3 event_cds[*]
           4 event_cd = f8
   )
   FREE RECORD temp_activity_rec
   RECORD temp_activity_rec(
     1 cr_report_section[*]
       2 report_section_id = f8
       2 section_content_type = vc
       2 activity[*]
         3 procedure_type_flag = i2
         3 event_set_name = vc
         3 catalog_cd = f8
   )
   FREE RECORD temp_request
   RECORD temp_request(
     1 cr_report_templates[*]
       2 report_template_id = f8
       2 report_template_publish_dt_tm = dq8
     1 cr_report_sections[*]
       2 report_section_id = f8
     1 cr_report_static_regions[*]
       2 report_static_region_id = f8
   )
   DECLARE activitycnt = i4 WITH noconstant(0)
   SET stat = alterlist(temp_request->cr_report_templates,1)
   SET temp_request->cr_report_templates[1].report_template_id = template_id
   SET temp_request->cr_report_templates[1].report_template_publish_dt_tm = cnvtdatetime(
    template_publish_dt_tm)
   FREE RECORD temp_reply
   RECORD temp_reply(
     1 template_version
       2 item[*]
         3 version_id = f8
         3 xml_detail = vc
     1 section_version
       2 item[*]
         3 version_id = f8
         3 xml_detail = vc
     1 static_region_version
       2 item[*]
         3 version_id = f8
         3 xml_detail = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   DECLARE lnumofsects = i4 WITH noconstant(0)
   DECLARE procedure_node = c11 WITH constant("procedure")
   DECLARE section_node = c9 WITH constant("section")
   DECLARE code_attr = c6 WITH constant("code")
   DECLARE type_attr = c6 WITH constant("type")
   DECLARE uid_attr = vc WITH constant("uid")
   DECLARE content_type_attr = vc WITH constant("content-type")
   DECLARE lproccnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(temp_request->cr_report_templates,5)),
     cr_template_publish cpt,
     cr_template_snapshot cts,
     cr_report_section crs
    PLAN (d)
     JOIN (cpt
     WHERE (cpt.template_id=temp_request->cr_report_templates[d.seq].report_template_id)
      AND cpt.beg_effective_dt_tm <= cnvtdatetime(temp_request->cr_report_templates[d.seq].
      report_template_publish_dt_tm)
      AND cpt.end_effective_dt_tm > cnvtdatetime(temp_request->cr_report_templates[d.seq].
      report_template_publish_dt_tm))
     JOIN (cts
     WHERE cts.template_id=cpt.template_id
      AND cts.beg_effective_dt_tm <= cpt.publish_dt_tm
      AND cts.end_effective_dt_tm > cpt.publish_dt_tm
      AND cts.section_id > 0)
     JOIN (crs
     WHERE crs.section_id=cts.section_id
      AND crs.beg_effective_dt_tm <= cpt.publish_dt_tm
      AND crs.end_effective_dt_tm > cpt.publish_dt_tm
      AND crs.active_ind > 0)
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(temp_request->cr_report_sections[cnt],(cnt+ 9))
     ENDIF
     temp_request->cr_report_sections[cnt].report_section_id = crs.report_section_id
    FOOT REPORT
     stat = alterlist(temp_request->cr_report_sections,cnt)
    WITH nocounter
   ;end select
   SET temp_request->cr_report_templates[1].report_template_id = 0
   SET stat = alterlist(temp_request->cr_report_templates,0)
   EXECUTE cr_get_report_long_text  WITH replace(request,temp_request), replace(reply,temp_reply)
   SET lnumofsects = size(temp_reply->section_version.item,5)
   SET stat = alterlist(temp_activity_rec->cr_report_section,lnumofsects)
   DECLARE uar_xml_closefile(filehandle=i4(ref)) = null
   DECLARE uar_xml_getroot(filehandle=i4(ref),nodehandle=i4(ref)) = i4
   DECLARE uar_xml_getchildcount(nodehandle=i4(ref)) = i4
   DECLARE uar_xml_getchildnode(nodehandle=i4(ref),nodeno=i4(ref),childnode=i4(ref)) = i4
   DECLARE uar_xml_getnodename(nodehandle=i4(ref)) = vc
   DECLARE uar_xml_getnodecontent(nodehandle=i4(ref)) = vc
   DECLARE uar_xml_getattrbypos(nodehandle=i4(ref),ndx=i4(ref),attributehandle=i4(ref)) = i4
   DECLARE uar_xml_getattrname(attributehandle=i4(ref)) = vc
   DECLARE uar_xml_getattrvalue(attributehandle=i4(ref)) = vc
   DECLARE uar_xml_getattrcount(nodehandle=i4(ref)) = i4
   DECLARE replace_escaped_xml(xmlstring=vc) = vc
   DECLARE hfile = i4 WITH private
   DECLARE hroot = i4 WITH private
   DECLARE srpt = vc WITH notrim
   DECLARE x = i4 WITH noconstant(0)
   FOR (x = 1 TO lnumofsects)
     SET stat = 0
     SET lproccnt = 0
     SET temp_activity_rec->cr_report_section[x].report_section_id = temp_reply->section_version.
     item[x].version_id
     SET stat = uar_xml_parsestring(nullterm(temp_reply->section_version.item[x].xml_detail),hfile)
     IF (stat=1)
      IF (uar_xml_getroot(hfile,hroot)=1)
       CALL importnode(hroot)
      ENDIF
     ELSE
      SET srpt = concat("File [",temp_reply->section_version.item[x].version_id,
       "] not found, Error Code = ",cnvtstring(stat))
     ENDIF
     SET stat = alterlist(temp_activity_rec->cr_report_section[x].activity,lproccnt)
     CALL uar_xml_closefile(hfile)
   ENDFOR
   SUBROUTINE importnode(hparent)
     DECLARE hattr = i4 WITH private
     DECLARE hchild = i4 WITH private
     DECLARE nodecount = i4 WITH private
     DECLARE attrcount = i4 WITH private
     DECLARE sattname = vc WITH private
     DECLARE sattvalue = vc WITH private
     DECLARE snodename = vc WITH private
     DECLARE chnode = i4 WITH private
     IF (hparent=0)
      RETURN
     ENDIF
     SET nodecount = uar_xml_getchildcount(hparent)
     SET attrcount = uar_xml_getattrcount(hparent)
     SET snodename = trim(uar_xml_getnodename(hparent))
     IF (attrcount > 0
      AND snodename=section_node)
      FOR (at = 0 TO (attrcount - 1))
       SET stat = uar_xml_getattrbypos(hparent,at,hattr)
       IF (stat=1)
        SET sattname = trim(uar_xml_getattrname(hattr))
        SET sattvalue = trim(uar_xml_getattrvalue(hattr))
        IF (sattname=content_type_attr)
         SET temp_activity_rec->cr_report_section[x].section_content_type = replace_escaped_xml(
          sattvalue)
        ENDIF
       ENDIF
      ENDFOR
     ENDIF
     IF (attrcount > 0
      AND snodename=procedure_node)
      SET lproccnt = (lproccnt+ 1)
      IF (mod(lproccnt,10)=1)
       SET stat = alterlist(temp_activity_rec->cr_report_section[x].activity[lproccnt],(lproccnt+ 9))
      ENDIF
      FOR (at = 0 TO (attrcount - 1))
       SET stat = uar_xml_getattrbypos(hparent,at,hattr)
       IF (stat=1)
        SET sattname = trim(uar_xml_getattrname(hattr))
        SET sattvalue = trim(uar_xml_getattrvalue(hattr))
        CASE (sattname)
         OF type_attr:
          IF (sattvalue="event-set")
           SET temp_activity_rec->cr_report_section[x].activity[lproccnt].procedure_type_flag = 0
          ELSEIF (sattvalue="orderable")
           SET temp_activity_rec->cr_report_section[x].activity[lproccnt].procedure_type_flag = 1
          ELSE
           SET temp_activity_rec->cr_report_section[x].activity[lproccnt].procedure_type_flag = - (1)
          ENDIF
         OF uid_attr:
          SET temp_activity_rec->cr_report_section[x].activity[lproccnt].event_set_name =
          replace_escaped_xml(sattvalue)
         OF code_attr:
          SET temp_activity_rec->cr_report_section[x].activity[lproccnt].catalog_cd = cnvtreal(
           sattvalue)
        ENDCASE
       ENDIF
      ENDFOR
     ENDIF
     IF (nodecount > 0)
      FOR (chnode = 0 TO (nodecount - 1))
       SET stat = uar_xml_getchildnode(hparent,chnode,hchild)
       IF (stat=1)
        CALL importnode(hchild)
       ENDIF
      ENDFOR
     ENDIF
   END ;Subroutine
   SUBROUTINE replace_escaped_xml(xmlstring)
     DECLARE __tmpstring = vc WITH protect
     SET __tmpstring = nullterm(xmlstring)
     SET __tmpstring = replace(__tmpstring,"&apos;",char(39),0)
     SET __tmpstring = replace(__tmpstring,"&quot;",char(34),0)
     SET __tmpstring = replace(__tmpstring,"&gt;",">",0)
     SET __tmpstring = replace(__tmpstring,"&lt;","<",0)
     SET __tmpstring = replace(__tmpstring,"&amp;","&",0)
     RETURN(nullterm(__tmpstring))
   END ;Subroutine
   SET stat = alterlist(activity_rec->cr_report_section,lnumofsects)
   FOR (x = 1 TO lnumofsects)
     SET activity_rec->cr_report_section[x].report_section_id = temp_activity_rec->cr_report_section[
     x].report_section_id
     SET activity_rec->cr_report_section[x].section_content_type = temp_activity_rec->
     cr_report_section[x].section_content_type
     IF (lnumofsects > 0)
      SELECT DISTINCT INTO "nl:"
       FROM cr_report_section crs
       PLAN (crs
        WHERE (crs.report_section_id=activity_rec->cr_report_section[x].report_section_id)
         AND crs.active_ind=1
         AND crs.end_effective_dt_tm > sysdate)
       DETAIL
        activity_rec->cr_report_section[x].report_section_name = crs.section_name
       WITH nocounter
      ;end select
      IF (size(temp_activity_rec->cr_report_section[x].activity,5) > 0)
       SELECT DISTINCT INTO "nl:"
        FROM (dummyt d  WITH seq = size(temp_activity_rec->cr_report_section[x].activity,5)),
         v500_event_set_code esc,
         v500_event_set_explode ese
        PLAN (d
         WHERE (temp_activity_rec->cr_report_section[x].activity[d.seq].procedure_type_flag=0))
         JOIN (esc
         WHERE (esc.event_set_name=temp_activity_rec->cr_report_section[x].activity[d.seq].
         event_set_name))
         JOIN (ese
         WHERE ese.event_set_cd=esc.event_set_cd)
        ORDER BY ese.event_set_cd, ese.event_cd
        HEAD REPORT
         activitycnt = 0, codecnt = 0
        HEAD ese.event_set_cd
         IF (ese.event_set_cd > 0)
          activitycnt = (activitycnt+ 1)
          IF (mod(activitycnt,10)=1)
           stat = alterlist(activity_rec->cr_report_section[x].activity[activitycnt],(activitycnt+ 9)
            )
          ENDIF
          activity_rec->cr_report_section[x].activity[activitycnt].procedure_type_flag = 0,
          activity_rec->cr_report_section[x].activity[activitycnt].event_set_name = esc
          .event_set_name
         ENDIF
        DETAIL
         codecnt = (codecnt+ 1)
         IF (mod(codecnt,10)=1)
          stat = alterlist(activity_rec->cr_report_section[x].activity[activitycnt].event_cds,(
           codecnt+ 9))
         ENDIF
         activity_rec->cr_report_section[x].activity[activitycnt].event_cds[codecnt].event_cd = ese
         .event_cd
        FOOT  ese.event_set_cd
         IF (ese.event_set_cd > 0)
          stat = alterlist(activity_rec->cr_report_section[x].activity[activitycnt].event_cds,codecnt
           ), codecnt = 0
         ENDIF
        FOOT REPORT
         stat = alterlist(activity_rec->cr_report_section[x].activity,activitycnt)
        WITH nocounter
       ;end select
       SELECT DISTINCT INTO "nl:"
        FROM (dummyt d  WITH seq = size(temp_activity_rec->cr_report_section[x].activity,5)),
         profile_task_r ptr,
         code_value_event_r cver
        PLAN (d
         WHERE (temp_activity_rec->cr_report_section[x].activity[d.seq].procedure_type_flag=1))
         JOIN (ptr
         WHERE (ptr.catalog_cd=temp_activity_rec->cr_report_section[x].activity[d.seq].catalog_cd)
          AND ptr.catalog_cd > 0)
         JOIN (cver
         WHERE ((cver.parent_cd=ptr.task_assay_cd) OR (cver.parent_cd=ptr.catalog_cd))
          AND cver.parent_cd > 0)
        ORDER BY cver.parent_cd, cver.event_cd
        HEAD REPORT
         codecnt = 0
        HEAD cver.parent_cd
         IF (cver.parent_cd > 0)
          activitycnt = (activitycnt+ 1)
          IF (mod(activitycnt,10)=1)
           stat = alterlist(activity_rec->cr_report_section[x].activity[activitycnt],(activitycnt+ 9)
            )
          ENDIF
          activity_rec->cr_report_section[x].activity[activitycnt].procedure_type_flag = 1,
          activity_rec->cr_report_section[x].activity[activitycnt].catalog_cd = ptr.catalog_cd
         ENDIF
        DETAIL
         codecnt = (codecnt+ 1)
         IF (mod(codecnt,10)=1)
          stat = alterlist(activity_rec->cr_report_section[x].activity[activitycnt].event_cds,(
           codecnt+ 9))
         ENDIF
         activity_rec->cr_report_section[x].activity[activitycnt].event_cds[codecnt].event_cd = cver
         .event_cd
        FOOT  cver.parent_cd
         IF (cver.parent_cd > 0)
          stat = alterlist(activity_rec->cr_report_section[x].activity[activitycnt].event_cds,codecnt
           ), codecnt = 0
         ENDIF
        FOOT REPORT
         stat = alterlist(activity_rec->cr_report_section[x].activity,activitycnt)
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
   ENDFOR
   SET total_section_cnt = size(activity_rec->cr_report_section,5)
   SELECT
    IF (( $SECTIONID != null))
     PLAN (cts
      WHERE (cts.template_id= $TEMPLATEID)
       AND cts.active_ind=1)
      JOIN (crs
      WHERE crs.section_id=cts.section_id
       AND crs.section_id=crs.report_section_id
       AND crs.active_ind=1
       AND (crs.report_section_id= $SECTIONID))
    ELSE
    ENDIF
    INTO "nl"
    crs.section_id
    FROM cr_report_section crs,
     cr_template_snapshot cts
    PLAN (cts
     WHERE (cts.template_id= $TEMPLATEID)
      AND cts.active_ind=1)
     JOIN (crs
     WHERE crs.section_id=cts.section_id
      AND crs.section_id=crs.report_section_id
      AND crs.active_ind=1)
    ORDER BY cts.sequence_nbr
    HEAD REPORT
     selected_section_cnt = 0
    DETAIL
     FOR (h = 1 TO total_section_cnt)
       IF ((activity_rec->cr_report_section[h].report_section_id=crs.section_id))
        selected_section_cnt = (selected_section_cnt+ 1)
        IF (mod(selected_section_cnt,10)=1)
         stat = alterlist(template_rec->cr_report_section[selected_section_cnt],(selected_section_cnt
          + 9))
        ENDIF
        template_rec->cr_report_section[selected_section_cnt].report_section_id = activity_rec->
        cr_report_section[h].report_section_id, template_rec->cr_report_section[selected_section_cnt]
        .report_section_name = activity_rec->cr_report_section[h].report_section_name, template_rec->
        cr_report_section[selected_section_cnt].section_content_type = activity_rec->
        cr_report_section[h].section_content_type,
        stat = alterlist(template_rec->cr_report_section[selected_section_cnt].activity,size(
          activity_rec->cr_report_section[h].activity,5))
        FOR (i = 1 TO size(activity_rec->cr_report_section[h].activity,5))
          template_rec->cr_report_section[selected_section_cnt].activity[i].procedure_type_flag =
          activity_rec->cr_report_section[h].activity[i].procedure_type_flag, template_rec->
          cr_report_section[selected_section_cnt].activity[i].event_set_name = activity_rec->
          cr_report_section[h].activity[i].event_set_name, template_rec->cr_report_section[
          selected_section_cnt].activity[i].catalog_cd = activity_rec->cr_report_section[h].activity[
          i].catalog_cd,
          stat = alterlist(template_rec->cr_report_section[selected_section_cnt].activity[i].
           event_cds,size(activity_rec->cr_report_section[h].activity[i].event_cds,5))
          FOR (j = 1 TO size(activity_rec->cr_report_section[h].activity[i].event_cds,5))
            template_rec->cr_report_section[selected_section_cnt].activity[i].event_cds[j].event_cd
             = activity_rec->cr_report_section[h].activity[i].event_cds[j].event_cd
          ENDFOR
        ENDFOR
       ENDIF
     ENDFOR
    FOOT REPORT
     stat = alterlist(template_rec->cr_report_section,selected_section_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_event_cds_on_template(null)
  DECLARE sline = vc WITH protect, noconstant(concat(
    "====================================================================",
    "========================================================="))
  SELECT INTO  $OUTDEV
   HEAD REPORT
    row 1, col 15,
    "This Report shows all the Event Sets and the Event Codes added to a Report Template",
    row + 1
   HEAD PAGE
    col 30, "Report Template: ", template_short_name = substring(1,40,template_name),
    col + 1, template_short_name, row + 1,
    col 30, "Report Template ID: ", col + 1,
    template_id, row + 1, col 1,
    sline, row + 1, col 1,
    "Event_set_name", col 20, "Event_cd",
    col 30, "Event_cd_disp", col 75,
    "Event_cd", col 85, "Event_cd_disp",
    row + 1, col 1, sline,
    row + 1
   DETAIL
    FOR (h = 1 TO size(template_rec->cr_report_section,5))
      col 1,
      "--------------------------------------------------------------------------------------------",
      row + 1,
      col 1, "Section Name:", section_short_name = substring(1,30,template_rec->cr_report_section[h].
       report_section_name),
      col 20, section_short_name, col 51,
      "(", col + 1, template_rec->cr_report_section[h].report_section_id,
      col + 1, " - ", col + 1,
      template_rec->cr_report_section[h].section_content_type, col + 1, ")",
      row + 1, col 1,
      "--------------------------------------------------------------------------------------------",
      row + 1
      IF (size(template_rec->cr_report_section[h].activity,5) > 0)
       FOR (i = 1 TO size(template_rec->cr_report_section[h].activity,5))
         total_activity_cnt = (total_activity_cnt+ size(template_rec->cr_report_section[h].activity[i
          ].event_cds,5)), col 1, template_rec->cr_report_section[h].activity[i].event_set_name
         FOR (j = 1 TO size(template_rec->cr_report_section[h].activity[i].event_cds,5))
           IF (mod(j,2)=1)
            activity_cnt = (activity_cnt+ 1), row + 1, col 15,
            template_rec->cr_report_section[h].activity[i].event_cds[j].event_cd, event_cd_disp =
            substring(1,40,uar_get_code_display(template_rec->cr_report_section[h].activity[i].
              event_cds[j].event_cd)), col 30,
            event_cd_disp
           ELSE
            col 70, template_rec->cr_report_section[h].activity[i].event_cds[j].event_cd,
            event_cd_disp = substring(1,40,uar_get_code_display(template_rec->cr_report_section[h].
              activity[i].event_cds[j].event_cd)),
            col 85, event_cd_disp
           ENDIF
         ENDFOR
         row + 1
       ENDFOR
      ELSE
       col 5, "No Events Added to this section", row + 1
      ENDIF
    ENDFOR
  ;end select
 END ;Subroutine
 SUBROUTINE get_event_and_catalog_cds(null)
  DECLARE sline = vc WITH protect, constant(concat(
    "----------------------------------------------------------------------",
    "-----------------------------------------------------------"))
  SELECT INTO  $OUTDEV
   HEAD REPORT
    row 1, col 15,
    "This Report shows all the Order Catalog Codes, Event Sets and the Event Codes added to a Report Template",
    row + 1
   HEAD PAGE
    col 30, "Report Template: ", template_short_name = substring(1,40,template_name),
    col + 1, template_short_name, row + 1,
    col 30, "Report Template ID: ", col + 1,
    template_id, row + 1, col 1,
    sline, row + 1, col 1,
    "Event_set_name", col 20, "Event_cd",
    col 40, "Event_cd_disp", col 80,
    "Catalog_cd", col 100, "Catalog_cd_disp",
    row + 1, col 1, sline,
    row + 1
   DETAIL
    FOR (h = 1 TO size(template_rec->cr_report_section,5))
      FOR (i = 1 TO size(template_rec->cr_report_section[h].activity,5))
        total_activity_cnt = (total_activity_cnt+ size(template_rec->cr_report_section[h].activity[i]
         .event_cds,5)), col 1, template_rec->cr_report_section[h].activity[i].event_set_name,
        col 80, template_rec->cr_report_section[h].activity[i].catalog_cd, catalog_cd_disp =
        substring(1,20,uar_get_code_display(template_rec->cr_report_section[h].activity[i].catalog_cd
          )),
        col 100, catalog_cd_disp, row + 1
        FOR (j = 1 TO size(template_rec->cr_report_section[h].activity[i].event_cds,5))
          activity_cnt = (activity_cnt+ 1), col 20, template_rec->cr_report_section[h].activity[i].
          event_cds[j].event_cd,
          event_cd_disp = substring(1,40,uar_get_code_display(template_rec->cr_report_section[h].
            activity[i].event_cds[j].event_cd)), col 40, event_cd_disp,
          row + 1
        ENDFOR
      ENDFOR
    ENDFOR
  ;end select
 END ;Subroutine
 SUBROUTINE get_event_cds_not_on_template(null)
   CALL create_flat_rec(null)
   DECLARE sline = vc WITH protect, constant(concat(
     "-----------------------------------------------------------------------",
     "----------------------------------------------------------"))
   SELECT DISTINCT INTO  $OUTDEV
    ese.event_cd
    FROM v500_event_set_explode ese
    PLAN (ese
     WHERE  NOT (ese.event_cd IN (
     (SELECT
      ese2.event_cd
      FROM v500_event_set_explode ese2
      WHERE expand(num,1,size(flat_activity_rec_cd->qual,5),ese2.event_cd,flat_activity_rec_cd->qual[
       num].event_cd))))
      AND ese.event_cd != 0.00)
    HEAD REPORT
     row 1, col 15,
     "This Report shows all the Event Sets and the Event Codes not added to a Report Template",
     row + 1
    HEAD PAGE
     col 30, "Report Template: ", template_short_name = substring(1,40,template_name),
     col + 1, template_short_name, row + 1,
     col 30, "Report Template ID: ", col + 1,
     template_id, row + 1, col 1,
     sline, row + 1, col 1,
     "Event_cd", col 20, "Event_cd_disp",
     col 71, "Event_cd", col 90,
     "Event_cd_disp", row + 1, col 1,
     sline, row + 1
    DETAIL
     k = (k+ 1)
     IF (mod(k,2)=1)
      row + 1, col 1, ese.event_cd,
      event_cd_disp = substring(1,40,uar_get_code_display(ese.event_cd)), col 20, event_cd_disp
     ELSE
      col 71, ese.event_cd, event_cd_disp = substring(1,40,uar_get_code_display(ese.event_cd)),
      col 90, event_cd_disp
     ENDIF
    WITH expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE get_event_cds_not_on_template_new(null)
   CALL echo("Begin get_event_cds_not_on_template_new")
   CALL create_esh(null)
   DECLARE sline = vc WITH protect, constant(concat(
     "-----------------------------------------------------------------------",
     "----------------------------------------------------------"))
   DECLARE event_set_cnt = i4 WITH protect, noconstant
   DECLARE idx = i4 WITH protect, noconstant
   DECLARE event_cd_cnt = i4 WITH protect, noconstant
   SELECT DISTINCT INTO "nl:"
    ese.event_cd
    FROM v500_event_set_explode ese
    PLAN (ese
     WHERE  NOT (ese.event_cd IN (
     (SELECT
      ese2.event_cd
      FROM v500_event_set_explode ese2
      WHERE expand(num,1,size(flat_activity_rec_cd->qual,5),ese2.event_cd,flat_activity_rec_cd->qual[
       num].event_cd))))
      AND ese.event_cd != 0.00)
    HEAD REPORT
     event_cd_cnt = 0
    DETAIL
     event_cd_cnt = (event_cd_cnt+ 1)
     IF (mod(event_cd_cnt,10)=1)
      stat = alterlist(missing_event_cds->qual,(event_cd_cnt+ 9))
     ENDIF
     missing_event_cds->qual[event_cd_cnt].event_cd = ese.event_cd
    FOOT REPORT
     stat = alterlist(missing_event_cds->qual,event_cd_cnt)
    WITH expand = 1, nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(missing_event_cds->qual,5)),
     v500_event_set_explode ese3
    PLAN (d)
     JOIN (ese3
     WHERE (ese3.event_cd=missing_event_cds->qual[d.seq].event_cd)
      AND ese3.event_set_level=0)
    ORDER BY ese3.event_cd
    DETAIL
     pos = locateval(idx,1,size(esh->event_sets,5),ese3.event_set_cd,esh->event_sets[idx].
      event_set_cd)
     IF (pos > 0)
      esh->event_sets[pos].missing = 1, e = (size(esh->event_sets[pos].event_codes,5)+ 1), stat =
      alterlist(esh->event_sets[pos].event_codes,e),
      esh->event_sets[pos].event_codes[e].event_cd = ese3.event_cd, esh->event_sets[pos].event_codes[
      e].event_cd_disp = uar_get_code_display(ese3.event_cd)
     ENDIF
    WITH nocounter
   ;end select
   SET cur_event_set_cd = 0
   SELECT INTO "nl:"
    d1.seq
    FROM (dummyt d1  WITH seq = size(esh->event_sets,5))
    PLAN (d1)
    DETAIL
     IF ((esh->event_sets[d1.seq].missing=1))
      cur_event_set_cd = esh->event_sets[d1.seq].event_set_cd,
      CALL mark_missing_event_sets(d1.seq)
     ENDIF
    WITH nocounter
   ;end select
   DECLARE string = c50 WITH noconstant("")
   SELECT INTO  $OUTDEV
    d0.seq
    FROM (dummyt d0  WITH seq = size(esh->event_sets,5))
    PLAN (d0)
    HEAD REPORT
     row 1, col 15,
     "This Report shows all the Event Sets and the Event Codes missing from a Report Template",
     row + 1
    HEAD PAGE
     col 30, "Report Template: ", template_short_name = substring(1,40,template_name),
     col + 1, template_short_name, row + 1,
     col 30, "Report Template ID: ", col + 1,
     template_id, row + 1, col 1,
     sline, row + 1
    DETAIL
     IF ((esh->event_sets[d0.seq].missing=1))
      string = "", string = build(esh->event_sets[d0.seq].event_set_disp," (",esh->event_sets[d0.seq]
       .event_set_cd,")")
      CASE (esh->event_sets[d0.seq].event_set_level)
       OF 1:
        col 0,string
       OF 2:
        col 2,string
       OF 3:
        col 4,string
       OF 4:
        col 6,string
       OF 5:
        col 8,string
       OF 6:
        col 10,string
       OF 7:
        col 12,string
       OF 8:
        col 14,string
       OF 9:
        col 16,string
       OF 10:
        col 18,string
       ELSE
        col 20,string
      ENDCASE
      row + 1
      FOR (i = 1 TO size(esh->event_sets[d0.seq].event_codes,5))
        string = "", string = build(esh->event_sets[d0.seq].event_codes[i].event_cd_disp," (",esh->
         event_sets[d0.seq].event_codes[i].event_cd,") [EC]"), col 25,
        string, row + 1
      ENDFOR
     ENDIF
    WITH nocounter
   ;end select
   CALL echo("End get_event_cds_not_on_template_new")
 END ;Subroutine
 SUBROUTINE check_template_against_ce(null)
   CALL create_flat_rec(null)
   DECLARE sline = vc WITH protect, constant(concat(
     "=====================================================================",
     "=====================================================================",
     "=================================================================="))
   SELECT
    IF (( $ACCESSIONNBR != ""))
     PLAN (ce
      WHERE expand(num,1,size(flat_activity_rec_cd->qual,5),ce.event_cd,flat_activity_rec_cd->qual[
       num].event_cd)
       AND (ce.accession_nbr= $ACCESSIONNBR)
       AND ce.valid_until_dt_tm > sysdate)
    ELSEIF (( $ENCNTRID != 0))
     PLAN (ce
      WHERE expand(num,1,size(flat_activity_rec_cd->qual,5),ce.event_cd,flat_activity_rec_cd->qual[
       num].event_cd)
       AND (ce.encntr_id= $ENCNTRID)
       AND ce.valid_until_dt_tm > sysdate)
    ELSE
    ENDIF
    INTO  $OUTDEV
    FROM clinical_event ce
    PLAN (ce
     WHERE expand(num,1,size(flat_activity_rec_cd->qual,5),ce.event_cd,flat_activity_rec_cd->qual[num
      ].event_cd)
      AND (ce.person_id= $PERSONID)
      AND ce.valid_until_dt_tm > sysdate)
    HEAD REPORT
     row 1, col 15,
     "This Report shows the clinical event results that would print on a Report Template",
     row + 1
    HEAD PAGE
     col 30, "Report Template: ", template_short_name = substring(1,40,template_name),
     col + 1, template_short_name, row + 1,
     col 30, "Report Template ID: ", col + 1,
     template_id, row + 1, col 1,
     sline, row + 1, col 1,
     "Event Display", col 20, "Event_cd",
     col 35, "Event Class", col 50,
     "Result Status", col 65, "Event_id",
     col 77, "Parent_event_id", col 94,
     "Clinsig_updt_dt_tm", col 120, "Result Value",
     col 145, "Section_id", col 165,
     "Content_Type", col 185, "Section Name",
     row + 1, col 1, sline,
     row + 1
    DETAIL
     pos = locateval(num,1,size(flat_activity_rec_cd->qual,5),ce.event_cd,flat_activity_rec_cd->qual[
      num].event_cd), evt_disp = substring(1,20,uar_get_code_display(ce.event_cd)), col 1,
     evt_disp, col 20, ce.event_cd,
     evt_class = substring(1,10,uar_get_code_meaning(ce.event_class_cd)), col 35, evt_class,
     result_status = substring(1,10,uar_get_code_meaning(ce.result_status_cd)), col 50, result_status,
     col 65, ce.event_id, col 77,
     ce.parent_event_id, col 94, ce.clinsig_updt_dt_tm,
     result_value = substring(1,20,ce.result_val), col 120, result_value,
     col 145, flat_activity_rec_cd->qual[pos].report_section_id, col 165,
     flat_activity_rec_cd->qual[pos].section_content_type, col 185, flat_activity_rec_cd->qual[pos].
     report_section_name,
     row + 1
    WITH format(date,";;q"), maxcol = 220, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_flat_rec(null)
   FOR (h = 1 TO size(template_rec->cr_report_section,5))
     FOR (i = 1 TO size(template_rec->cr_report_section[h].activity,5))
       SET total_activity_cnt = (total_activity_cnt+ size(template_rec->cr_report_section[h].
        activity[i].event_cds,5))
       SET stat = alterlist(flat_activity_rec_cd->qual,total_activity_cnt)
       FOR (j = 1 TO size(template_rec->cr_report_section[h].activity[i].event_cds,5))
         SET activity_cnt = (activity_cnt+ 1)
         SET flat_activity_rec_cd->qual[activity_cnt].event_cd = template_rec->cr_report_section[h].
         activity[i].event_cds[j].event_cd
         SET flat_activity_rec_cd->qual[activity_cnt].report_section_id = template_rec->
         cr_report_section[h].report_section_id
         SET flat_activity_rec_cd->qual[activity_cnt].report_section_name = template_rec->
         cr_report_section[h].report_section_name
         SET flat_activity_rec_cd->qual[activity_cnt].section_content_type = template_rec->
         cr_report_section[h].section_content_type
       ENDFOR
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE create_esh(null)
   CALL echo("Begin create_esh")
   DECLARE x1 = i4 WITH noconstant(0)
   DECLARE offset = i4 WITH noconstant(0)
   DECLARE comma_cnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    p.coll_seq_key, col1 = cnvtint(piece(p.coll_seq_key,",",1,"0")), col2 = cnvtint(piece(p
      .coll_seq_key,",",2,"0")),
    col3 = cnvtint(piece(p.coll_seq_key,",",3,"0")), col4 = cnvtint(piece(p.coll_seq_key,",",4,"0")),
    col5 = cnvtint(piece(p.coll_seq_key,",",5,"0")),
    col6 = cnvtint(piece(p.coll_seq_key,",",6,"0")), col7 = cnvtint(piece(p.coll_seq_key,",",7,"0")),
    col8 = cnvtint(piece(p.coll_seq_key,",",8,"0")),
    col9 = cnvtint(piece(p.coll_seq_key,",",9,"0")), col10 = cnvtint(piece(p.coll_seq_key,",",10,"0")
     )
    FROM (
     (
     (SELECT
      parent.event_set_cd, parent.parent_event_set_cd, parent.event_set_collating_seq,
      lev = 1, parent_collating_seq = parent.event_set_collating_seq, coll_seq_key = concat("1,",
       cnvtstring(parent.event_set_collating_seq))
      FROM v500_event_set_canon parent
      WHERE ((parent.parent_event_set_cd=allresultsect_cd) UNION ALL (
      (SELECT
       child.event_set_cd, child.parent_event_set_cd, child.event_set_collating_seq,
       lev = (parent.lev+ 1), parent_collating_seq = parent.event_set_collating_seq, coll_seq_key =
       concat(coll_seq_key,",",cnvtstring(child.event_set_collating_seq))
       FROM recursiveparent parent,
        v500_event_set_canon child
       WHERE ((child.parent_event_set_cd=parent.event_set_cd) RECURSIVE (
       (SELECT
        event_set_cd, parent_event_set_cd, event_set_collating_seq,
        lev, parent_collating_seq, coll_seq_key
        FROM recursiveparent))) )))
      WITH sqltype("F8","F8","I4","I4","I4",
        "C40"), recursive = recursiveparent(event_set_cd,parent_event_set_cd,event_set_collating_seq,
        lev,parent_collating_seq,
        coll_seq_key)))
     p)
    ORDER BY col1, col2, col3,
     col4, col5, col6,
     col7, col8, col9,
     col10
    HEAD REPORT
     event_set_cnt = 1, cur_event_set_cd = p.event_set_cd, cur_level = 1
     IF (mod(event_set_cnt,10)=1)
      stat = alterlist(esh->event_sets,(event_set_cnt+ 9))
     ENDIF
     esh->event_sets[event_set_cnt].event_set_cd = allresultsect_cd, esh->event_sets[event_set_cnt].
     event_set_disp = uar_get_code_display(allresultsect_cd), esh->event_sets[event_set_cnt].
     parent_event_set_cd = 0,
     esh->event_sets[event_set_cnt].collation_seq = 1, esh->event_sets[event_set_cnt].coll_seq_key =
     "1", esh->event_sets[event_set_cnt].event_set_level = 1
    DETAIL
     event_set_cnt = (event_set_cnt+ 1)
     IF (mod(event_set_cnt,10)=1)
      stat = alterlist(esh->event_sets,(event_set_cnt+ 9))
     ENDIF
     esh->event_sets[event_set_cnt].event_set_cd = p.event_set_cd, esh->event_sets[event_set_cnt].
     event_set_disp = uar_get_code_display(p.event_set_cd), esh->event_sets[event_set_cnt].
     parent_event_set_cd = p.parent_event_set_cd,
     esh->event_sets[event_set_cnt].collation_seq = p.event_set_collating_seq, esh->event_sets[
     event_set_cnt].coll_seq_key = p.coll_seq_key, comma_cnt = 0,
     x1 = size(trim(esh->event_sets[event_set_cnt].coll_seq_key)), offset = 1
     WHILE ((offset <= (x1+ 2)))
      IF (substring(offset,1,esh->event_sets[event_set_cnt].coll_seq_key)=",")
       comma_cnt = (comma_cnt+ 1)
      ENDIF
      ,offset = (offset+ 1)
     ENDWHILE
     esh->event_sets[event_set_cnt].event_set_level = (comma_cnt+ 1)
    FOOT REPORT
     stat = alterlist(esh->event_sets,event_set_cnt)
    WITH nocounter
   ;end select
   CALL echo("End create_esh")
 END ;Subroutine
 SUBROUTINE mark_missing_event_sets(pos)
   DECLARE idx = i4
   SET esh->event_sets[pos].missing = 1
   SET pos = locateval(idx,1,size(esh->event_sets,5),esh->event_sets[pos].parent_event_set_cd,esh->
    event_sets[idx].event_set_cd)
   IF (pos > 0)
    CALL mark_missing_event_sets(pos)
   ELSE
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE get_event_cds_on_template_csv(null)
   SELECT INTO  $OUTDEV
    HEAD REPORT
     row 1, col 1, "Report Templat Name",
     col + 0, ",Report_Template_ID", col + 0,
     ",Section Name", col + 0, ",Content_type",
     col + 0, ",Section_ID", col + 0,
     ",Event_set_name", col + 0, ",Event_cd",
     col + 0, ",Event_cd_disp", row + 1
    DETAIL
     FOR (h = 1 TO size(template_rec->cr_report_section,5))
       IF (size(template_rec->cr_report_section[h].activity,5) > 0)
        FOR (i = 1 TO size(template_rec->cr_report_section[h].activity,5))
         total_activity_cnt = (total_activity_cnt+ size(template_rec->cr_report_section[h].activity[i
          ].event_cds,5)),
         FOR (j = 1 TO size(template_rec->cr_report_section[h].activity[i].event_cds,5))
           col 1, template_name, col + 0,
           ",", col + 0, template_id,
           col + 0, ",", section_name = template_rec->cr_report_section[h].report_section_name,
           col + 0, section_name, col + 0,
           ",", col + 0, template_rec->cr_report_section[h].section_content_type,
           col + 0, ",", col + 0,
           template_rec->cr_report_section[h].report_section_id, col + 0, ",",
           col + 0, template_rec->cr_report_section[h].activity[i].event_set_name, col + 0,
           ",", col + 0, template_rec->cr_report_section[h].activity[i].event_cds[j].event_cd,
           col + 0, ",", event_cd_disp = uar_get_code_display(template_rec->cr_report_section[h].
            activity[i].event_cds[j].event_cd),
           col + 0, event_cd_disp, row + 1
         ENDFOR
        ENDFOR
       ENDIF
     ENDFOR
    WITH maxcol = 200
   ;end select
 END ;Subroutine
 SUBROUTINE get_event_cds_not_on_template_csv(null)
  CALL create_flat_rec(null)
  SELECT DISTINCT INTO  $OUTDEV
   ese.event_cd
   FROM v500_event_set_explode ese
   PLAN (ese
    WHERE  NOT (ese.event_cd IN (
    (SELECT
     ese2.event_cd
     FROM v500_event_set_explode ese2
     WHERE expand(num,1,size(flat_activity_rec_cd->qual,5),ese2.event_cd,flat_activity_rec_cd->qual[
      num].event_cd))))
     AND ese.event_cd != 0.00)
   HEAD REPORT
    row 1, col 1, "Event_cd",
    col + 0, ",Event_cd_disp", row + 1
   DETAIL
    col 1, ese.event_cd, col + 0,
    ",", event_cd_disp = uar_get_code_display(ese.event_cd), col + 0,
    event_cd_disp, row + 1
   WITH expand = 1
  ;end select
 END ;Subroutine
 SUBROUTINE check_template_against_ce_csv(null)
  CALL create_flat_rec(null)
  SELECT
   IF (( $ACCESSIONNBR != ""))
    PLAN (ce
     WHERE expand(num,1,size(flat_activity_rec_cd->qual,5),ce.event_cd,flat_activity_rec_cd->qual[num
      ].event_cd)
      AND (ce.accession_nbr= $ACCESSIONNBR)
      AND ce.valid_until_dt_tm > sysdate)
   ELSEIF (( $ENCNTRID != 0))
    PLAN (ce
     WHERE expand(num,1,size(flat_activity_rec_cd->qual,5),ce.event_cd,flat_activity_rec_cd->qual[num
      ].event_cd)
      AND (ce.encntr_id= $ENCNTRID)
      AND ce.valid_until_dt_tm > sysdate)
   ELSE
   ENDIF
   INTO  $OUTDEV
   FROM clinical_event ce
   PLAN (ce
    WHERE expand(num,1,size(flat_activity_rec_cd->qual,5),ce.event_cd,flat_activity_rec_cd->qual[num]
     .event_cd)
     AND (ce.person_id= $PERSONID)
     AND ce.valid_until_dt_tm > sysdate)
   HEAD REPORT
    row 1, col 1, "Event Display",
    col + 0, ",Event_cd", col + 0,
    ",Event Class", col + 0, ",Result Status",
    col + 0, ",Event_id", col + 0,
    ",Parent_event_id", col + 0, ",Clinsig_updt_dt_tm",
    col + 0, ",Result Value", col + 0,
    ",Section_id", col + 0, ",Content_Type",
    col + 0, ",Section Name", row + 1
   DETAIL
    pos = locateval(num,1,size(flat_activity_rec_cd->qual,5),ce.event_cd,flat_activity_rec_cd->qual[
     num].event_cd), evt_disp = uar_get_code_display(ce.event_cd), col 1,
    evt_disp, col + 0, ",",
    col + 0, ce.event_cd, col + 0,
    ",", evt_class = uar_get_code_meaning(ce.event_class_cd), col + 0,
    evt_class, col + 0, ",",
    result_status = uar_get_code_meaning(ce.result_status_cd), col + 0, result_status,
    col + 0, ",", col + 0,
    ce.event_id, col + 0, ",",
    col + 0, ce.parent_event_id, col + 0,
    ",", col + 0, ce.clinsig_updt_dt_tm,
    col + 0, ",", result_value = substring(1,20,ce.result_val),
    col + 0, result_value, col + 0,
    ",", col + 0, flat_activity_rec_cd->qual[pos].report_section_id,
    col + 0, ",", col + 0,
    flat_activity_rec_cd->qual[pos].section_content_type, col + 0, ",",
    col + 0, flat_activity_rec_cd->qual[pos].report_section_name, row + 1
   WITH format(date,";;q"), maxcol = 220, expand = 1
  ;end select
 END ;Subroutine
#exit_script
 SET script_ver = "004  07/01/2016  SG7581                       Add ESH hierarchy to option 2"
END GO
