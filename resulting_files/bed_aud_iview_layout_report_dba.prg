CREATE PROGRAM bed_aud_iview_layout_report:dba
 IF ( NOT (validate(request,0)))
  FREE SET request
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 iviews[*]
      2 view_id = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
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
 FREE RECORD temp
 RECORD temp(
   1 wvs[*]
     2 id = f8
     2 name = vc
     2 sections[*]
       3 id = f8
       3 name = vc
       3 status = vc
       3 open_ind = vc
       3 event_set_name = vc
       3 subsection[*]
         4 id = f8
         4 name = vc
         4 display = vc
         4 prim_disp = vc
         4 disp_assoc = i2
         4 fall_off_time = vc
         4 disp_assoc_name = vc
         4 disp_assoc_cd = f8
         4 prim_event_set = vc
         4 prim_event_set_name = vc
         4 item_status = vc
         4 da_list[*]
           5 prim_event_set = vc
         4 details[*]
           5 da_prim_event_set = vc
           5 assay_mnemonic = vc
           5 assay_result_type = vc
           5 alpha_response
             6 display = vc
             6 result_detail = vc
           5 uom = vc
           5 max_digits = vc
           5 min_digits = vc
           5 dec_places = vc
           5 def_value = vc
           5 age_range = vc
           5 ref_low = vc
           5 ref_high = vc
           5 crt_low = vc
           5 crt_high = vc
           5 fea_low = vc
           5 fea_high = vc
           5 sex = vc
           5 calc = vc
           5 dynamic = vc
           5 dynamic_type = vc
           5 dynamic_id = f8
 )
 FREE RECORD dynamic_added
 RECORD dynamic_added(
   1 dadd[*]
     2 label_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 EXECUTE prefrtl
 SET reply->status_data.status = "F"
 SET minutes_per_year = 525600
 SET minutes_per_month = 43200
 SET minutes_per_week = 10080
 SET minutes_per_day = 1440
 SET minutes_per_hour = 60
 SET minutes_per_minute = 1
 SET female = 0.0
 SET female = uar_get_code_by("MEANING",57,"FEMALE")
 SET male = 0.0
 SET male = uar_get_code_by("MEANING",57,"MALE")
 SET unknown = 0.0
 SET unknown = uar_get_code_by("MEANING",57,"UNKNOWN")
 SET hours = 0.0
 SET hours = uar_get_code_by("MEANING",340,"HOURS")
 SET days = 0.0
 SET days = uar_get_code_by("MEANING",340,"DAYS")
 SET weeks = 0.0
 SET weeks = uar_get_code_by("MEANING",340,"WEEKS")
 SET months = 0.0
 SET months = uar_get_code_by("MEANING",340,"MONTHS")
 SET years = 0.0
 SET years = uar_get_code_by("MEANING",340,"YEARS")
 SET tot_col = 14
 SET stat = alterlist(reply->collist,tot_col)
 SET reply->collist[1].header_text = "View"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Section Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Section Display"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Section Status"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Section Default Open"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Primitive Fall-Off Hours"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Subsection Name"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Subsection Display"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Display Association"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Dynamic Group"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Primitive Event Set Name"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Primitive Event Set Display"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Item Status"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Assay Display"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET req_cnt = size(request->iviews,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 SET tot_wvcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   working_view wv,
   working_view_section wvs,
   v500_event_set_code vsi,
   v500_event_set_code ves,
   working_view_item wvi
  PLAN (d)
   JOIN (wv
   WHERE (wv.working_view_id=request->iviews[d.seq].view_id)
    AND wv.active_ind=1)
   JOIN (wvs
   WHERE wvs.working_view_id=wv.working_view_id)
   JOIN (wvi
   WHERE wvi.working_view_section_id=outerjoin(wvs.working_view_section_id))
   JOIN (vsi
   WHERE cnvtupper(vsi.event_set_name)=outerjoin(cnvtupper(wvi.parent_event_set_name)))
   JOIN (ves
   WHERE cnvtupper(ves.event_set_name)=outerjoin(cnvtupper(wvi.primitive_event_set_name)))
  ORDER BY wv.display_name, wv.working_view_id, wvs.working_view_section_id,
   wvi.working_view_item_id
  HEAD REPORT
   wvcnt = 0, tot_wvcnt = 0, stat = alterlist(temp->wvs,100)
  HEAD wv.working_view_id
   wvcnt = (wvcnt+ 1), tot_wvcnt = (tot_wvcnt+ 1)
   IF (wvcnt > 100)
    stat = alterlist(temp->wvs,(tot_wvcnt+ 100)), wvcnt = 1
   ENDIF
   temp->wvs[tot_wvcnt].id = wv.working_view_id, temp->wvs[tot_wvcnt].name = wv.display_name, wscnt
    = 0,
   tot_wscnt = 0, stat = alterlist(temp->wvs[tot_wvcnt].sections,100)
  HEAD wvs.working_view_section_id
   wicnt = 0, tot_wicnt = 0, wvs_set = 0
  HEAD wvi.working_view_item_id
   IF (wvs_set=0
    AND ((wvs.section_type_flag=1) OR (wvi.working_view_item_id > 0
    AND vsi.event_set_cd > 0
    AND ves.event_set_cd > 0)) )
    wvs_set = 1, wscnt = (wscnt+ 1), tot_wscnt = (tot_wscnt+ 1)
    IF (wscnt > 100)
     stat = alterlist(temp->wvs[tot_wvcnt].sections,(tot_wscnt+ 100)), wscnt = 1
    ENDIF
    temp->wvs[tot_wvcnt].sections[tot_wscnt].id = wvs.working_view_section_id, temp->wvs[tot_wvcnt].
    sections[tot_wscnt].name = wvs.display_name, temp->wvs[tot_wvcnt].sections[tot_wscnt].
    event_set_name = wvs.event_set_name
    IF (wvs.included_ind=1)
     temp->wvs[tot_wvcnt].sections[tot_wscnt].status = "Included"
    ELSEIF (wvs.required_ind=1)
     temp->wvs[tot_wvcnt].sections[tot_wscnt].status = "Required"
    ELSE
     temp->wvs[tot_wvcnt].sections[tot_wscnt].status = "Excluded"
    ENDIF
    stat = alterlist(temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection,100)
   ENDIF
   IF (wvi.working_view_item_id > 0
    AND vsi.event_set_cd > 0
    AND ves.event_set_cd > 0)
    wicnt = (wicnt+ 1), tot_wicnt = (tot_wicnt+ 1)
    IF (wicnt > 100)
     stat = alterlist(temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection,(tot_wicnt+ 100)), wicnt =
     1
    ENDIF
    IF (wvi.falloff_view_minutes > 0)
     ftime = 0.0, ftime = (wvi.falloff_view_minutes/ 60), temp->wvs[tot_wvcnt].sections[tot_wscnt].
     subsection[tot_wicnt].fall_off_time = build(ftime),
     temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].fall_off_time = substring(1,(
      findstring(".",temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].fall_off_time,1,1
       )+ 2),temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].fall_off_time)
    ENDIF
    temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].id = wvi.working_view_item_id
    IF (cnvtupper(wvi.parent_event_set_name) != cnvtupper(wvs.event_set_name))
     temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].name = wvi.parent_event_set_name,
     temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].display = vsi.event_set_cd_disp
    ENDIF
    IF (wvi.included_ind=1)
     temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].item_status = "Included"
    ELSE
     temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].item_status = "Excluded"
    ENDIF
    temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].prim_event_set = ves
    .event_set_cd_disp, temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].
    prim_event_set_name = wvi.primitive_event_set_name, temp->wvs[tot_wvcnt].sections[tot_wscnt].
    subsection[tot_wicnt].prim_disp = ves.event_set_cd_disp,
    temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].disp_assoc = ves
    .display_association_ind
    IF (ves.display_association_ind=1)
     temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].disp_assoc_name = ves
     .event_set_name, temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].disp_assoc_cd =
     ves.event_set_cd
    ENDIF
   ENDIF
  FOOT  wvs.working_view_section_id
   stat = alterlist(temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection,tot_wicnt)
  FOOT  wv.working_view_id
   stat = alterlist(temp->wvs[tot_wvcnt].sections,tot_wscnt)
  FOOT REPORT
   stat = alterlist(temp->wvs,tot_wvcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("working view retrieval error")
 FOR (x = 1 TO tot_wvcnt)
  SET sec_cnt = size(temp->wvs[x].sections,5)
  FOR (y = 1 TO sec_cnt)
   SET sub_cnt = size(temp->wvs[x].sections[y].subsection,5)
   IF (sub_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = sub_cnt),
      v500_event_code vc,
      v500_event_set_code vsc,
      v500_event_set_explode ve,
      discrete_task_assay dta,
      dynamic_label_template dgt,
      doc_set_ref dsr
     PLAN (d
      WHERE (temp->wvs[x].sections[y].subsection[d.seq].disp_assoc != 1))
      JOIN (vsc
      WHERE cnvtupper(vsc.event_set_name)=cnvtupper(temp->wvs[x].sections[y].subsection[d.seq].
       prim_event_set_name))
      JOIN (ve
      WHERE ve.event_set_cd=vsc.event_set_cd
       AND ve.event_set_level=0)
      JOIN (vc
      WHERE vc.event_cd=ve.event_cd)
      JOIN (dta
      WHERE dta.event_cd=outerjoin(vc.event_cd))
      JOIN (dgt
      WHERE dgt.label_template_id=outerjoin(dta.label_template_id))
      JOIN (dsr
      WHERE dsr.doc_set_ref_id=outerjoin(dgt.doc_set_ref_id)
       AND dsr.active_ind=outerjoin(1))
     ORDER BY d.seq, dta.mnemonic
     HEAD d.seq
      ecnt = 0, etot_cnt = 0, stat = alterlist(temp->wvs[x].sections[y].subsection[d.seq].details,100
       )
     DETAIL
      ecnt = (ecnt+ 1), etot_cnt = (etot_cnt+ 1)
      IF (ecnt > 100)
       stat = alterlist(temp->wvs[x].sections[y].subsection[d.seq].details,(etot_cnt+ 100)), ecnt = 1
      ENDIF
      temp->wvs[x].sections[y].subsection[d.seq].details[etot_cnt].assay_mnemonic = dta.mnemonic
      IF (dsr.doc_set_ref_id > 0)
       temp->wvs[x].sections[y].subsection[d.seq].details[etot_cnt].dynamic_type = "Template", temp->
       wvs[x].sections[y].subsection[d.seq].details[etot_cnt].dynamic_id = dsr.doc_set_ref_id
      ENDIF
     FOOT  d.seq
      stat = alterlist(temp->wvs[x].sections[y].subsection[d.seq].details,etot_cnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("non-display associations retrieval error")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = sub_cnt),
      v500_event_set_canon vs,
      v500_event_set_code vc
     PLAN (d
      WHERE (temp->wvs[x].sections[y].subsection[d.seq].disp_assoc=1))
      JOIN (vs
      WHERE (vs.parent_event_set_cd=temp->wvs[x].sections[y].subsection[d.seq].disp_assoc_cd))
      JOIN (vc
      WHERE vc.event_set_cd=vs.event_set_cd)
     ORDER BY d.seq
     HEAD d.seq
      ecnt = 0, etot_cnt = 0, stat = alterlist(temp->wvs[x].sections[y].subsection[d.seq].da_list,100
       )
     HEAD vc.event_set_cd
      ecnt = (ecnt+ 1), etot_cnt = (etot_cnt+ 1)
      IF (ecnt > 100)
       stat = alterlist(temp->wvs[x].sections[y].subsection[d.seq].da_list,(etot_cnt+ 100)), ecnt = 1
      ENDIF
      temp->wvs[x].sections[y].subsection[d.seq].da_list[etot_cnt].prim_event_set = vc.event_set_name
     FOOT  d.seq
      stat = alterlist(temp->wvs[x].sections[y].subsection[d.seq].da_list,etot_cnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("display associations retrieval error")
    IF ((temp->wvs[x].name > " "))
     SET hpref = uar_prefcreateinstance(18)
     SET stat = uar_prefsetbasedn(hpref,"prefcontext=default,prefroot=prefroot")
     SET stat = uar_prefaddattr(hpref,"prefvalue")
     SET stat = uar_prefaddfilter(hpref,"prefentry=default_open")
     SET stat = uar_prefperform(hpref)
     DECLARE count = i4
     SET stat = uar_prefgetentrycount(hpref,count)
     SET i = 0
     DECLARE dnstr = c255 WITH noconstant("")
     DECLARE grpstr = c255 WITH noconstant("")
     DECLARE cxtstr = c255 WITH noconstant("")
     DECLARE viewstr = c255 WITH noconstant("")
     SET strlen = 255
     FOR (xx = 0 TO (count - 1))
       SET hentry = uar_prefgetentry(hpref,xx)
       SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
       SET a = findstring("prefcontext=",dnstr,1)
       SET b = findstring("=",dnstr,a)
       SET c = findstring(",",dnstr,(b+ 1))
       SET cxtstr = substring((b+ 1),((c - b) - 1),dnstr)
       SET a = findstring("prefgroup=",dnstr,1)
       SET b = findstring("=",dnstr,a)
       SET c = findstring(",",dnstr,a)
       SET viewstr = substring((b+ 1),((c - b) - 1),dnstr)
       SET acnt = 0
       SET stat = uar_prefgetentryattrcount(hentry,acnt)
       FOR (yy = 0 TO (acnt - 1))
         SET hattr = uar_prefgetentryattr(hentry,yy)
         SET valcnt = 0
         SET stat = uar_prefgetattrvalcount(hattr,valcnt)
         DECLARE xvalue = c255 WITH noconstant("")
         IF (cnvtupper(viewstr)=cnvtupper(temp->wvs[x].name))
          SET search_ind = 0
          FOR (zz = 0 TO (valcnt - 1))
            SET stat = uar_prefgetattrval(hattr,xvalue,255,zz)
            SET search_ind = 1
            IF (cnvtupper(temp->wvs[x].sections[y].event_set_name)=cnvtupper(xvalue))
             SET temp->wvs[x].sections[y].open_ind = "Yes"
            ENDIF
          ENDFOR
          IF (search_ind=1
           AND (temp->wvs[x].sections[y].open_ind != "Yes"))
           SET temp->wvs[x].sections[y].open_ind = "No"
          ENDIF
         ENDIF
       ENDFOR
     ENDFOR
     CALL uar_prefdestroyinstance(hpref)
    ENDIF
    FOR (z = 1 TO sub_cnt)
      IF ((temp->wvs[x].sections[y].subsection[z].disp_assoc=1))
       SET da_cnt = size(temp->wvs[x].sections[y].subsection[z].da_list,5)
       IF (da_cnt > 0)
        SELECT INTO "nl:"
         FROM (dummyt d  WITH seq = da_cnt),
          v500_event_code vc,
          discrete_task_assay dta,
          dynamic_label_template dgt,
          doc_set_ref dsr
         PLAN (d)
          JOIN (vc
          WHERE cnvtupper(vc.event_set_name)=outerjoin(cnvtupper(temp->wvs[x].sections[y].subsection[
            z].da_list[d.seq].prim_event_set)))
          JOIN (dta
          WHERE dta.event_cd=outerjoin(vc.event_cd))
          JOIN (dgt
          WHERE dgt.label_template_id=outerjoin(dta.label_template_id))
          JOIN (dsr
          WHERE dsr.doc_set_ref_id=outerjoin(dgt.doc_set_ref_id)
           AND dsr.active_ind=outerjoin(1))
         ORDER BY d.seq, dta.mnemonic
         HEAD REPORT
          ecnt = 0, etot_cnt = 0, stat = alterlist(temp->wvs[x].sections[y].subsection[z].details,100
           )
         DETAIL
          ecnt = (ecnt+ 1), etot_cnt = (etot_cnt+ 1)
          IF (ecnt > 100)
           stat = alterlist(temp->wvs[x].sections[y].subsection[z].details,(etot_cnt+ 100)), ecnt = 1
          ENDIF
          temp->wvs[x].sections[y].subsection[z].details[etot_cnt].da_prim_event_set = temp->wvs[x].
          sections[y].subsection[z].da_list[d.seq].prim_event_set, temp->wvs[x].sections[y].
          subsection[z].details[etot_cnt].assay_mnemonic = dta.mnemonic
          IF (dsr.doc_set_ref_id > 0)
           temp->wvs[x].sections[y].subsection[z].details[etot_cnt].dynamic_type = "Template", temp->
           wvs[x].sections[y].subsection[z].details[etot_cnt].dynamic_id = dsr.doc_set_ref_id
          ENDIF
         FOOT REPORT
          stat = alterlist(temp->wvs[x].sections[y].subsection[z].details,etot_cnt)
         WITH nocounter
        ;end select
        CALL bederrorcheck("disp event code retrieval error")
       ELSE
        SELECT INTO "nl:"
         FROM v500_event_code vc,
          discrete_task_assay dta,
          dynamic_label_template dgt,
          doc_set_ref dsr
         PLAN (vc
          WHERE (vc.event_set_name=temp->wvs[x].sections[y].subsection[z].disp_assoc_name))
          JOIN (dta
          WHERE dta.event_cd=outerjoin(vc.event_cd))
          JOIN (dgt
          WHERE dgt.label_template_id=outerjoin(dta.label_template_id))
          JOIN (dsr
          WHERE dsr.doc_set_ref_id=outerjoin(dgt.doc_set_ref_id)
           AND dsr.active_ind=outerjoin(1))
         ORDER BY dta.mnemonic
         HEAD REPORT
          ecnt = 0, etot_cnt = 0, stat = alterlist(temp->wvs[x].sections[y].subsection[z].details,100
           )
         DETAIL
          ecnt = (ecnt+ 1), etot_cnt = (etot_cnt+ 1)
          IF (ecnt > 100)
           stat = alterlist(temp->wvs[x].sections[y].subsection[z].details,(etot_cnt+ 100)), ecnt = 1
          ENDIF
          temp->wvs[x].sections[y].subsection[z].details[etot_cnt].assay_mnemonic = dta.mnemonic,
          temp->wvs[x].sections[y].subsection[z].details[etot_cnt].da_prim_event_set = vc
          .event_set_name
          IF (dsr.doc_set_ref_id > 0)
           temp->wvs[x].sections[y].subsection[z].details[etot_cnt].dynamic_type = "Template", temp->
           wvs[x].sections[y].subsection[z].details[etot_cnt].dynamic_id = dsr.doc_set_ref_id
          ENDIF
         FOOT REPORT
          stat = alterlist(temp->wvs[x].sections[y].subsection[z].details,etot_cnt)
         WITH nocounter
        ;end select
        CALL bederrorcheck("no disp event code retrieval error")
       ENDIF
      ENDIF
      SET det_cnt = size(temp->wvs[x].sections[y].subsection[z].details,5)
      IF (det_cnt > 0)
       FOR (a = 1 TO det_cnt)
        IF ((temp->wvs[x].sections[y].subsection[z].details[a].dynamic_id > 0))
         SELECT INTO "nl:"
          FROM discrete_task_assay dta,
           doc_set_element_ref der,
           doc_set_section_ref_r drr,
           v500_event_set_explode ve,
           v500_event_set_code v
          PLAN (drr
           WHERE (drr.doc_set_ref_id=temp->wvs[x].sections[y].subsection[z].details[a].dynamic_id)
            AND drr.active_ind=1)
           JOIN (der
           WHERE der.doc_set_section_ref_id=drr.doc_set_section_ref_id
            AND der.active_ind=1
            AND der.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
            AND der.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
           JOIN (dta
           WHERE dta.task_assay_cd=der.task_assay_cd)
           JOIN (ve
           WHERE dta.event_cd=ve.event_cd
            AND ve.event_set_level=0)
           JOIN (v
           WHERE v.event_set_cd=ve.event_set_cd)
          ORDER BY der.doc_set_elem_sequence
          DETAIL
           found_label_ind = 0, dy_size = size(dynamic_added->dadd,5)
           IF (dy_size > 0)
            FOR (da = 1 TO dy_size)
              IF ((dynamic_added->dadd[da].label_id=der.doc_set_element_id))
               found_label_ind = 1
              ENDIF
            ENDFOR
           ENDIF
           IF (((dy_size=0) OR (found_label_ind=0)) )
            dy_size = (dy_size+ 1), stat = alterlist(dynamic_added->dadd,dy_size), dynamic_added->
            dadd[dy_size].label_id = der.doc_set_element_id,
            stat = add_label(x,y,z,v.event_set_name,v.event_set_cd_disp,
             dta.mnemonic)
           ENDIF
          WITH nocounter
         ;end select
         CALL bederrorcheck("dynamic label retrieval error")
        ENDIF
        SET stat = add_rep(x,y,z,a)
       ENDFOR
      ELSE
       SET stat = add_rep(x,y,z,0)
      ENDIF
    ENDFOR
   ELSE
    SET stat = add_rep(x,y,0,0)
   ENDIF
  ENDFOR
 ENDFOR
 SUBROUTINE add_rep(p1,p2,p3,p4)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,tot_col)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->wvs[p1].name
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->wvs[p1].sections[p2].event_set_name
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->wvs[p1].sections[p2].name
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->wvs[p1].sections[p2].status
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->wvs[p1].sections[p2].open_ind
   IF (p3 > 0)
    SET reply->rowlist[row_nbr].celllist[6].string_value = temp->wvs[p1].sections[p2].subsection[p3].
    fall_off_time
    SET reply->rowlist[row_nbr].celllist[7].string_value = temp->wvs[p1].sections[p2].subsection[p3].
    name
    SET reply->rowlist[row_nbr].celllist[8].string_value = temp->wvs[p1].sections[p2].subsection[p3].
    display
    SET reply->rowlist[row_nbr].celllist[9].string_value = temp->wvs[p1].sections[p2].subsection[p3].
    disp_assoc_name
    SET reply->rowlist[row_nbr].celllist[11].string_value = temp->wvs[p1].sections[p2].subsection[p3]
    .prim_event_set_name
    SET reply->rowlist[row_nbr].celllist[12].string_value = temp->wvs[p1].sections[p2].subsection[p3]
    .prim_disp
    SET reply->rowlist[row_nbr].celllist[13].string_value = temp->wvs[p1].sections[p2].subsection[p3]
    .item_status
    IF (p4 > 0)
     SET reply->rowlist[row_nbr].celllist[10].string_value = temp->wvs[p1].sections[p2].subsection[p3
     ].details[p4].dynamic_type
     SET reply->rowlist[row_nbr].celllist[14].string_value = temp->wvs[p1].sections[p2].subsection[p3
     ].details[p4].assay_mnemonic
     IF ((temp->wvs[p1].sections[p2].subsection[p3].disp_assoc=1))
      SET reply->rowlist[row_nbr].celllist[11].string_value = temp->wvs[p1].sections[p2].subsection[
      p3].details[p4].da_prim_event_set
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_label(l1,l2,l3,l4,l5,l6)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,tot_col)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->wvs[l1].name
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->wvs[l1].sections[l2].event_set_name
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->wvs[l1].sections[l2].name
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->wvs[l1].sections[l2].status
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->wvs[l1].sections[l2].open_ind
   SET reply->rowlist[row_nbr].celllist[6].string_value = temp->wvs[l1].sections[l2].subsection[l3].
   fall_off_time
   SET reply->rowlist[row_nbr].celllist[7].string_value = temp->wvs[l1].sections[l2].subsection[l3].
   name
   SET reply->rowlist[row_nbr].celllist[8].string_value = temp->wvs[l1].sections[l2].subsection[l3].
   display
   SET reply->rowlist[row_nbr].celllist[9].string_value = temp->wvs[l1].sections[l2].subsection[l3].
   disp_assoc_name
   SET reply->rowlist[row_nbr].celllist[10].string_value = "Label"
   SET reply->rowlist[row_nbr].celllist[11].string_value = l4
   SET reply->rowlist[row_nbr].celllist[12].string_value = l5
   SET reply->rowlist[row_nbr].celllist[13].string_value = temp->wvs[l1].sections[l2].subsection[l3].
   item_status
   SET reply->rowlist[row_nbr].celllist[14].string_value = l6
   RETURN(1)
 END ;Subroutine
 IF ((request->skip_volume_check_ind=0))
  IF (row_nbr > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ELSEIF (row_nbr > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
 SET reply->run_status_flag = 1
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("iview_design_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
