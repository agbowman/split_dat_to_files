CREATE PROGRAM bed_rec_surg_doc_detail:dba
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
 SET col_cnt = 10
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Check Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Institution"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Department"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Surgical Area"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Surgical Stage"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Document Type"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Setting Name"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Recommended Setting"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Actual Setting"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Resolution"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->run_status_flag = 1
 DECLARE short_desc = vc
 DECLARE resolution_txt = vc
 SET plsize = size(request->paramlist,5)
 FOR (x = 1 TO plsize)
  IF ((request->paramlist[x].meaning="SURGAUTOFILL"))
   SET short_desc = ""
   SET resolution_txt = ""
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE b.rec_mean="SURGAUTOFILL")
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
    WITH nocounter
   ;end select
   SET inst_code = 0.0
   SET inst_code = uar_get_code_by("MEANING",223,"INSTITUTION")
   SET dept_code = 0.0
   SET dept_code = uar_get_code_by("MEANING",223,"DEPARTMENT")
   SET surg_code = 0.0
   SET surg_code = uar_get_code_by("MEANING",223,"SURGAREA")
   SELECT INTO "nl:"
    FROM sn_doc_ref sdr,
     sn_name_value_prefs snvp,
     sn_name_value_prefs snvp2,
     code_value cv,
     resource_group rg_dp,
     resource_group rg_sa,
     resource_group rg_ss,
     code_value inst,
     code_value dept,
     code_value sa,
     code_value ss
    PLAN (sdr)
     JOIN (snvp
     WHERE snvp.parent_entity_id=sdr.doc_ref_id
      AND snvp.parent_entity_name="SN_DOC_REF"
      AND cnvtupper(snvp.pref_name)="AUTO_FILL_IND")
     JOIN (snvp2
     WHERE snvp2.parent_entity_id=snvp.parent_entity_id
      AND snvp2.parent_entity_name="SN_DOC_REF"
      AND cnvtupper(snvp2.pref_name)="QTY_ON_HAND_IND"
      AND snvp2.pref_value=snvp.pref_value)
     JOIN (cv
     WHERE cv.code_value=sdr.doc_type_cd
      AND cv.active_ind=1)
     JOIN (ss
     WHERE ss.code_value=sdr.stage_cd
      AND ss.active_ind=1)
     JOIN (rg_ss
     WHERE rg_ss.child_service_resource_cd=ss.code_value
      AND rg_ss.resource_group_type_cd=surg_code
      AND rg_ss.parent_service_resource_cd=sdr.area_cd
      AND rg_ss.root_service_resource_cd=0
      AND rg_ss.active_ind=1)
     JOIN (sa
     WHERE sa.code_value=rg_ss.parent_service_resource_cd
      AND sa.active_ind=1)
     JOIN (rg_sa
     WHERE rg_sa.child_service_resource_cd=sa.code_value
      AND rg_sa.resource_group_type_cd=dept_code
      AND rg_sa.root_service_resource_cd=0
      AND rg_sa.active_ind=1)
     JOIN (dept
     WHERE dept.code_value=rg_sa.parent_service_resource_cd
      AND dept.active_ind=1)
     JOIN (rg_dp
     WHERE rg_dp.child_service_resource_cd=dept.code_value
      AND rg_dp.resource_group_type_cd=inst_code
      AND rg_dp.root_service_resource_cd=0
      AND rg_dp.active_ind=1)
     JOIN (inst
     WHERE inst.code_value=rg_dp.parent_service_resource_cd
      AND inst.active_ind=1)
    ORDER BY inst.display, dept.display, sa.display,
     ss.display, cv.display
    DETAIL
     IF (snvp.pref_value="1")
      stat = add_rep(short_desc,inst.display,dept.display,sa.display,ss.display,
       cv.display,snvp.pref_name,"0-No, when QTY_ON_HAND = 1-Yes","1-Yes",resolution_txt)
     ELSE
      stat = add_rep(short_desc,inst.display,dept.display,sa.display,ss.display,
       cv.display,snvp.pref_name,"1-Yes, when QTY_ON_HAND = 0-No","0-No",resolution_txt)
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF ((request->paramlist[x].meaning="SURGPICKLIST"))
   SET short_desc = ""
   SET resolution_txt = ""
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE b.rec_mean="SURGPICKLIST")
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
    WITH nocounter
   ;end select
   SET inst_code = 0.0
   SET inst_code = uar_get_code_by("MEANING",223,"INSTITUTION")
   SET dept_code = 0.0
   SET dept_code = uar_get_code_by("MEANING",223,"DEPARTMENT")
   SET surg_code = 0.0
   SET surg_code = uar_get_code_by("MEANING",223,"SURGAREA")
   SELECT INTO "nl:"
    FROM sn_doc_ref sdr,
     sn_name_value_prefs snvp,
     code_value cv,
     resource_group rg_dp,
     resource_group rg_sa,
     resource_group rg_ss,
     code_value inst,
     code_value dept,
     code_value sa,
     code_value ss
    PLAN (sdr)
     JOIN (snvp
     WHERE snvp.parent_entity_id=sdr.doc_ref_id
      AND snvp.parent_entity_name="SN_DOC_REF"
      AND cnvtupper(snvp.pref_name)="BY_PROC_PICK_LIST_IND")
     JOIN (cv
     WHERE cv.code_value=sdr.doc_type_cd
      AND cv.active_ind=1)
     JOIN (ss
     WHERE ss.code_value=sdr.stage_cd
      AND ss.active_ind=1)
     JOIN (rg_ss
     WHERE rg_ss.child_service_resource_cd=ss.code_value
      AND rg_ss.resource_group_type_cd=surg_code
      AND rg_ss.parent_service_resource_cd=sdr.area_cd
      AND rg_ss.root_service_resource_cd=0
      AND rg_ss.active_ind=1)
     JOIN (sa
     WHERE sa.code_value=rg_ss.parent_service_resource_cd
      AND sa.active_ind=1)
     JOIN (rg_sa
     WHERE rg_sa.child_service_resource_cd=sa.code_value
      AND rg_sa.resource_group_type_cd=dept_code
      AND rg_sa.root_service_resource_cd=0
      AND rg_sa.active_ind=1)
     JOIN (dept
     WHERE dept.code_value=rg_sa.parent_service_resource_cd
      AND dept.active_ind=1)
     JOIN (rg_dp
     WHERE rg_dp.child_service_resource_cd=dept.code_value
      AND rg_dp.resource_group_type_cd=inst_code
      AND rg_dp.root_service_resource_cd=0
      AND rg_dp.active_ind=1)
     JOIN (inst
     WHERE inst.code_value=rg_dp.parent_service_resource_cd
      AND inst.active_ind=1)
    ORDER BY inst.display, dept.display, sa.display,
     ss.display, cv.display
    DETAIL
     IF (snvp.pref_value != "1")
      stat = add_rep(short_desc,inst.display,dept.display,sa.display,ss.display,
       cv.display,snvp.pref_name,"1-Procedure","0-Case",resolution_txt)
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET stat = add_rep(short_desc,"","","","",
     "","BY_PROC_PICK_LIST_IND","1-Procedure","Not Set",resolution_txt)
   ENDIF
  ENDIF
 ENDFOR
 SUBROUTINE add_rep(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)
   SET row_tot_cnt = (size(reply->rowlist,5)+ 1)
   SET stat = alterlist(reply->rowlist,row_tot_cnt)
   SET stat = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt)
   SET reply->rowlist[row_tot_cnt].celllist[1].string_value = p1
   SET reply->rowlist[row_tot_cnt].celllist[2].string_value = p2
   SET reply->rowlist[row_tot_cnt].celllist[3].string_value = p3
   SET reply->rowlist[row_tot_cnt].celllist[4].string_value = p4
   SET reply->rowlist[row_tot_cnt].celllist[5].string_value = p5
   SET reply->rowlist[row_tot_cnt].celllist[6].string_value = p6
   SET reply->rowlist[row_tot_cnt].celllist[7].string_value = p7
   SET reply->rowlist[row_tot_cnt].celllist[8].string_value = p8
   SET reply->rowlist[row_tot_cnt].celllist[9].string_value = p9
   SET reply->rowlist[row_tot_cnt].celllist[10].string_value = p10
   RETURN(1)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
