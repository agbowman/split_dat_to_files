CREATE PROGRAM bhs_sn_picklist_item_used:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Surg Area" = 0,
  "Start Time" = "CURDATE",
  "End Time" = "CURDATE",
  "Case Number" = "*",
  "Charge Quantity:" = "1"
  WITH outdev, surg_unit, s_starttime,
  s_endtime, s_casenumber, s_charge_quantity
 DECLARE mf_itemmaster_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",11001,"ITEMMASTER"
   ))
 DECLARE mf_billcode_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",13019,"BILLCODE"))
 DECLARE ms_charge_quantity_parser = vc WITH protect, noconstant(" 1 = 1 ")
 DECLARE ms_surgunit_ind = c1 WITH protect, constant(substring(1,1,reflect(parameter(2,0))))
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 FREE RECORD sunit
 RECORD sunit(
   1 l_cnt = i4
   1 list[*]
     2 f_unit_cd = f8
     2 s_unit_name = vc
 ) WITH protect
 IF (ms_surgunit_ind="C")
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=221
    AND cv.cdf_meaning="SURGAREA"
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm >= cnvtdatetime(cnvtdate(123114),0)
   ORDER BY cv.display
   HEAD REPORT
    sunit->l_cnt = 0
   DETAIL
    sunit->l_cnt = (sunit->l_cnt+ 1), stat = alterlist(sunit->list,sunit->l_cnt), sunit->list[sunit->
    l_cnt].f_unit_cd = cv.code_value,
    sunit->list[sunit->l_cnt].s_unit_name = cv.display
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=221
    AND cv.cdf_meaning="SURGAREA"
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm >= cnvtdatetime(cnvtdate(123114),0)
    AND (cv.code_value= $SURG_UNIT)
   ORDER BY cv.display
   HEAD REPORT
    sunit->l_cnt = 0
   DETAIL
    sunit->l_cnt = (sunit->l_cnt+ 1), stat = alterlist(sunit->list,sunit->l_cnt), sunit->list[sunit->
    l_cnt].f_unit_cd = cv.code_value,
    sunit->list[sunit->l_cnt].s_unit_name = cv.display
   WITH nocounter
  ;end select
 ENDIF
 IF (( $S_CHARGE_QUANTITY="2"))
  SET ms_charge_quantity_parser = " ccpl.charge_qty = outerjoin(0) "
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  s_surg_area_disp = uar_get_code_display(sc.surg_area_cd), sc.sched_start_dt_tm, sc
  .surg_case_nbr_formatted,
  patinet_name = omf_get_pers_full(sc.person_id), account_num = cnvtalias(omf_get_alias("FIN NBR",sc
    .encntr_id),omf_get_alias_pool_cd("FIN NBR",319,sc.encntr_id)), moim.stock_nbr,
  moim.description, ccpl.qty_used, ccpl.charge_qty,
  cdm = bi.key6
  FROM surgical_case sc,
   case_cart_pick_list ccpl,
   mm_omf_item_master moim,
   bill_item b,
   bill_item_modifier bi
  PLAN (sc
   WHERE expand(ml_idx,1,sunit->l_cnt,sc.sched_surg_area_cd,sunit->list[ml_idx].f_unit_cd)
    AND sc.sched_start_dt_tm BETWEEN cnvtdatetime(cnvtdate2( $S_STARTTIME,"mm/dd/yyyy"),0) AND
   cnvtdatetime(cnvtdate2( $S_ENDTIME,"mm/dd/yyyy"),235959)
    AND (sc.surg_case_nbr_formatted= $S_CASENUMBER))
   JOIN (ccpl
   WHERE sc.surg_case_id=outerjoin(ccpl.surg_case_id)
    AND ccpl.qty_used != outerjoin(0)
    AND parser(ms_charge_quantity_parser))
   JOIN (moim
   WHERE ccpl.item_id=outerjoin(moim.item_master_id)
    AND moim.type_cd=outerjoin(mf_itemmaster_cd))
   JOIN (b
   WHERE b.ext_short_desc=outerjoin(moim.stock_nbr))
   JOIN (bi
   WHERE bi.bill_item_id=outerjoin(b.bill_item_id)
    AND bi.bill_item_type_cd=outerjoin(mf_billcode_cd)
    AND bi.active_ind=outerjoin(1)
    AND bi.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY sc.sched_start_dt_tm, sc.surg_case_nbr_formatted
  WITH nocounter, separator = " ", format
 ;end select
#exit_program
END GO
