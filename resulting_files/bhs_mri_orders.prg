CREATE PROGRAM bhs_mri_orders
 PROMPT
  "Output to File/Printer/MINE/Email Address" = "MINE",
  "Beginning Date: " = "01012005",
  "Ending Date: " = "01312005"
  WITH outdev, bg_dt, en_dt
 EXECUTE bhs_sys_stand_subroutine
 SET beg_date_qual = cnvtdate( $2)
 SET end_date_qual = cnvtdate( $3)
 DECLARE output_dest = vc
 IF (findstring("@", $1) > 0)
  SET output_dest = concat(trim(cnvtlower(curprog)),format(cnvtdatetime(curdate,0),"YYYYMMDD;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 DECLARE rad_catalog_type_cd = f8
 DECLARE rad_activity_type_cd = f8
 DECLARE mri_act_subtype_cd = f8
 DECLARE order_oa_type_cd = f8
 DECLARE inp_enc_type_cd = f8
 DECLARE disch_inp_enc_type_cd = f8
 DECLARE exp_inp_enc_type_cd = f8
 DECLARE obs_enc_type_cd = f8
 DECLARE disch_obs_enc_type_cd = f8
 DECLARE exp_obs_enc_type_cd = f8
 SET rad_catalog_type_cd = uar_get_code_by("MEANING",6000,"RADIOLOGY")
 SET rad_activity_type_cd = uar_get_code_by("MEANING",106,"RADIOLOGY")
 SET mri_act_subtype_cd = uar_get_code_by("MEANING",5801,"MRI")
 SET order_oa_type_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET inp_enc_type_cd = uar_get_code_by("DISPLAYKEY",71,"INPATIENT")
 SET disch_inp_enc_type_cd = uar_get_code_by("DISPLAYKEY",71,"DISCHIP")
 SET exp_inp_enc_type_cd = uar_get_code_by("DISPLAYKEY",71,"EXPRIEDIP")
 SET obs_enc_type_cd = uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
 SET disch_obs_enc_type_cd = uar_get_code_by("DISPLAYKEY",71,"DISCHOBV")
 SET exp_obs_enc_type_cd = uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV")
 FREE RECORD mri_orders
 RECORD mri_orders(
   1 list[*]
     2 catalog_cd = f8
 )
 SELECT INTO "nl:"
  FROM order_catalog oc
  PLAN (oc
   WHERE oc.catalog_type_cd=rad_catalog_type_cd
    AND oc.activity_subtype_cd=mri_act_subtype_cd
    AND oc.activity_type_cd=rad_activity_type_cd)
  DETAIL
   stat = alterlist(mri_orders->list,(size(mri_orders->list,5)+ 1)), mri_orders->list[size(mri_orders
    ->list,5)].catalog_cd = oc.catalog_cd
  WITH nocounter
 ;end select
 FREE RECORD mris
 RECORD mris(
   1 list[*]
     2 encntr_id = f8
     2 order_id = f8
     2 fin_nbr = vc
     2 pat_name = vc
     2 person_id = f8
     2 catalog_cd = f8
     2 orig_order_dt_tm = dq8
     2 last_oa_cd = f8
     2 last_oa_dt_tm = dq8
     2 cancel_rsn_cd = f8
     2 cancel_rsn_ft = vc
 )
 DECLARE cnt = i4
 DECLARE idx = i4
 DECLARE output_string = vc
 SET cnt = 1
 SET idx = 1
 SET stat = alterlist(mris->list,1)
 SELECT INTO value(output_dest)
  order_name_out = o.order_mnemonic, order_status_out = uar_get_code_display(o.order_status_cd),
  orig_order_dt_tm_out = concat(evaluate(weekday(o.orig_order_dt_tm),0.0,"Sunday, ",1.0,"Monday, ",
    2.0,"Tuesday, ",3.0,"Wednesday, ",4.0,
    "Thursday, ",5.0,"Friday, ",6.0,"Saturday, "),format(o.orig_order_dt_tm,"MM/DD/YYYY HH:MM;;D")),
  last_action_dt_tm_out = concat(evaluate(weekday(oa2.action_dt_tm),0.0,"Sunday, ",1.0,"Monday, ",
    2.0,"Tuesday, ",3.0,"Wednesday, ",4.0,
    "Thursday, ",5.0,"Friday, ",6.0,"Saturday, "),format(oa2.action_dt_tm,"MM/DD/YYYY HH:MM;;D")),
  dc_reason_out = uar_get_code_display(od.oe_field_value)
  FROM order_action oa,
   orders o,
   person p,
   encounter e,
   encntr_alias ea,
   order_detail od,
   order_action oa2
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(beg_date_qual,0) AND cnvtdatetime(end_date_qual,235959)
    AND oa.action_type_cd=order_oa_type_cd)
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND o.catalog_type_cd=rad_catalog_type_cd
    AND o.activity_type_cd=rad_activity_type_cd
    AND expand(idx,1,size(mri_orders->list,5),(o.catalog_cd+ 0),mri_orders->list[idx].catalog_cd))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.encntr_type_cd IN (inp_enc_type_cd, disch_inp_enc_type_cd, exp_inp_enc_type_cd,
   obs_enc_type_cd, disch_obs_enc_type_cd,
   exp_obs_enc_type_cd))
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ea.encntr_alias_type_cd=1077)
   JOIN (od
   WHERE od.oe_field_meaning=outerjoin("DCREASON")
    AND od.order_id=outerjoin(o.order_id))
   JOIN (oa2
   WHERE oa2.order_id=o.order_id
    AND oa2.action_sequence=o.last_action_sequence)
  HEAD REPORT
   output_string = concat(',"Fin","PatientName","Orderable","Original Order Date"',
    ',"Order Status","Last Action Date","DC Reason",'), col 1, output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  DETAIL
   output_string = concat(',"',trim(ea.alias),'","',trim(p.name_full_formatted),'","',
    trim(order_name_out),'","',trim(orig_order_dt_tm_out),'","',trim(order_status_out),
    '","',trim(last_action_dt_tm_out),'","',trim(dc_reason_out),'",'), col 1, output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, maxcol = 200, maxrow = 1,
   nullreport
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
  SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  CALL emailfile(filename_in,filename_out, $1,concat(trim(curprog),
    " - Baystate Medical Center MRI Orders"),1)
 ENDIF
END GO
