CREATE PROGRAM bbt_rpt_ex_disp_nodetail:dba
 DECLARE exception_count = i4 WITH protect, noconstant(0)
 DECLARE datafoundflag = i2 WITH protect, noconstant(false)
 RECORD temp_dispense_exception(
   1 disp_exception_info[*]
     2 exception_id = f8
     2 pe_dt_tm = dq8
     2 prod_nbr_display = vc
     2 product_aborh_disp = vc
     2 patient_aborh_disp = vc
     2 per_name_full_formatted = vc
     2 prsnl_name_full_formatted = vc
     2 usr_username = vc
     2 override_reason_disp = vc
     2 product_disp = vc
     2 alias_disp = vc
     2 exception_dt_tm = dq8
 )
 SET exception_meaning = uar_get_code_meaning(disp_exception_cd)
 IF (((exception_meaning="DISPNOCURABO") OR (((exception_meaning="DISPNO2NDABO") OR (((
 exception_meaning="DISPUMDEMO") OR (exception_meaning="DISPUMCUR2D")) )) )) )
  SET exception_disp = uar_get_code_display(disp_exception_cd)
 ELSE
  GO TO exit_script
 ENDIF
 SELECT
  bp_cur_abo_disp = uar_get_code_display(bp.cur_abo_cd), bp_cur_rh_disp = uar_get_code_display(bp
   .cur_rh_cd), pa_abo_disp = uar_get_code_display(pa.abo_cd),
  pa_rh_disp = uar_get_code_display(pa.rh_cd), override_reason_disp = uar_get_code_display(bb
   .override_reason_cd), product_disp = uar_get_code_display(pr.product_cd),
  alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd), exception_dt_tm = cnvtdatetime(pe.event_dt_tm)
  FROM bb_exception bb,
   prsnl usr,
   product_event pe,
   product pr,
   blood_product bp,
   person per,
   encntr_alias ea,
   person_aborh pa,
   patient_dispense pd,
   prsnl prsnl
  PLAN (bb
   WHERE bb.exception_type_cd=disp_exception_cd
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
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(pe.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(encntr_mrn_code))
    AND (ea.active_ind= Outerjoin(1)) )
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(pe.person_id))
    AND (pa.active_ind= Outerjoin(1)) )
   JOIN (pd
   WHERE pe.product_event_id=pd.product_event_id)
   JOIN (prsnl
   WHERE prsnl.person_id=pd.dispense_prov_id)
  ORDER BY exception_dt_tm, bb.exception_id
  HEAD REPORT
   row + 0
  HEAD exception_dt_tm
   row + 0
  HEAD bb.exception_id
   row + 0
  DETAIL
   exception_count += 1
   IF (size(temp_dispense_exception->disp_exception_info,5) <= exception_count)
    stat = alterlist(temp_dispense_exception->disp_exception_info,(exception_count+ 10))
   ENDIF
   temp_dispense_exception->disp_exception_info[exception_count].exception_id = bb.exception_id,
   temp_dispense_exception->disp_exception_info[exception_count].pe_dt_tm = cnvtdatetime(pe
    .event_dt_tm), temp_dispense_exception->disp_exception_info[exception_count].prod_nbr_display =
   concat(trim(bp.supplier_prefix),trim(pr.product_nbr)," ",trim(pr.product_sub_nbr)),
   temp_dispense_exception->disp_exception_info[exception_count].product_disp = product_disp,
   temp_dispense_exception->disp_exception_info[exception_count].product_aborh_disp = fillstring(11,
    " "), temp_dispense_exception->disp_exception_info[exception_count].product_aborh_disp = trim(
    concat(trim(bp_cur_abo_disp)," ",trim(bp_cur_rh_disp))),
   temp_dispense_exception->disp_exception_info[exception_count].patient_aborh_disp = fillstring(11,
    " "), temp_dispense_exception->disp_exception_info[exception_count].patient_aborh_disp = trim(
    concat(trim(pa_abo_disp)," ",trim(pa_rh_disp))), temp_dispense_exception->disp_exception_info[
   exception_count].per_name_full_formatted = per.name_full_formatted,
   temp_dispense_exception->disp_exception_info[exception_count].prsnl_name_full_formatted = prsnl
   .name_full_formatted
   IF (alias_disp > " ")
    temp_dispense_exception->disp_exception_info[exception_count].alias_disp = alias_disp
   ELSE
    temp_dispense_exception->disp_exception_info[exception_count].alias_disp = captions->not_on_file
   ENDIF
   temp_dispense_exception->disp_exception_info[exception_count].override_reason_disp =
   override_reason_disp, temp_dispense_exception->disp_exception_info[exception_count].usr_username
    = usr.username
  FOOT  bb.exception_id
   row + 0
  FOOT  exception_dt_tm
   row + 0
  FOOT REPORT
   stat = alterlist(temp_dispense_exception->disp_exception_info,exception_count)
  WITH nullreport, nocounter
 ;end select
 IF (((exception_count > 0) OR ((request->null_ind=1))) )
  IF (exception_meaning="DISPNOCURABO")
   EXECUTE cpm_create_file_name_logical "bbt_disp_noabo", "txt", "x"
  ELSEIF (exception_meaning="DISPNO2NDABO")
   EXECUTE cpm_create_file_name_logical "bbt_disp_no2abo", "txt", "x"
  ELSEIF (exception_meaning="DISPUMDEMO")
   EXECUTE cpm_create_file_name_logical "bbt_disp_unmatdemo", "txt", "x"
  ELSEIF (exception_meaning="DISPUMCUR2D")
   EXECUTE cpm_create_file_name_logical "bbt_disp_unmatcur2d", "txt", "x"
  ELSE
   GO TO exit_script
  ENDIF
  SELECT INTO cpm_cfn_info->file_name_logical
   exception_id = temp_dispense_exception->disp_exception_info[d.seq].exception_id, exception_dt_tm
    = cnvtdatetime(temp_dispense_exception->disp_exception_info[d.seq].pe_dt_tm)
   FROM (dummyt d  WITH seq = value(size(temp_dispense_exception->disp_exception_info,5)))
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
    CALL center(captions->aborh,54,76),
    CALL center(captions->name,78,98),
    CALL center(captions->physician,100,118), row + 1,
    CALL center(captions->dispd,1,7),
    CALL center(captions->product_number,9,33),
    CALL center(captions->product_type,35,52),
    CALL center(captions->unit,54,64),
    CALL center(captions->patient,66,76),
    CALL center(captions->alias,78,97),
    CALL center(captions->reason,99,118),
    CALL center(captions->tech,120,125), row + 1, col 1,
    "-------", col 9, "-------------------------",
    col 35, "------------------", col 54,
    "-----------------------", col 78, "---------------------",
    col 100, "-------------------", col 120,
    "--------"
   DETAIL
    datafoundflag = true
    IF (row > 54)
     BREAK
    ENDIF
    row + 1, col 1, exception_dt_tm"@DATECONDENSED;;d",
    col 9, temp_dispense_exception->disp_exception_info[d.seq].prod_nbr_display, col 35,
    temp_dispense_exception->disp_exception_info[d.seq].product_disp"##################", col 54,
    temp_dispense_exception->disp_exception_info[d.seq].product_aborh_disp"###########",
    col 66, temp_dispense_exception->disp_exception_info[d.seq].patient_aborh_disp"###########", col
    78,
    temp_dispense_exception->disp_exception_info[d.seq].per_name_full_formatted
    "#####################", col 100, temp_dispense_exception->disp_exception_info[d.seq].
    prsnl_name_full_formatted"###################",
    col 120, temp_dispense_exception->disp_exception_info[d.seq].usr_username"########", row + 1,
    col 1, temp_dispense_exception->disp_exception_info[d.seq].pe_dt_tm"@TIMENOSECONDS;;M"
    IF ((temp_dispense_exception->disp_exception_info[d.seq].alias_disp > " "))
     col 78, temp_dispense_exception->disp_exception_info[d.seq].alias_disp"#####################"
    ELSE
     col 78, captions->not_on_file
    ENDIF
    col 100, temp_dispense_exception->disp_exception_info[d.seq].override_reason_disp
    "###################", row + 1
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
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF (((datafoundflag=true) OR ((request->null_ind=1))) )
  SET rpt_cnt += 1
  SET stat = alterlist(reply->rpt_list,rpt_cnt)
  SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
  SET datafoundflag = false
 ENDIF
END GO
