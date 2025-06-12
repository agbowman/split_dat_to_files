CREATE PROGRAM bhs_charge_rpt_flat:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Email to:" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  s_recipients
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD m_rec
 RECORD m_rec(
   1 list[*]
     2 s_name = vc
     2 f_person_id = f8
     2 s_name_last = vc
     2 s_name_first = vc
     2 f_encntr_id = f8
     2 s_encntr_type = vc
     2 s_facility = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_primary_ins = vc
     2 s_secondary_ins = vc
     2 f_bill_item_id = f8
     2 f_bill_item_mod_id = f8
     2 s_key6 = vc
     2 s_key7 = vc
     2 f_dispense_hx_id = f8
     2 f_order_id = f8
     2 s_order_disp_line = vc
     2 s_order_mnemonic = vc
     2 s_order_dt_tm = vc
     2 s_action_type = vc
     2 s_disp_dt_tm = vc
     2 s_cdm = vc
     2 f_doses = f8
     2 s_dose_quantity = vc
     2 s_disp_event = vc
     2 s_line = vc
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(concat(trim( $S_BEG_DT)))
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(concat(trim( $S_END_DT)))
 DECLARE ms_filename = vc WITH protect, noconstant("bhs_charges_flat.dat")
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_dclcom_str = vc WITH protect, noconstant(" ")
 DECLARE ml_dclcom_len = i4 WITH protect, noconstant(0.0)
 DECLARE mn_dclcom_stat = i2 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_fac_cd = c2 WITH protect, noconstant("00")
 SELECT INTO "nl:"
  FROM dispense_hx dh1,
   order_action oa,
   orders o,
   order_product op,
   med_identifier mi,
   med_identifier mi2,
   person p,
   encntr_alias ea,
   encntr_alias ea2,
   encounter e
  PLAN (dh1
   WHERE dh1.dispense_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND  NOT ( EXISTS (
   (SELECT
    pdh.dispense_hx_id
    FROM prod_dispense_hx pdh
    WHERE dh1.dispense_hx_id=pdh.dispense_hx_id)))
    AND dh1.disp_event_type_cd=643458
    AND dh1.charge_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    rpc.order_id
    FROM rx_pending_charge rpc
    WHERE dh1.order_id=rpc.order_id))))
   JOIN (oa
   WHERE oa.order_id=dh1.order_id
    AND oa.action_type_cd=2536
    AND oa.action_sequence=dh1.action_sequence)
   JOIN (o
   WHERE o.order_id=dh1.order_id
    AND o.active_ind=1)
   JOIN (op
   WHERE op.order_id=o.order_id
    AND op.action_sequence IN (
   (SELECT
    max(oa1.action_sequence)
    FROM order_action oa1,
     order_ingredient oi1,
     order_product op1
    WHERE oa1.order_id=o.order_id
     AND oa1.action_dt_tm <= dh1.dispense_dt_tm
     AND oi1.order_id=o.order_id
     AND oi1.action_sequence=oa1.action_sequence
     AND op1.order_id=o.order_id
     AND op1.action_sequence=oa1.action_sequence
     AND op1.ingred_sequence=oi1.comp_sequence)))
   JOIN (mi
   WHERE mi.item_id=op.item_id
    AND mi.primary_ind=1
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=3106)
   JOIN (mi2
   WHERE mi2.item_id=op.item_id
    AND mi2.primary_ind=1
    AND mi2.med_product_id=0
    AND mi2.med_identifier_type_cd=3098)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate
    AND e.loc_facility_cd != 2583987)
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=1079
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
   JOIN (ea2
   WHERE ea2.encntr_id=o.encntr_id
    AND ea2.encntr_alias_type_cd=1077
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > sysdate)
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->list,5))
    stat = alterlist(m_rec->list,(pl_cnt+ 20))
   ENDIF
   m_rec->list[pl_cnt].s_name = trim(p.name_full_formatted), m_rec->list[pl_cnt].s_name_last = trim(p
    .name_last), m_rec->list[pl_cnt].s_name_first = trim(p.name_first),
   m_rec->list[pl_cnt].f_encntr_id = o.encntr_id, m_rec->list[pl_cnt].f_person_id = o.person_id,
   m_rec->list[pl_cnt].s_mrn = trim(ea.alias),
   m_rec->list[pl_cnt].s_fin = trim(ea2.alias), m_rec->list[pl_cnt].f_dispense_hx_id = dh1
   .dispense_hx_id, m_rec->list[pl_cnt].f_order_id = o.order_id,
   m_rec->list[pl_cnt].s_order_disp_line = trim(o.order_detail_display_line), m_rec->list[pl_cnt].
   s_order_mnemonic = trim(o.order_mnemonic), m_rec->list[pl_cnt].s_order_dt_tm = trim(format(o
     .orig_order_dt_tm,"dd-mmm-yyyy hh:mm;;d")),
   m_rec->list[pl_cnt].s_disp_dt_tm = trim(format(dh1.dispense_dt_tm,"dd-mmm-yyyy hh:mm;;d")), m_rec
   ->list[pl_cnt].s_disp_event = uar_get_code_display(dh1.disp_event_type_cd), m_rec->list[pl_cnt].
   s_action_type = uar_get_code_display(oa.action_type_cd),
   m_rec->list[pl_cnt].s_cdm = trim(mi.value), m_rec->list[pl_cnt].f_doses = dh1.doses, m_rec->list[
   pl_cnt].s_dose_quantity = trim(cnvtstring(op.dose_quantity)),
   m_rec->list[pl_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd))
  FOOT REPORT
   stat = alterlist(m_rec->list,pl_cnt)
  WITH nocounter, format, separator = " "
 ;end select
 IF (size(m_rec->list,5) < 1)
  GO TO exit_script
 ENDIF
 FOR (ml_cnt = 1 TO size(m_rec->list,5))
   SET ms_fac_cd = "XX"
   IF (((trim(m_rec->list[ml_cnt].s_facility)="BMC*") OR (trim(m_rec->list[ml_cnt].s_facility)="CTR*"
   )) )
    SET ms_fac_cd = "01"
   ELSEIF (trim(m_rec->list[ml_cnt].s_facility) IN ("FMC", "BFMC"))
    SET ms_fac_cd = "02"
   ELSEIF (trim(m_rec->list[ml_cnt].s_facility) IN ("MLH", "BMLH"))
    SET ms_fac_cd = "03"
   ELSEIF (trim(m_rec->list[ml_cnt].s_facility)="BWH*")
    SET ms_fac_cd = "04"
   ENDIF
   SET ms_tmp = ""
   SET ms_tmp = concat(format(m_rec->list[ml_cnt].s_fin,"##########;P0")," ",ms_fac_cd)
   SET ms_tmp = concat(ms_tmp,format(trim(m_rec->list[ml_cnt].s_cdm),"#######;P0"),format(trim(
      cnvtstring(m_rec->list[ml_cnt].f_doses)),"#####;P0"),"0",trim(format(cnvtdatetime(m_rec->list[
       ml_cnt].s_disp_dt_tm),"mmddyy;;d")),
    m_rec->list[ml_cnt].s_name_last,", ",m_rec->list[ml_cnt].s_name_first)
   SET m_rec->list[ml_cnt].s_line = trim(ms_tmp)
 ENDFOR
 SELECT INTO value(ms_filename)
  line = m_rec->list[d.seq].s_line
  FROM (dummyt d  WITH seq = value(size(m_rec->list,5)))
  PLAN (d)
  ORDER BY d.seq
  DETAIL
   line, row + 1
  WITH nocounter, separator = "*", format,
   noheader
 ;end select
 IF (findfile(ms_filename) > 0)
  CALL echo("found email file")
  SET ms_line = concat('"Charges Flat File ',format(sysdate,"dd-mmm-yyyy hh:mm;;d"),'"')
  CALL emailfile(ms_filename,ms_filename,ms_recipients,ms_line,1)
  IF (findfile(ms_filename)=1)
   CALL echo("Unable to delete email file")
  ELSE
   CALL echo("Email File Deleted")
  ENDIF
 ELSE
  CALL echo("email file not found")
 ENDIF
 SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",ms_filename,
  " transfer.baystatehealth.org CernerFTP gJeZD64 'chargereports'")
 CALL echo(dclcom)
 SET status = 0
 SET len = size(trim(dclcom))
 CALL dcl(dclcom,len,status)
 CALL pause(5)
 CALL echo("deleting email file")
 SET stat = remove(ms_filename)
 IF (((stat=0) OR (findfile(ms_filename)=1)) )
  CALL echo("unable to delete file")
 ELSE
  CALL echo("file deleted")
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
END GO
