CREATE PROGRAM bed_rec_dup_la_po_detail:dba
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
 SET col_cnt = 8
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Check Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Laboratory Assay Short Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Laboratory Assay Activity Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Assay Active Indicator"
 SET reply->collist[4].data_type = 3
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Pharmacy Primary Synonym"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Pharmacy Orderable Item Active Indicator"
 SET reply->collist[6].data_type = 3
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Recommendation"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Resolution"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET cnt = 0
 SET tcnt = 0
 SET rcnt = 0
 SET reply->run_status_flag = 1
 DECLARE short_desc = vc
 DECLARE resolution_txt = vc
 SET plsize = size(request->paramlist,5)
 FOR (x = 1 TO plsize)
   IF ((request->paramlist[x].meaning="EMARDTAORDDUP"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="EMARDTAORDDUP")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SET pharm_at = 0.0
    SET pharm_at = uar_get_code_by("MEANING",106,"PHARMACY")
    SET ap_at = 0.0
    SET ap_at = uar_get_code_by("MEANING",106,"AP")
    SET bb_at = 0.0
    SET bb_at = uar_get_code_by("MEANING",106,"BB")
    SET glb_at = 0.0
    SET glb_at = uar_get_code_by("MEANING",106,"GLB")
    SET micro_at = 0.0
    SET micro_at = uar_get_code_by("MEANING",106,"MICROBIOLOGY")
    SELECT INTO "nl:"
     FROM order_catalog oc,
      discrete_task_assay dta,
      code_value c
     PLAN (oc
      WHERE trim(oc.primary_mnemonic) > ""
       AND oc.activity_type_cd=pharm_at)
      JOIN (dta
      WHERE dta.mnemonic_key_cap=cnvtupper(oc.primary_mnemonic)
       AND dta.activity_type_cd IN (ap_at, bb_at, glb_at, micro_at))
      JOIN (c
      WHERE c.code_value=dta.activity_type_cd
       AND c.active_ind=1)
     ORDER BY dta.mnemonic, c.display
     DETAIL
      stat = add_rep(short_desc,dta.mnemonic,c.display,dta.active_ind,oc.primary_mnemonic,
       oc.active_ind,"Mnemonics should be unique",resolution_txt)
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SUBROUTINE add_rep(p1,p2,p3,p4,p5,p6,p7,p8)
   SET row_tot_cnt = (size(reply->rowlist,5)+ 1)
   SET stat = alterlist(reply->rowlist,row_tot_cnt)
   SET stat = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt)
   SET reply->rowlist[row_tot_cnt].celllist[1].string_value = p1
   SET reply->rowlist[row_tot_cnt].celllist[2].string_value = p2
   SET reply->rowlist[row_tot_cnt].celllist[3].string_value = p3
   SET reply->rowlist[row_tot_cnt].celllist[4].nbr_value = p4
   SET reply->rowlist[row_tot_cnt].celllist[5].string_value = p5
   SET reply->rowlist[row_tot_cnt].celllist[6].nbr_value = p6
   SET reply->rowlist[row_tot_cnt].celllist[7].string_value = p7
   SET reply->rowlist[row_tot_cnt].celllist[8].string_value = p8
   RETURN(1)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
