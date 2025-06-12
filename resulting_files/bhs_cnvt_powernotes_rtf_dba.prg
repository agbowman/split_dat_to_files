CREATE PROGRAM bhs_cnvt_powernotes_rtf:dba
 PROMPT
  "Clinical Event ID" = ""
  WITH s_clin_event_id
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_powernote_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",29520,"POWERNOTE"))
 DECLARE mf_no_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE mf_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE mf_disch_note_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGETRANSFERNOTEHOSPITAL"))
 DECLARE mf_fax_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3000,"FAX"))
 DECLARE mf_sign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE mf_pcp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE mf_clin_event_id = f8 WITH protect, noconstant(request->clin_detail_list[1].
  clinical_event_id)
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(request->clin_detail_list[1].encntr_id)
 DECLARE mf_event_id = f8 WITH protect, noconstant(request->clin_detail_list[1].event_id)
 DECLARE ms_fin_nbr = vc WITH protect, noconstant("")
 DECLARE mf_person_id = f8 WITH protect, noconstant(request->clin_detail_list[1].person_id)
 DECLARE ms_string = vc WITH protect, noconstant("")
 DECLARE ms_tmp_str = vc WITH protect, noconstant("")
 DECLARE ms_file_name = vc WITH protect, noconstant("")
 DECLARE mf_faxto_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_faxto_name = vc WITH protect, noconstant("")
 DECLARE ms_fax_file_list = vc WITH protect, constant("bhscust:autofax_file_list.dat")
 DECLARE ms_logfile_name = vc WITH protect, constant("bhscust:autofax_cnvt_logfile.dat")
 DECLARE ms_title_text = vc WITH protect, constant("Physician Discharge Summary")
 DECLARE ms_signing_phys = vc WITH protect, noconstant("")
 DECLARE mn_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE retval = i4 WITH public, noconstant(0)
 DECLARE log_message = vc WITH public, noconstant("")
 DECLARE sbr_log(ms_log_str=vc) = null
 CALL sbr_log(concat("Begin Log (bhs_cnvt_powernotes): ",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d")))
 CALL sbr_log("Parameter values:")
 CALL sbr_log(concat("clinical_event_id: ",trim(cnvtstring(request->clin_detail_list[1].
     clinical_event_id))))
 CALL sbr_log(concat("encntr_id: ",trim(cnvtstring(request->clin_detail_list[1].encntr_id))))
 CALL sbr_log(concat("event_id: ",trim(cnvtstring(request->clin_detail_list[1].event_id))))
 CALL sbr_log(concat("person_id: ",trim(cnvtstring(request->clin_detail_list[1].person_id))))
 CALL sbr_log(concat("event_title_text: ",trim(cnvtstring(request->clin_detail_list[1].
     event_title_text))))
 IF (mf_clin_event_id <= 0.0)
  SET log_message = concat("invalid clinical_event_id: ",cnvtstring(mf_clin_event_id),
   " exiting script")
  CALL sbr_log(log_message)
  CALL echo(log_message)
  GO TO exit_script
 ENDIF
 IF (trim(request->clin_detail_list[1].event_title_text) != ms_title_text)
  SET log_message = "event_title_text invalid"
  CALL sbr_log(log_message)
  CALL echo(log_message)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM ce_event_prsnl cep,
   prsnl p
  PLAN (cep
   WHERE cep.event_id=mf_event_id
    AND ((cep.action_type_cd+ 0)=mf_sign_cd)
    AND ((cep.action_status_cd+ 0)=mf_completed_cd)
    AND cep.valid_until_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=cep.action_prsnl_id
    AND p.name_full_formatted IN ("Bryson DO, Christine", "Lachance MD, Christopher",
   "Mahmoud MD , Fade A", "Sittig MD, Roy"))
  DETAIL
   ms_signing_phys = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET log_message = "Signing Physician not in fax list"
  CALL sbr_log(log_message)
  CALL echo(log_message)
  GO TO exit_script
 ELSE
  CALL sbr_log(concat("Signing Physician: ",ms_signing_phys))
  CALL echo(concat("Signing Physician: ",ms_signing_phys))
 ENDIF
 SELECT INTO "nl:"
  FROM device_xref dx,
   person_prsnl_reltn ppr,
   prsnl p
  PLAN (ppr
   WHERE ppr.person_id=mf_person_id
    AND ppr.person_prsnl_r_cd=mf_pcp_cd
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm > sysdate)
   JOIN (dx
   WHERE dx.parent_entity_id=ppr.prsnl_person_id
    AND dx.usage_type_cd=mf_fax_cd)
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id
    AND p.username="PN*")
  DETAIL
   mf_faxto_id = dx.parent_entity_id, ms_faxto_name = p.name_last_key
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET log_message = "PCP fax not found or PCP not in fax list"
  CALL sbr_log(log_message)
  CALL echo(log_message)
  GO TO exit_script
 ELSE
  CALL sbr_log(concat("PCP name: ",ms_faxto_name))
  CALL echo(concat("PCP name: ",ms_faxto_name))
 ENDIF
 SELECT INTO "nl:"
  ea.alias
  FROM encntr_alias ea
  PLAN (ea
   WHERE ea.encntr_id=mf_encntr_id)
  DETAIL
   ms_fin_nbr = trim(ea.alias)
  WITH nocounter
 ;end select
 IF (textlen(trim(ms_fin_nbr)) > 0)
  IF (textlen(trim(ms_fin_nbr)) > 22)
   SET ms_fin_nbr = concat(substring(1,21,ms_fin_nbr),"X")
  ENDIF
  SET ms_file_name = concat("fax_",ms_fin_nbr,".dat")
  CALL sbr_log(concat("filename: ",ms_file_name))
  CALL echo(concat("filename: ",ms_file_name))
 ELSE
  SET log_message = concat("FIN_NBR not found: ",cnvtstring(mf_clin_event_id))
  CALL sbr_log(log_message)
  CALL echo(log_message)
  GO TO exit_script
 ENDIF
 CALL echo("write to file")
 SELECT INTO value(concat("bhscust:",ms_file_name))
  FROM ce_blob cb
  PLAN (cb
   WHERE cb.event_id=mf_event_id
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
       ms_tmp_str, mn_beg_pos = mn_space_pos, ms_string = substring(mn_beg_pos,((textlen(ms_string)
         - mn_beg_pos)+ 1),ms_string),
       mn_beg_pos = 1, mn_rem_len = (textlen(ms_string) - mn_beg_pos)
       IF (mn_rem_len < mn_max_print_len)
        ms_tmp_str = trim(ms_string), row + 1, ms_tmp_str
       ENDIF
     ENDWHILE
    ENDIF
    ms_tmp_str = ""
   ENDMACRO
   , ms_tmp_str = concat("**** Please Forward This Document to ",ms_faxto_name,".****"), col 0,
   row 0, ms_tmp_str, col 0,
   row + 1,
   "BAYSTATE MEDICAL CENTER PHYSICIAN DISCHARGE SUMMARY: This document is being automatically faxed",
   col 0,
   row + 1, "to the office of the primary care physician from Baystate Medical Center", col 0,
   row + 1,
   "If this patient is not under your care, please contact BMC Admitting Office ASAP to note", col 0,
   row + 1, "this incorrect assignment. ", row + 2
  DETAIL
   IF (textlen(trim(cb.blob_contents)) > 0)
    blob_size = cnvtint(cb.blob_length), blob_out_detail = fillstring(64000," "),
    blob_compressed_trimmed = fillstring(64000," "),
    blob_uncompressed = fillstring(64000," "), blob_rtf = fillstring(64000," "), blob_out_detail =
    fillstring(64000," "),
    blob_compressed_trimmed = trim(cb.blob_contents), blob_return_len = 0, blob_return_len2 = 0,
    ps_blob_out = fillstring(64000," ")
    IF (cb.compression_cd=mf_comp_cd)
     CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),blob_uncompressed,
     size(blob_uncompressed),blob_return_len), ps_blob_out = trim(blob_uncompressed,3)
    ELSEIF (cb.compression_cd=mf_no_comp_cd)
     ps_blob_out = trim(cb.blob_contents)
     IF (findstring("ocf_blob",ps_blob_out) > 0)
      ps_blob_out = trim(substring(1,(findstring("ocf_blob",ps_blob_out) - 1),ps_blob_out))
     ENDIF
    ENDIF
   ENDIF
   ps_blob_out = replace(ps_blob_out,char(10),""), ms_string = ps_blob_out, print_text
  WITH nocounter, maxcol = 80, maxrow = 10000
 ;end select
 IF (curqual < 1)
  SET log_message = concat("Data not found: ",cnvtstring(mf_clin_event_id))
  CALL sbr_log(log_message)
  CALL echo(log_message)
  GO TO exit_script
 ELSE
  CALL sbr_log("file written")
  CALL echo("file written")
 ENDIF
 SELECT INTO value(ms_fax_file_list)
  HEAD REPORT
   ps_tmp_str = concat("filename:",ms_file_name," pcpid:",trim(cnvtstring(mf_faxto_id))," pcpname:",
    trim(ms_faxto_name)), col 0, ps_tmp_str
  WITH nocounter, append
 ;end select
 IF (log_message="")
  CALL sbr_log(concat("File created: ",ms_file_name))
  SET log_message = concat("Success: ",cnvtstring(mf_clin_event_id))
  CALL sbr_log(log_message)
 ENDIF
 IF (retval=0)
  SET retval = 100
 ENDIF
#exit_script
 CALL sbr_log(concat("End Log (bhs_cnvt_powernotes): ",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d")))
 CALL echo(concat("log_message: ",log_message))
 SUBROUTINE sbr_log(ms_log_str)
  CALL echo("write to log")
  SELECT INTO value(ms_logfile_name)
   DETAIL
    col 0, row + 1, ms_log_str
   WITH nocounter, append
  ;end select
 END ;Subroutine
END GO
