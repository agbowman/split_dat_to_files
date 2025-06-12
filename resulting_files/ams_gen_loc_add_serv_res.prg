CREATE PROGRAM ams_gen_loc_add_serv_res
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
 FREE RECORD temp1
 RECORD temp1(
   1 list[*]
     2 institution = vc
     2 department = vc
     2 section = vc
     2 subsection = vc
     2 serv_res_desc = vc
     2 disp_name = vc
     2 discipline_type = vc
     2 activity_type = vc
     2 activity_subtype = vc
     2 login_location = vc
     2 spec_login_location = vc
     2 cdf_meaning = vc
 )
 FREE RECORD request_13055
 RECORD request_13055(
   1 code_set = i4
   1 cdf_meaning = c12
 )
 FREE RECORD reply_13055
 RECORD reply_13055(
   1 max_coll_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request_13059
 RECORD request_13059(
   1 parent_service_resource_cd = f8
   1 resource_group_type_mean = c12
   1 root_service_resource_cd = f8
 )
 FREE RECORD request_13001
 RECORD request_13001(
   1 qual[*]
     2 location_cd = f8
     2 cdf_meaning = c12
     2 root_service_resource_cd = f8
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 description = vc
     2 short_desc = c40
     2 definition = vc
     2 collation_seq = i4
     2 specimen_login_cd = f8
     2 activity_type_cd = f8
     2 activity_subtype_cd = f8
     2 discipline_type_cd = f8
     2 organization_id = f8
     2 autologin_ind = i2
     2 dispatch_download_ind = i2
     2 multiplexor_ind = i2
     2 charge_cost_ratio = i4
     2 reimbursement_cost_ratio = i4
     2 transcript_que_cd = f8
     2 temp_multi_flag = i2
     2 nbr_exam_on_req = i4
     2 prelim_ind = i2
     2 expedite_nursing_ind = i2
     2 unread_films_ind = i2
     2 chk_diff_borr_ind = i2
     2 daily_folder_ind = i2
     2 folder_nbr_format_cd = f8
     2 return_loc_flag = i2
     2 lib_ind = i2
     2 purge_lib_ind = i2
     2 filing_method_cd = f8
     2 pull_list_by_sect_ind = i2
     2 inventory_resoure_cd = f8
     2 pat_care_loc_ind = i2
     2 pharmacy_type_cd = f8
     2 rx_loc_type = i4
     2 rx_license = c18
     2 rx_code = c18
     2 nabp_nbr = c18
     2 mobile_cart = c18
     2 mobile_reorder_loc_cd = f8
     2 dispense_ind = i2
     2 supply_ind = i2
     2 atd_req_ind = i2
     2 rx_charge_ind = i2
     2 tax_payer_nbr = vc
     2 min_order_cost = f8
     2 approved_vendor_status_cd = f8
     2 vendor_number = i4
     2 vendor_type_cd = f8
     2 auto_commit_po_ind = i2
     2 auto_commit_receipt_ind = i2
     2 bb_device_type = i4
     2 bb_prod_ind = i2
     2 bb_monitored_temp_hi = f8
     2 bb_monitored_temp_lo = f8
     2 bb_barcode_id = f8
     2 location_type = i4
     2 primary_vendor = i4
     2 primary_fill_location = i4
     2 worklist_build_flag = i2
     2 worklist_hours = i4
     2 worklist_max = i4
     2 container_ind = i2
     2 gate_ind = i2
     2 strt_model_id = f8
     2 instr_identifier = i4
     2 identifier_flag = i2
     2 auto_verify_flag = i2
     2 instr_alias = vc
     2 point_of_care_flag = i2
     2 blind_receipt_ind = i2
     2 manual_receipt_ind = i2
     2 allow_overshipments_ind = i2
     2 ack_variance_percent = f8
     2 ack_variance_amount = f8
     2 po_max_lines = i4
     2 allow_backorders_ind = i2
     2 accn_site_prefix = c5
     2 inv_location_cd = f8
     2 inventory_resource_cd = f8
     2 eso_tpn_cmpd_ind = i2
     2 eso_dose_msg_ind = i2
     2 eso_ingred_ind = i2
     2 clia_number = vc
     2 medical_director_name = vc
 )
 FREE RECORD reply_13001
 RECORD reply_13001(
   1 qual[*]
     2 service_resource_cd = f8
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 FREE RECORD request_13023
 RECORD request_13023(
   1 qual[*]
     2 parent_service_resource_cd = f8
     2 child_service_resource_cd = f8
     2 cdf_meaning = c12
     2 root_service_resource_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 sequence = i4
 )
 FREE RECORD request_951010
 RECORD request_951010(
   1 nbr_of_recs = i2
   1 qual[*]
     2 action = i2
     2 ext_id = f8
     2 ext_contributor_cd = f8
     2 parent_qual_ind = f8
     2 careset_ind = i2
     2 ext_owner_cd = f8
     2 ext_sub_owner_cd = f8
     2 ext_description = c100
     2 ext_short_desc = c50
     2 workload_only_ind = i2
     2 price_qual = i2
     2 prices[*]
       3 price_sched_id = f8
       3 price = f8
     2 billcode_qual = i2
     2 billcodes[*]
       3 billcode_sched_cd = f8
       3 billcode = c25
       3 bim1_int = f8
     2 child_qual = i4
     2 children[*]
       3 ext_id = f8
       3 ext_contributor_cd = f8
       3 ext_description = c100
       3 ext_short_desc = c50
       3 child_seq = i4
       3 bi_id = f8
       3 ext_owner_cd = f8
       3 ext_sub_owner_cd = f8
   1 logical_domain_id = f8
 )
 DEFINE rtl2 value(file_path)
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, count = 0, stat = alterlist(temp1->list,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1)
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (count > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=0)
      stat = alterlist(temp1->list,(row_count+ 9))
     ENDIF
     temp1->list[row_count].institution = piece(r.line,",",1,"0"), temp1->list[row_count].department
      = piece(r.line,",",2,"0"), temp1->list[row_count].section = piece(r.line,",",3,"0"),
     temp1->list[row_count].subsection = piece(r.line,",",4,"0"), temp1->list[row_count].
     serv_res_desc = piece(r.line,",",5,"0"), temp1->list[row_count].disp_name = piece(r.line,",",6,
      "0"),
     temp1->list[row_count].discipline_type = piece(r.line,",",7,"0"), temp1->list[row_count].
     activity_type = piece(r.line,",",8,"0"), temp1->list[row_count].activity_subtype = piece(r.line,
      ",",9,"0"),
     temp1->list[row_count].login_location = piece(r.line,",",10,"0"), temp1->list[row_count].
     spec_login_location = piece(r.line,",",11,"0"), temp1->list[row_count].cdf_meaning = piece(r
      .line,",",12,"0")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp1->list,row_count)
  WITH nocounter
 ;end select
 SET scnt = 0
 SET scnt1 = 0
 DECLARE cat_cd = f8
 DECLARE serv_res_cd = f8
 FOR (i = 1 TO size(temp1->list,5))
   SET stat = initrec(request_13001)
   SET scnt = (scnt+ 1)
   SET stat = alterlist(request_13001->qual,scnt)
   SET request_13055->code_set = 221
   SET request_13055->cdf_meaning = trim(temp1->list[i].cdf_meaning) WITH nocounter
   CALL echorecord(request_13055)
   SET stat = tdbexecute(13000,13000,13055,"REC",request_13055,
    "REC",reply_13055)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.display=trim(temp1->list[i].login_location)
     AND cv.code_set=220
     AND cv.active_ind=1
    HEAD cv.code_value
     request_13001->qual[scnt].location_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.display=trim(temp1->list[i].spec_login_location)
     AND cv.code_set=220
     AND cv.active_ind=1
    HEAD cv.code_value
     request_13001->qual[scnt].specimen_login_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.display=trim(temp1->list[i].activity_type)
     AND cv.code_set=106
     AND cv.active_ind=1
    HEAD cv.code_value
     request_13001->qual[scnt].activity_type_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.display=trim(temp1->list[i].activity_subtype)
     AND cv.code_set=5801
     AND cv.active_ind=1
    HEAD cv.code_value
     request_13001->qual[scnt].activity_subtype_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.display=trim(temp1->list[i].discipline_type)
     AND cv.code_set=6000
     AND cv.active_ind=1
    HEAD cv.code_value
     request_13001->qual[scnt].discipline_type_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.display=trim(temp1->list[i].institution)
     AND cv.code_set=221
     AND cv.active_ind=1
    HEAD cv.code_value
     cat_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM service_resource sr
    WHERE sr.service_resource_cd=cat_cd
    HEAD sr.service_resource_cd
     request_13001->qual[scnt].organization_id = sr.organization_id
    WITH nocounter
   ;end select
   SET request_13001->qual[scnt].description = temp1->list[i].serv_res_desc
   SET request_13001->qual[scnt].short_desc = temp1->list[i].disp_name
   SET request_13001->qual[scnt].cdf_meaning = temp1->list[i].cdf_meaning
   SET request_13001->qual[scnt].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
   SET request_13001->qual[scnt].end_effective_dt_tm = cnvtdatetime(cnvtdate(12302100),2359)
   SET request_13001->qual[scnt].active_ind = 1
   SET request_13001->qual[scnt].collation_seq = reply_13055->max_coll_seq
   SET stat = tdbexecute(13000,13001,13001,"REC",request_13001,
    "REC",reply_13001)
   CALL echorecord(reply_13001)
   SET stat = alterlist(request_13023->qual,1)
   SET request_13023->qual[1].child_service_resource_cd = reply_13001->qual[1].service_resource_cd
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.display=trim(temp1->list[i].subsection)
     AND cv.active_ind=1
    HEAD cv.code_value
     request_13023->qual[1].parent_service_resource_cd = cv.code_value, request_13023->qual[1].
     cdf_meaning = cv.cdf_meaning, request_13023->qual[1].beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime),
     request_13023->qual[1].end_effective_dt_tm = cnvtdatetime(cnvtdate(12312100),2359)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM resource_group rg
    WHERE (rg.parent_service_resource_cd=request_13023->qual[1].parent_service_resource_cd)
    ORDER BY rg.sequence DESC
    HEAD rg.parent_service_resource_cd
     request_13023->qual[1].sequence = (rg.sequence+ 1)
    WITH nocounter
   ;end select
   EXECUTE loc_add_res_parent_child_r  WITH replace("REQUEST",request_13023)
   SET stat = alterlist(request_951010->qual,scnt)
   SET request_951010->nbr_of_recs = scnt
   SET request_951010->qual[scnt].ext_id = request_13023->qual[1].child_service_resource_cd
   SET request_951010->qual[scnt].ext_contributor_cd = 3443.00
   SET request_951010->qual[scnt].parent_qual_ind = 1
   SET request_951010->qual[scnt].ext_owner_cd = 692.00
   SET request_951010->qual[scnt].ext_description = temp1->list[i].serv_res_desc
   SET request_951010->qual[scnt].ext_short_desc = temp1->list[i].disp_name
   SET stat = tdbexecute(13000,13001,951010,"REC",request_951010,
    "REC",reply_951010)
   CALL echorecord(reply_951010)
 ENDFOR
 CALL echorecord(reply_13055)
 CALL echorecord(reply_13001)
 CALL echorecord(request_13023)
 CALL echorecord(request_13001)
 CALL echorecord(request_951010)
 SELECT INTO  $OUTDEV
  qual_location_cd = request_13001->qual[d1.seq].location_cd, qual_cdf_meaning = request_13001->qual[
  d1.seq].cdf_meaning, qual_description = substring(1,30,request_13001->qual[d1.seq].description),
  qual_short_desc = request_13001->qual[d1.seq].short_desc, qual_specimen_login_cd = request_13001->
  qual[d1.seq].specimen_login_cd, qual_activity_subtype_cd = request_13001->qual[d1.seq].
  activity_subtype_cd,
  qual_activity_type_cd = request_13001->qual[d1.seq].activity_type_cd, qual_discipline_type_cd =
  request_13001->qual[d1.seq].discipline_type_cd, qual_organization_id = request_13001->qual[d1.seq].
  organization_id
  FROM (dummyt d1  WITH seq = value(size(request_13001->qual,5)))
  PLAN (d1)
  WITH nocounter, separator = " ", format
 ;end select
END GO
