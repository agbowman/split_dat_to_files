CREATE PROGRAM ams_iv_builder
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "input file" = ""
  WITH outdev, directory, input_file
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUT_FILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 FREE RECORD temp
 RECORD temp(
   1 list[*]
     2 desc = vc
     2 catlog_type = vc
     2 activity_type = vc
     2 activity_subtype = vc
     2 component = vc
 )
 FREE SET request_951010
 RECORD request_951010(
   1 nbr_of_recs = i2
   1 qual[*]
     2 action = i2
     2 ext_id = f8
     2 ext_contributor_cd = f8
     2 parent_qual_ind = f8
     2 careset_ind = i2
     2 ext_owner_cd = f8
     2 ext_description = c100
     2 ext_short_desc = c50
     2 price_qual = i2
     2 prices[1]
       3 price_sched_id = f8
       3 price = f8
     2 billcode_qual = i2
     2 billcodes[1]
       3 billcode_sched_cd = f8
       3 billcode = c25
     2 child_qual = i2
     2 children[*]
       3 ext_id = f8
       3 ext_contributor_cd = f8
       3 ext_description = c100
       3 ext_short_desc = c50
 )
 RECORD reply_951010(
   1 bill_item_qual = i4
   1 bill_item[*]
     2 bill_item_id = f8
   1 qual[*]
     2 bill_item_id = f8
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 price_sched_id = f8
     2 price_sched_items_id = f8
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[*]
     2 bill_item_mod_id = f8
   1 actioncnt = i2
   1 actionlist[*]
     2 action1 = vc
     2 action2 = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c20
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET request_500178
 RECORD request_500178(
   1 consent_form_ind = i2
   1 modifiable_flag = i2
   1 active_ind = i2
   1 catalog_type_cd = f8
   1 activity_type_cd = f8
   1 activity_subtype_cd = f8
   1 requisition_format_cd = f8
   1 requisition_routing_cd = f8
   1 inst_restriction_ind = i2
   1 schedule_ind = i2
   1 description = c100
   1 iv_ingredient_ind = i2
   1 print_req_ind = i2
   1 oe_format_id = f8
   1 orderable_type_flag = i2
   1 complete_upon_order_ind = i2
   1 quick_chart_ind = i2
   1 comment_template_flag = i2
   1 prep_info_flag = i2
   1 dup_checking_ind = i2
   1 bill_only_ind = i2
   1 cont_order_method_flag = i2
   1 order_review_ind = i2
   1 dcp_clin_cat_cd = f8
   1 orc_text = vc
   1 cscomp_cnt = i4
   1 qual_cscomp[*]
     2 comp_seq = i4
     2 comp_type_cd = f8
     2 comp_id = f8
     2 comp_label = vc
     2 comment_text = vc
     2 required_ind = i2
     2 include_exclude_ind = i2
     2 lockdown_details_flag = i2
     2 av_optional_ingredient_ind = i2
     2 order_sentence_id = f8
     2 linked_date_comp_seq = i4
   1 mnemonic_cnt = i4
   1 qual_mnemonic[*]
     2 mnemonic = c100
     2 mnemonic_type_cd = f8
     2 order_sentence_id = f8
     2 hide_flag = i2
     2 active_ind = i2
     2 orderable_type_flag = i2
     2 dcp_clin_cat_cd = f8
     2 virtual_view = c100
     2 qual_facility[*]
       3 facility_cd = f8
   1 review_cnt = i4
   1 qual_review[*]
     2 action_type_cd = f8
     2 nurse_review_flag = i2
     2 doctor_cosign_flag = i2
     2 rx_verify_flag = i2
   1 dup_cnt = i4
   1 qual_dup[*]
     2 dup_check_seq = i4
     2 exact_hit_action_cd = f8
     2 min_behind = i4
     2 min_behind_action_cd = f8
     2 min_ahead = i4
     2 min_ahead_action_cd = f8
     2 active_ind = i2
 )
 FREE RECORD reply_500178
 RECORD reply_500178(
   1 ockey = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DEFINE rtl2 value(file_path)
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, count = 0, stat = alterlist(temp->list,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1)
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (count > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=0)
      stat = alterlist(temp->list,(row_count+ 9))
     ENDIF
     temp->list[row_count].desc = piece(r.line,",",1,"0"), temp->list[row_count].catlog_type = piece(
      r.line,",",2,"0"), temp->list[row_count].activity_type = piece(r.line,",",3,"0"),
     temp->list[row_count].activity_subtype = piece(r.line,",",4,"0"), temp->list[row_count].
     component = piece(r.line,",",5,"0")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->list,row_count)
  WITH nocounter
 ;end select
 SET scnt = 1
 SET scnt1 = 1
 DECLARE cat_cd = f8
 FOR (i = 1 TO size(temp->list,5))
   SET stat = initrec(request_500178)
   SET stat = alterlist(request_500178->qual_cscomp,1)
   SET stat = alterlist(request_500178->qual_mnemonic,1)
   SET stat = alterlist(request_951010->qual,1)
   SET stat = alterlist(request_951010->qual[1].children,1)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.display=trim(temp->list[i].catlog_type)
     AND cv.code_set=6000
     AND cv.active_ind=1
    HEAD cv.code_value
     request_500178->catalog_type_cd = cv.code_value, request_500178->active_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.display=trim(temp->list[i].activity_type)
     AND cv.code_set=106
     AND cv.active_ind=1
    HEAD cv.code_value
     request_500178->activity_type_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.display=trim(temp->list[i].activity_subtype)
     AND cv.code_set=5801
     AND cv.active_ind=1
    HEAD cv.code_value
     request_500178->activity_subtype_cd = cv.code_value
    WITH nocounter
   ;end select
   SET request_500178->cscomp_cnt = 1
   SET request_500178->mnemonic_cnt = 1
   SET request_500178->qual_cscomp[1].comp_type_cd = 2718
   SELECT INTO "nl:"
    FROM order_catalog_synonym oc,
     cs_component cc
    PLAN (oc
     WHERE (oc.catalog_cd=
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=200
       AND cv.display=trim(temp->list[i].component))))
     JOIN (cc
     WHERE oc.synonym_id=cc.comp_id
      AND cc.comp_type_cd=2718)
    DETAIL
     request_500178->qual_cscomp[1].comp_id = oc.synonym_id
    WITH nocounter
   ;end select
   SET request_500178->qual_cscomp[1].comp_seq = 1
   SET request_500178->qual_cscomp[1].include_exclude_ind = 1
   SET request_500178->modifiable_flag = 1
   SET request_500178->orderable_type_flag = 8
   SET request_500178->description = temp->list[i].desc
   SET request_500178->dcp_clin_cat_cd = 10575
   SET request_500178->qual_mnemonic[1].active_ind = 1
   SET request_500178->qual_mnemonic[1].mnemonic = temp->list[i].desc
   SET request_500178->qual_mnemonic[1].mnemonic_type_cd = 2583.00
   SET request_500178->qual_mnemonic[1].dcp_clin_cat_cd = 10575.00
   SET request_500178->qual_mnemonic[1].active_ind = 1
   SET stat = tdbexecute(500029,500179,500178,"REC",request_500178,
    "REC",reply_500178)
   SET request_951010->qual[1].ext_id = reply_500178->ockey
   SET request_951010->qual[1].ext_contributor_cd = 3443.00
   SET request_951010->qual[1].ext_owner_cd = 705.00
   SET request_951010->qual[1].ext_description = temp->list[i].desc
   SET request_951010->qual[1].ext_short_desc = temp->list[i].desc
   SET request_951010->qual[1].parent_qual_ind = 1
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=200
     AND cv.display=trim(temp->list[i].component)
    DETAIL
     request_951010->qual[1].children[1].ext_id = cv.code_value
    WITH nocounter
   ;end select
   SET request_951010->qual[1].children[1].ext_contributor_cd = 3443.00
   SET request_951010->qual[1].children[1].ext_description = trim(temp->list[i].component)
   SET request_951010->qual[1].children[1].ext_short_desc = trim(temp->list[i].component)
   SET stat = tdbexecute(500029,951002,951010,"REC",request_951010,
    "REC",reply_951010)
 ENDFOR
 CALL echorecord(request_500178)
 CALL echorecord(request_951010)
 CALL echorecord(reply_500178)
 CALL echorecord(reply_951010)
 SELECT INTO  $OUTDEV
  request_500178_catalog_type_cd = request_500178->catalog_type_cd, request_500178_activity_type_cd
   = request_500178->activity_type_cd, request_500178_activity_subtype_cd = request_500178->
  activity_subtype_cd,
  qual_cscomp_comp_type_cd = request_500178->qual_cscomp[d1.seq].comp_type_cd, qual_cscomp_comp_id =
  request_500178->qual_cscomp[d1.seq].comp_id
  FROM (dummyt d1  WITH seq = value(size(request_500178->qual_cscomp,5)))
  PLAN (d1)
  WITH nocounter, separator = " ", format
 ;end select
END GO
