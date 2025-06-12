CREATE PROGRAM autofax_audit:dba
 FREE RECORD m_data
 RECORD m_data(
   1 pat[*]
     2 s_patient = vc
     2 s_acct_nbr = vc
     2 s_disch_dt = vc
     2 s_pcp_name = vc
     2 s_pcp_phone = vc
     2 s_pcp_fax_station = vc
     2 f_pcp_id = f8
     2 s_pcp_username = vc
     2 s_note_title = vc
     2 s_file_name = vc
     2 s_physician_name = vc
     2 s_physician_action = vc
     2 s_updt_dt = vc
     2 f_physician_id = f8
     2 s_status = vc
     2 f_event_id = f8
     2 f_encntr_id = f8
     2 n_fax_nbr_ind = i2
     2 n_data_ind = i2
     2 n_fax_ind = i2
 ) WITH protect
 EXECUTE bhs_sys_stand_subroutine:dba
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_powernote_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",29520,"POWERNOTE"))
 DECLARE mf_no_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE mf_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE mf_disch_note_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGETRANSFERNOTEHOSPITAL"))
 DECLARE mf_fax_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3000,"FAX"))
 DECLARE mf_sign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE mf_pcp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"PCP"))
 DECLARE mf_story_stat_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",15750,"SIGNED"))
 DECLARE mf_fin_nbr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_discharged_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",261,"DISCHARGED"))
 DECLARE ms_string = vc WITH protect, noconstant("")
 DECLARE ms_tmp_str = vc WITH protect, noconstant("")
 DECLARE ms_file_name = vc WITH protect, noconstant("")
 DECLARE ms_fax_file_list = vc WITH protect, constant("bhscust:autofax_file_list.dat")
 DECLARE ms_logfile_name = vc WITH protect, constant("bhscust:autofax_cnvt_logfile.dat")
 DECLARE ms_title_text = vc WITH protect, constant("Physician Discharge Summary")
 DECLARE ms_title_text2 = vc WITH protect, constant("Medical H & P")
 DECLARE mn_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_file_prefix = vc WITH protect, noconstant("")
 DECLARE ms_fin_nbr = vc WITH protect, noconstant("")
 DECLARE ms_email_filename = vc WITH protect, constant("autofax_email_file.txt")
 DECLARE ms_line = vc WITH protect, noconstant("")
 DECLARE mf_output_dest_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mn_beg_pos = i4 WITH protect, noconstant(0)
 DECLARE mn_end_pos = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 DECLARE ms_pcp_fax_file = vc WITH protect, noconstant("autofax_pcp_fax_list.csv")
 DECLARE ms_rtl_file = vc WITH protect, noconstant(" ")
 DECLARE mn_pcp_fax_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_pcp_id = vc WITH protect, noconstant("")
 DECLARE ms_pcp_name = vc WITH protect, noconstant("")
 DECLARE retval = i4 WITH public, noconstant(0)
 DECLARE log_message = vc WITH public, noconstant("")
 DECLARE sbr_log(ms_log_str=vc) = null
 CALL sbr_log(concat("Begin Log (bhs_cnvt_powernotes): ",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d")))
 SELECT INTO "nl:"
  FROM device d,
   output_dest od
  PLAN (d
   WHERE d.description="Auto Fax Station")
   JOIN (od
   WHERE od.device_cd=d.device_cd)
  DETAIL
   mf_output_dest_cd = od.output_dest_cd
  WITH nocounter
 ;end select
 IF (mf_output_dest_cd=0)
  CALL echo("output_dest_cd = 0; no autofax station: exiting")
  CALL sbr_log("output_dest_cd = 0; no autofax station: exiting")
  GO TO exit_script
 ELSE
  CALL echo(concat("output_dest_cd = ",trim(cnvtstring(mf_output_dest_cd))))
  CALL sbr_log(concat("output_dest_cd = ",trim(cnvtstring(mf_output_dest_cd))))
 ENDIF
 SELECT INTO "nl:"
  pf_report_id = s.scd_story_id, pn_patient_name = substring(1,40,trim(pe.name_full_formatted)),
  pf_acct_nbr = trim(cnvtstring(ea.alias)),
  ps_disch_dt_tm = format(e.disch_dt_tm,"mm/dd/yyyy HH:MM:SS"), ps_title = substring(1,40,trim(s
    .title)), ps_physician_name = p.name_full_formatted,
  ps_phys_action = uar_get_code_display(cep.action_status_cd), ps_updt_dt_tm = format(cep.updt_dt_tm,
   "MM/DD/YYYY HH:MM:SS"), ps_story_status = uar_get_code_display(s.story_completion_status_cd),
  p3.name_full_formatted, p3.username, cep.action_prsnl_id,
  s.event_id, cep.ce_event_prsnl_id
  FROM scd_story s,
   scd_story_pattern ssp,
   scr_pattern srp,
   ce_event_prsnl cep,
   prsnl p,
   person pe,
   encounter e,
   encntr_prsnl_reltn epr,
   prsnl p3,
   encntr_alias ea,
   ce_blob ceb
  PLAN (srp
   WHERE trim(srp.display_key) IN ("MEDICALHP", "PHYSICIANDISCHARGESUMMARY"))
   JOIN (ssp
   WHERE ssp.scr_pattern_id=srp.scr_pattern_id)
   JOIN (s
   WHERE s.scd_story_id=ssp.scd_story_id
    AND s.story_completion_status_cd=mf_story_stat_cd
    AND s.updt_dt_tm BETWEEN cnvtdatetime((curdate - 14),0) AND cnvtdatetime((curdate - 1),235959))
   JOIN (cep
   WHERE cep.event_id=s.event_id
    AND cep.valid_until_dt_tm >= cnvtdatetime("31-DEC-2100")
    AND ((cep.action_type_cd+ 0)=mf_sign_cd)
    AND ((cep.action_status_cd+ 0) IN (mf_completed_cd))
    AND ((cep.action_dt_tm+ 0) BETWEEN cnvtdatetime((curdate - 14),0) AND cnvtdatetime((curdate - 1),
    235959)))
   JOIN (p
   WHERE p.person_id=cep.action_prsnl_id
    AND ((p.physician_ind+ 0)=1)
    AND p.name_full_formatted IN ("Bryson DO, Christine", "Lachance MD, Christopher",
   "Mahmoud MD , Fade A", "Sittig MD, Roy", "Mulligan MD, Timothy",
   "Goldberg MD, Robert B"))
   JOIN (pe
   WHERE pe.person_id=s.person_id)
   JOIN (e
   WHERE e.encntr_id=s.encounter_id
    AND e.disch_dt_tm BETWEEN cnvtdatetime((curdate - 14),0) AND cnvtdatetime(curdate,0))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(s.encounter_id)
    AND ea.encntr_alias_type_cd=outerjoin(mf_fin_nbr_cd))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=mf_pcp_cd
    AND epr.end_effective_dt_tm > sysdate)
   JOIN (p3
   WHERE p3.person_id=epr.prsnl_person_id
    AND  NOT (p3.username IN ("EN*", "SPNDEN*")))
   JOIN (ceb
   WHERE ceb.event_id=s.event_id
    AND ceb.valid_until_dt_tm > sysdate)
  ORDER BY ceb.event_id, 0
  HEAD REPORT
   pn_cnt = 0
  HEAD ceb.event_id
   pn_cnt = (pn_cnt+ 1)
   IF (pn_cnt > size(m_data->pat,5))
    stat = alterlist(m_data->pat,(pn_cnt+ 10))
   ENDIF
   m_data->pat[pn_cnt].s_patient = pn_patient_name, m_data->pat[pn_cnt].s_acct_nbr = pf_acct_nbr,
   m_data->pat[pn_cnt].s_disch_dt = ps_disch_dt_tm,
   m_data->pat[pn_cnt].f_event_id = ceb.event_id, m_data->pat[pn_cnt].s_pcp_name = p3
   .name_full_formatted, m_data->pat[pn_cnt].s_pcp_username = p3.username,
   m_data->pat[pn_cnt].s_physician_action = ps_phys_action, m_data->pat[pn_cnt].f_physician_id = cep
   .action_prsnl_id, m_data->pat[pn_cnt].s_physician_name = p.name_full_formatted,
   m_data->pat[pn_cnt].s_note_title = ps_title, m_data->pat[pn_cnt].s_status = ps_story_status,
   m_data->pat[pn_cnt].s_updt_dt = ps_updt_dt_tm,
   m_data->pat[pn_cnt].f_encntr_id = e.encntr_id, m_data->pat[pn_cnt].f_pcp_id = p3.person_id
  FOOT REPORT
   stat = alterlist(m_data->pat,pn_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(m_data)
 GO TO exit_script
 IF (size(m_data->pat,5)=0)
  SET log_message = "No records found for today - exiting"
  CALL echo(log_message)
  CALL sbr_log(log_message)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_data->pat,5))),
   device_xref dx
  PLAN (d
   WHERE (m_data->pat[d.seq].f_pcp_id > 0))
   JOIN (dx
   WHERE (dx.parent_entity_id=m_data->pat[d.seq].f_pcp_id)
    AND dx.usage_type_cd=mf_fax_cd)
  DETAIL
   m_data->pat[d.seq].n_fax_nbr_ind = 1, m_data->pat[d.seq].s_pcp_fax_station = trim(cnvtstring(dx
     .device_cd)), mn_pcp_fax_cnt = (mn_pcp_fax_cnt+ 1)
  WITH nocounter
 ;end select
 IF (mn_pcp_fax_cnt < size(m_data->pat,5))
  IF (findfile(concat("bhscust:",ms_pcp_fax_file))=1)
   CALL parser(concat('set logical ms_rtl_file "bhscust:',ms_pcp_fax_file,'" go'))
   FREE DEFINE rtl2
   DEFINE rtl2 "ms_rtl_file"
   SELECT INTO "nl:"
    t.line
    FROM (dummyt d  WITH seq = value(size(m_data->pat,5))),
     rtl2t t
    PLAN (d)
     JOIN (t
     WHERE t.line > " ")
    HEAD REPORT
     pn_beg_pos = 0, pn_end_pos = 0
    DETAIL
     ms_line = "", ms_line = trim(t.line), ms_pcp_id = trim(cnvtstring(m_data->pat[d.seq].f_pcp_id)),
     ms_pcp_name = m_data->pat[d.seq].s_pcp_name
     IF (((findstring(ms_pcp_id,ms_line) > 0) OR (findstring(ms_pcp_name,ms_line) > 0)) )
      pn_beg_pos = (findstring('",',ms_line,pn_beg_pos)+ 2), pn_end_pos = textlen(trim(ms_line)),
      ms_tmp_str = substring(pn_beg_pos,(pn_end_pos - (pn_beg_pos - 1)),ms_line),
      ms_tmp_str = replace(ms_tmp_str,"-","",0), ms_tmp_str = replace(ms_tmp_str,",","",0),
      ms_tmp_str = replace(ms_tmp_str," ","",0),
      m_data->pat[d.seq].s_pcp_fax_station = trim(ms_tmp_str), m_data->pat[d.seq].n_fax_nbr_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   FREE DEFINE rtl2
  ENDIF
 ENDIF
 CALL echorecord(m_data)
 CALL echo(build("items: ",size(m_data->pat,5)))
 FOR (x = 1 TO size(m_data->pat,5))
   CALL echo(build("acct nbr: ",m_data->pat[x].s_acct_nbr))
   CALL echo(build("disch date: ",m_data->pat[x].s_disch_dt))
   CALL echo(build("pcp username: ",m_data->pat[x].s_pcp_username))
   CALL sbr_log("Parameter values:")
   CALL sbr_log(concat("Event_id: ",trim(cnvtstring(m_data->pat[x].f_event_id))))
   CALL sbr_log(concat("encntr_id: ",trim(cnvtstring(m_data->pat[x].f_encntr_id))))
   CALL sbr_log(concat("event_title_text: ",trim(m_data->pat[x].s_note_title)))
   IF ((m_data->pat[x].n_fax_nbr_ind=1))
    CALL sbr_log(concat("Signing Physician: ",m_data->pat[x].s_physician_name))
    CALL echo(concat("Signing Physician: ",m_data->pat[x].s_physician_name))
    SET ms_fin_nbr = ""
    SET ms_file_prefix = ""
    SET ms_file_name = ""
    SET ms_fin_nbr = m_data->pat[x].s_acct_nbr
    IF (textlen(trim(ms_fin_nbr)) > 0)
     IF (textlen(trim(ms_fin_nbr)) > 22)
      SET ms_fin_nbr = concat(substring(1,21,ms_fin_nbr),"X")
     ENDIF
     IF (trim(m_data->pat[x].s_note_title)=ms_title_text)
      SET ms_file_prefix = "fax1_"
     ELSEIF (trim(m_data->pat[x].s_note_title)=ms_title_text2)
      SET ms_file_prefix = "fax2_"
     ENDIF
     SET ms_file_name = concat(ms_file_prefix,ms_fin_nbr,".dat")
     SET m_data->pat[x].s_file_name = concat(ms_file_prefix,ms_fin_nbr)
     CALL sbr_log(concat("filename: ",ms_file_name))
     CALL echo(concat("filename: ",ms_file_name))
    ELSE
     SET log_message = concat("FIN_NBR not found: ",cnvtstring(mf_clin_event_id))
     CALL sbr_log(log_message)
     CALL echo(log_message)
    ENDIF
    SELECT INTO value(concat("bhscust:",ms_file_name))
     FROM ce_blob cb
     PLAN (cb
      WHERE (cb.event_id=m_data->pat[x].f_event_id)
       AND cb.valid_until_dt_tm > sysdate)
     HEAD REPORT
      MACRO (print_text)
       mn_max_print_len = 80, mn_loop_cnt = 0, mn_space_pos = 0,
       mn_tmp_pos = 0, mn_end_pos = 0, mn_beg_pos = 1,
       mn_rem_len = 0
       IF (textlen(ms_string) < mn_max_print_len
        AND textlen(trim(ms_string)) > 0)
        ms_string = trim(ms_string), ms_string
       ELSEIF (textlen(ms_string) > 0)
        mn_rem_len = textlen(ms_string)
        WHILE (mn_rem_len >= mn_max_print_len)
          mn_loop_cnt = (mn_loop_cnt+ 1), mn_tmp_pos = mn_beg_pos, mn_space_pos = 0
          WHILE (mn_space_pos < mn_max_print_len)
           mn_space_pos = findstring(char(13),ms_string,mn_tmp_pos),
           IF (mn_space_pos > 0
            AND mn_space_pos <= mn_max_print_len)
            mn_tmp_pos = (mn_space_pos+ 1)
           ELSEIF (((mn_space_pos=0) OR (mn_space_pos > mn_max_print_len)) )
            IF (mn_tmp_pos=mn_beg_pos)
             mn_tmp_pos = mn_max_print_len
            ENDIF
            mn_space_pos = (mn_max_print_len+ 1)
           ENDIF
          ENDWHILE
          mn_space_pos = mn_tmp_pos, row + 1, ms_tmp_str = trim(substring(mn_beg_pos,(mn_space_pos -
            mn_beg_pos),ms_string)),
          ms_tmp_str, mn_beg_pos = mn_space_pos, ms_string = substring(mn_beg_pos,((textlen(ms_string
            ) - mn_beg_pos)+ 1),ms_string),
          mn_beg_pos = 1, mn_rem_len = (textlen(ms_string) - mn_beg_pos)
          IF (mn_rem_len < mn_max_print_len)
           ms_tmp_str = trim(ms_string), row + 1, ms_tmp_str
          ENDIF
        ENDWHILE
       ENDIF
       ms_tmp_str = ""
      ENDMACRO
     DETAIL
      IF (textlen(trim(cb.blob_contents)) > 0)
       blob_size = cnvtint(cb.blob_length), blob_out_detail = fillstring(64000," "),
       blob_compressed_trimmed = fillstring(64000," "),
       blob_uncompressed = fillstring(64000," "), blob_rtf = fillstring(64000," "), blob_out_detail
        = fillstring(64000," "),
       blob_compressed_trimmed = trim(cb.blob_contents), blob_return_len = 0, blob_return_len2 = 0,
       ps_blob_out = fillstring(64000," ")
       IF (cb.compression_cd=mf_comp_cd)
        CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),
        blob_uncompressed,size(blob_uncompressed),blob_return_len),
        CALL uar_rtf2(blob_uncompressed,blob_return_len,blob_rtf,size(blob_rtf),blob_return_len2,1),
        ps_blob_out = trim(blob_rtf,3)
       ELSEIF (cb.compression_cd=mf_no_comp_cd)
        ps_blob_out = trim(cb.blob_contents)
        IF (findstring("rtf",ps_blob_out) > 0)
         CALL uar_rtf2(ps_blob_out,textlen(ps_blob_out),blob_rtf,size(blob_rtf),blob_return_len2,1),
         ps_blob_out = trim(blob_rtf,3)
        ENDIF
        IF (findstring("ocf_blob",ps_blob_out) > 0)
         ps_blob_out = trim(substring(1,(findstring("ocf_blob",ps_blob_out) - 1),ps_blob_out))
        ENDIF
       ENDIF
      ENDIF
      ps_blob_out = replace(ps_blob_out,char(10),""), ms_string = ps_blob_out, print_text
     WITH nocounter, maxcol = 80, maxrow = 10000,
      dio = 36
    ;end select
    IF (curqual < 1)
     SET log_message = concat("Data not found: ",cnvtstring(mf_clin_event_id))
     CALL sbr_log(log_message)
     CALL echo(log_message)
     SET m_data->pat[x].n_data_ind = 0
    ELSE
     CALL sbr_log(concat("file created: ",ms_file_name))
     CALL echo(concat("file created: ",ms_file_name))
     SET m_data->pat[x].n_data_ind = 1
    ENDIF
    IF ((m_data->pat[x].n_data_ind=1))
     SELECT INTO "nl:"
      FROM encntr_alias ea,
       encounter e
      PLAN (ea
       WHERE ea.alias=ms_fin_nbr
        AND ea.active_ind=1)
       JOIN (e
       WHERE e.encntr_id=ea.encntr_id
        AND e.encntr_status_cd=mf_discharged_cd)
      HEAD REPORT
       m_data->pat[x].n_fax_ind = 1
      WITH nocounter
     ;end select
     IF (curqual < 1)
      CALL echo(concat("Patient is not discharged.  File ",ms_file_name," not faxed."))
      CALL sbr_log(concat("Patient is not discharged.  File ",ms_file_name," not faxed."))
     ELSE
      CALL echo(concat("Patient is discharged.  Faxing file."))
      CALL sbr_log(concat("Patient is discharged.  Faxing file."))
      CALL sbr_log(concat("Processing file: ",ms_file_name))
      CALL sbr_log(trim(build2("PCP ID: ",m_data->pat[x].f_pcp_id)))
      CALL sbr_log(concat("PCP Name: ",m_data->pat[x].s_pcp_name))
      CALL echo(concat("Finding file: ",ms_file_name))
      IF (findfile(concat("bhscust:",ms_file_name))=1)
       CALL sbr_log("Found File")
       CALL sbr_log(concat("Faxing file: ",ms_file_name," to PCP ID: ",trim(cnvtstring(m_data->pat[x]
           .f_pcp_id))," PCP Name: ",
         m_data->pat[x].s_pcp_name))
       EXECUTE bhs_sys_send_fax ms_file_name, trim(cnvtstring(m_data->pat[x].f_pcp_id)),
       mf_output_dest_cd
      ELSE
       CALL echo(concat("Unable to find file: ",ms_file_name))
       CALL sbr_log(concat("Unable to find file: ",ms_file_name))
      ENDIF
     ENDIF
    ENDIF
    SELECT INTO "bhscust:testfaxfiles.dat"
     HEAD REPORT
      ps_tmp_str = concat("filename:",ms_file_name," pcpid:",trim(cnvtstring(m_data->pat[x].f_pcp_id)
        )," pcpname:",
       trim(m_data->pat[x].s_pcp_name)), col 0, ps_tmp_str
     WITH nocounter, append
    ;end select
   ELSE
    IF ((m_data->pat[x].n_fax_nbr_ind=0))
     SET log_message = "PCP fax not found"
     SET m_data->pat[x].s_pcp_fax_station = "PCP fax not found"
     CALL sbr_log(log_message)
     CALL echo(log_message)
    ENDIF
   ENDIF
 ENDFOR
 SELECT INTO value(concat("bhscust:",ms_email_filename))
  pn_fax_ind = m_data->pat[d.seq].n_fax_ind, pn_fax_nbr_ind = m_data->pat[d.seq].n_fax_nbr_ind,
  pn_data_ind = m_data->pat[d.seq].n_data_ind
  FROM (dummyt d  WITH seq = value(size(m_data->pat,5)))
  PLAN (d)
  ORDER BY pn_fax_ind, pn_fax_nbr_ind, pn_data_ind
  HEAD pn_fax_ind
   IF ((m_data->pat[d.seq].n_fax_ind=1))
    col 0, row + 1, "     ",
    ms_tmp_str = "SUCCESS - Files sent to fax:", col 0, row + 1,
    ms_tmp_str, ms_tmp_str = fillstring(80,"-"), col 0,
    row + 1, ms_tmp_str
   ELSE
    ms_tmp_str = "FAIL - Files not sent to fax:", col 0, ms_tmp_str,
    ms_tmp_str = fillstring(82,"-"), col 0, row + 1,
    ms_tmp_str
   ENDIF
  HEAD pn_fax_nbr_ind
   IF ((m_data->pat[d.seq].n_fax_nbr_ind=0))
    ms_tmp_str = "Fax station not found for the following:"
   ENDIF
  HEAD pn_data_ind
   IF ((m_data->pat[d.seq].n_fax_nbr_ind=0))
    col 0, row + 1, "     ",
    col 0, row + 1, ms_tmp_str
   ELSEIF ((m_data->pat[d.seq].n_data_ind=0))
    col 0, row + 1, "     ",
    ms_tmp_str = "Data not found for the following:", col 0, row + 1,
    ms_tmp_str
   ENDIF
  DETAIL
   ms_tmp_str = concat("filename:",m_data->pat[d.seq].s_file_name,".dat ","pcpid:",trim(cnvtstring(
      m_data->pat[d.seq].f_pcp_id)),
    " ","pcpname:",m_data->pat[d.seq].s_pcp_name), col 0, row + 1,
   ms_tmp_str
  FOOT REPORT
   col 0, row + 1, "     ",
   col 0, row + 1, "*** END ***"
  WITH nocounter
 ;end select
 IF (findfile(concat("bhscust:",ms_email_filename))=1)
  CALL echo("found email file")
  CALL sbr_log("Found Email File")
  CALL echo("emailing 2")
  SET email_list = "joe.echols@bhs.org, naser.sanjar@bhs.org"
  SET ms_tmp_str = concat('"Files Faxed ',format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"),'"')
  CALL emailfile(concat("$bhscust/",ms_email_filename),concat("$bhscust/",ms_email_filename),
   email_list,ms_tmp_str,1)
  IF (findfile(concat("bhscust:",ms_email_filename))=1)
   CALL echo("Unable to delete email file")
   CALL sbr_log("Unable to delete email file")
  ELSE
   CALL echo("Email File Deleted")
   CALL sbr_log("Email File Deleted")
  ENDIF
 ELSE
  CALL echo("email file not found")
  CALL sbr_log("Email File Not found")
 ENDIF
 CALL sbr_log(concat("End Log (bhs_ops_fax_powernotes): ",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d")))
 CALL echo(concat("log_message: ",log_message))
 SUBROUTINE sbr_log(ms_log_str)
   SELECT INTO value(ms_logfile_name)
    DETAIL
     col 0, row + 1, ms_log_str
    WITH nocounter, append
   ;end select
 END ;Subroutine
#exit_script
END GO
