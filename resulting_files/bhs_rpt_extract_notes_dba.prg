CREATE PROGRAM bhs_rpt_extract_notes:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Input Type:" = "1",
  "Source Directory:" = "",
  "Input-File Directory Full string:" = "",
  "Source File Name:" = "",
  "Beg DateTime:" = curdate,
  "End DateTime:" = curdate,
  "Select Note Types:" = 0,
  "Output Type:" = "3",
  "Target Directory:" = "",
  "Output Directory Full string:" = "",
  "Email (optional):" = ""
  WITH s_outdev, s_input_type, s_input_file_dir,
  s_input_file_dir_str, s_input_filename, s_begin_date,
  s_end_date, s_select_note_types, s_output_type,
  s_output_dir, s_output_dir_str, s_email
 DECLARE ms_backend_dir = vc WITH protect, constant(concat(trim(logical("CCLUSERDIR")),"/"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_no_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE mf_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE mf_cancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"CANCELLED"))
 DECLARE mf_in_error_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN ERROR"))
 DECLARE mf_inerror_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE mf_inerrnomut_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE mf_inerrornoview_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE ms_outdev = vc WITH protect, constant(trim( $S_OUTDEV))
 DECLARE ms_input_type = vc WITH protect, constant(trim( $S_INPUT_TYPE))
 DECLARE ms_input_file_dir = vc WITH protect, constant(concat(trim( $S_INPUT_FILE_DIR,3),"\\Input"))
 DECLARE ms_input_file_dir_str = vc WITH protect, constant(trim( $S_INPUT_FILE_DIR_STR,3))
 DECLARE ms_filename_in = vc WITH protect, constant(trim( $S_INPUT_FILENAME,3))
 DECLARE mf_beg_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate( $S_BEGIN_DATE),000000))
 DECLARE mf_end_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate( $S_END_DATE),235959))
 DECLARE ms_output_type = vc WITH protect, constant(trim( $S_OUTPUT_TYPE))
 DECLARE ms_output_dir = vc WITH protect, constant(trim( $S_OUTPUT_DIR,3))
 DECLARE ms_output_dir_str = vc WITH protect, constant(trim( $S_OUTPUT_DIR_STR,3))
 DECLARE ms_email = vc WITH protect, constant(trim( $S_EMAIL,3))
 DECLARE ms_output_sub_fold = vc WITH protect, noconstant("")
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 DECLARE ms_log = vc WITH protect, noconstant("")
 DECLARE mc_list_check = c1 WITH protect, noconstant("")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_index_filename = vc WITH protect, noconstant("")
 DECLARE ms_output_type_st = vc WITH protect, noconstant("")
 DECLARE ms_input_summary = vc WITH protect, noconstant("")
 DECLARE ms_blob_rtf = vc WITH protect, noconstant("")
 DECLARE ms_tmp = vc WITH protect, noconstant("")
 DECLARE ms_filename_out = vc WITH protect, noconstant("")
 DECLARE ms_filetype = vc WITH protect, noconstant("")
 DECLARE ml_blob_len = i4 WITH protect, noconstant(0)
 DECLARE ms_blob = vc WITH protect, noconstant("")
 DECLARE ms_addendum = vc WITH protect, noconstant("")
 DECLARE ml_header = i4 WITH protect, noconstant(0)
 DECLARE mn_any_note_type_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_list = i4 WITH protect, noconstant(0)
 DECLARE ml_encounter_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_note_type_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_note = i4 WITH protect, noconstant(0)
 DECLARE ml_ver = i4 WITH protect, noconstant(0)
 DECLARE ml_blob = i4 WITH protect, noconstant(0)
 DECLARE ml_note_total = i4 WITH protect, noconstant(0)
 DECLARE ml_patient_total = i4 WITH protect, noconstant(0)
 FREE RECORD m_select_notes
 RECORD m_select_notes(
   1 select_notes[*]
     2 f_select_note = f8
 ) WITH protect
 IF (ms_input_type="1"
  AND ((ms_filename_in="") OR (ms_input_file_dir="\Input")) )
  SET ms_log = " Please enter a valid directory and/or filename when 'Input File' has been selected."
  GO TO exit_script
 ENDIF
 IF (ms_input_type IN ("2", "3")
  AND mf_beg_dt_tm > mf_end_dt_tm)
  SET ms_log = " Invalid dates - begin date must be less than end date."
  GO TO exit_script
 ENDIF
 IF (ms_output_type != "4"
  AND ms_output_dir <= "")
  SET ms_log = " Output file directory must be selected unless 'Summary' is selected."
  GO TO exit_script
 ENDIF
 IF (textlen(ms_email) > 0
  AND findstring("@bhs.org",cnvtlower(ms_email))=0
  AND findstring("@baystatehealth.org",cnvtlower(ms_email))=0)
  SET ms_log = " Email is invalid - must be a valid '@bhs.org' or '@baystatehealth.org' address."
  GO TO exit_script
 ENDIF
 SET mc_list_check = substring(1,1,reflect(parameter(8,0)))
 SET ms_output_sub_fold = replace(ms_output_dir_str,
  "\\bhsdata01\data$\BH AppTech Quality Measures\Cerner Clinical Notes","clinicalnotes")
 SET ms_output_sub_fold = replace(ms_output_dir_str,
  "S:\BH AppTech Quality Measures\Cerner Clinical Notes","clinicalnotes")
 IF (mc_list_check="L")
  WHILE (mc_list_check > " ")
    SET ml_cnt = (ml_cnt+ 1)
    SET mc_list_check = substring(1,1,reflect(parameter(8,ml_cnt)))
    IF (mc_list_check > " ")
     IF (mod(ml_cnt,5)=1)
      CALL alterlist(m_select_notes->select_notes,(ml_cnt+ 4))
     ENDIF
     SET m_select_notes->select_notes[ml_cnt].f_select_note = parameter(8,ml_cnt)
    ENDIF
  ENDWHILE
  SET ml_cnt = (ml_cnt - 1)
  CALL alterlist(m_select_notes->select_notes,ml_cnt)
 ELSEIF (mc_list_check="F")
  CALL alterlist(m_select_notes->select_notes,1)
  SET m_select_notes->select_notes[1].f_select_note =  $S_SELECT_NOTE_TYPES
 ELSEIF (mc_list_check="C")
  SET mn_any_note_type_ind = 1
 ELSE
  SET ms_log = "Error - Unexpected Type Found"
  GO TO exit_script
 ENDIF
 IF (ms_input_type="1")
  SET ms_dclcom = concat("$cust_script/bhs_ftp_get_file.ksh ",ms_filename_in,
   " 172.17.10.5 'bhs/cisftp' C!sftp01 ","'",ms_backend_dir,
   "' ","'",ms_input_file_dir,"'")
  CALL echo(ms_dclcom)
  CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
  CALL echo(ml_stat)
  EXECUTE kia_dm_dbimport ms_filename_in, "bhs_rpt_extract_notes_child", 500,
  0
 ELSE
  EXECUTE bhs_rpt_extract_notes_child
 ENDIF
#exit_script
 SELECT INTO value(ms_outdev)
  FROM dummyt d
  HEAD REPORT
   col 0, ms_log, row + 1
  WITH formfeed = none, maxrow = 1, maxcol = 30000
 ;end select
END GO
