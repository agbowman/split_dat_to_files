CREATE PROGRAM bhs_fax_powernotes:dba
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD m_files
 RECORD m_files(
   1 files[*]
     2 s_file_name = vc
     2 s_pcp_id = vc
     2 s_pcp_name = vc
     2 s_fax_ind = i2
 )
 DECLARE ms_file_list_name = vc WITH protect, noconstant("autofax_file_list.dat")
 DECLARE ms_rtl_file = vc WITH protect, noconstant(" ")
 DECLARE ms_line = vc WITH protect, noconstant("")
 DECLARE mn_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_dclcom_str = vc WITH protect, noconstant("")
 DECLARE mn_dclcom_len = i4 WITH protect, noconstant(0)
 DECLARE mn_dclcom_stat = i4 WITH protect, noconstant(0)
 DECLARE ms_old_file_name = vc WITH proetct, noconstant("")
 DECLARE ms_new_file_name = vc WITH protect, noconstant("")
 DECLARE ms_logfile_name = vc WITH protect, constant("bhscust:autofax_fax_logfile.dat")
 DECLARE mf_output_dest_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_fin_nbr = vc WITH protect, noconstant("")
 DECLARE mn_beg_pos = i4 WITH protect, noconstant(0)
 DECLARE mn_end_pos = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 DECLARE ms_email_filename = vc WITH protect, constant("autofax_email_file.dat")
 DECLARE ms_tmp_file_list = vc WITH protect, noconstant("autofax_tmp_file_list.dat")
 DECLARE mf_discharged_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",261,"DISCHARGED"))
 DECLARE sbr_log(ms_log_str=vc) = null
 CALL sbr_log(concat("Begin Log (bhs_fax_powernotes): ",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d")))
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
  CALL echo("output_dest_cd = 0: exiting")
  CALL sbr_log("output_dest_cd = 0: exiting")
  GO TO exit_script
 ELSE
  CALL echo(concat("output_dest_cd = ",trim(cnvtstring(mf_output_dest_cd))))
  CALL sbr_log(concat("output_dest_cd = ",trim(cnvtstring(mf_output_dest_cd))))
 ENDIF
 IF (findfile(concat("bhscust:",ms_file_list_name))=0)
  CALL echo(concat(ms_file_list_name," not found: exit"))
  CALL sbr_log(concat(ms_file_list_name," not found: exit"))
  GO TO exit_script
 ENDIF
 CALL parser(concat('set logical ms_rtl_file "bhscust:',ms_file_list_name,'" go'))
 FREE DEFINE rtl2
 DEFINE rtl2 "ms_rtl_file"
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   pn_file_cnt = 0, pn_beg_pos = 0, pn_end_pos = 0,
   pn_line_len = 0,
   CALL echo("reading file")
  DETAIL
   pn_file_cnt = (pn_file_cnt+ 1)
   IF (pn_file_cnt > size(m_files->files,5))
    stat = alterlist(m_files->files,(pn_file_cnt+ 10))
   ENDIF
   CALL echo(t.line), ms_line = "", ms_line = trim(t.line),
   pn_line_len = textlen(ms_line)
   IF (findstring("filename:",ms_line)=0)
    CALL echo("filename not found")
   ELSE
    pn_beg_pos = (findstring(":",ms_line,1)+ 1), pn_end_pos = findstring(".dat",ms_line,pn_beg_pos),
    m_files->files[pn_file_cnt].s_file_name = substring(pn_beg_pos,(pn_end_pos - pn_beg_pos),ms_line),
    pn_beg_pos = 0, pn_beg_pos = (findstring(":",ms_line,pn_end_pos)+ 1), pn_end_pos = findstring(
     " pcpname",ms_line,pn_beg_pos),
    m_files->files[pn_file_cnt].s_pcp_id = substring(pn_beg_pos,((pn_end_pos - pn_beg_pos)+ 1),
     ms_line), pn_beg_pos = 0, pn_beg_pos = (findstring(":",ms_line,pn_end_pos)+ 1),
    pn_end_pos = pn_line_len, m_files->files[pn_file_cnt].s_pcp_name = substring(pn_beg_pos,((
     pn_end_pos - pn_beg_pos)+ 1),ms_line)
   ENDIF
  FOOT REPORT
   stat = alterlist(m_files->files,pn_file_cnt)
  WITH nocounter
 ;end select
 FREE DEFINE rtl2
 IF (size(m_files->files,5) > 0)
  CALL echo(concat(trim(cnvtstring(size(m_files->files,5)))," file(s) found"))
  CALL sbr_log(concat(trim(cnvtstring(size(m_files->files,5)))," file(s) found"))
 ELSE
  CALL echo("No files found: exit")
  CALL sbr_log("No files found: exit")
  GO TO exit_script
 ENDIF
 FOR (mn_loop_cnt = 1 TO size(m_files->files,5))
   SET ms_old_file_name = build("bhscust:",m_files->files[mn_loop_cnt].s_file_name,".dat")
   SET mn_beg_pos = (findstring("_",ms_old_file_name)+ 1)
   SET mn_end_pos = findstring(".dat",ms_old_file_name)
   SET ms_fin_nbr = substring(mn_beg_pos,(mn_end_pos - mn_beg_pos),ms_old_file_name)
   CALL echo(build("Fin:",ms_fin_nbr))
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
     m_files->files[mn_loop_cnt].s_fax_ind = 1
    WITH nocounter
   ;end select
   IF (curqual < 1)
    CALL echo(concat("Patient is not discharged.  File ",ms_old_file_name," not faxed."))
    CALL sbr_log(concat("Patient is not discharged.  File ",ms_old_file_name," not faxed."))
   ELSE
    CALL echo(concat("Patient is discharged.  Faxing file."))
    CALL sbr_log(concat("Patient is discharged.  Faxing file."))
    CALL sbr_log(concat("Processing file ",trim(cnvtstring(mn_loop_cnt))," of ",trim(cnvtstring(size(
         m_files->files,5)))))
    CALL sbr_log(concat("File name: ",ms_old_file_name))
    CALL sbr_log(concat("PCP ID: ",m_files->files[mn_loop_cnt].s_pcp_id))
    CALL sbr_log(concat("PCP Name: ",m_files->files[mn_loop_cnt].s_pcp_name))
    IF (findfile(ms_old_file_name)=1)
     CALL sbr_log("Found File")
     CALL sbr_log(concat("Faxing file: ",ms_old_file_name," to PCP ID: ",m_files->files[mn_loop_cnt].
       s_pcp_id," PCP Name: ",
       m_files->files[mn_loop_cnt].s_pcp_name))
     EXECUTE bhs_sys_send_fax m_files->files[mn_loop_cnt].s_file_name, m_files->files[mn_loop_cnt].
     s_pcp_id, mf_output_dest_cd
     SET ms_new_file_name = build("$bhscust/",m_files->files[mn_loop_cnt].s_file_name,".old")
     SET ms_old_file_name = build("$bhscust/",m_files->files[mn_loop_cnt].s_file_name,".dat")
     CALL sbr_log("Faxing complete - renaming file")
    ELSE
     CALL echo(concat("Unable to find file: ",ms_old_file_name))
     CALL sbr_log(concat("Unable to find file: ",ms_old_file_name))
    ENDIF
   ENDIF
 ENDFOR
 IF (findfile(concat("bhscust:",ms_email_filename))=1)
  CALL echo("found email file")
  CALL sbr_log("Found Email File")
  CALL echo("emailing 2")
  SET email_list = "joe.echols@bhs.org, naser.sanjar@bhs.org"
  SET ms_tmp_str = concat("Files Faxed ",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
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
 CALL sbr_log("Removing file list")
 SET stat = remove(concat("bhscust:",ms_file_list_name))
 IF (((stat=0) OR (findfile(concat("bhscust:",ms_file_list_name))=1)) )
  CALL echo("Unable to delete file list")
  CALL sbr_log("Unable to delete file list")
 ELSE
  CALL echo("File list deleted")
  CALL sbr_log("File list deleted")
 ENDIF
 SELECT INTO value(concat("bhscust:",ms_tmp_file_list))
  FROM (dummyt d  WITH seq = value(size(m_files->files,5)))
  PLAN (d
   WHERE (m_files->files[d.seq].s_fax_ind=0))
  DETAIL
   ms_tmp_str = build("filename:",m_files->files[d.seq].s_file_name,".dat pcpid:",m_files->files[d
    .seq].s_pcp_id," pcpname:",
    m_files->files[d.seq].s_pcp_name), col 0, ms_tmp_str,
   row + 1
  WITH nocounter
 ;end select
 SET ms_dclcom_str = concat("mv ",trim(logical("bhscust"),3),"/",ms_tmp_file_list," ",
  trim(logical("bhscust"),3),"/",ms_file_list_name)
 CALL echo(concat("ms_dcl_str: ",ms_dclcom_str))
 SET len = textlen(trim(ms_dclcom_str))
 SET status = 0
 SET stat = dcl(ms_dclcom_str,len,status)
 CALL echo(concat("mn_dcl_stat: ",trim(cnvtstring(status))," stat: ",trim(cnvtstring(stat))))
 IF (stat=1)
  CALL echo("File move complete")
 ELSE
  CALL echo("File not moved successfully")
 ENDIF
#exit_script
 FREE RECORD m_files
 CALL sbr_log(concat("End Log (bhs_fax_powernotes): ",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d")))
 SUBROUTINE sbr_log(ms_log_str)
   SELECT INTO value(ms_logfile_name)
    DETAIL
     col 0, row + 1, ms_log_str
    WITH nocounter, append
   ;end select
 END ;Subroutine
END GO
