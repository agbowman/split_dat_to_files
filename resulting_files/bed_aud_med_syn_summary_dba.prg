CREATE PROGRAM bed_aud_med_syn_summary:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 synonyms[*]
      2 id = f8
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
 FREE RECORD temp
 RECORD temp(
   1 synonyms[*]
     2 id = f8
     2 mnemonic = vc
     2 type = vc
     2 powerplans[*]
       3 name = vc
       3 phase_pcat_id = f8
     2 caresets[*]
       3 description = vc
       3 primary_syn = vc
     2 orderfolders[*]
       3 unique_desc = vc
       3 display_name = vc
       3 owner = vc
 )
 SET reply->status_data.status = "F"
 SET rcnt = size(request->synonyms,5)
 IF (rcnt > 0)
  SET pcount = 0
  SET oscount = 0
  SET ofcount = 0
  SET tcnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = rcnt),
    order_catalog_synonym ocs,
    code_value cv
   PLAN (d)
    JOIN (ocs
    WHERE (ocs.synonym_id=request->synonyms[d.seq].id)
     AND ocs.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=outerjoin(ocs.mnemonic_type_cd)
     AND cv.active_ind=outerjoin(1))
   ORDER BY cnvtupper(ocs.mnemonic)
   DETAIL
    tcnt = (tcnt+ 1), stat = alterlist(temp->synonyms,tcnt), temp->synonyms[tcnt].id = ocs.synonym_id,
    temp->synonyms[tcnt].mnemonic = ocs.mnemonic, temp->synonyms[tcnt].type = cv.display
   WITH nocounter
  ;end select
  IF (tcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = tcnt),
     pathway_comp p,
     pathway_catalog pc
    PLAN (d)
     JOIN (p
     WHERE p.parent_entity_name="ORDER_CATALOG_SYNONYM"
      AND (p.parent_entity_id=temp->synonyms[d.seq].id)
      AND p.active_ind=1)
     JOIN (pc
     WHERE pc.pathway_catalog_id=outerjoin(p.pathway_catalog_id)
      AND pc.active_ind=outerjoin(1))
    ORDER BY d.seq, pc.description
    HEAD d.seq
     pcount = 0
    DETAIL
     IF (pc.pathway_catalog_id > 0)
      pcount = (pcount+ 1), stat = alterlist(temp->synonyms[d.seq].powerplans,pcount)
      IF (pc.type_mean="PHASE")
       temp->synonyms[d.seq].powerplans[pcount].phase_pcat_id = pc.pathway_catalog_id
      ELSE
       temp->synonyms[d.seq].powerplans[pcount].name = pc.description
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   FOR (s = 1 TO tcnt)
    SET pcnt = size(temp->synonyms[s].powerplans,5)
    IF (pcnt > 0)
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = pcnt),
       pw_cat_reltn pw,
       pathway_catalog pcat
      PLAN (d
       WHERE (temp->synonyms[s].powerplans[d.seq].phase_pcat_id > 0))
       JOIN (pw
       WHERE (pw.pw_cat_t_id=temp->synonyms[s].powerplans[d.seq].phase_pcat_id)
        AND pw.type_mean="GROUP")
       JOIN (pcat
       WHERE pcat.pathway_catalog_id=pw.pw_cat_s_id)
      DETAIL
       temp->synonyms[s].powerplans[d.seq].name = pcat.description
      WITH nocounter
     ;end select
    ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = tcnt),
     alt_sel_list l,
     alt_sel_cat c,
     prsnl p
    PLAN (d)
     JOIN (l
     WHERE (l.synonym_id=temp->synonyms[d.seq].id))
     JOIN (c
     WHERE c.alt_sel_category_id=outerjoin(l.alt_sel_category_id))
     JOIN (p
     WHERE p.person_id=outerjoin(c.owner_id)
      AND p.active_ind=outerjoin(1))
    ORDER BY d.seq, c.long_description, c.short_description
    HEAD d.seq
     ofcount = 0
    DETAIL
     IF (c.alt_sel_category_id > 0
      AND c.adhoc_ind IN (0, null)
      AND c.ahfs_ind IN (0, null))
      ofcount = (ofcount+ 1), stat = alterlist(temp->synonyms[d.seq].orderfolders,ofcount), temp->
      synonyms[d.seq].orderfolders[ofcount].unique_desc = c.long_description,
      temp->synonyms[d.seq].orderfolders[ofcount].display_name = c.short_description, temp->synonyms[
      d.seq].orderfolders[ofcount].owner = p.name_full_formatted
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = tcnt),
     cs_component cc,
     order_catalog oc
    PLAN (d)
     JOIN (cc
     WHERE (cc.comp_id=temp->synonyms[d.seq].id))
     JOIN (oc
     WHERE oc.catalog_cd=outerjoin(cc.catalog_cd)
      AND oc.active_ind=outerjoin(1))
    ORDER BY d.seq, oc.description
    HEAD d.seq
     oscount = 0
    DETAIL
     IF (oc.catalog_cd > 0)
      oscount = (oscount+ 1), stat = alterlist(temp->synonyms[d.seq].caresets,oscount), temp->
      synonyms[d.seq].caresets[oscount].description = oc.description,
      temp->synonyms[d.seq].caresets[oscount].primary_syn = oc.primary_mnemonic
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,8)
 SET reply->collist[1].header_text = "Synonym"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Synonym Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Order Set Description"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Order Set Millennium Name (Primary Synonym)"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "PowerPlan"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Order Folder Unique Description"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Order Folder Display Name"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Order Folder Owner"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET tcnt = size(temp->synonyms,5)
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SET high_volume_cnt = 0
  FOR (x = 1 TO tcnt)
    SET ppcnt = size(temp->synonyms[x].powerplans,5)
    SET cscnt = size(temp->synonyms[x].caresets,5)
    SET ofcnt = size(temp->synonyms[x].orderfolders,5)
    SET maxlength = maxval(ppcnt,cscnt,ofcnt)
    SET high_volume_cnt = (high_volume_cnt+ maxlength)
  ENDFOR
  CALL echo(build("***** high_volume_cnt = ",high_volume_cnt))
  IF (high_volume_cnt > 60000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 30000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET ppcnt = size(temp->synonyms[x].powerplans,5)
   SET cscnt = size(temp->synonyms[x].caresets,5)
   SET ofcnt = size(temp->synonyms[x].orderfolders,5)
   SET maxlength = maxval(ppcnt,cscnt,ofcnt)
   FOR (t = 1 TO maxlength)
     SET row_nbr = (row_nbr+ 1)
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,8)
     SET reply->rowlist[row_nbr].celllist[1].string_value = temp->synonyms[x].mnemonic
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->synonyms[x].type
     IF (t <= cscnt)
      SET reply->rowlist[row_nbr].celllist[3].string_value = temp->synonyms[x].caresets[t].
      description
      SET reply->rowlist[row_nbr].celllist[4].string_value = temp->synonyms[x].caresets[t].
      primary_syn
     ENDIF
     IF (t <= ppcnt)
      SET reply->rowlist[row_nbr].celllist[5].string_value = temp->synonyms[x].powerplans[t].name
     ENDIF
     IF (t <= ofcnt)
      SET reply->rowlist[row_nbr].celllist[6].string_value = temp->synonyms[x].orderfolders[t].
      unique_desc
      SET reply->rowlist[row_nbr].celllist[7].string_value = temp->synonyms[x].orderfolders[t].
      display_name
      SET reply->rowlist[row_nbr].celllist[8].string_value = temp->synonyms[x].orderfolders[t].owner
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("med_syn_summary.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO
