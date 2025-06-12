CREATE PROGRAM bbt_rpt_ex_xmdetail:dba
 DECLARE datafoundflag = i2 WITH protect, noconstant(false)
 SET exception_disp = uar_get_code_display(xm_exception_cd)
 SET exception_meaning = uar_get_code_meaning(xm_exception_cd)
 IF (exception_meaning="XMNOAG")
  EXECUTE cpm_create_file_name_logical "bbt_xmnoag", "txt", "x"
 ELSEIF (exception_meaning="XMNOTREQ")
  EXECUTE cpm_create_file_name_logical "bbt_xmnotreq", "txt", "x"
 ELSEIF (exception_meaning="XM ALLO BLK")
  EXECUTE cpm_create_file_name_logical "bbt_xmalloblk", "txt", "x"
 ELSE
  GO TO exit_script
 ENDIF
 SELECT INTO cpm_cfn_info->file_name_logical
  requirement_disp = uar_get_code_display(bb1.requirement_cd), special_testing_disp =
  uar_get_code_display(bb1.special_testing_cd), bp_cur_abo_disp = uar_get_code_display(bp.cur_abo_cd),
  bp_cur_rh_disp = uar_get_code_display(bp.cur_rh_cd), pa_abo_disp = uar_get_code_display(pa.abo_cd),
  pa_rh_disp = uar_get_code_display(pa.rh_cd),
  override_reason_disp = uar_get_code_display(bb.override_reason_cd), product_disp =
  uar_get_code_display(pr.product_cd), alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd),
  exception_dt_tm = cnvtdatetime(pe.event_dt_tm), accn = cnvtacc(ac.accession), blk_prod_disp =
  uar_get_code_display(a_pr.product_cd)
  FROM bb_exception bb,
   prsnl usr,
   product_event pe,
   product pr,
   blood_product bp,
   person per,
   result re,
   accession_order_r ac,
   bb_reqs_exception bb1,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   prsnl prs,
   person_aborh pa,
   bb_autodir_exception bba,
   product a_pr,
   blood_product a_bp
  PLAN (bb
   WHERE bb.exception_type_cd=xm_exception_cd
    AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND bb.exception_id > 0)
   JOIN (usr
   WHERE bb.updt_id=usr.person_id)
   JOIN (pe
   WHERE bb.product_event_id=pe.product_event_id)
   JOIN (pr
   WHERE pe.product_id=pr.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (per
   WHERE pe.person_id=per.person_id)
   JOIN (bp
   WHERE pe.product_id=bp.product_id)
   JOIN (re
   WHERE bb.result_id=re.result_id)
   JOIN (ac
   WHERE re.order_id=ac.order_id
    AND ac.primary_flag=0)
   JOIN (ea
   WHERE outerjoin(pe.encntr_id)=ea.encntr_id
    AND ea.encntr_alias_type_cd=outerjoin(encntr_mrn_code)
    AND ea.active_ind=outerjoin(1)
    AND ea.beg_effective_dt_tm <= outerjoin(pe.event_dt_tm)
    AND ea.end_effective_dt_tm >= outerjoin(pe.event_dt_tm))
   JOIN (pa
   WHERE outerjoin(pe.person_id)=pa.person_id
    AND pa.active_ind=outerjoin(1))
   JOIN (epr
   WHERE outerjoin(pe.encntr_id)=epr.encntr_id
    AND epr.encntr_prsnl_r_cd=outerjoin(admitdoc)
    AND epr.active_ind=outerjoin(1)
    AND epr.beg_effective_dt_tm <= outerjoin(pe.event_dt_tm)
    AND epr.end_effective_dt_tm >= outerjoin(pe.event_dt_tm))
   JOIN (prs
   WHERE outerjoin(epr.prsnl_person_id)=prs.person_id)
   JOIN (bb1
   WHERE bb1.exception_id=outerjoin(bb.exception_id))
   JOIN (bba
   WHERE bba.bb_exception_id=outerjoin(bb.exception_id))
   JOIN (a_pr
   WHERE a_pr.product_id=outerjoin(bba.product_id))
   JOIN (a_bp
   WHERE a_bp.product_id=outerjoin(bba.product_id))
  ORDER BY exception_dt_tm, bb.exception_id
  HEAD REPORT
   col_head_7 = fillstring(7,"-"), col_head_25 = fillstring(25,"-"), col_head_20 = fillstring(20,"-"),
   col_head_15 = fillstring(15,"-"), blk_prod_number = fillstring(25," ")
  HEAD PAGE
   beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
   inc_i18nhandle = 0,
   inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
   IF (sub_get_location_name="<<INFORMATION NOT FOUND>>")
    inc_info_not_found = uar_i18ngetmessage(inc_i18nhandle,"inc_information_not_found",
     "<<INFORMATION NOT FOUND>>"), col 1, inc_info_not_found
   ELSE
    col 1, sub_get_location_name
   ENDIF
   row + 1
   IF (sub_get_location_name != "<<INFORMATION NOT FOUND>>")
    IF (sub_get_location_address1 != " ")
     col 1, sub_get_location_address1, row + 1
    ENDIF
    IF (sub_get_location_address2 != " ")
     col 1, sub_get_location_address2, row + 1
    ENDIF
    IF (sub_get_location_address3 != " ")
     col 1, sub_get_location_address3, row + 1
    ENDIF
    IF (sub_get_location_address4 != " ")
     col 1, sub_get_location_address4, row + 1
    ENDIF
    IF (sub_get_location_citystatezip != ",   ")
     col 1, sub_get_location_citystatezip, row + 1
    ENDIF
    IF (sub_get_location_country != " ")
     col 1, sub_get_location_country, row + 1
    ENDIF
   ENDIF
   save_row = row, row 0,
   CALL center(captions->bb_exception,1,125),
   col 104, captions->time, col 118,
   curtime"@TIMENOSECONDS;;M", row + 1, col 104,
   captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
   row save_row, row + 1, col 1,
   captions->bb_owner, col 19, cur_owner_area_disp,
   row + 1, col 1, captions->inventory_area,
   col 17, cur_inv_area_disp, row + 2,
   col 32, captions->beg_date, col 48,
   beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
   col 69, captions->end_date, col 82,
   end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M",
   row + 2, col 1, exception_disp,
   row + 2,
   CALL center(captions->product_number,9,33),
   CALL center(captions->product_type,35,59),
   CALL center(captions->unit_abo,61,75),
   CALL center(captions->reason,98,117), row + 1,
   CALL center(captions->xmd,1,7),
   CALL center(captions->accession_number,9,33),
   CALL center(captions->name,35,59),
   CALL center(captions->patient_abo,61,75),
   CALL center(captions->alias,77,96),
   CALL center(captions->physician,98,117),
   CALL center(captions->tech,119,125), row + 1, col 1,
   col_head_7, col 9, col_head_25,
   col 35, col_head_25, col 61,
   col_head_15, col 77, col_head_20,
   col 98, col_head_20, col 119,
   col_head_7
  HEAD exception_dt_tm
   row + 0
  HEAD bb.exception_id
   IF (row > 54)
    BREAK
   ENDIF
   datafoundflag = true, row + 1, pe_dt_tm = cnvtdatetime(pe.event_dt_tm),
   col 1, pe_dt_tm"@DATECONDENSED;;d", prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr
     .product_nbr)," ",trim(pr.product_sub_nbr)),
   col 9, prod_nbr_display, col 35,
   product_disp"#########################", product_aborh_disp = fillstring(15," "),
   product_aborh_disp = trim(concat(trim(bp_cur_abo_disp)," ",trim(bp_cur_rh_disp))),
   col 61, product_aborh_disp"###############", col 98,
   override_reason_disp"####################", col 119, usr.username"#######",
   row + 1, col 1, pe_dt_tm"@TIMENOSECONDS;;M",
   col 9, accn"#########################", col 35,
   per.name_full_formatted"#########################", patient_aborh_disp = fillstring(15," "),
   patient_aborh_disp = trim(concat(trim(pa_abo_disp)," ",trim(pa_rh_disp))),
   col 61, patient_aborh_disp"###############"
   IF (alias_disp > "")
    col 77, alias_disp"####################"
   ELSE
    col 77, captions->not_on_file
   ENDIF
   col 98, prs.name_full_formatted"####################", row + 1,
   first_ag_ab = "Y"
  DETAIL
   IF (row > 54)
    BREAK
   ENDIF
   IF (first_ag_ab="Y")
    first_ag_ab = "N", row + 1
    IF (exception_meaning="XMNOAG")
     CALL center(captions->patient_antibodies,37,63),
     CALL center(captions->product_antigens,65,89)
    ELSEIF (exception_meaning="XMNOTREQ")
     CALL center(captions->trans_reqs,37,63),
     CALL center(captions->prod_attributes,65,89)
    ELSEIF (exception_meaning="XM ALLO BLK")
     CALL center(captions->product_number,37,63),
     CALL center(captions->product_type,65,89)
    ENDIF
    row + 1, col 37, col_head_25,
    col 65, col_head_25
   ENDIF
   IF (row > 55)
    BREAK
   ENDIF
   row + 1
   IF (exception_meaning="XM ALLO BLK")
    blk_prod_number = concat(trim(a_bp.supplier_prefix),trim(a_pr.product_nbr)," ",trim(a_pr
      .product_sub_nbr)), col 37, blk_prod_number,
    col 65, blk_prod_disp"#########################"
   ELSE
    col 37, requirement_disp"#########################", col 65,
    special_testing_disp"#########################"
   ENDIF
  FOOT  bb.exception_id
   row + 1
  FOOT  exception_dt_tm
   row + 0
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, cpm_cfn_info->file_name_path,
   col 58, captions->page_no, col 64,
   curpage"###", col 100, captions->printed,
   col 109, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M"
  FOOT REPORT
   row 60, col 51, captions->end_of_report
  WITH maxrow = 61, nullreport, compress,
   nolandscape, nocounter
 ;end select
 IF (((datafoundflag=true) OR ((request->null_ind=1))) )
  SET rpt_cnt = (rpt_cnt+ 1)
  SET stat = alterlist(reply->rpt_list,rpt_cnt)
  SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
  SET datafoundflag = false
 ENDIF
#exit_script
END GO
