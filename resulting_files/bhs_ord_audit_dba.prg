CREATE PROGRAM bhs_ord_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Order Type" = 720861.00,
  "Enter e-mail" = "example@bhs.org",
  "Select Contributors" = 0
  WITH outdev, f_ord_type, s_email,
  s_cont_cd
 DECLARE f_activity_type_cd = f8 WITH protect, constant( $F_ORD_TYPE)
 DECLARE f_primary_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE f_radiology_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"RADIOLOGY"))
 DECLARE f_cvis_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "NONINVASIVECARDIOLOGYTXPROCEDURES"))
 DECLARE s_email_out = vc WITH protect, constant(trim( $S_EMAIL))
 DECLARE s_email_cmd = vc WITH protect, noconstant("")
 DECLARE s_email_sub = vc WITH protect, noconstant("")
 DECLARE n_email_cmd_size = i4 WITH protect, noconstant(0)
 DECLARE n_email_status = i4 WITH protect, noconstant(0)
 DECLARE s_output_file = vc WITH protect, constant(concat("ord_aud",cnvtstring(sysdate),".csv"))
 DECLARE n_loc1 = i4 WITH protect, noconstant(0)
 DECLARE n_loc2 = i4 WITH protect, noconstant(0)
 DECLARE n_idx1 = i4 WITH protect, noconstant(0)
 DECLARE n_idx2 = i4 WITH protect, noconstant(0)
 DECLARE s_temp_str = vc WITH protect, noconstant("")
 FREE RECORD boa_contr
 RECORD boa_contr(
   1 n_cnt = i4
   1 list[*]
     2 s_name = vc
     2 f_contr_cd = f8
 )
 FREE RECORD oc_audit
 RECORD oc_audit(
   1 n_cnt = i4
   1 list[*]
     2 f_catalog_cd = f8
     2 s_order_desc = vc
     2 s_department_name = vc
     2 s_order_entry_format = vc
     2 i_active_ind = i2
     2 i_hide_ind = i2
     2 n_cnt = i4
     2 contr[*]
       3 f_contr_cd = f8
       3 s_contr_val = vc
       3 i_type_ind = i2
 ) WITH protect
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=73
   AND (cv.code_value= $S_CONT_CD)
   AND cv.active_ind=1
  ORDER BY cv.display
  HEAD REPORT
   boa_contr->n_cnt = 0
  DETAIL
   boa_contr->n_cnt = (boa_contr->n_cnt+ 1), stat = alterlist(boa_contr->list,boa_contr->n_cnt),
   boa_contr->list[boa_contr->n_cnt].s_name = cv.display,
   boa_contr->list[boa_contr->n_cnt].f_contr_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   order_catalog oc,
   code_value_alias cva,
   code_value_outbound cvo,
   order_entry_format oef
  PLAN (ocs
   WHERE ocs.activity_type_cd=f_activity_type_cd
    AND ocs.mnemonic_type_cd=f_primary_cd)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd)
   JOIN (cva
   WHERE cva.code_value=outerjoin(oc.catalog_cd))
   JOIN (cvo
   WHERE cvo.code_value=outerjoin(oc.catalog_cd))
   JOIN (oef
   WHERE oef.oe_format_id=ocs.oe_format_id)
  ORDER BY ocs.mnemonic_key_cap
  HEAD REPORT
   oc_audit->n_cnt = 0
  HEAD ocs.catalog_cd
   oc_audit->n_cnt = (oc_audit->n_cnt+ 1), stat = alterlist(oc_audit->list,oc_audit->n_cnt), oc_audit
   ->list[oc_audit->n_cnt].f_catalog_cd = oc.catalog_cd,
   oc_audit->list[oc_audit->n_cnt].s_department_name = oc.dept_display_name, oc_audit->list[oc_audit
   ->n_cnt].s_order_desc = ocs.mnemonic, oc_audit->list[oc_audit->n_cnt].i_active_ind = ocs
   .active_ind,
   oc_audit->list[oc_audit->n_cnt].i_hide_ind = ocs.hide_flag, oc_audit->list[oc_audit->n_cnt].
   s_order_entry_format = oef.oe_format_name, oc_audit->list[oc_audit->n_cnt].n_cnt = 0
  DETAIL
   IF (cva.contributor_source_cd > 0)
    n_loc1 = locateval(n_idx1,1,oc_audit->list[oc_audit->n_cnt].n_cnt,cva.contributor_source_cd,
     oc_audit->list[oc_audit->n_cnt].contr[n_idx1].f_contr_cd,
     1,oc_audit->list[oc_audit->n_cnt].contr[n_idx1].i_type_ind)
    IF (n_loc1=0)
     oc_audit->list[oc_audit->n_cnt].n_cnt = (oc_audit->list[oc_audit->n_cnt].n_cnt+ 1), stat =
     alterlist(oc_audit->list[oc_audit->n_cnt].contr,oc_audit->list[oc_audit->n_cnt].n_cnt), oc_audit
     ->list[oc_audit->n_cnt].contr[oc_audit->list[oc_audit->n_cnt].n_cnt].f_contr_cd = cva
     .contributor_source_cd,
     oc_audit->list[oc_audit->n_cnt].contr[oc_audit->list[oc_audit->n_cnt].n_cnt].i_type_ind = 1,
     oc_audit->list[oc_audit->n_cnt].contr[oc_audit->list[oc_audit->n_cnt].n_cnt].s_contr_val = cva
     .alias
    ENDIF
   ENDIF
   IF (cvo.contributor_source_cd > 0)
    n_loc1 = locateval(n_idx1,1,oc_audit->list[oc_audit->n_cnt].n_cnt,cvo.contributor_source_cd,
     oc_audit->list[oc_audit->n_cnt].contr[n_idx1].f_contr_cd,
     2,oc_audit->list[oc_audit->n_cnt].contr[n_idx1].i_type_ind)
    IF (n_loc1=0)
     oc_audit->list[oc_audit->n_cnt].n_cnt = (oc_audit->list[oc_audit->n_cnt].n_cnt+ 1), stat =
     alterlist(oc_audit->list[oc_audit->n_cnt].contr,oc_audit->list[oc_audit->n_cnt].n_cnt), oc_audit
     ->list[oc_audit->n_cnt].contr[oc_audit->list[oc_audit->n_cnt].n_cnt].f_contr_cd = cvo
     .contributor_source_cd,
     oc_audit->list[oc_audit->n_cnt].contr[oc_audit->list[oc_audit->n_cnt].n_cnt].i_type_ind = 2,
     oc_audit->list[oc_audit->n_cnt].contr[oc_audit->list[oc_audit->n_cnt].n_cnt].s_contr_val = cvo
     .alias
    ENDIF
   ENDIF
  WITH nocounter, orahintcbo("LEADING(ocs,oc,cva,cvo,oef)","INDEX(OCS XIE4ORDER_CATALOG_SYNONYM)",
    "INDEX(OC XPKORDER_CATALOG)","INDEX(CVA XIE2CODE_VALUE_ALIAS)",
    "INDEX(CVO XAK1CODE_VALUE_OUTBOUND)",
    "INDEX(OEF XPKORDER_ENTRY_FORMAT)","USE_NL(OC)","USE_NL(CVA)","USE_NL(CVO)","USE_NL(OEF)")
 ;end select
 SELECT INTO value(s_output_file)
  FROM dual
  HEAD REPORT
   col 0, s_temp_str = '"Order Description (Primary)",'
   IF (f_activity_type_cd=f_radiology_cd)
    s_temp_str = concat(s_temp_str,'"Department Display Name",')
   ENDIF
   s_temp_str = concat(s_temp_str,'"Order Entry Format","Active/Inactive","Hide Indicator"')
   FOR (n_loc = 1 TO boa_contr->n_cnt)
     s_temp_str = concat(s_temp_str,',"',boa_contr->list[n_loc].s_name,'(I)","',boa_contr->list[n_loc
      ].s_name,
      '(O)"')
   ENDFOR
   s_temp_str
  DETAIL
   FOR (n_loc1 = 1 TO oc_audit->n_cnt)
     row + 1, col 0, s_temp_str = concat('"',trim(oc_audit->list[n_loc1].s_order_desc),'",')
     IF (f_activity_type_cd=f_radiology_cd)
      s_temp_str = concat(s_temp_str,'"',trim(oc_audit->list[n_loc1].s_department_name),'",')
     ENDIF
     s_temp_str = concat(s_temp_str,'"',oc_audit->list[n_loc1].s_order_entry_format,'","',trim(
       cnvtstring(oc_audit->list[n_loc1].i_active_ind)),
      '","',trim(cnvtstring(oc_audit->list[n_loc1].i_hide_ind)),'"')
     FOR (n_loc2 = 1 TO boa_contr->n_cnt)
       CALL echo(boa_contr->list[n_loc2].f_contr_cd), n_idx1 = locateval(n_idx2,1,oc_audit->list[
        n_loc1].n_cnt,boa_contr->list[n_loc2].f_contr_cd,oc_audit->list[n_loc1].contr[n_idx2].
        f_contr_cd,
        1,oc_audit->list[n_loc1].contr[n_idx2].i_type_ind)
       IF (n_idx1 > 0)
        s_temp_str = concat(s_temp_str,',"',oc_audit->list[n_loc1].contr[n_idx1].s_contr_val,'"')
       ELSE
        s_temp_str = concat(s_temp_str,',""')
       ENDIF
       n_idx1 = locateval(n_idx2,1,oc_audit->list[n_loc1].n_cnt,boa_contr->list[n_loc2].f_contr_cd,
        oc_audit->list[n_loc1].contr[n_idx2].f_contr_cd,
        2,oc_audit->list[n_loc1].contr[n_idx2].i_type_ind)
       IF (n_idx1 > 0)
        s_temp_str = concat(s_temp_str,',"',oc_audit->list[n_loc1].contr[n_idx1].s_contr_val,'"')
       ELSE
        s_temp_str = concat(s_temp_str,',""')
       ENDIF
     ENDFOR
     s_temp_str
   ENDFOR
  WITH nocounter, format = variable, formfeed = none,
   maxcol = 500
 ;end select
 SET s_email_sub = "Order Audit Report"
 SET s_email_cmd = concat('echo "Order Audit Report is attached here" | mailx -s "',s_email_sub,
  '" -a ',s_output_file," ",
  s_email_out)
 SET n_email_cmd_size = size(trim(s_email_cmd))
 SET n_email_status = 0
 SET stat = dcl(s_email_cmd,n_email_cmd_size,n_email_status)
 SET stat = remove(s_output_file)
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   msg1 = concat("Report has been emailed to: ",s_email_out), col 0,
   "{PS/792 0 translate 90 rotate/}",
   y_pos = 18, row + 1, "{F/1}{CPI/7}",
   CALL print(calcpos(36,(y_pos+ 0))), msg1
  WITH dio = 08
 ;end select
 CALL echorecord(oc_audit)
#exit_script
 FREE RECORD oc_audit
 FREE RECORD boa_contr
 SET last_mod = "002 04/25/17 Naiyar Alam SR416021214  Fixed email issue"
END GO
