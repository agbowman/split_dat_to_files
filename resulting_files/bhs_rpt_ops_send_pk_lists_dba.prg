CREATE PROGRAM bhs_rpt_ops_send_pk_lists:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Domain" = "",
  "FTP to" = ""
  WITH outdev, domain, ftp_flag
 IF (cnvtupper(trim(curdomain,3)) != cnvtupper( $DOMAIN))
  GO TO exit_program
 ENDIF
 EXECUTE bhs_check_domain
 DECLARE mf_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT")), protect
 DECLARE mf_jdoe = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"JDOE")), protect
 DECLARE mf_expireddaystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDDAYSTAY")),
 protect
 DECLARE mf_expiredobv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV")), protect
 DECLARE mf_expiredes1 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDES")), protect
 DECLARE mf_expiredes = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDES")), protect
 DECLARE mf_emergency = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY")), protect
 DECLARE mf_expiredip = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP")), protect
 DECLARE mf_daystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")), protect
 DECLARE mf_dischdaystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHDAYSTAY")), protect
 DECLARE mf_disches = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHES")), protect
 DECLARE mf_dischip = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP")), protect
 DECLARE mf_dischobv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV")), protect
 DECLARE mf_observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")), protect
 DECLARE mf_cmrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4,"CORPORATEMEDICALRECORDNUMBER")),
 protect
 DECLARE mf_finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_careteam = f8 WITH constant(uar_get_code_by("DISPLAYKEY",19189,"CARETEAM")), protect
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE ml_careteamlst_cnt = i4 WITH noconstant(0), protect
 DECLARE ml_pat_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_ftp_path = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ms_var_pkfile = vc WITH protect
 SET ms_var_pkfile = build(logical("bhscust"),"/ftp/bhs_rpt_ops_send_pk_lists/patient_list_",trim(
   format(cnvtdatetime(sysdate),"MMDDYYYYHHMMSS;;q"),3),".dat")
 DECLARE md_pretime = dq8 WITH protect
 RECORD pk_lists(
   1 careteamlst[*]
     2 f_patient_list_id = f8
     2 s_pk_patient_list_id = vc
     2 s_patient_list_name = vc
     2 patients[*]
       3 s_person_name = vc
       3 s_visit_num = vc
       3 s_mrn = vc
       3 s_pk_pat_type = vc
 )
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="BHS_LIST_KEYS:PK_PAT_LIST"
   AND d.info_long_id=1
  ORDER BY d.info_name
  HEAD REPORT
   stat = alterlist(pk_lists->careteamlst,10), ml_careteamlst_cnt = 0
  DETAIL
   ml_careteamlst_cnt += 1
   IF (mod(ml_careteamlst_cnt,10)=1)
    stat = alterlist(pk_lists->careteamlst,(ml_careteamlst_cnt+ 9))
   ENDIF
   pk_lists->careteamlst[ml_careteamlst_cnt].s_patient_list_name = d.info_name, pk_lists->
   careteamlst[ml_careteamlst_cnt].s_pk_patient_list_id = d.info_char, pk_lists->careteamlst[
   ml_careteamlst_cnt].f_patient_list_id = d.info_number
  FOOT REPORT
   stat = alterlist(pk_lists->careteamlst,ml_careteamlst_cnt), ml_careteamlst_cnt = 0
  WITH nocounter
 ;end select
 SET md_pretime = cnvtdatetime(sysdate)
 IF (curqual=0)
  CALL echo("No List Selected Go to Explorer Menu to Add Lists")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM person p,
   person_alias pa,
   encounter e,
   dcp_pl_custom_entry ce,
   encntr_alias ea,
   (dummyt d1  WITH seq = value(size(pk_lists->careteamlst,5)))
  PLAN (d1)
   JOIN (ce
   WHERE (ce.prsnl_group_id=pk_lists->careteamlst[d1.seq].f_patient_list_id))
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND ((e.disch_dt_tm=null) OR (e.disch_dt_tm > cnvtdatetime((curdate - 7),curtime3)))
    AND e.organization_id != 0)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_finnbr
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (p
   WHERE p.person_id=ce.person_id)
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.person_alias_type_cd=mf_cmrn
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ORDER BY ce.prsnl_group_id, p.person_id
  HEAD REPORT
   null
  HEAD ce.prsnl_group_id
   stat = alterlist(pk_lists->careteamlst[d1.seq].patients,10), ml_pat_cnt = 0
  HEAD p.person_id
   ml_pat_cnt += 1
   IF (mod(ml_pat_cnt,10)=1)
    stat = alterlist(pk_lists->careteamlst[d1.seq].patients,(ml_pat_cnt+ 9))
   ENDIF
   pk_lists->careteamlst[d1.seq].patients[ml_pat_cnt].s_person_name = p.name_full_formatted, pk_lists
   ->careteamlst[d1.seq].patients[ml_pat_cnt].s_visit_num = ea.alias
   IF (e.encntr_type_cd IN (mf_inpatient, mf_dischip, mf_expiredip))
    pk_lists->careteamlst[d1.seq].patients[ml_pat_cnt].s_pk_pat_type = "T"
   ELSEIF (e.encntr_type_cd IN (mf_observation, mf_dischobv, mf_expiredobv))
    pk_lists->careteamlst[d1.seq].patients[ml_pat_cnt].s_pk_pat_type = "OBV"
   ELSEIF (e.encntr_type_cd IN (mf_daystay, mf_dischdaystay, mf_expireddaystay))
    pk_lists->careteamlst[d1.seq].patients[ml_pat_cnt].s_pk_pat_type = "DST"
   ELSEIF (e.encntr_type_cd IN (mf_jdoe, mf_emergency, mf_disches, mf_expiredes))
    pk_lists->careteamlst[d1.seq].patients[ml_pat_cnt].s_pk_pat_type = "E"
   ENDIF
   pk_lists->careteamlst[d1.seq].patients[ml_pat_cnt].s_mrn = pa.alias
  FOOT  p.person_id
   null
  FOOT  ce.prsnl_group_id
   stat = alterlist(pk_lists->careteamlst[d1.seq].patients,ml_pat_cnt), ml_pat_cnt = 0
  WITH nocounter
 ;end select
 CALL echo(build("selectime =",datetimediff(cnvtdatetime(sysdate),cnvtdatetime(md_pretime),5)))
 IF (size(pk_lists->careteamlst,5) > 0)
  SELECT INTO value(ms_var_pkfile)
   patient_list_name = trim(substring(1,30,pk_lists->careteamlst[d1.seq].s_patient_list_name),3),
   patient_list_id = trim(substring(1,30,pk_lists->careteamlst[d1.seq].s_pk_patient_list_id),3),
   visit_num = trim(pk_lists->careteamlst[d1.seq].patients[d2.seq].s_visit_num,3)"##########;rp0",
   encounter_type = substring(1,30,trim(pk_lists->careteamlst[d1.seq].patients[d2.seq].s_pk_pat_type,
     3)), mrn = trim(pk_lists->careteamlst[d1.seq].patients[d2.seq].s_mrn,3)"#########;r"
   FROM (dummyt d1  WITH seq = value(size(pk_lists->careteamlst,5))),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(pk_lists->careteamlst[d1.seq].patients,5)))
    JOIN (d2)
   DETAIL
    line = trim(build(trim(patient_list_name,3),"|",patient_list_id,"|",trim(visit_num,3),
      "|",trim(mrn,3),trim("||",3),trim(encounter_type,3),"|"),3), col 0, line,
    row + 1
   WITH nocounter, format = variable, maxrow = 1
  ;end select
 ENDIF
#exit_program
 IF (cnvtupper(trim(curdomain,3)) != cnvtupper( $DOMAIN))
  CALL echo(build("Current domain ",curdomain," not valid"))
 ENDIF
END GO
