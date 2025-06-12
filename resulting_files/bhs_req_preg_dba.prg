CREATE PROGRAM bhs_req_preg:dba
 DECLARE mf_inpatient_cd = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_onetimeop_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"ONETIMEOP"))
 DECLARE mf_bmc_cd = f8 WITH protect, noconstant(0.00)
 DECLARE mf_pdc_cd = f8 WITH protect, noconstant(0.00)
 DECLARE mf_wetu1_cd = f8 WITH protect, noconstant(0.00)
 DECLARE ml_order_cnt = i4 WITH noconstant(value(size(request->order_qual,5)))
 DECLARE ms_call_program = vc WITH noconstant(curprog)
 DECLARE mn_print_ind = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM code_value loc
  PLAN (loc
   WHERE loc.code_set=220
    AND ((loc.display_key="WETU1"
    AND loc.cdf_meaning="AMBULATORY") OR (loc.display_key="BMC"
    AND loc.cdf_meaning="FACILITY"))
    AND loc.active_ind=1)
  ORDER BY loc.display_key
  HEAD loc.display_key
   CASE (loc.display_key)
    OF "BMC":
     mf_bmc_cd = loc.code_value
    OF "WETU1":
     mf_wetu1_cd = loc.code_value
   ENDCASE
  WITH nocounter
 ;end select
 CALL echo(build2("mf_bmc_cd: ",build(mf_bmc_cd)))
 CALL echo(build2("mf_wetu1_cd: ",build(mf_wetu1_cd)))
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(ml_order_cnt)),
   orders o,
   encounter e,
   order_detail od
  PLAN (d1)
   JOIN (o
   WHERE (o.order_id=request->order_qual[d1.seq].order_id)
    AND o.template_order_flag IN (0))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning="REQSTARTDTTM"
    AND od.oe_field_dt_tm_value >= cnvtdatetime(curdate,0)
    AND od.oe_field_dt_tm_value < cnvtdatetime((curdate+ 1),0))
  ORDER BY od.action_sequence DESC
  HEAD REPORT
   CASE (e.encntr_type_cd)
    OF mf_inpatient_cd:
     IF (e.loc_facility_cd=mf_bmc_cd)
      mn_print_ind = 1
     ENDIF
    OF mf_onetimeop_cd:
     IF (e.loc_nurse_unit_cd=mf_wetu1_cd)
      mn_print_ind = 1
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 IF (mn_print_ind=0)
  GO TO exit_program
 ENDIF
 CALL echo(";****** execute bhs_req_preg_layout ******")
 EXECUTE bhs_req_preg_layout ms_call_program WITH replace("REQUEST",request)
#exit_program
END GO
