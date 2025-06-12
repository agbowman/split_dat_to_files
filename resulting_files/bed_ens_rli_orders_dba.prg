CREATE PROGRAM bed_ens_rli_orders:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET dtalist
 RECORD dtalist(
   1 catcd = f8
   1 dlist[*]
     2 dtacd = f8
     2 description = vc
     2 mnemonic = vc
     2 alias = vc
 )
 FREE RECORD cntnrs
 RECORD cntnrs(
   1 cntnrlist[*]
     2 c_rli_alias_id = f8
     2 c_alias = vc
     2 c_code_value = f8
 )
 FREE SET children
 RECORD children(
   1 clist[*]
     2 child_rli_order_id = f8
 )
 FREE SET ch_cntnrs
 RECORD ch_cntnrs(
   1 ch_rli_order_id = f8
   1 ch_clist[*]
     2 ch_cntnr_id = f8
     2 ch_alias = vc
     2 ch_code_value = f8
 )
 FREE SET add_syns
 RECORD add_syns(
   1 rli_order_id = f8
   1 syn_list[*]
     2 syn_type = i2
     2 synonym = vc
 )
 FREE SET cvlist
 RECORD cvlist(
   1 cvrec[*]
     2 cs = i4
     2 cv = f8
     2 disp = vc
     2 code_value = f8
 )
 FREE RECORD cv_request
 RECORD cv_request(
   1 cd_value_list[*]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 FREE RECORD cv_reply
 RECORD cv_reply(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD orc_request
 RECORD orc_request(
   1 list_0[*]
     2 description = vc
     2 hna_mnemonic = vc
     2 dept_name = vc
     2 catalog_type_cd = vc
     2 activity_type_cd = vc
     2 activity_subtype_cd = vc
     2 order_entry_format = vc
     2 dcp_clin_cat_cd = vc
     2 mnemonic_type = vc
     2 mnemonic = vc
     2 billcode = vc
     2 concept_cki = vc
     2 catalog_cki = vc
 )
 FREE RECORD orc_reply
 RECORD orc_reply(
   1 oc_list[*]
     2 catalog_cd = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET dta_request
 RECORD dta_request(
   1 assay_list[*]
     2 action_flag = i2
     2 code_value = f8
     2 display = c40
     2 description = vc
     2 general_info
       3 result_type_code_value = f8
       3 activity_type_code_value = f8
       3 delta_check_ind = i2
       3 inter_data_check_ind = i2
       3 res_proc_type_code_value = f8
       3 rad_section_type_code_value = f8
       3 single_select_ind = i2
       3 io_flag = i2
       3 default_type_flag = i2
       3 sci_notation_ind = i2
     2 data_map[*]
       3 action_flag = i4
       3 service_resource_code_value = f8
       3 min_digits = i4
       3 max_digits = i4
       3 dec_place = i4
     2 rr_list[*]
       3 action_flag = i4
       3 rrf_id = f8
       3 def_value = f8
       3 uom_code_value = f8
       3 from_age = i4
       3 from_age_code_value = f8
       3 to_age = i4
       3 to_age_code_value = f8
       3 sex_code_value = f8
       3 specimen_type_code_value = f8
       3 service_resource_code_value = f8
       3 ref_low = f8
       3 ref_high = f8
       3 ref_ind = i2
       3 crit_low = f8
       3 crit_high = f8
       3 crit_ind = i2
       3 review_low = f8
       3 review_high = f8
       3 review_ind = i2
       3 linear_low = f8
       3 linear_high = f8
       3 linear_ind = i2
       3 dilute_ind = i2
       3 feasible_low = f8
       3 feasible_high = f8
       3 feasible_ind = i2
       3 alpha_list[*]
         4 action_flag = i2
         4 nomenclature_id = f8
         4 sequence = i4
         4 short_string = c60
         4 default_ind = i2
         4 use_units_ind = i2
         4 reference_ind = i2
         4 result_process_code_value = f8
         4 result_value = f8
         4 multi_alpha_sort_order = i4
       3 rule_list[*]
         4 action_flag = i2
         4 ref_range_notify_trig_id = f8
         4 trigger_name = vc
         4 trigger_seq_nbr = i4
       3 species_code_value = f8
       3 adv_deltas[*]
         4 action_flag = i2
         4 delta_ind = i2
         4 delta_low = f8
         4 delta_high = f8
         4 delta_check_type_code_value = f8
         4 delta_minutes = i4
         4 delta_value = f8
       3 delta_check_type_code_value = f8
       3 delta_minutes = i4
       3 delta_value = f8
       3 delta_chk_flag = i2
       3 mins_back = i4
       3 gestational_ind = i2
     2 equivalent_assay[*]
       3 action_flag = i4
       3 code_value = f8
 )
 FREE SET dta_reply
 RECORD dta_reply(
   1 assay_list[*]
     2 code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE error_flag = vc WITH private
 DECLARE error_msg = vc WITH private
 DECLARE msg = vc WITH private
 DECLARE active_cd = f8
 DECLARE inactive_cd = f8
 DECLARE result_type_cd = f8
 DECLARE numorders = i4
 DECLARE supplier_flag = i4
 DECLARE supplier_disp = vc
 DECLARE supplier_meaning = vc
 DECLARE supplier_source_cd = f8
 DECLARE dtacnt = i4
 DECLARE cc = i4
 DECLARE cvcnt = i4
 DECLARE cncnt = i4
 DECLARE dcount = i4
 DECLARE cur_alias = vc
 DECLARE hold_code_value = f8
 DECLARE alias = vc
 DECLARE unit_meaning = vc
 DECLARE volume_units_cd = f8
 DECLARE code_set = i4
 DECLARE cat_cd = f8
 DECLARE act_cd = f8
 DECLARE act_sub_cd = f8
 DECLARE orc_found = vc
 DECLARE alias_found = vc
 DECLARE cntnrcnt = i4
 DECLARE rli_alias_id = f8
 DECLARE new_dta_cd = f8
 DECLARE rli_order_id = f8
 DECLARE loc_suffix = vc
 DECLARE loc_found = i2
 DECLARE dta_found = vc
 DECLARE mseq = i4
 DECLARE orc_cat_cd = f8
 DECLARE order_desc = vc
 DECLARE order_mnemonic = vc
 DECLARE orc_alias = vc
 DECLARE performing_loc = vc
 DECLARE order_desc = vc
 DECLARE supplier_mnemonic = vc
 DECLARE dept_name = vc
 DECLARE specimen_type = vc
 DECLARE special_handling = vc
 DECLARE min_vol = f8
 DECLARE min_vol_units = vc
 DECLARE transfer_temp = vc
 DECLARE collection_method = vc
 DECLARE accession_class = vc
 DECLARE collection_class = vc
 DECLARE concept_cki = vc
 SET childcnt = 0
 DECLARE ancillary_type_cd = f8
 DECLARE dcp_type_cd = f8
 DECLARE outreach_type_cd = f8
 DECLARE lab_cd = f8
 DECLARE lab_oef_id = f8
 DECLARE lab_act_cd = f8
 DECLARE call_lab_collclass_cd = f8
 DECLARE specimen_type_cd = f8
 DECLARE special_handling_cd = f8
 DECLARE collection_method_cd = f8
 DECLARE accession_class_cd = f8
 DECLARE collection_class_cd = f8
 DECLARE container_cd = f8
 DECLARE min_vol_units_cd = f8
 DECLARE dta_cd = f8
 DECLARE dta_alias = vc
 DECLARE dta_description = vc
 DECLARE dta_mnemonic = vc
 SET reply->status_data.status = "F"
 SET cntnrcnt = 0
 SET rvar = 0
 SELECT INTO "ccluserdir:bed_rli_orders.log"
  rvar
  HEAD REPORT
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, "Bedrock RLI Orders Log"
  DETAIL
   row + 2, col 2, " "
  WITH nocounter, format = variable, noformfeed,
   maxcol = 132, maxrow = 1
 ;end select
 SELECT INTO "ccluserdir:bed_rli_orders_error.log"
  rvar
  HEAD REPORT
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, "Bedrock RLI Orders Error Log"
  DETAIL
   row + 2, col 2, " "
  WITH nocounter, format = variable, noformfeed,
   maxcol = 132, maxrow = 1
 ;end select
 SET error_flag = "F"
 SET numorders = size(request->order_list,5)
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="ACTIVE")
  DETAIL
   active_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_msg = "ACTIVE code not found."
  SET error_flag = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="INACTIVE")
  DETAIL
   inactive_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_msg = "INACTIVE code not found."
  SET error_flag = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=289
    AND c.cdf_meaning="7"
    AND c.active_ind=1)
  DETAIL
   result_type_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_msg = "Freetext code not found on code set 289."
  SET error_flag = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6000
    AND c.cdf_meaning="GENERAL LAB"
    AND c.active_ind=1)
  DETAIL
   cat_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_msg = "General Lab code not found on code set 6000."
  SET error_flag = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=106
    AND c.cdf_meaning="GLB"
    AND c.active_ind=1)
  DETAIL
   act_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_msg = "GLB code not found on code set 106."
  SET error_flag = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM br_rli_supplier brs
  PLAN (brs
   WHERE (brs.supplier_flag=request->supplier_flag))
  DETAIL
   supplier_disp = brs.supplier_name, supplier_meaning = brs.supplier_meaning, supplier_flag = brs
   .supplier_flag
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "T"
  SET error_msg = concat(error_msg,"Invalid supplier flag.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=5801
    AND c.display_key=cnvtupper(cnvtalphanum(supplier_meaning))
    AND c.active_ind=1)
  DETAIL
   act_sub_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_msg = "Supplier activity subtype code not found on code set 289."
  SET error_flag = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.display_key=cnvtalphanum(cnvtupper(supplier_meaning))
    AND cv.code_set=73)
  DETAIL
   supplier_source_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "T"
  SET error_msg = concat(error_msg,"Unable to read contributor source")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6011
    AND cv.active_ind=1
    AND cv.cdf_meaning="DCP")
  DETAIL
   dcp_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6011
    AND cv.active_ind=1
    AND cv.cdf_meaning="ANCILLARY")
  DETAIL
   ancillary_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6011
    AND cv.active_ind=1
    AND cv.cdf_meaning="OUTREACH")
  DETAIL
   outreach_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.active_ind=1
    AND cv.cdf_meaning="GENERAL LAB")
  DETAIL
   lab_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.active_ind=1
    AND cv.cdf_meaning="GLB")
  DETAIL
   lab_act_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_entry_format oef
  PLAN (oef
   WHERE oef.oe_format_name="Lab - Gen Lab")
  DETAIL
   lab_oef_id = oef.oe_format_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "T"
  SET error_msg = concat(error_msg,"Unable to read lab oef")
  GO TO exit_script
 ENDIF
 SET call_lab_collclass_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=231
    AND cv.display_key="CALLLAB"
    AND cv.active_ind=1)
  DETAIL
   call_lab_collclass_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (call_lab_collclass_cd=0.0)
  SET error_flag = "T"
  SET error_msg = concat(error_msg,"Unable to read call lab container code")
  GO TO exit_script
 ENDIF
 SET cvcnt = 0
 FOR (ii = 1 TO numorders)
   SELECT INTO "nl:"
    FROM br_auto_rli_order baro,
     br_auto_rli_alias bara,
     dummyt d1,
     code_value_alias cva
    PLAN (baro
     WHERE (((baro.rli_order_id=request->order_list[ii].catalog_cd)) OR ((baro.parent_order_id=
     request->order_list[ii].catalog_cd)))
      AND baro.supplier_flag=supplier_flag)
     JOIN (bara
     WHERE cnvtupper(trim(bara.display))=cnvtupper(trim(baro.specimen_type))
      AND bara.code_set=2052
      AND bara.supplier_flag=supplier_flag)
     JOIN (d1)
     JOIN (cva
     WHERE cva.code_set=2052
      AND cva.alias=bara.alias_name
      AND cva.contributor_source_cd=supplier_source_cd)
    DETAIL
     cvcnt = (cvcnt+ 1), stat = alterlist(cvlist->cvrec,cvcnt), cvlist->cvrec[cvcnt].cv = bara
     .alias_id,
     cvlist->cvrec[cvcnt].cs = bara.code_set, cvlist->cvrec[cvcnt].disp = trim(bara.display), cvlist
     ->cvrec[cvcnt].code_value = cva.code_value
    WITH nocounter, outerjoin = d1
   ;end select
   SELECT INTO "nl:"
    FROM br_auto_rli_order baro,
     br_auto_rli_alias bara,
     dummyt d1,
     code_value_alias cva
    PLAN (baro
     WHERE (((baro.rli_order_id=request->order_list[ii].catalog_cd)) OR ((baro.parent_order_id=
     request->order_list[ii].catalog_cd)))
      AND baro.supplier_flag=supplier_flag)
     JOIN (bara
     WHERE cnvtupper(trim(bara.display))=cnvtupper(trim(baro.special_handling))
      AND bara.code_set=230
      AND bara.supplier_flag=supplier_flag)
     JOIN (d1)
     JOIN (cva
     WHERE cva.code_set=230
      AND cva.alias=bara.alias_name
      AND cva.contributor_source_cd=supplier_source_cd)
    DETAIL
     cvcnt = (cvcnt+ 1), stat = alterlist(cvlist->cvrec,cvcnt), cvlist->cvrec[cvcnt].cv = bara
     .alias_id,
     cvlist->cvrec[cvcnt].cs = bara.code_set, cvlist->cvrec[cvcnt].disp = trim(bara.display), cvlist
     ->cvrec[cvcnt].code_value = cva.code_value
    WITH nocounter, outerjoin = d1
   ;end select
   SET cncnt = size(request->order_list[ii].cntnr_list,5)
   IF (cncnt > 0)
    FOR (jj = 1 TO cncnt)
      SELECT INTO "nl:"
       FROM br_auto_rli_alias bara,
        dummyt d1,
        code_value_alias cva
       PLAN (bara
        WHERE (bara.alias_id=request->order_list[ii].cntnr_list[jj].cntnr_cd)
         AND bara.code_set=2051
         AND bara.supplier_flag=supplier_flag)
        JOIN (d1)
        JOIN (cva
        WHERE cva.code_set=2051
         AND cva.alias=bara.alias_name
         AND cva.contributor_source_cd=supplier_source_cd)
       DETAIL
        cvcnt = (cvcnt+ 1), stat = alterlist(cvlist->cvrec,cvcnt), cvlist->cvrec[cvcnt].cv = bara
        .alias_id,
        cvlist->cvrec[cvcnt].cs = bara.code_set, cvlist->cvrec[cvcnt].disp = trim(bara.display),
        cvlist->cvrec[cvcnt].code_value = cva.code_value
       WITH nocounter, outerjoin = d1
      ;end select
    ENDFOR
   ELSE
    SELECT INTO "nl:"
     FROM br_auto_rli_order baro,
      br_auto_rli_alias bara,
      br_auto_rli_container barc,
      dummyt d1,
      code_value_alias cva
     PLAN (baro
      WHERE (baro.rli_order_id=request->order_list[ii].catalog_cd)
       AND baro.supplier_flag=supplier_flag)
      JOIN (barc
      WHERE barc.rli_order_id=baro.rli_order_id)
      JOIN (bara
      WHERE bara.alias_name=barc.container
       AND bara.code_set=2051
       AND bara.supplier_flag=supplier_flag)
      JOIN (d1)
      JOIN (cva
      WHERE cva.code_set=2051
       AND cva.alias=bara.alias_name
       AND cva.contributor_source_cd=supplier_source_cd)
     DETAIL
      cvcnt = (cvcnt+ 1), stat = alterlist(cvlist->cvrec,cvcnt), cvlist->cvrec[cvcnt].cv = bara
      .alias_id,
      cvlist->cvrec[cvcnt].cs = bara.code_set, cvlist->cvrec[cvcnt].disp = trim(bara.display), cvlist
      ->cvrec[cvcnt].code_value = cva.code_value,
      cncnt = (cncnt+ 1), stat = alterlist(request->order_list[ii].cntnr_list,cncnt), request->
      order_list[ii].cntnr_list[cncnt].cntnr_cd = bara.alias_id
     WITH nocounter, outerjoin = d1
    ;end select
    SELECT INTO "nl:"
     FROM br_auto_rli_order baro,
      br_auto_rli_alias bara,
      br_auto_rli_container barc,
      dummyt d1,
      code_value_alias cva
     PLAN (baro
      WHERE (baro.parent_order_id=request->order_list[ii].catalog_cd)
       AND baro.supplier_flag=supplier_flag)
      JOIN (barc
      WHERE barc.rli_order_id=baro.rli_order_id)
      JOIN (bara
      WHERE bara.alias_name=barc.container
       AND bara.code_set=2051
       AND bara.supplier_flag=supplier_flag)
      JOIN (d1)
      JOIN (cva
      WHERE cva.code_set=2051
       AND cva.alias=bara.alias_name
       AND cva.contributor_source_cd=supplier_source_cd)
     DETAIL
      cvcnt = (cvcnt+ 1), stat = alterlist(cvlist->cvrec,cvcnt), cvlist->cvrec[cvcnt].cv = bara
      .alias_id,
      cvlist->cvrec[cvcnt].cs = bara.code_set, cvlist->cvrec[cvcnt].disp = trim(bara.display), cvlist
      ->cvrec[cvcnt].code_value = cva.code_value
     WITH nocounter, outerjoin = d1
    ;end select
   ENDIF
 ENDFOR
 SET ii = 0
 FOR (ii = 1 TO cvcnt)
   SET map_code_value = 0.0
   SET hold_code_value = 0.0
   SELECT INTO "nl:"
    FROM br_auto_rli_alias bara
    PLAN (bara
     WHERE (bara.alias_id=cvlist->cvrec[ii].cv)
      AND (bara.code_set=cvlist->cvrec[ii].cs)
      AND bara.active_ind=1
      AND bara.supplier_flag=supplier_flag)
    DETAIL
     stat = alterlist(cv_request->cd_value_list,1), rli_alias_id = bara.alias_id, code_set = bara
     .code_set,
     alias = bara.alias_name, unit_meaning = bara.unit_meaning, cv_request->cd_value_list[1].
     action_flag = 1,
     cv_request->cd_value_list[1].active_ind = 1, cv_request->cd_value_list[1].begin_effective_dt_tm
      = cnvtdatetime(curdate,curtime), cv_request->cd_value_list[1].cdf_meaning = bara.cdf_meaning,
     cv_request->cd_value_list[1].cki = " ", cv_request->cd_value_list[1].code_set = bara.code_set,
     cv_request->cd_value_list[1].code_value = 0.0,
     cv_request->cd_value_list[1].collation_seq = 0, cv_request->cd_value_list[1].concept_cki = " ",
     cv_request->cd_value_list[1].definition = bara.definition,
     cv_request->cd_value_list[1].description = bara.description, cv_request->cd_value_list[1].
     display = bara.display, cv_request->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(bara
       .display)),
     cv_request->cd_value_list[1].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
     map_code_value = bara.code_value
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=code_set
       AND cv.code_value=map_code_value
       AND cv.active_ind=1)
     DETAIL
      hold_code_value = cv.code_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=code_set
        AND (cv.display=cv_request->cd_value_list[1].display)
        AND cv.active_ind=1)
      DETAIL
       hold_code_value = cv.code_value
      WITH nocounter
     ;end select
    ENDIF
    IF (curqual=0)
     CALL echo(build("Adding ",alias,"to code set ",cnvtstring(code_set)))
     EXECUTE bed_ens_cd_value  WITH replace("REQUEST",cv_request), replace("REPLY",cv_reply)
     IF ((cv_reply->qual[1].code_value > 0.0))
      SET msg = concat("Successfully added code value for: ",cnvtstring(code_set),":",alias)
      CALL logmessage(msg)
      SET hold_code_value = cv_reply->qual[1].code_value
      IF (code_set=2051)
       CALL addcontainer(ii)
      ENDIF
     ELSE
      SET hold_code_value = 0.0
     ENDIF
    ELSE
     IF (code_set=2051)
      SET ccsze = size(cntnrs->cntnrlist,5)
      SET cntnr_found = "N"
      IF (ccsze > 0)
       FOR (jj = 1 TO ccsze)
         IF ((cntnrs->cntnrlist[jj].c_rli_alias_id=rli_alias_id))
          SET cntnr_found = "Y"
         ENDIF
       ENDFOR
      ENDIF
      IF (cntnr_found="N")
       SET cntnrcnt = (cntnrcnt+ 1)
       SET stat = alterlist(cntnrs->cntnrlist,cntnrcnt)
       SET cntnrs->cntnrlist[cntnrcnt].c_alias = alias
       SET cntnrs->cntnrlist[cntnrcnt].c_code_value = hold_code_value
       SET cntnrs->cntnrlist[cntnrcnt].c_rli_alias_id = rli_alias_id
      ENDIF
     ENDIF
    ENDIF
    IF (hold_code_value > 0.0)
     SET cvlist->cvrec[ii].code_value = hold_code_value
     SELECT INTO "nl:"
      FROM code_value_alias cva
      PLAN (cva
       WHERE cva.code_set=code_set
        AND cva.alias=alias
        AND cva.contributor_source_cd=supplier_source_cd)
      DETAIL
       hold_code_value = cva.code_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL echo(build("Adding ",alias,"to code value alias ",cnvtstring(code_set)))
      INSERT  FROM code_value_alias cva
       SET cva.alias = alias, cva.alias_type_meaning = " ", cva.code_set = code_set,
        cva.code_value = hold_code_value, cva.contributor_source_cd = supplier_source_cd, cva
        .primary_ind = 0,
        cva.updt_applctx = reqinfo->updt_applctx, cva.updt_cnt = 0, cva.updt_dt_tm = cnvtdatetime(
         curdate,curtime),
        cva.updt_id = reqinfo->updt_id, cva.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual > 0)
       SET msg = concat("Successfully added code value alias for: ",cnvtstring(code_set),":",alias)
       CALL logmessage(msg)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 CALL echorecord(cvlist)
 CALL echorecord(cntnrs)
 SET ii = 0
 FOR (ii = 1 TO numorders)
   IF ((request->order_list[ii].action_flag=1))
    SET ordcount = 0
    SET concept_cki = " "
    SELECT INTO "nl:"
     FROM br_auto_rli_order baro
     PLAN (baro
      WHERE (baro.rli_order_id=request->order_list[ii].catalog_cd)
       AND baro.supplier_flag=supplier_flag)
     DETAIL
      ordcount = (ordcount+ 1), rli_order_id = baro.rli_order_id, order_desc = baro.order_desc,
      performing_loc = baro.performing_loc, order_mnemonic = baro.order_mnemonic, supplier_mnemonic
       = baro.supplier_mnemonic,
      dept_name = baro.dept_name, orc_alias = baro.alias_name, specimen_type = trim(baro
       .specimen_type),
      special_handling = trim(baro.special_handling), min_vol = baro.min_vol_value, min_vol_units =
      trim(baro.min_vol_units),
      transfer_temp = trim(baro.transfer_temp), collection_method = trim(baro.collection_method),
      accession_class = trim(baro.accession_class),
      collection_class = trim(baro.collection_class), concept_cki = trim(baro.concept_cki)
     WITH nocounter
    ;end select
    IF (ordcount=0)
     SET error_flag = "T"
     SET error_msg = concat(error_msg,"Error reading order catalog item: ",request->order_list[ii].
      catalog_cd)
     SET errmsg = error_msg
     CALL logerrormessage(errmsg)
    ELSE
     IF (supplier_flag=2)
      SET loc_found = findstring("NE",performing_loc)
      IF (loc_found > 0)
       SET loc_suffix = "NE"
      ELSE
       SET loc_suffix = "Roch"
      ENDIF
     ENDIF
     SET stat = alterlist(children->clist,0)
     SET childcnt = 0
     SELECT INTO "nl:"
      FROM br_auto_rli_order baro
      PLAN (baro
       WHERE (baro.parent_order_id=request->order_list[ii].catalog_cd)
        AND baro.supplier_flag=supplier_flag)
      DETAIL
       childcnt = (childcnt+ 1), stat = alterlist(children->clist,childcnt), children->clist[childcnt
       ].child_rli_order_id = baro.rli_order_id
      WITH nocounter
     ;end select
     CALL decode_ciq_data(ii)
     SET orc_found = "N"
     SET alias_found = "Y"
     CALL check_dup_orc(ii)
     IF (orc_found="Y")
      IF (alias_found="Y")
       SET error_msg = concat(error_msg,"Duplicate order catalog for alias: ",orc_alias)
       SET errmsg = error_msg
       CALL logerrormessage(errmsg)
      ELSE
       SET error_msg = concat(error_msg,"Duplicate order catalog for primary mnemonic: ",
        order_mnemonic)
       SET errmsg = error_msg
       CALL logerrormessage(errmsg)
      ENDIF
     ELSE
      SET stat = alterlist(orc_request->list_0,1)
      SET orc_request->list_0[1].description = order_desc
      SET orc_request->list_0[1].hna_mnemonic = order_mnemonic
      SET orc_request->list_0[1].dept_name = dept_name
      SET orc_request->list_0[1].catalog_type_cd = "Laboratory"
      SET orc_request->list_0[1].activity_type_cd = "General Lab"
      SET orc_request->list_0[1].activity_subtype_cd = supplier_meaning
      SET orc_request->list_0[1].order_entry_format = "Lab - Gen Lab"
      SET orc_request->list_0[1].dcp_clin_cat_cd = "Laboratory"
      SET orc_request->list_0[1].mnemonic_type = "ANCILLARY"
      SET orc_request->list_0[1].mnemonic = supplier_mnemonic
      SET orc_request->list_0[1].billcode = ""
      SET orc_request->list_0[1].concept_cki = concept_cki
      SET orc_request->list_0[1].catalog_cki = ""
      SET trace = recpersist
      EXECUTE bed_ens_rli_oc_ps  WITH replace("REQUESTIN",orc_request), replace("REPLY",orc_reply)
      IF ((orc_reply->status_data.status="F"))
       SET error_flag = "T"
       SET error_msg = concat(error_msg,"Failure adding order catalog for primary mnemonic: ",
        order_mnemonic)
       SET errmsg = error_msg
       CALL logerrormessage(errmsg)
       GO TO exit_script
      ELSE
       SET msg = concat("Successfully added order catalog for: ",order_mnemonic)
       CALL logmessage(msg)
      ENDIF
      SET orc_cat_cd = orc_reply->oc_list[1].catalog_cd
      INSERT  FROM code_value_alias cva
       SET cva.code_set = 200, cva.contributor_source_cd = supplier_source_cd, cva.alias = orc_alias,
        cva.code_value = orc_cat_cd, cva.primary_ind = 0, cva.updt_dt_tm = cnvtdatetime(curdate,
         curtime),
        cva.updt_id = reqinfo->updt_id, cva.updt_cnt = 0, cva.updt_task = reqinfo->updt_task,
        cva.updt_applctx = reqinfo->updt_applctx, cva.alias_type_meaning = null
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "T"
       SET error_msg = concat(error_msg,"Error creating code_value_alias row for catalog_cd: ",
        cnvtstring(request->order_list[ii].catalog_cd))
       GO TO exit_script
      ENDIF
      INSERT  FROM code_value_outbound cvo
       SET cvo.code_value = orc_cat_cd, cvo.contributor_source_cd = supplier_source_cd, cvo
        .alias_type_meaning = null,
        cvo.code_set = 200, cvo.alias = orc_alias, cvo.updt_dt_tm = cnvtdatetime(curdate,curtime),
        cvo.updt_id = reqinfo->updt_id, cvo.updt_cnt = 0, cvo.updt_task = reqinfo->updt_task,
        cvo.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "T"
       SET error_msg = concat(error_msg,"Error creating code_value_outbound row for catalog_cd: ",
        cnvtstring(request->order_list[ii].catalog_cd))
       GO TO exit_script
      ENDIF
      SET syncnt = 0
      SET stat = alterlist(add_syns->syn_list,0)
      SELECT INTO "nl:"
       FROM br_auto_rli_synonym bars
       PLAN (bars
        WHERE (bars.rli_order_id=request->order_list[ii].catalog_cd))
       DETAIL
        syncnt = (syncnt+ 1), stat = alterlist(add_syns->syn_list,syncnt), add_syns->syn_list[syncnt]
        .syn_type = bars.synonym_type_flag,
        add_syns->syn_list[syncnt].synonym = bars.synonym_name
       WITH nocounter
      ;end select
      IF (syncnt > 0)
       FOR (zzz = 1 TO syncnt)
         SET dup_syn_found = 0
         SELECT INTO "nl:"
          FROM order_catalog_synonym ocs
          PLAN (ocs
           WHERE ocs.mnemonic_key_cap=cnvtupper(trim(add_syns->syn_list[zzz].synonym)))
          DETAIL
           dup_syn_found = 1
          WITH nocounter
         ;end select
         IF (dup_syn_found=1)
          SET msg = concat("Duplicate synonym found for catalog_cd: ",cnvtstring(request->order_list[
            ii].catalog_cd))
          CALL logmessage(msg)
         ELSE
          SET new_synonym_id = 0.0
          SELECT INTO "nl:"
           y = seq(reference_seq,nextval)"##################;rp0"
           FROM dual
           DETAIL
            new_synonym_id = cnvtreal(y)
           WITH format, nocounter
          ;end select
          IF (curqual=0)
           SET error_flag = "T"
           SET msg = "Unable to generate new synonym_id"
           GO TO exit_script
          ENDIF
          IF ((add_syns->syn_list[zzz].syn_type=1))
           SET syn_type_cd = ancillary_type_cd
          ELSEIF ((add_syns->syn_list[zzz].syn_type=2))
           SET syn_type_cd = dcp_type_cd
          ELSEIF ((add_syns->syn_list[zzz].syn_type=3))
           SET syn_type_cd = outreach_cd
          ENDIF
          INSERT  FROM order_catalog_synonym ocs
           SET ocs.synonym_id = new_synonym_id, ocs.catalog_cd = orc_cat_cd, ocs.catalog_type_cd =
            lab_cd,
            ocs.mnemonic = add_syns->syn_list[zzz].synonym, ocs.mnemonic_key_cap = cnvtupper(add_syns
             ->syn_list[zzz].synonym), ocs.mnemonic_type_cd = syn_type_cd,
            ocs.oe_format_id = lab_oef_id, ocs.order_sentence_id = 0, ocs.active_ind = 1,
            ocs.activity_type_cd = lab_act_cd, ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt
             = 0,
            ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id, ocs
            .updt_task = reqinfo->updt_task,
            ocs.activity_subtype_cd = act_sub_cd, ocs.orderable_type_flag = 0, ocs.active_status_cd
             = active_cd,
            ocs.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ocs.active_status_prsnl_id =
            reqinfo->updt_id, ocs.ref_text_mask = 0,
            ocs.cs_index_cd = 0, ocs.multiple_ord_sent_ind = 0, ocs.hide_flag = 0,
            ocs.rx_mask = 0, ocs.dcp_clin_cat_cd = 0, ocs.filtered_od_ind = 0,
            ocs.item_id = 0, ocs.cki = null, ocs.mnemonic_key_cap_nls = " ",
            ocs.virtual_view = " ", ocs.health_plan_view = " ", ocs.concept_cki = null,
            ocs.concentration_strength = 0, ocs.concentration_strength_unit_cd = 0, ocs
            .concentration_volume = 0,
            ocs.concentration_volume_unit_cd = 0, ocs.template_mnemonic_flag = 0, ocs
            .ingredient_rate_conversion_ind = 0,
            ocs.witness_flag = 0
           WITH nocounter
          ;end insert
         ENDIF
       ENDFOR
      ENDIF
      UPDATE  FROM br_rli_client_orders brco
       SET brco.status_flag = 3, brco.updt_cnt = (brco.updt_cnt+ 1), brco.updt_id = reqinfo->updt_id,
        brco.updt_task = reqinfo->updt_task, brco.updt_applctx = reqinfo->updt_applctx, brco
        .updt_dt_tm = cnvtdatetime(curdate,curtime)
       WHERE brco.alias=orc_alias
       WITH nocounter
      ;end update
      IF (curqual=0)
       INSERT  FROM br_rli_client_orders brco
        SET brco.alias = orc_alias, brco.supplier_flag = supplier_flag, brco.supplier_meaning =
         supplier_meaning,
         brco.active_ind = 1, brco.status_flag = 3, brco.updt_cnt = 1,
         brco.updt_id = reqinfo->updt_id, brco.updt_task = reqinfo->updt_task, brco.updt_applctx =
         reqinfo->updt_applctx,
         brco.updt_dt_tm = cnvtdatetime(curdate,curtime)
        WITH nocounter
       ;end insert
      ENDIF
      SET mseq = 0
      SET tcnt = 0
      SELECT INTO "nl:"
       orl.sequence
       FROM orc_resource_list orl
       PLAN (orl
        WHERE orl.catalog_cd=orc_cat_cd)
       DETAIL
        tcnt = (tcnt+ 1)
        IF (mseq < orl.sequence)
         mseq = orl.sequence
        ENDIF
       WITH nocounter
      ;end select
      IF (tcnt=0)
       SET mseq = 0
      ELSE
       SET mseq = (mseq+ 1)
      ENDIF
      CALL echo(build("***  mseq =   ",mseq))
      INSERT  FROM orc_resource_list orl
       SET orl.service_resource_cd = request->service_resource_cd, orl.catalog_cd = orc_cat_cd, orl
        .sequence = mseq,
        orl.primary_ind = 1, orl.script_name = " ", orl.updt_applctx = reqinfo->updt_applctx,
        orl.updt_dt_tm = cnvtdatetime(curdate,curtime), orl.updt_cnt = 0, orl.updt_id = reqinfo->
        updt_id,
        orl.updt_task = reqinfo->updt_task, orl.active_ind = 1, orl.active_status_cd = active_cd,
        orl.active_status_dt_tm = cnvtdatetime(curdate,curtime), orl.active_status_prsnl_id = reqinfo
        ->updt_id, orl.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
        orl.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error adding orc_resource_list row for catalog_cd: ",cnvtstring(request->
         order_list[ii].catalog_cd))
       CALL logmessage(msg)
      ENDIF
      INSERT  FROM procedure_specimen_type pst
       SET pst.catalog_cd = orc_cat_cd, pst.specimen_type_cd = specimen_type_cd, pst
        .default_collection_method_cd = collection_method_cd,
        pst.default_ind = null, pst.accession_class_cd = accession_class_cd, pst.updt_applctx =
        reqinfo->updt_applctx,
        pst.updt_dt_tm = cnvtdatetime(curdate,curtime), pst.updt_id = reqinfo->updt_id, pst.updt_cnt
         = 0,
        pst.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "T"
       SET error_msg = concat(error_msg,"Error creating procedure_specimen_type row for catalog_cd: ",
        cnvtstring(request->order_list[ii].catalog_cd))
       GO TO exit_script
      ENDIF
      SET cc = size(request->order_list[ii].cntnr_list,5)
      FOR (xx = 1 TO cc)
        SET ccs = size(cntnrs->cntnrlist,5)
        SET container_cd = 0.0
        FOR (jj = 1 TO ccs)
          IF ((cntnrs->cntnrlist[jj].c_rli_alias_id=request->order_list[ii].cntnr_list[xx].cntnr_cd))
           SET container_cd = cntnrs->cntnrlist[jj].c_code_value
          ENDIF
        ENDFOR
        CALL echo(build("Container_cd = ",container_cd))
        INSERT  FROM collection_info_qualifiers ciq
         SET ciq.age_from_minutes = 0, ciq.age_to_minutes = 78840000, ciq.aliquot_ind = 0,
          ciq.aliquot_route_sequence = 0, ciq.aliquot_seq = 0, ciq.catalog_cd = orc_cat_cd,
          ciq.coll_class_cd = call_lab_collclass_cd, ciq.min_vol = min_vol, ciq.min_vol_units =
          min_vol_units,
          ciq.required_ind = null, ciq.sequence = seq(reference_seq,nextval), ciq.spec_cntnr_cd =
          container_cd,
          ciq.spec_hndl_cd = special_handling_cd, ciq.species_cd = 0.0, ciq.specimen_type_cd =
          specimen_type_cd,
          ciq.updt_applctx = reqinfo->updt_applctx, ciq.updt_cnt = 0, ciq.updt_dt_tm = cnvtdatetime(
           curdate,curtime),
          ciq.updt_id = reqinfo->updt_id, ciq.updt_task = reqinfo->updt_task, ciq.service_resource_cd
           = 0.0,
          ciq.optional_ind = 0, ciq.additional_labels = 0, ciq.units_cd = min_vol_units_cd,
          ciq.collection_priority_cd = 0.0
         WITH nocounter
        ;end insert
        INSERT  FROM collection_info_qualifiers ciq
         SET ciq.age_from_minutes = 0, ciq.age_to_minutes = 78840000, ciq.aliquot_ind = 0,
          ciq.aliquot_route_sequence = 0, ciq.aliquot_seq = 0, ciq.catalog_cd = orc_cat_cd,
          ciq.coll_class_cd = collection_class_cd, ciq.min_vol = min_vol, ciq.min_vol_units =
          min_vol_units,
          ciq.required_ind = null, ciq.sequence = seq(reference_seq,nextval), ciq.spec_cntnr_cd =
          container_cd,
          ciq.spec_hndl_cd = special_handling_cd, ciq.species_cd = 0.0, ciq.specimen_type_cd =
          specimen_type_cd,
          ciq.updt_applctx = reqinfo->updt_applctx, ciq.updt_cnt = 0, ciq.updt_dt_tm = cnvtdatetime(
           curdate,curtime),
          ciq.updt_id = reqinfo->updt_id, ciq.updt_task = reqinfo->updt_task, ciq.service_resource_cd
           = request->service_resource_cd,
          ciq.optional_ind = 0, ciq.additional_labels = 0, ciq.units_cd = min_vol_units_cd,
          ciq.collection_priority_cd = 0.0
         WITH nocounter
        ;end insert
      ENDFOR
      IF (childcnt > 0)
       CALL addchildren(childcnt)
      ENDIF
      SET dtacnt = 0
      SET stat = alterlist(dtalist->dlist,0)
      SELECT INTO "nl:"
       FROM br_auto_rli_order_dta_r barod,
        br_auto_rli_dta bart
       PLAN (barod
        WHERE barod.rli_order_id=rli_order_id
         AND barod.supplier_flag=supplier_flag)
        JOIN (bart
        WHERE bart.rli_dta_id=barod.rli_dta_id)
       ORDER BY barod.rli_order_id
       HEAD barod.rli_order_id
        dtalist->catcd = barod.rli_order_id
       DETAIL
        dtacnt = (dtacnt+ 1), stat = alterlist(dtalist->dlist,dtacnt), dtalist->dlist[dtacnt].dtacd
         = bart.rli_dta_id,
        dtalist->dlist[dtacnt].description = bart.description, dtalist->dlist[dtacnt].mnemonic = bart
        .mnemonic, dtalist->dlist[dtacnt].alias = bart.alias_name
       WITH nocounter
      ;end select
      FOR (jj = 1 TO dtacnt)
        SET dta_found = "N"
        SELECT INTO "nl:"
         FROM discrete_task_assay dta
         PLAN (dta
          WHERE (dta.mnemonic=dtalist->dlist[jj].mnemonic))
         DETAIL
          new_dta_cd = dta.task_assay_cd, dta_found = "Y"
         WITH nocounter
        ;end select
        IF (dta_found="Y")
         SET dtalist->dlist[jj].mnemonic = concat(dtalist->dlist[jj].mnemonic,"-",loc_suffix)
         SELECT INTO "nl:"
          FROM discrete_task_assay dta
          PLAN (dta
           WHERE (dta.mnemonic=dtalist->dlist[jj].mnemonic))
          DETAIL
           dta_found = "Y", new_dta_cd = dta.task_assay_cd
          WITH nocounter
         ;end select
         IF (curqual=0)
          SET dta_found = "N"
          SET new_dta_cd = 0.0
          SET dtalist->dlist[jj].description = concat(dtalist->dlist[jj].description,"-",loc_suffix)
         ENDIF
        ENDIF
        SELECT INTO "nl:"
         FROM code_value_alias cva
         PLAN (cva
          WHERE (cva.alias=dtalist->dlist[jj].alias)
           AND cva.code_set=14003
           AND cva.contributor_source_cd=supplier_source_cd)
         DETAIL
          dta_found = "Y", new_dta_cd = cva.code_value
         WITH nocounter
        ;end select
        IF (dta_found="N")
         SET new_dta_cd = 0.0
         SET stat = alterlist(dta_request->assay_list,1)
         SET dta_request->assay_list[1].action_flag = 1
         SET dta_request->assay_list[1].code_value = 0.0
         SET dta_request->assay_list[1].description = dtalist->dlist[jj].description
         SET dta_request->assay_list[1].display = dtalist->dlist[jj].mnemonic
         SET dta_request->assay_list[1].general_info.activity_type_code_value = act_cd
         SET dta_request->assay_list[1].general_info.result_type_code_value = result_type_cd
         SET dta_request->assay_list[1].general_info.delta_check_ind = 0
         SET dta_request->assay_list[1].general_info.res_proc_type_code_value = 0.0
         SET trace = recpersist
         EXECUTE bed_ens_assay  WITH replace("REQUEST",dta_request), replace("REPLY",dta_reply)
         SET new_dta_cd = dta_reply->assay_list[1].code_value
         IF (new_dta_cd > 0.0)
          SET msg = concat("Successfully added RLI DTA: ",dtalist->dlist[jj].mnemonic)
          CALL logmessage(msg)
          INSERT  FROM code_value_alias cva
           SET cva.alias = dtalist->dlist[jj].alias, cva.code_set = 14003, cva.code_value =
            new_dta_cd,
            cva.contributor_source_cd = supplier_source_cd, cva.primary_ind = 0, cva.updt_applctx =
            reqinfo->updt_applctx,
            cva.updt_cnt = 0, cva.updt_dt_tm = cnvtdatetime(curdate,curtime), cva.updt_id = reqinfo->
            updt_id,
            cva.updt_task = reqinfo->updt_task
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET msg = concat("Error adding code value alias for ",request->orders[ii].assay_list[jj].
            assay_desc,".  Alias: ",request->orders[ii].assay_list[jj].assay_alias)
           CALL logerrormessage(msg)
           SET err = "Y"
           GO TO exit_script
          ENDIF
          INSERT  FROM code_value_outbound cvo
           SET cvo.code_value = new_dta_cd, cvo.contributor_source_cd = supplier_source_cd, cvo
            .alias_type_meaning = null,
            cvo.code_set = 14003, cvo.alias = dtalist->dlist[jj].alias, cvo.updt_dt_tm = cnvtdatetime
            (curdate,curtime),
            cvo.updt_id = reqinfo->updt_id, cvo.updt_cnt = 0, cvo.updt_task = reqinfo->updt_task,
            cvo.updt_applctx = reqinfo->updt_applctx
           WITH nocounter
          ;end insert
          SET mseq = 0
          SELECT INTO "nl:"
           apr.display_sequence
           FROM assay_processing_r apr
           PLAN (apr
            WHERE (apr.service_resource_cd=request->service_resource_cd))
           DETAIL
            IF (mseq < apr.display_sequence)
             mseq = apr.display_sequence
            ENDIF
           WITH nocounter
          ;end select
          CALL echo(build("***  mseq2 =   ",mseq))
          INSERT  FROM assay_processing_r apr
           SET apr.task_assay_cd = new_dta_cd, apr.service_resource_cd = request->service_resource_cd,
            apr.upld_assay_alias = null,
            apr.process_sequence = null, apr.active_ind = 1, apr.default_result_type_cd =
            result_type_cd,
            apr.default_result_template_id = 0.0, apr.qc_result_type_cd = 0.0, apr.qc_sequence = 0,
            apr.updt_cnt = 0, apr.updt_dt_tm = cnvtdatetime(curdate,curtime), apr.updt_task = reqinfo
            ->updt_task,
            apr.updt_id = reqinfo->updt_id, apr.updt_applctx = reqinfo->updt_applctx, apr
            .dnld_assay_alias = null,
            apr.post_zero_result_ind = null, apr.display_sequence = (mseq+ 1), apr.downld_ind = 0,
            apr.code_set = 0, apr.active_status_cd = active_cd, apr.active_status_dt_tm =
            cnvtdatetime(curdate,curtime),
            apr.active_status_prsnl_id = reqinfo->updt_id
           WITH nocounter
          ;end insert
         ENDIF
         CALL add_oc_dta_reltn(jj)
        ELSE
         CALL add_oc_dta_reltn(jj)
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ELSEIF ((request->order_list[ii].action_flag=2))
    CALL chgrliorder(ii)
   ELSEIF ((request->order_list[ii].action_flag=3))
    CALL delrliorder(ii)
   ENDIF
 ENDFOR
 SET foundrec = 0
 SELECT INTO "nl:"
  FROM br_rli_client_log br
  PLAN (br
   WHERE br.supplier_flag=supplier_flag)
  DETAIL
   foundrec = 1
  WITH nocounter
 ;end select
 IF (foundrec=0)
  INSERT  FROM br_rli_client_log br
   SET br.supplier_flag = supplier_flag, br.last_updt_dt_tm = cnvtdatetime(curdate,curtime)
   WITH nocounter
  ;end insert
 ELSE
  UPDATE  FROM br_rli_client_log br
   SET br.last_updt_dt_tm = cnvtdatetime(curdate,curtime)
   WHERE br.supplier_flag=supplier_flag
   WITH nocounter
  ;end update
 ENDIF
 GO TO exit_script
 SUBROUTINE check_dup_orc(ii)
  SELECT INTO "nl:"
   FROM order_catalog o
   PLAN (o
    WHERE o.primary_mnemonic=order_mnemonic)
   DETAIL
    orc_found = "Y"
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value_alias cva
   PLAN (cva
    WHERE cva.alias=orc_alias
     AND cva.code_set=200
     AND cva.contributor_source_cd=supplier_source_cd)
   DETAIL
    orc_found = "Y", alias_found = "Y"
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE addchildren(cnum)
   DECLARE spectype = vc
   DECLARE spechandle = vc
   DECLARE collmeth = vc
   DECLARE accclass = vc
   DECLARE collclass = vc
   DECLARE minvolunit = vc
   FOR (gg = 1 TO cnum)
     SET specimen_type_cd = 0.0
     SET special_handling_cd = 0.0
     SET collection_method_cd = 0.0
     SET accession_class_cd = 0.0
     SET collection_class_cd = 0.0
     SET min_vol_units_cd = 0.0
     SET container_cd = 0.0
     SET spectype = ""
     SET spechandle = ""
     SET collmeth = ""
     SET accclass = ""
     SET collclass = ""
     SET minvolunit = ""
     CALL echo(build("Cnum = ",cnum))
     CALL echorecord(children)
     SELECT INTO "nl:"
      FROM br_auto_rli_order baro
      PLAN (baro
       WHERE (baro.rli_order_id=children->clist[gg].child_rli_order_id))
      DETAIL
       spectype = baro.specimen_type, spechandle = baro.special_handling, collmeth = baro
       .collection_method,
       accclass = baro.accession_class, collclass = baro.collection_class, min_vol_units = baro
       .min_vol_units,
       min_vol = baro.min_vol_value
      WITH nocounter
     ;end select
     CALL echo(build("Spectype = ",spectype))
     CALL echo(build("Spechandle = ",spechandle))
     CALL echo(build("collmeth = ",collmeth))
     CALL echo(build("accclass = ",accclass))
     CALL echo(build("collclass = ",collclass))
     CALL echo(build("minvolunit = ",min_vol_units))
     IF (curqual=0)
      SET msg = concat("Error reading child collection row for ",children->clist[gg].
       child_rli_order_id)
      CALL logerrormessage(msg)
     ELSE
      SET specimen_type_cd = 0.0
      SET special_handling_cd = 0.0
      SET collection_method_cd = 0.0
      SET accession_class_cd = 0.0
      SET collection_class_cd = 0.0
      SET min_vol_units_cd = 0.0
      IF (cvcnt > 0)
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = cvcnt)
        PLAN (d
         WHERE (cvlist->cvrec[d.seq].cs=230)
          AND trim(cvlist->cvrec[d.seq].disp)=trim(spechandle))
        DETAIL
         special_handling_cd = cvlist->cvrec[d.seq].code_value
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = cvcnt)
        PLAN (d
         WHERE (cvlist->cvrec[d.seq].cs=2052)
          AND (cvlist->cvrec[d.seq].disp=trim(spectype)))
        DETAIL
         specimen_type_cd = cvlist->cvrec[d.seq].code_value
        WITH nocounter
       ;end select
      ENDIF
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=2058
         AND cv.display_key=cnvtupper(cnvtalphanum(trim(collmeth)))
         AND cv.active_ind=1)
       DETAIL
        collection_method_cd = cv.code_value
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=2056
         AND cv.display_key=cnvtupper(cnvtalphanum(trim(accclass))))
       DETAIL
        accession_class_cd = cv.code_value
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=231
         AND cv.display_key=cnvtupper(cnvtalphanum(trim(collclass))))
       DETAIL
        collection_class_cd = cv.code_value
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=54
         AND cv.display_key=cnvtupper(trim(min_vol_units)))
       DETAIL
        min_vol_units_cd = cv.code_value
       WITH nocounter
      ;end select
      INSERT  FROM procedure_specimen_type pst
       SET pst.catalog_cd = orc_cat_cd, pst.specimen_type_cd = specimen_type_cd, pst
        .default_collection_method_cd = collection_method_cd,
        pst.default_ind = null, pst.accession_class_cd = accession_class_cd, pst.updt_applctx =
        reqinfo->updt_applctx,
        pst.updt_dt_tm = cnvtdatetime(curdate,curtime), pst.updt_id = reqinfo->updt_id, pst.updt_cnt
         = 0,
        pst.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "T"
       SET error_msg = concat(error_msg,"Error creating procedure_specimen_type row for catalog_cd: ",
        cnvtstring(request->order_list[ii].catalog_cd))
       GO TO exit_script
      ENDIF
      SET ccc = 0
      SET stat = alterlist(ch_cntnrs->ch_clist,0)
      SELECT INTO "nl:"
       FROM br_auto_rli_container barc,
        br_auto_rli_alias bara,
        code_value cv
       PLAN (barc
        WHERE (barc.rli_order_id=children->clist[gg].child_rli_order_id))
        JOIN (bara
        WHERE bara.alias_id=barc.container_alias_id)
        JOIN (cv
        WHERE cv.display=bara.display)
       HEAD barc.rli_order_id
        ch_cntnrs->ch_rli_order_id = barc.rli_order_id
       DETAIL
        ccc = (ccc+ 1), stat = alterlist(ch_cntnrs->ch_clist,ccc), ch_cntnrs->ch_clist[ccc].ch_alias
         = bara.alias_name,
        ch_cntnrs->ch_clist[ccc].ch_cntnr_id = bara.alias_id, ch_cntnrs->ch_clist[ccc].ch_code_value
         = cv.code_value
       WITH nocounter
      ;end select
      CALL echo(build("Child container record: "))
      CALL echorecord(ch_cntnrs)
      IF (ccc > 0)
       FOR (ddd = 1 TO ccc)
         INSERT  FROM collection_info_qualifiers ciq
          SET ciq.age_from_minutes = 0, ciq.age_to_minutes = 78840000, ciq.aliquot_ind = 0,
           ciq.aliquot_route_sequence = 0, ciq.aliquot_seq = 0, ciq.catalog_cd = orc_cat_cd,
           ciq.coll_class_cd = call_lab_collclass_cd, ciq.min_vol = min_vol, ciq.min_vol_units =
           min_vol_units,
           ciq.required_ind = null, ciq.sequence = seq(reference_seq,nextval), ciq.spec_cntnr_cd =
           container_cd,
           ciq.spec_hndl_cd = special_handling_cd, ciq.species_cd = 0.0, ciq.specimen_type_cd =
           specimen_type_cd,
           ciq.updt_applctx = reqinfo->updt_applctx, ciq.updt_cnt = 0, ciq.updt_dt_tm = cnvtdatetime(
            curdate,curtime),
           ciq.updt_id = reqinfo->updt_id, ciq.updt_task = reqinfo->updt_task, ciq
           .service_resource_cd = 0.0,
           ciq.optional_ind = 0, ciq.additional_labels = 0, ciq.units_cd = min_vol_units_cd,
           ciq.collection_priority_cd = 0.0
          WITH nocounter
         ;end insert
         SET container_cd = ch_cntnrs->ch_clist[ddd].ch_code_value
         INSERT  FROM collection_info_qualifiers ciq
          SET ciq.age_from_minutes = 0, ciq.age_to_minutes = 78840000, ciq.aliquot_ind = 0,
           ciq.aliquot_route_sequence = 0, ciq.aliquot_seq = 0, ciq.catalog_cd = orc_cat_cd,
           ciq.coll_class_cd = collection_class_cd, ciq.min_vol = min_vol, ciq.min_vol_units =
           min_vol_units,
           ciq.required_ind = null, ciq.sequence = seq(reference_seq,nextval), ciq.spec_cntnr_cd =
           container_cd,
           ciq.spec_hndl_cd = special_handling_cd, ciq.species_cd = 0.0, ciq.specimen_type_cd =
           specimen_type_cd,
           ciq.updt_applctx = reqinfo->updt_applctx, ciq.updt_cnt = 0, ciq.updt_dt_tm = cnvtdatetime(
            curdate,curtime),
           ciq.updt_id = reqinfo->updt_id, ciq.updt_task = reqinfo->updt_task, ciq
           .service_resource_cd = request->service_resource_cd,
           ciq.optional_ind = 0, ciq.additional_labels = 0, ciq.units_cd = min_vol_units_cd,
           ciq.collection_priority_cd = 0.0
          WITH nocounter
         ;end insert
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE decode_ciq_data(ii)
   SET specimen_type_cd = 0.0
   SET special_handling_cd = 0.0
   SET collection_method_cd = 0.0
   SET accession_class_cd = 0.0
   SET collection_class_cd = 0.0
   SET min_vol_units_cd = 0.0
   SET cvcnt = size(cvlist->cvrec,5)
   CALL echo(build("Special handling = ",special_handling))
   IF (cvcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = cvcnt)
     PLAN (d
      WHERE (cvlist->cvrec[d.seq].cs=230)
       AND trim(cvlist->cvrec[d.seq].disp)=trim(special_handling))
     DETAIL
      special_handling_cd = cvlist->cvrec[d.seq].code_value
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("special handling cd = ",special_handling_cd))
   CALL echo(build("Specimen type = ",specimen_type))
   IF (cvcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = cvcnt)
     PLAN (d
      WHERE (cvlist->cvrec[d.seq].cs=2052)
       AND (cvlist->cvrec[d.seq].disp=specimen_type))
     DETAIL
      specimen_type_cd = cvlist->cvrec[d.seq].code_value
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("specimen type cd = ",specimen_type_cd))
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=2058
      AND cv.display_key=cnvtupper(cnvtalphanum(collection_method))
      AND cv.active_ind=1)
    DETAIL
     collection_method_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=2056
      AND cv.display_key=cnvtupper(cnvtalphanum(accession_class)))
    DETAIL
     accession_class_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key=cnvtupper(cnvtalphanum(collection_class)))
    DETAIL
     collection_class_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=54
      AND cv.display_key=cnvtupper(min_vol_units))
    DETAIL
     min_vol_units_cd = cv.code_value
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE add_oc_dta_reltn(jj)
   SET mseq = 0
   SET tcnt = 0
   SELECT INTO "NL:"
    ptr.sequence
    FROM profile_task_r ptr
    PLAN (ptr
     WHERE ptr.catalog_cd=orc_cat_cd)
    DETAIL
     tcnt = (tcnt+ 1)
     IF (mseq < ptr.sequence)
      mseq = ptr.sequence
     ENDIF
    WITH nocounter
   ;end select
   CALL echo(build("***  mseq3 =   ",mseq))
   IF (tcnt=0)
    SET assay_seq = 0
   ELSE
    SET assay_seq = (mseq+ 1)
   ENDIF
   INSERT  FROM profile_task_r ptr
    SET ptr.catalog_cd = orc_cat_cd, ptr.task_assay_cd = new_dta_cd, ptr.version_nbr = 0,
     ptr.group_cd = 0.0, ptr.item_type_flag = 0, ptr.pending_ind = 0,
     ptr.repeat_ind = 0, ptr.sequence = assay_seq, ptr.dup_chk_min = 0,
     ptr.dup_chk_action_cd = 0.0, ptr.updt_dt_tm = cnvtdatetime(curdate,curtime), ptr.updt_id =
     reqinfo->updt_id,
     ptr.updt_task = reqinfo->updt_task, ptr.updt_cnt = 0, ptr.updt_applctx = reqinfo->updt_applctx,
     ptr.active_ind = 1, ptr.post_prompt_ind = 0, ptr.prompt_resource_cd = 0.0,
     ptr.active_status_cd = active_cd, ptr.active_status_dt_tm = cnvtdatetime(curdate,curtime), ptr
     .active_status_prsnl_id = reqinfo->updt_id,
     ptr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), ptr.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100, 00:00:00"), ptr.reference_task_id = 0.0,
     ptr.prompt_long_text_id = 0.0, ptr.restrict_display_ind = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET msg = concat("Error adding dta relationship: ",request->orders[ii].order_desc,":",request->
     orders[ii].assay_list[jj].assay_desc)
    CALL logerrormessage(msg)
    SET msg = concat("New_dta_cd =  ",cnvtstring(new_dta_cd))
    CALL logerrormessage(msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE addcontainer(ii)
   CALL echo(build("Adding a new container now: ",alias))
   SET ccsze = size(cntnrs->cntnrlist,5)
   SET cntnr_found = "N"
   IF (ccsze > 0)
    FOR (jj = 1 TO ccsze)
      IF ((cntnrs->cntnrlist[jj].c_rli_alias_id=rli_alias_id))
       SET cntnr_found = "Y"
      ENDIF
    ENDFOR
   ENDIF
   IF (cntnr_found="N")
    SET cntnrcnt = (cntnrcnt+ 1)
    SET stat = alterlist(cntnrs->cntnrlist,cntnrcnt)
    SET cntnrs->cntnrlist[cntnrcnt].c_alias = alias
    SET cntnrs->cntnrlist[cntnrcnt].c_code_value = hold_code_value
    SET cntnrs->cntnrlist[cntnrcnt].c_rli_alias_id = rli_alias_id
   ENDIF
   SELECT INTO "nl:"
    FROM specimen_container sc
    PLAN (sc
     WHERE sc.spec_cntnr_cd=hold_code_value)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET volume_units_cd = 0.0
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.cdf_meaning=unit_meaning
       AND cv.active_ind=1
       AND cv.code_set=54)
     DETAIL
      volume_units_cd = cv.code_value
     WITH nocounter
    ;end select
    INSERT  FROM specimen_container sc
     SET sc.spec_cntnr_cd = hold_code_value, sc.aliquot_ind = 0, sc.volume_units = null,
      sc.volume_units_cd = volume_units_cd, sc.updt_cnt = 0, sc.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      sc.updt_id = reqinfo->updt_id, sc.updt_task = reqinfo->updt_task, sc.updt_applctx = reqinfo->
      updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     INSERT  FROM specimen_container_volume scv
      SET scv.spec_cntnr_cd = hold_code_value, scv.volume = 99.9, scv.updt_cnt = 0,
       scv.updt_dt_tm = cnvtdatetime(curdate,curtime), scv.updt_id = reqinfo->updt_id, scv.updt_task
        = reqinfo->updt_task,
       scv.updt_applctx = reqinfo->updt_applctx, scv.spec_cntnr_seq = seq(reference_seq,nextval)
      WITH nocounter
     ;end insert
    ELSE
     SET error_flag = "T"
     SET error_msg = concat(error_msg,"Error adding specimen container for: ",alias)
     SET errmsg = error_msg
     CALL logerrormessage(errmsg)
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE chgrliorder(ii)
  SET msg = concat("Change action sent for : ",cnvtstring(request->order_list[ii].catalog_cd),
   "  Change is invalid.  Skipping order.")
  CALL logmessage(msg)
 END ;Subroutine
 SUBROUTINE delrliorder(ii)
  SET msg = concat("Delete action sent for : ",cnvtstring(request->order_list[ii].catalog_cd),
   "  Delete is invalid.  Skipping order.")
  CALL logmessage(msg)
 END ;Subroutine
 SUBROUTINE logmessage(msg)
   SELECT INTO "ccluserdir:bed_rli_orders.log"
    rvar
    DETAIL
     row + 1, col 0, msg
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logerrormessage(msg)
   SELECT INTO "ccluserdir:bed_rli_orders_error.log"
    rvar
    DETAIL
     row + 2, col 0, msg
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = error_msg
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
