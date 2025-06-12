CREATE PROGRAM bhs_rpt_rt_charge_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Email To:" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  s_recipient
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_fin = vc
     2 f_charge_item_id = f8
     2 s_cdm_num = vc
     2 s_charge_desc = vc
     2 f_item_quantity = f8
     2 s_service_dt_tm = vc
     2 s_activity_dt_tm = vc
     2 n_process_flag = i2
     2 s_status = vc
     2 n_reason_flag = i2
     2 s_reason = vc
     2 s_activity_type = vc
     2 s_facility = vc
     2 s_updt_prsnl = vc
     2 s_nurse_unit = vc
 ) WITH protect
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE ms_output = vc WITH protect, constant( $OUTDEV)
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"))
 DECLARE mf_rtrx_act_typ_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "RTTXPROCEDURES"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_susp_mod_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13019,"SUSPENSE"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_recipient = vc WITH protect, noconstant(trim( $S_RECIPIENT))
 DECLARE ms_file_name = vc WITH protect, noconstant(concat("bhs_rt_charge",trim(format(sysdate,
     "mmddyyhhmmss;;d")),".csv"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ms_dcl = vc WITH protect, noconstant(" ")
 DECLARE mn_dcl_stat = i2 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 CALL echo(build2("mf_RTRX_ACT_TYP_CD: ",mf_rtrx_act_typ_cd))
 IF (((validate(request->batch_selection)) OR (mn_ops=1)) )
  SET mn_ops = 1
  SET ms_beg_dt_tm = trim(format(cnvtdatetime((curdate - 1),0),"dd-mmm-yyyy hh:mm:ss;;d"))
  SET ms_end_dt_tm = trim(format(cnvtdatetime((curdate - 1),235959),"dd-mmm-yyyy hh:mm:ss;;d"))
  IF (((textlen(ms_recipient)=0) OR (findstring("@",ms_recipient)=0)) )
   SET ms_recipient = "joe.echols@bhs.org"
  ENDIF
 ELSE
  IF (((textlen(ms_recipient)=0) OR (findstring("@",ms_recipient)=0)) )
   SET ms_log = "No recipient entered"
   GO TO exit_script
  ENDIF
  SET ms_beg_dt_tm = concat( $S_BEG_DT," 00:00:00")
  SET ms_end_dt_tm = concat( $S_END_DT," 23:59:59")
  IF (cnvtdatetime(ms_beg_dt_tm) > cnvtdatetime(ms_end_dt_tm))
   SET ms_log = "Beg Date must be earlier than End Date"
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo(ms_file_name)
 CALL echo(concat("beg: ",ms_beg_dt_tm))
 CALL echo(concat("end: ",ms_end_dt_tm))
 SELECT INTO "nl:"
  FROM charge c,
   encounter e,
   prsnl pr,
   encntr_alias ea,
   charge_mod cm
  PLAN (c
   WHERE c.activity_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND c.active_ind=1
    AND c.end_effective_dt_tm > sysdate
    AND c.activity_type_cd=mf_rtrx_act_typ_cd
    AND c.process_flg IN (1, 2, 3, 4, 5,
   8, 177, 777, 997))
   JOIN (e
   WHERE e.encntr_id=c.encntr_id
    AND e.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=c.updt_id)
   JOIN (ea
   WHERE ea.encntr_id=c.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
   JOIN (cm
   WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id)) )
  ORDER BY c.person_id, c.encntr_id, c.activity_dt_tm
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1, stat = alterlist(m_rec->pat,pl_cnt), m_rec->pat[pl_cnt].f_person_id = c.person_id,
   m_rec->pat[pl_cnt].f_encntr_id = c.encntr_id, m_rec->pat[pl_cnt].s_fin = trim(ea.alias), m_rec->
   pat[pl_cnt].f_charge_item_id = c.charge_item_id,
   m_rec->pat[pl_cnt].s_charge_desc = trim(c.charge_description), m_rec->pat[pl_cnt].f_item_quantity
    = c.item_quantity, m_rec->pat[pl_cnt].s_service_dt_tm = trim(format(c.service_dt_tm,
     "mm/dd/yy hh:mm;;d")),
   m_rec->pat[pl_cnt].s_activity_dt_tm = trim(format(c.activity_dt_tm,"mm/dd/yy hh:mm;;d")), m_rec->
   pat[pl_cnt].s_facility = substring(1,3,uar_get_code_display(c.tier_group_cd)), m_rec->pat[pl_cnt].
   s_updt_prsnl = trim(pr.name_full_formatted),
   m_rec->pat[pl_cnt].s_nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd))
   IF (cm.charge_item_id > 0)
    IF (c.process_flg != 1
     AND trim(uar_get_code_meaning(cm.field1_id))="CDM_SCHED")
     m_rec->pat[pl_cnt].s_cdm_num = trim(cm.field6)
    ELSEIF (c.process_flg != 1
     AND trim(uar_get_code_meaning(cm.field1_id))="HCPCS"
     AND cm.field7 > "")
     m_rec->pat[pl_cnt].f_item_quantity *= cnvtreal(cm.field7)
    ELSEIF (c.process_flg=1
     AND cm.charge_mod_type_cd=mf_susp_mod_cd)
     m_rec->pat[pl_cnt].n_reason_flag = 2, m_rec->pat[pl_cnt].s_reason = trim(uar_get_code_display(cm
       .field1_id))
    ENDIF
   ENDIF
   IF (c.process_flg=3)
    m_rec->pat[pl_cnt].n_reason_flag = 1
   ELSE
    m_rec->pat[pl_cnt].n_reason_flag = 10
   ENDIF
   m_rec->pat[pl_cnt].s_activity_type = trim(uar_get_code_display(c.activity_type_cd))
  WITH nocounter
 ;end select
 FOR (ml_loop = 1 TO size(m_rec->pat,5))
  CASE (m_rec->pat[ml_loop].n_process_flag)
   OF 0:
    SET m_rec->pat[ml_loop].s_status = "Pnd"
   OF 1:
    SET m_rec->pat[ml_loop].s_status = "Sus"
   OF 2:
    SET m_rec->pat[ml_loop].s_status = "Rvw"
   OF 3:
    SET m_rec->pat[ml_loop].s_status = "Hld"
   OF 4:
    SET m_rec->pat[ml_loop].s_status = "Mnl"
   OF 6:
    SET m_rec->pat[ml_loop].s_status = "Cmb"
   OF 7:
    SET m_rec->pat[ml_loop].s_status = "Abs"
   OF 8:
    SET m_rec->pat[ml_loop].s_status = "ABN"
   OF 10:
    SET m_rec->pat[ml_loop].s_status = "Ofs"
   OF 11:
    SET m_rec->pat[ml_loop].s_status = "Adj"
   OF 100:
    SET m_rec->pat[ml_loop].s_status = "Pst"
   OF 177:
    SET m_rec->pat[ml_loop].s_status = "Bnd"
   OF 777:
    SET m_rec->pat[ml_loop].s_status = "Bnd"
   OF 977:
    SET m_rec->pat[ml_loop].s_status = "Bnd"
   OF 996:
    SET m_rec->pat[ml_loop].s_status = "OMF"
   OF 997:
    SET m_rec->pat[ml_loop].s_status = "Stt"
   OF 998:
    SET m_rec->pat[ml_loop].s_status = "PNC"
   OF 999:
    SET m_rec->pat[ml_loop].s_status = "Itf"
  ENDCASE
  CASE (m_rec->pat[ml_loop].n_reason_flag)
   OF 1:
    SET m_rec->pat[ml_loop].s_reason = "Held"
   OF 3:
    SET m_rec->pat[ml_loop].s_reason = "Svc Dt Not Reg"
   OF 4:
    SET m_rec->pat[ml_loop].s_reason = "Enc Type"
   OF 5:
    SET m_rec->pat[ml_loop].s_reason = "Svc Dt post DC"
   OF 6:
    SET m_rec->pat[ml_loop].s_reason = "Svc Dt pre ADM"
   OF 7:
    SET m_rec->pat[ml_loop].s_reason = "CDM Issue"
   OF 8:
    SET m_rec->pat[ml_loop].s_reason = "Act too late"
   OF 9:
    SET m_rec->pat[ml_loop].s_reason = "Act too early"
   OF 10:
    SET m_rec->pat[ml_loop].s_reason = "Charge Status"
  ENDCASE
 ENDFOR
 IF (size(m_rec->pat) > 0)
  CALL echo("create csv")
  SELECT INTO value(ms_file_name)
   FROM (dummyt d  WITH seq = value(size(m_rec->pat,5)))
   PLAN (d)
   ORDER BY d.seq
   HEAD REPORT
    ms_tmp = concat(
     '"Account Number","CDM","Description","Quan","Service Dt","Activity","Status","Reason","Activity Type",',
     '"FAC","Update Personnel","Nurse Unit"'), col 0, ms_tmp,
    row + 1
   HEAD d.seq
    ms_tmp = concat('"',m_rec->pat[d.seq].s_fin,'",','"',m_rec->pat[d.seq].s_cdm_num,
     '",','"',m_rec->pat[d.seq].s_charge_desc,'",','"',
     trim(cnvtstring(m_rec->pat[d.seq].f_item_quantity)),'",','"',m_rec->pat[d.seq].s_service_dt_tm,
     '",',
     '"',m_rec->pat[d.seq].s_activity_dt_tm,'",','"',m_rec->pat[d.seq].s_status,
     '",','"',m_rec->pat[d.seq].s_reason,'",','"',
     m_rec->pat[d.seq].s_activity_type,'",','"',m_rec->pat[d.seq].s_facility,'",',
     '"',m_rec->pat[d.seq].s_updt_prsnl,'",','"',m_rec->pat[d.seq].s_nurse_unit,
     '"'), col 0, ms_tmp,
    row + 1
   WITH nocounter, format = variable, maxrow = 1,
    maxcol = 2000
  ;end select
  CALL echo("email file")
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_file_name,ms_file_name,ms_recipient,"RT Charges Rpt",1)
 ELSE
  IF (mn_ops=1)
   CALL echo("send email no charges found")
   SET ms_tmp = concat("RT Charges Report ",ms_beg_dt_tm," to ",ms_end_dt_tm,": No Charges Found")
   CALL uar_send_mail(nullterm("joe.echols@bhs.org"),nullterm(ms_tmp),nullterm(
     "No Charges found for range"),nullterm("RT Charges Report"),1,
    nullterm("IPM.NOTE"))
  ELSE
   SELECT INTO value(ms_output)
    FROM dummyt d
    HEAD REPORT
     col 0, "No Charges Found"
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 IF (size(m_rec->pat,5)=0
  AND mn_ops=0)
  SELECT INTO value(ms_output)
   FROM dual
   HEAD REPORT
    col 0, ms_log
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data[1].status = "S"
 FREE RECORD m_rec
END GO
