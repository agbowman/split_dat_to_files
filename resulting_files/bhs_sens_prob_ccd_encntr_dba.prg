CREATE PROGRAM bhs_sens_prob_ccd_encntr:dba
 PROMPT
  "Encntr Type Class" = "",
  "Beg Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH s_encntr_type_class, s_beg_dt, s_end_dt
 EXECUTE bhs_check_domain:dba
 DECLARE ms_encntr_type_class = vc WITH protect, constant(trim(cnvtupper( $S_ENCNTR_TYPE_CLASS)))
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT)," 23:59:59"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_pre1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREADMITDAYSTAY"))
 DECLARE mf_pre2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREADMITIP"))
 DECLARE mf_pre3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PRECMTYOFFICEVISIT")
  )
 DECLARE mf_pre4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREOFFICEVISIT"))
 DECLARE mf_pre5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "PREOUTPATIENTONETIME"))
 DECLARE mf_pre6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREOUTPT"))
 DECLARE mf_pre7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PRERECUROFFICEVISIT"
   ))
 DECLARE mf_outp_typ_cls_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"OUTPATIENT")
  )
 DECLARE mf_inpt_typ_cls_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE ms_file_name = vc WITH protect, noconstant(" ")
 DECLARE mf_encntr_type_cls_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE mn_dcl_stat = i4 WITH protect, noconstant(0)
 DECLARE ms_ftp_path = vc WITH protect, noconstant("")
 DECLARE ms_dcl = vc WITH protect, noconstant(" ")
 DECLARE ml_enc_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_prod_ind = i2 WITH protect, noconstant(0)
 CALL echo(build2("mf_FIN_CD: ",mf_fin_cd))
 CALL echo(build2("mf_PRE1_CD: ",mf_pre1_cd))
 CALL echo(build2("mf_PRE2_CD: ",mf_pre2_cd))
 CALL echo(build2("mf_PRE3_CD: ",mf_pre3_cd))
 CALL echo(build2("mf_PRE4_CD: ",mf_pre4_cd))
 CALL echo(build2("mf_PRE5_CD: ",mf_pre5_cd))
 CALL echo(build2("mf_PRE6_CD: ",mf_pre6_cd))
 CALL echo(build2("mf_PRE7_CD: ",mf_pre7_cd))
 IF (cnvtdatetime(ms_beg_dt_tm) > cnvtdatetime(ms_end_dt_tm))
  CALL echo("Beg date > End date")
  GO TO exit_script
 ENDIF
 IF (((textlen(trim( $S_BEG_DT))=0) OR (textlen(trim( $S_END_DT))=0)) )
  CALL echo("Dates must be filled out")
  GO TO exit_script
 ENDIF
 CALL echo(concat("Beg: ",ms_beg_dt_tm))
 CALL echo(concat("End: ",ms_end_dt_tm))
 IF (ms_encntr_type_class="OUTPATIENT")
  SET mf_encntr_type_cls_cd = mf_outp_typ_cls_cd
  SET ms_file_name = concat("bhs_cda_outpat_enc_",trim(format(cnvtdatetime(ms_beg_dt_tm),"mmddyy;;d")
    ),"-",trim(format(cnvtdatetime(ms_end_dt_tm),"mmddyy;;d")),".csv")
 ELSEIF (ms_encntr_type_class="INPATIENT")
  SET mf_encntr_type_cls_cd = mf_inpt_typ_cls_cd
  SET ms_file_name = concat("bhs_cda_inpat_enc_",trim(format(cnvtdatetime(ms_beg_dt_tm),"mmddyy;;d")),
   "-",trim(format(cnvtdatetime(ms_end_dt_tm),"mmddyy;;d")),".csv")
 ENDIF
 CALL echo(ms_file_name)
 SELECT INTO value(ms_file_name)
  FROM encounter e,
   encntr_alias ea
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND ((e.disch_dt_tm > cnvtdatetime(ms_beg_dt_tm)) OR (e.disch_dt_tm=null))
    AND e.active_ind=1
    AND e.encntr_type_class_cd=mf_encntr_type_cls_cd
    AND  NOT (e.encntr_type_cd IN (mf_pre1_cd, mf_pre2_cd, mf_pre3_cd, mf_pre4_cd, mf_pre5_cd,
   mf_pre6_cd, mf_pre7_cd)))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.alias != "ATR*")
  ORDER BY e.encntr_id
  HEAD REPORT
   ms_tmp = '"encntr_id","person_id","fin","enc_typ_cls","enc_typ","reg_dt_tm","disch_dt_tm"', col 0,
   ms_tmp
  HEAD e.encntr_id
   ml_enc_cnt = (ml_enc_cnt+ 1), ms_tmp = "", ms_tmp = concat('"',trim(cnvtstring(e.encntr_id)),'",',
    '"',trim(cnvtstring(e.person_id)),
    '",','"',trim(ea.alias),'",','"',
    trim(uar_get_code_display(e.encntr_type_class_cd)),'",','"',trim(uar_get_code_display(e
      .encntr_type_cd)),'",',
    '"',trim(format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;d")),'",','"',trim(format(e.disch_dt_tm,
      "mm/dd/yyyy hh:mm;;d")),
    '"'),
   row + 1, col 0, ms_tmp
  WITH nocounter, format = variable, maxrow = 1,
   maxcol = 1000
 ;end select
 IF (ml_enc_cnt=0)
  CALL echo("no patients found")
  GO TO exit_script
 ELSE
  CALL echo(concat("found ",trim(cnvtstring(ml_enc_cnt))," encounters for ",ms_encntr_type_class))
  IF (findfile(ms_file_name))
   IF (gl_bhs_prod_flag=1)
    SET mn_prod_ind = 1
   ENDIF
   IF (mn_prod_ind=1)
    SET ms_ftp_path = "ciscore\HIE\PROD\PVIX SENSITIVE CDA"
   ELSE
    SET ms_ftp_path = "ciscore\HIE\NONPROD\PVIX SENSITIVE CDA"
   ENDIF
   CALL echo("FTP")
   IF (((gl_bhs_prod_flag=1) OR (gs_bhs_domain_name="READ")) )
    SET ms_dcl = concat("$cust_script/bhs_ftp_file.ksh ",ms_file_name,
     " 172.17.10.5 'bhs\cisftp' C!sftp01 '",'"',ms_ftp_path,
     '"',"'")
   ELSE
    SET ms_dcl = concat("$bhscust/bhs_ftp_file.ksh $bhscust/",ms_file_name,
     " 172.17.10.5 'bhs\cisftp' C!sftp01 '",'"',ms_ftp_path,
     '"',"'")
   ENDIF
   CALL echo(ms_dcl)
   CALL dcl(ms_dcl,size(ms_dcl),mn_dcl_stat)
   CALL echo(build2("ftp dcl stat: ",mn_dcl_stat))
  ELSE
   CALL echo(concat("can't find file: ",ms_file_name))
  ENDIF
 ENDIF
#exit_script
END GO
