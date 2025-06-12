CREATE PROGRAM bed_rec_ord_items_detail:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 paramlist[*]
      2 meaning = vc
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp(
   1 pelist[*]
     2 oe_format = f8
     2 oe_field = f8
     2 catalog = f8
     2 synonym = f8
 )
 SET col_cnt = 6
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Check Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Catalog Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Activity Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Subactivity Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Millennium Name (Primary Synonym)"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Resolution"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET cnt = 0
 SET tcnt = 0
 SET rcnt = 0
 SET reply->run_status_flag = 1
 DECLARE short_desc = vc
 DECLARE resolution_txt = vc
 SET plsize = size(request->paramlist,5)
 FOR (x = 1 TO plsize)
   IF ((request->paramlist[x].meaning="PARCHILDORDALLIGN"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="PARCHILDORDALLIGN")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SET cont_pass_value = 0
    SET acc_pass_value = 0
    SET cont_fail_value = 0
    DECLARE order_action = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
    DECLARE z_var = f8 WITH constant(uar_get_code_by("MEANING",6011,"TRADEPROD")), protect
    DECLARE y_var = f8 WITH constant(uar_get_code_by("MEANING",6011,"GENERICPROD")), protect
    SET tcnt = 0
    SELECT DISTINCT INTO "nl:"
     FROM order_catalog oc,
      order_catalog_synonym ocs,
      order_entry_format oef,
      oe_format_fields off,
      order_entry_fields oefs,
      oe_field_meaning ofm,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      code_value cv4
     PLAN (oc
      WHERE oc.active_ind=1
       AND oc.cont_order_method_flag=0)
      JOIN (ocs
      WHERE ocs.catalog_cd=oc.catalog_cd
       AND  NOT (ocs.mnemonic_type_cd IN (z_var, y_var))
       AND ocs.active_ind=1)
      JOIN (oef
      WHERE oef.oe_format_id=ocs.oe_format_id
       AND oef.action_type_cd=order_action)
      JOIN (off
      WHERE off.oe_format_id=oef.oe_format_id
       AND off.action_type_cd=oef.action_type_cd)
      JOIN (oefs
      WHERE oefs.oe_field_id=off.oe_field_id)
      JOIN (ofm
      WHERE ofm.oe_field_meaning_id=oefs.oe_field_meaning_id
       AND trim(ofm.oe_field_meaning) IN ("FREQ", "FREQSCHEDID"))
      JOIN (cv1
      WHERE outerjoin(oc.catalog_type_cd)=cv1.code_value
       AND cv1.active_ind=outerjoin(1))
      JOIN (cv2
      WHERE outerjoin(oc.activity_type_cd)=cv2.code_value
       AND cv2.active_ind=outerjoin(1))
      JOIN (cv3
      WHERE outerjoin(oc.activity_subtype_cd)=cv3.code_value
       AND cv3.active_ind=outerjoin(1))
      JOIN (cv4
      WHERE outerjoin(ocs.mnemonic_type_cd)=cv4.code_value
       AND cv4.active_ind=outerjoin(1))
     ORDER BY oc.primary_mnemonic, ocs.synonym_id
     HEAD oc.primary_mnemonic
      temp_cnt = 0
     HEAD ocs.synonym_id
      tmp_cnt = 0
     DETAIL
      IF (((off.accept_flag=0) OR (((off.accept_flag=1) OR (((off.accept_flag=2) OR (off.accept_flag=
      3))
       AND ((off.default_value > " ") OR (off.default_parent_entity_id > 0)) )) )) )
       temp_cnt = (temp_cnt+ 1)
      ELSE
       cont_pass_value = 1, tcnt = (tcnt+ 1), stat = alterlist(temp->pelist,tcnt),
       temp->pelist[tcnt].oe_format = oef.oe_format_id, temp->pelist[tcnt].oe_field = off.oe_field_id,
       temp->pelist[tcnt].catalog = oc.catalog_cd,
       temp->pelist[tcnt].synonym = ocs.synonym_id,
       CALL echo(build("temp->pelist[tcnt].oe_format",temp->pelist[tcnt].oe_format)), acc_pass_value
        = 1
      ENDIF
     FOOT  oc.primary_mnemonic
      IF (temp_cnt > 0)
       stat = add_rep(short_desc,cv1.display,cv2.display,cv3.display,oc.primary_mnemonic,
        resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (tcnt=0)
     GO TO exit_script
    ENDIF
    IF (tcnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = tcnt),
       order_catalog oc,
       order_catalog_synonym ocs,
       accept_format_flexing aff,
       code_value cv1,
       code_value cv2,
       code_value cv3,
       code_value cv4
      PLAN (d
       WHERE (temp->pelist[d.seq].oe_format > 0))
       JOIN (oc
       WHERE (oc.catalog_cd=temp->pelist[d.seq].catalog)
        AND oc.cont_order_method_flag=0
        AND oc.active_ind=1)
       JOIN (ocs
       WHERE (ocs.synonym_id=temp->pelist[d.seq].synonym)
        AND ocs.catalog_cd=oc.catalog_cd
        AND  NOT (ocs.mnemonic_type_cd IN (z_var, y_var))
        AND ocs.active_ind=1)
       JOIN (aff
       WHERE (aff.oe_format_id=temp->pelist[d.seq].oe_format)
        AND (aff.oe_field_id=temp->pelist[d.seq].oe_field)
        AND aff.action_type_cd=order_action)
       JOIN (cv1
       WHERE outerjoin(oc.catalog_type_cd)=cv1.code_value
        AND cv1.active_ind=outerjoin(1))
       JOIN (cv2
       WHERE outerjoin(oc.activity_type_cd)=cv2.code_value
        AND cv2.active_ind=outerjoin(1))
       JOIN (cv3
       WHERE outerjoin(oc.activity_subtype_cd)=cv3.code_value
        AND cv3.active_ind=outerjoin(1))
       JOIN (cv4
       WHERE outerjoin(ocs.mnemonic_type_cd)=cv4.code_value
        AND cv4.active_ind=outerjoin(1))
      ORDER BY oc.primary_mnemonic, ocs.synonym_id
      HEAD oc.primary_mnemonic
       temp_cnt = 0
      HEAD ocs.synonym_id
       tmp_cnt = 0
      DETAIL
       IF (((aff.accept_flag=0) OR (((aff.accept_flag=1) OR (((aff.accept_flag=2) OR (aff.accept_flag
       =3))
        AND ((aff.default_value > " ") OR (aff.default_parent_entity_id > 0)) )) )) )
        temp_cnt = (temp_cnt+ 1)
       ELSE
        cont_pass_value = 1, acc_pass_value = 1
       ENDIF
      FOOT  oc.primary_mnemonic
       IF (temp_cnt > 0)
        stat = add_rep(short_desc,cv1.display,cv2.display,cv3.display,oc.primary_mnemonic,
         resolution_txt)
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE add_rep(p1,p2,p3,p4,p5,p6)
   SET row_tot_cnt = (size(reply->rowlist,5)+ 1)
   SET stat = alterlist(reply->rowlist,row_tot_cnt)
   SET stat = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt)
   SET reply->rowlist[row_tot_cnt].celllist[1].string_value = p1
   SET reply->rowlist[row_tot_cnt].celllist[2].string_value = p2
   SET reply->rowlist[row_tot_cnt].celllist[3].string_value = p3
   SET reply->rowlist[row_tot_cnt].celllist[4].string_value = p4
   SET reply->rowlist[row_tot_cnt].celllist[5].string_value = p5
   SET reply->rowlist[row_tot_cnt].celllist[6].string_value = p6
   RETURN(1)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
