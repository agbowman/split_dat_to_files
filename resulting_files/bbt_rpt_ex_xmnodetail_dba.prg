CREATE PROGRAM bbt_rpt_ex_xmnodetail:dba
 DECLARE exception_description = vc
 DECLARE datafoundflag = i2 WITH protect, noconstant(false)
 SET exception_meaning = uar_get_code_meaning(xm_exception_cd)
 SET exception_description = uar_get_code_description(xm_exception_cd)
 IF (exception_meaning="XMNO2NDABO")
  EXECUTE cpm_create_file_name_logical "bbt_xmno2ndabo", "txt", "x"
 ELSEIF (exception_meaning="XMNOABSC")
  EXECUTE cpm_create_file_name_logical "bbt_xmnoabsc", "txt", "x"
 ELSEIF (exception_meaning="XMNOCURABO")
  EXECUTE cpm_create_file_name_logical "bbt_xmnocurabo", "txt", "x"
 ELSEIF (exception_meaning="XMUNMATCUR2D")
  EXECUTE cpm_create_file_name_logical "bbt_xmunmatcur2d", "txt", "x"
 ELSEIF (exception_meaning="XMUNMATDEMO")
  EXECUTE cpm_create_file_name_logical "bbt_xmunmatdemo", "txt", "x"
 ELSEIF (exception_meaning="INCXM")
  EXECUTE cpm_create_file_name_logical "bbt_xmincmptxm", "txt", "x"
 ELSEIF (exception_meaning="INCXMDISP")
  EXECUTE cpm_create_file_name_logical "bbt_dispincmptxm", "txt", "x"
 ELSE
  GO TO exit_script
 ENDIF
 SELECT INTO cpm_cfn_info->file_name_logical
  bp_cur_abo_disp = uar_get_code_display(bp.cur_abo_cd), bp_cur_rh_disp = uar_get_code_display(bp
   .cur_rh_cd), pa_abo_disp = uar_get_code_display(pa.abo_cd),
  pa_rh_disp = uar_get_code_display(pa.rh_cd), override_reason_disp = uar_get_code_display(bb
   .override_reason_cd), product_disp = uar_get_code_display(pr.product_cd),
  alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd), exception_dt_tm = cnvtdatetime(pe.event_dt_tm),
  accn = cnvtacc(ac.accession)
  FROM bb_exception bb,
   prsnl usr,
   product_event pe,
   product pr,
   blood_product bp,
   person per,
   result re,
   accession_order_r ac,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   prsnl prs,
   person_aborh pa
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
    AND ea.active_ind=outerjoin(1))
   JOIN (pa
   WHERE outerjoin(pe.person_id)=pa.person_id
    AND pa.active_ind=outerjoin(1))
   JOIN (epr
   WHERE outerjoin(pe.encntr_id)=epr.encntr_id
    AND epr.encntr_prsnl_r_cd=outerjoin(admitdoc)
    AND epr.active_ind=outerjoin(1))
   JOIN (prs
   WHERE outerjoin(epr.prsnl_person_id)=prs.person_id)
  ORDER BY exception_dt_tm, bb.exception_id
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
   row save_row, row + 1, col 32,
   captions->beg_date, col 48, beg_dt_tm"@DATECONDENSED;;d",
   col 56, beg_dt_tm"@TIMENOSECONDS;;M", col 69,
   captions->end_date, col 82, end_dt_tm"@DATECONDENSED;;d",
   col 90, end_dt_tm"@TIMENOSECONDS;;M", row + 2,
   col 1, captions->bb_owner, col 19,
   cur_owner_area_disp, row + 1, col 1,
   captions->inventory_area, col 17, cur_inv_area_disp,
   row + 2, col 1, exception_description,
   row + 2
   IF (exception_meaning="INCXM")
    col 1, captions->updated_to
   ELSEIF (exception_meaning="INCXMDISP")
    col 1, captions->dispensed
   ELSE
    col 1, captions->xmd
   ENDIF
   col 16, captions->product_number, col 35,
   captions->product_type, col 59, captions->aborh,
   col 78, captions->patient_name, col 100,
   captions->physician, col 120, captions->tech,
   row + 1
   IF (exception_meaning="INCXM")
    col 1, captions->crossmatched
   ENDIF
   col 16, captions->accession_number, col 54,
   captions->unit, col 66, captions->patient,
   col 78, captions->patient_mrn, col 100,
   captions->reason
   IF (exception_meaning="INCXM")
    row + 1, col 1, captions->state
   ENDIF
   row + 1, col 1, "--------------",
   col 16, "------------------", col 35,
   "------------------", col 54, "-----------------------",
   col 78, "---------------------", col 100,
   "-------------------", col 120, "------"
  HEAD exception_dt_tm
   row + 0
  HEAD bb.exception_id
   IF (row > 54)
    BREAK
   ENDIF
   datafoundflag = true, row + 1, pe_dt_tm = cnvtdatetime(pe.event_dt_tm),
   col 1, pe_dt_tm"@DATECONDENSED;;d", prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr
     .product_nbr)," ",trim(pr.product_sub_nbr)),
   col 16, prod_nbr_display, col 35,
   product_disp"##################", product_aborh_disp = fillstring(11," "), product_aborh_disp =
   trim(concat(trim(bp_cur_abo_disp)," ",trim(bp_cur_rh_disp))),
   col 54, product_aborh_disp"###########", patient_aborh_disp = fillstring(11," "),
   patient_aborh_disp = trim(concat(trim(pa_abo_disp)," ",trim(pa_rh_disp))), col 66,
   patient_aborh_disp"###########",
   col 78, per.name_full_formatted"#####################", col 100,
   prs.name_full_formatted"###################", col 120, usr.username"######",
   row + 1, col 1, pe_dt_tm"@TIMENOSECONDS;;M",
   col 16, accn"####################"
   IF (alias_disp > " ")
    col 78, alias_disp"#####################"
   ELSE
    col 78, captions->not_on_file
   ENDIF
   col 100, override_reason_disp"###################"
  DETAIL
   row + 0
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
END GO
