CREATE PROGRAM cv_get_harvest_output_acc3:dba
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_date = vc WITH protect, constant("31-DEC-2100 00:00:00")
  DECLARE cv_log_debug = i4 WITH protect, constant(4)
  DECLARE cv_log_info = i4 WITH protect, constant(3)
  DECLARE cv_log_audit = i4 WITH protect, constant(2)
  DECLARE cv_log_warning = i4 WITH protect, constant(1)
  DECLARE cv_log_error = i4 WITH protect, constant(0)
  DECLARE cv_log_handle_cnt = i4 WITH protect, noconstant(1)
  DECLARE cv_log_handle = i4 WITH protect
  DECLARE cv_log_status = i4 WITH protect
  DECLARE cv_log_error_file = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_string = c32000 WITH protect, noconstant(fillstring(32000," "))
  DECLARE cv_err_msg = c100 WITH protect, noconstant(fillstring(100," "))
  DECLARE cv_log_err_num = i4 WITH protect
  DECLARE cv_log_file_name = vc WITH protect, noconstant(build("cer_temp:CV_DEFAULT",format(
     cnvtdatetime(curdate,curtime3),"HHMMSS;;q"),".dat"))
  DECLARE cv_log_struct_file_name = vc WITH protect, noconstant(build("cer_temp:",curprog))
  DECLARE cv_log_struct_file_nbr = i4 WITH protect
  DECLARE cv_log_event = vc WITH protect, noconstant("CV_DEFAULT_LOG")
  DECLARE cv_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_def_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_log_echo_level = i4 WITH protect, noconstant(cv_log_debug)
  SET cv_log_level = reqdata->loglevel
  SET cv_def_log_level = reqdata->loglevel
  SET cv_log_echo_level = reqdata->loglevel
  IF (cv_log_level >= cv_log_info)
   SET cv_log_error_file = 1
  ELSE
   SET cv_log_error_file = 0
  ENDIF
  DECLARE cv_log_chg_to_default = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_time = i4 WITH protect, noconstant(1)
  DECLARE serrmsg = c132 WITH protect, noconstant(fillstring(132," "))
  DECLARE ierrcode = i4 WITH protect
  DECLARE cv_chk_err_label = vc WITH protect, noconstant("EXIT_SCRIPT")
  DECLARE num_event = i4 WITH protect
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt = (cv_log_handle_cnt+ 1)
 ENDIF
 DECLARE cv_log_createhandle(dummy=i2) = null
 SUBROUTINE cv_log_createhandle(dummy)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 DECLARE cv_log_current_default(dummy=i2) = null
 SUBROUTINE cv_log_current_default(dummy)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
 DECLARE cv_echo(string=vc) = null
 SUBROUTINE cv_echo(string)
   IF (cv_log_echo_level >= cv_log_audit)
    CALL echo(string)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message(log_message_param=vc) = null
 SUBROUTINE cv_log_message(log_message_param)
   SET cv_log_err_num = (cv_log_err_num+ 1)
   SET cv_err_msg = fillstring(100," ")
   IF (cv_log_error_time=0)
    SET cv_err_msg = log_message_param
   ELSE
    SET cv_err_msg = build(log_message_param," at :",format(cnvtdatetime(curdate,curtime3),
      "@SHORTDATETIME"))
   ENDIF
   IF (cv_log_chg_to_default=1)
    SET cv_log_level = cv_def_log_level
   ENDIF
   IF (cv_log_echo_level > cv_log_audit)
    CALL echo(cv_err_msg)
   ENDIF
   IF (cv_log_error_file=1)
    SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message_status(object_name_param=vc,operation_status_param=c1,operation_name_param=vc,
  target_object_value_param=vc) = null
 SUBROUTINE cv_log_message_status(object_name_param,operation_status_param,operation_name_param,
  target_object_value_param)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event = (num_event+ 1)
     SET stat = alterlist(reply->status_data.subeventstatus,num_event)
     SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
      object_name_param)
     SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
     SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
      operation_name_param)
     SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
    ENDIF
   ELSE
    SET num_event = (num_event+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,num_event)
    SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
     object_name_param)
    SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
    SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
     operation_name_param)
    SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
   ENDIF
 END ;Subroutine
 DECLARE cv_check_err(opname=vc,opstatus=c1,targetname=vc) = null
 SUBROUTINE cv_check_err(opname,opstatus,targetname)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode=0)
    RETURN
   ENDIF
   WHILE (ierrcode != 0)
     CALL cv_log_message_status(targetname,opstatus,opname,serrmsg)
     CALL cv_log_message(serrmsg)
     SET ierrcode = error(serrmsg,0)
     SET reply->status_data.status = "F"
   ENDWHILE
   IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
    GO TO cv_chk_err_label
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
 ENDIF
 DECLARE cv_log_message_pre_vrsn = vc WITH private, constant("MOD 003 10/12/04 MH9140")
 DECLARE geteventcd(prmmeaning=vc) = f8
 DECLARE getcvcontrol(paramdatasetid=f8,paramuniquestring=vc) = i4
 DECLARE getseason(paramdatecd=f8) = c1
 DECLARE getcuryr(paramdatecd=f8) = i4
 DECLARE fmt_mean = c12 WITH protect
 DECLARE iret = i2 WITH protect
 DECLARE the_dta = f8 WITH protect
 DECLARE return_ec = f8 WITH protect
 DECLARE return_nbr = i4 WITH protect
 DECLARE fall_mean = c12 WITH protect
 DECLARE spring_mean = c12 WITH protect
 DECLARE fall_cd = f8 WITH protect
 DECLARE spring_cd = f8 WITH protect
 DECLARE fall_any_mean = c12 WITH protect
 DECLARE spring_any_mean = c12 WITH protect
 DECLARE fall_any_cd = f8 WITH protect
 DECLARE spring_any_cd = f8 WITH protect
 DECLARE cv_date_set = i4 WITH protect
 DECLARE retseason = c1 WITH protect
 DECLARE century19 = i2 WITH protect
 DECLARE century20 = i2 WITH protect
 DECLARE ret_yr = i4 WITH protect
 SUBROUTINE geteventcd(prmmeaning)
   IF (size(trim(prmmeaning)) > 12)
    CALL echo(build("String too long to be CDF meaning:",prmmeaning))
    RETURN(0.0)
   ENDIF
   SET fmt_mean = trim(prmmeaning)
   SET the_dta = 0.0
   SET return_ec = 0.0
   SET the_dta = uar_get_code_by("MEANING",14003,nullterm(fmt_mean))
   IF (the_dta=0.0)
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=14003
      AND cv.cdf_meaning=fmt_mean
      AND cv.active_ind=1
     DETAIL
      the_dta = cv.code_value
     WITH nocounter, maxqual(cv,1)
    ;end select
   ENDIF
   IF (the_dta=0.0)
    CALL echo(build("Could not locate CDF meaning in CS 14003:",fmt_mean))
    RETURN(0.0)
   ENDIF
   SELECT INTO "nl:"
    FROM discrete_task_assay dta
    WHERE dta.task_assay_cd=the_dta
    DETAIL
     return_ec = dta.event_cd
    WITH nocounter
   ;end select
   RETURN(return_ec)
 END ;Subroutine
 SUBROUTINE getcvcontrol(paramdatasetid,paramuniquestring)
   SET return_nbr = 0
   SELECT INTO "nl:"
    FROM dm_prefs dp
    WHERE dp.pref_domain IN ("CVNET", "CVNet")
     AND dp.parent_entity_id=paramdatasetid
     AND dp.parent_entity_name="CV_DATASET"
     AND cnvtupper(trim(dp.pref_section,3))=cnvtupper(trim(paramuniquestring,3))
    DETAIL
     return_nbr = dp.pref_nbr
    WITH nocounter
   ;end select
   RETURN(return_nbr)
 END ;Subroutine
 SUBROUTINE getseason(paramdatecd)
   SET cv_date_set = 25832
   SET fall_mean = "FALLCURYEAR"
   SET spring_mean = "SPRINGCURYR"
   SET fall_any_mean = "FALLANYYEAR"
   SET spring_any_mean = "SPRINGANYYR"
   SET spring_cd = uar_get_code_by("MEANING",cv_date_set,spring_mean)
   SET fall_cd = uar_get_code_by("MEANING",cv_date_set,fall_mean)
   SET spring_any_cd = uar_get_code_by("MEANING",cv_date_set,spring_any_mean)
   SET fall_any_cd = uar_get_code_by("MEANING",cv_date_set,fall_any_mean)
   IF (((spring_cd=paramdatecd) OR (spring_any_cd=paramdatecd)) )
    SET retseason = "S"
   ENDIF
   IF (((fall_cd=paramdatecd) OR (fall_any_cd=paramdatecd)) )
    SET retseason = "F"
   ENDIF
   RETURN(retseason)
 END ;Subroutine
 SUBROUTINE getcuryr(paramdatecd)
   SET century19 = 0
   SET century20 = 0
   SET cv_date_set = 25832
   SET fall_mean = "FALLCURYEAR"
   SET spring_mean = "SPRINGCURYR"
   SET fall_any_mean = "FALLANYYEAR"
   SET spring_any_mean = "SPRINGANYYR"
   SET spring_cd = uar_get_code_by("MEANING",cv_date_set,spring_mean)
   SET fall_cd = uar_get_code_by("MEANING",cv_date_set,fall_mean)
   SET spring_any_cd = uar_get_code_by("MEANING",cv_date_set,spring_any_mean)
   SET fall_any_cd = uar_get_code_by("MEANING",cv_date_set,fall_any_mean)
   IF (((spring_cd=paramdatecd) OR (fall_cd=paramdatecd)) )
    SET ret_yr = 0
   ENDIF
   IF (((spring_any_cd=paramdatecd) OR (fall_any_cd=paramdatecd)) )
    SET paramdatedisp = uar_get_code_display(paramdatecd)
    SET century19 = findstring("19",trim(paramdatedisp,3))
    SET century20 = findstring("20",trim(paramdatedisp,3))
    IF (century19 > 0)
     SET ret_yr = cnvtint(substring(century19,4,trim(paramdatedisp,3)))
    ELSEIF (century20 > 0)
     SET ret_yr = cnvtint(substring(century20,4,trim(paramdatedisp,3)))
    ELSE
     SET ret_yr = 0
    ENDIF
   ENDIF
   RETURN(ret_yr)
 END ;Subroutine
 DECLARE proccnt_str = vc WITH protect
 DECLARE patid_str = vc WITH protect
 DECLARE admitdt_str = vc WITH protect
 DECLARE patmrn_str = vc WITH protect
 DECLARE patfin_str = vc WITH protect
 DECLARE mrn_cd = f8 WITH protect
 DECLARE fin_cd = f8 WITH protect
 DECLARE procdt_ec = f8 WITH protect
 DECLARE med_cnt = i4 WITH protect
 DECLARE g_proc_cnt = i4 WITH protect
 DECLARE les_cnt = i4 WITH protect
 DECLARE icdev_cnt = i4 WITH protect
 DECLARE file_icdev_nbr = i4 WITH protect, constant(9)
 DECLARE file_lesion_nbr = i4 WITH protect, constant(8)
 DECLARE file_pci_nbr = i4 WITH protect, constant(7)
 DECLARE file_diagcath_nbr = i4 WITH protect, constant(6)
 DECLARE file_closuredev_nbr = i4 WITH protect, constant(5)
 DECLARE file_labvisit_nbr = i4 WITH protect, constant(4)
 DECLARE file_patmed_nbr = i4 WITH protect, constant(3)
 DECLARE file_admitdisch_nbr = i4 WITH protect, constant(2)
 DECLARE file_administrative_nbr = i4 WITH protect, constant(1)
 DECLARE num_clos_abstr_data = i4 WITH protect, constant(2)
 DECLARE num_les_abstr_data = i4 WITH protect, constant(40)
 DECLARE pci_proc_nbr = i4 WITH protect
 DECLARE file_nbr = i4 WITH protect
 DECLARE file_cnt = i4 WITH protect
 DECLARE row_cnt = i4 WITH protect
 DECLARE row_nbr = i4 WITH protect
 DECLARE myrow = vc WITH protect
 DECLARE position = i4 WITH protect
 DECLARE char_pos = i4 WITH protect
 DECLARE len = i4 WITH protect
 DECLARE delim_size = i4 WITH protect
 DECLARE abs_cnt = i4 WITH protect
 DECLARE hrv_rec_nbr = i4 WITH protect, noconstant(1)
 DECLARE raw_ind = i2 WITH protect, noconstant(- (1))
 DECLARE raw_const = i4 WITH protect, constant(9)
 DECLARE max_loop = i2 WITH protect
 DECLARE file_icdev_cnt = i4 WITH protect
 DECLARE file_les_cnt = i4 WITH protect
 SET file_cnt = size(ofilerec->rec,5)
 FREE RECORD file_data
 RECORD file_data(
   1 file[*]
     2 use = i2
     2 position_cnt = i4
     2 positions[*]
       3 xref_id = f8
       3 display_name = vc
 )
 SET stat = alterlist(file_data->file,file_cnt)
 IF (file_cnt=18)
  SET raw_ind = 1
 ELSEIF (file_cnt=9)
  SET raw_ind = 0
 ELSE
  CALL cv_log_message("Not a valid ACCv3 case.")
 ENDIF
 FREE RECORD cv_out
 RECORD cv_out(
   1 file[*]
     2 row[*]
       3 field[*]
         4 value = vc
 )
 SELECT INTO "nl:"
  position_idx = xf.position
  FROM (dummyt d  WITH seq = value(file_cnt)),
   cv_xref_field xf
  PLAN (d)
   JOIN (xf
   WHERE (xf.file_id=ofilerec->rec[d.seq].file_id)
    AND xf.position > 0)
  ORDER BY d.seq, position_idx DESC
  HEAD d.seq
   file_data->file[d.seq].position_cnt = position_idx, stat = alterlist(file_data->file[d.seq].
    positions,position_idx)
  DETAIL
   file_data->file[d.seq].positions[position_idx].xref_id = xf.xref_id, file_data->file[d.seq].
   positions[position_idx].display_name = xf.display_name
  FOOT  d.seq
   col 0
  WITH nocounter
 ;end select
 CALL echo(build("size(cv_hrv_rec->harvest_rec) ===>",size(cv_hrv_rec->harvest_rec,5)))
 SET mrn_cd = uar_get_code_by("MEANING",4,"MRN")
 IF (mrn_cd <= 0.0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=4
    AND cv.active_ind=1
    AND cv.cdf_meaning="MRN"
   DETAIL
    mrn_cd = cv.code_value
   WITH nocounter
  ;end select
 ENDIF
 SET fin_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 IF (fin_cd <= 0.0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=319
    AND cv.active_ind=1
    AND cv.cdf_meaning="FIN NBR"
   DETAIL
    fin_cd = cv.code_value
   WITH nocounter
  ;end select
 ENDIF
 FOR (hrv_rec_nbr = 1 TO size(cv_hrv_rec->harvest_rec,5))
   SET admitdt_str = format(cv_hrv_rec->harvest_rec[hrv_rec_nbr].admit_dt_tm,"MM/DD/YYYY;;D")
   SET patid_str = trim(cnvtstring(cv_hrv_rec->harvest_rec[hrv_rec_nbr].person_id))
   SET patmrn_str = " "
   SET patfin_str = " "
   SELECT INTO "nl:"
    FROM encounter e,
     location l,
     org_alias_pool_reltn o,
     person_alias p
    PLAN (e
     WHERE (e.encntr_id=cv_hrv_rec->harvest_rec[hrv_rec_nbr].encntr_id))
     JOIN (l
     WHERE l.location_cd=e.loc_facility_cd
      AND l.active_ind=1
      AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (o
     WHERE o.organization_id=l.organization_id
      AND o.alias_entity_alias_type_cd=mrn_cd
      AND o.alias_entity_name="PERSON_ALIAS"
      AND o.active_ind=1
      AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (p
     WHERE (p.person_id=cv_hrv_rec->harvest_rec[hrv_rec_nbr].person_id)
      AND p.alias_pool_cd=o.alias_pool_cd
      AND p.person_alias_type_cd=mrn_cd
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    DETAIL
     patmrn_str = trim(p.alias)
    WITH nocounter
   ;end select
   IF (size(patmrn_str) <= 0)
    SELECT INTO "nl:"
     FROM encntr_alias ea
     WHERE (ea.encntr_id=cv_hrv_rec->harvest_rec[hrv_rec_nbr].encntr_id)
      AND ea.encntr_alias_type_cd=mrn_cd
      AND ea.active_ind=1
      AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     DETAIL
      patmrn_str = trim(ea.alias)
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM encntr_alias ea
    WHERE (ea.encntr_id=cv_hrv_rec->harvest_rec[hrv_rec_nbr].encntr_id)
     AND ea.encntr_alias_type_cd=fin_cd
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     patfin_str = trim(ea.alias)
    WITH nocounter
   ;end select
   SET stat = alterlist(cv_out->file,file_cnt)
   SET abs_cnt = size(cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data,5)
   SET file_data->file[file_administrative_nbr].use = 0
   SET file_data->file[file_labvisit_nbr].use = 0
   SET file_data->file[file_closuredev_nbr].use = 0
   SET file_data->file[file_admitdisch_nbr].use = 0
   SET file_data->file[file_patmed_nbr].use = 0
   SET file_data->file[file_diagcath_nbr].use = 0
   SET file_data->file[file_pci_nbr].use = 0
   SET file_data->file[file_lesion_nbr].use = 0
   SET file_data->file[file_icdev_nbr].use = 0
   IF (raw_ind=1)
    SET file_data->file[(file_administrative_nbr+ raw_const)].use = 0
    SET file_data->file[(file_labvisit_nbr+ raw_const)].use = 0
    SET file_data->file[(file_closuredev_nbr+ raw_const)].use = 0
    SET file_data->file[(file_admitdisch_nbr+ raw_const)].use = 0
    SET file_data->file[(file_patmed_nbr+ raw_const)].use = 0
    SET file_data->file[(file_diagcath_nbr+ raw_const)].use = 0
    SET file_data->file[(file_pci_nbr+ raw_const)].use = 0
    SET file_data->file[(file_lesion_nbr+ raw_const)].use = 0
    SET file_data->file[(file_icdev_nbr+ raw_const)].use = 0
   ENDIF
   IF ((cv_hrv_rec->harvest_rec[hrv_rec_nbr].form_type_mean="ADMIT"))
    SET file_data->file[file_admitdisch_nbr].use = 1
    SET file_data->file[file_patmed_nbr].use = 1
    IF (raw_ind=1)
     SET file_data->file[(file_admitdisch_nbr+ raw_const)].use = 1
     SET file_data->file[(file_patmed_nbr+ raw_const)].use = 1
    ENDIF
   ELSEIF ((cv_hrv_rec->harvest_rec[hrv_rec_nbr].form_type_mean="LABVISIT"))
    SET g_proc_cnt = (g_proc_cnt+ 1)
    SET proccnt_str = cnvtstring(g_proc_cnt)
    SET file_data->file[file_labvisit_nbr].use = 1
    SET file_data->file[file_closuredev_nbr].use = 1
    IF (raw_ind=1)
     SET file_data->file[(file_labvisit_nbr+ raw_const)].use = 1
     SET file_data->file[(file_closuredev_nbr+ raw_const)].use = 1
    ENDIF
    FOR (abs_idx = 1 TO abs_cnt)
     CASE (cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data[abs_idx].task_assay_mean)
      OF "AC03LHCPROC":
      OF "AC03RHCPROC":
       IF ((cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data[abs_idx].result_val="Yes"))
        SET file_data->file[file_diagcath_nbr].use = 1
        IF (raw_ind=1)
         SET file_data->file[(file_diagcath_nbr+ raw_const)].use = 1
        ENDIF
       ENDIF
      OF "AC03PCIPROC":
       IF ((cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data[abs_idx].result_val="Yes"))
        SET file_data->file[file_pci_nbr].use = 1
        SET file_data->file[file_lesion_nbr].use = 1
        SET file_data->file[file_icdev_nbr].use = 1
        IF (raw_ind=1)
         SET file_data->file[(file_pci_nbr+ raw_const)].use = 1
         SET file_data->file[(file_lesion_nbr+ raw_const)].use = 1
         SET file_data->file[(file_icdev_nbr+ raw_const)].use = 1
        ENDIF
       ENDIF
     ENDCASE
     CASE (cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data[abs_idx].abstr_data_name)
      OF "CV_LES_ABSTR_DATA":
      OF "IC_DEV_ABSTR_DATA":
       SET file_data->file[file_pci_nbr].use = 1
       SET file_data->file[file_lesion_nbr].use = 1
       SET file_data->file[file_icdev_nbr].use = 1
       IF (raw_ind=1)
        SET file_data->file[(file_pci_nbr+ raw_const)].use = 1
        SET file_data->file[(file_lesion_nbr+ raw_const)].use = 1
        SET file_data->file[(file_icdev_nbr+ raw_const)].use = 1
       ENDIF
     ENDCASE
    ENDFOR
   ELSE
    CALL cv_log_message("ERROR: invalid form_type_mean; can't determine correct output rows")
   ENDIF
   IF ((file_data->file[file_pci_nbr].use=1))
    SET pci_proc_nbr = size(cv_hrv_rec->harvest_rec[hrv_rec_nbr].proc_data,5)
   ELSE
    SET pci_proc_nbr = 0
   ENDIF
   CALL echo("Building output template")
   SELECT INTO "NL:"
    position_idx = xf.position, file_idx = d1.seq
    FROM (dummyt d1  WITH seq = file_cnt),
     cv_xref_field xf
    PLAN (d1
     WHERE (file_data->file[d1.seq].use=1))
     JOIN (xf
     WHERE (xf.file_id=ofilerec->rec[d1.seq].file_id))
    ORDER BY file_idx, position_idx DESC
    HEAD REPORT
     col 0
    HEAD file_idx
     stat = alterlist(cv_out->file[file_idx].row,1), stat = alterlist(cv_out->file[file_idx].row[1].
      field,file_data->file[file_idx].position_cnt)
    HEAD position_idx
     CASE (file_data->file[file_idx].positions[position_idx].display_name)
      OF "PATID":
       cv_out->file[file_idx].row[1].field[position_idx].value = patid_str,
       CALL echo(concat("Setting Patid = ",patid_str,":"))
      OF "ADMITDT":
       cv_out->file[file_idx].row[1].field[position_idx].value = admitdt_str
      OF "PROCCNT":
       cv_out->file[file_idx].row[1].field[position_idx].value = proccnt_str
      OF "PATMRN":
       cv_out->file[file_idx].row[1].field[position_idx].value = patmrn_str
      OF "PATFIN":
       cv_out->file[file_idx].row[1].field[position_idx].value = patfin_str
      ELSE
       FOR (abstr_data_idx = 1 TO size(cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data,5))
         IF ((xf.xref_id=cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data[abstr_data_idx].xref_id))
          IF (raw_ind=1
           AND file_idx > raw_const)
           cv_out->file[file_idx].row[1].field[position_idx].value = cv_hrv_rec->harvest_rec[
           hrv_rec_nbr].abstr_data[abstr_data_idx].result_val
          ELSE
           cv_out->file[file_idx].row[1].field[position_idx].value = cv_hrv_rec->harvest_rec[
           hrv_rec_nbr].abstr_data[abstr_data_idx].translated_value
          ENDIF
          abstr_data_idx = size(cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data,5)
         ENDIF
       ENDFOR
     ENDCASE
    DETAIL
     col 0
    FOOT  position_idx
     col 0
    FOOT  d1.seq
     col 0
    FOOT REPORT
     col 0
    WITH nocounter
   ;end select
   SET file_nbr = file_closuredev_nbr
   IF ((file_data->file[file_nbr].use=1))
    CALL echo("Adding Closure Device rows")
    IF (raw_ind=1)
     SET max_loop = 2
    ELSE
     SET max_loop = 1
    ENDIF
    FOR (loop_idx = 1 TO max_loop)
     SELECT INTO "NL:"
      position_idx = xf.position, cdev_idx = d1.seq
      FROM cv_xref_field xf,
       (dummyt d1  WITH seq = value(cv_hrv_rec->max_closdev))
      PLAN (xf
       WHERE (xf.file_id=ofilerec->rec[file_nbr].file_id))
       JOIN (d1
       WHERE d1.seq <= size(cv_hrv_rec->harvest_rec[hrv_rec_nbr].closuredevice,5))
      ORDER BY cdev_idx
      HEAD REPORT
       cdev_cnt = size(cv_hrv_rec->harvest_rec[hrv_rec_nbr].closuredevice,5), stat = alterlist(cv_out
        ->file[file_nbr].row,cdev_cnt)
      HEAD cdev_idx
       stat = alterlist(cv_out->file[file_nbr].row[cdev_idx].field,file_data->file[file_nbr].
        position_cnt)
       IF (cdev_idx > 1)
        FOR (field_idx = 1 TO file_data->file[file_nbr].position_cnt)
          cv_out->file[file_nbr].row[cdev_idx].field[field_idx].value = cv_out->file[file_nbr].row[1]
          .field[field_idx].value
        ENDFOR
       ENDIF
      DETAIL
       CASE (file_data->file[file_nbr].positions[position_idx].display_name)
        OF "PATID":
        OF "ADMITDT":
        OF "PROCCNT":
        OF "PATMRN":
        OF "PATFIN":
         col 0
        ELSE
         FOR (dev_abstr_idx = 1 TO size(cv_hrv_rec->harvest_rec[hrv_rec_nbr].closuredevice[cdev_idx].
          cd_abstr_data,5))
           IF ((xf.xref_id=cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data[cv_hrv_rec->harvest_rec[
           hrv_rec_nbr].closuredevice[cdev_idx].cd_abstr_data[dev_abstr_idx].abstr_data_idx].xref_id)
           )
            IF (file_nbr > raw_const)
             cv_out->file[file_nbr].row[cdev_idx].field[position_idx].value = cv_hrv_rec->
             harvest_rec[hrv_rec_nbr].abstr_data[cv_hrv_rec->harvest_rec[hrv_rec_nbr].closuredevice[
             cdev_idx].cd_abstr_data[dev_abstr_idx].abstr_data_idx].result_val
            ELSE
             cv_out->file[file_nbr].row[cdev_idx].field[position_idx].value = cv_hrv_rec->
             harvest_rec[hrv_rec_nbr].abstr_data[cv_hrv_rec->harvest_rec[hrv_rec_nbr].closuredevice[
             cdev_idx].cd_abstr_data[dev_abstr_idx].abstr_data_idx].translated_value
            ENDIF
           ENDIF
         ENDFOR
       ENDCASE
      FOOT  cdev_idx
       cv_out->file[file_nbr].row[cdev_idx].field[6].value = cnvtstring(cdev_idx)
      FOOT REPORT
       col 0
      WITH nocounter
     ;end select
     SET file_nbr = (file_nbr+ raw_const)
    ENDFOR
   ENDIF
   SET file_nbr = file_patmed_nbr
   SET med_cnt = 0
   IF ((file_data->file[file_nbr].use=1))
    IF (raw_ind=1)
     SET max_loop = 2
    ELSE
     SET max_loop = 1
    ENDIF
    FOR (loop_idx = 1 TO max_loop)
      SELECT INTO "NL:"
       position_idx = xf.position, display_name = xf.display_name, med_idx = d.seq
       FROM cv_xref_field xf,
        (dummyt d  WITH seq = value(cv_hrv_rec->max_abstr_data))
       PLAN (xf
        WHERE (xf.file_id=ofilerec->rec[file_nbr].file_id))
        JOIN (d
        WHERE d.seq <= size(cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data,5)
         AND (cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data[d.seq].task_assay_mean=patstring(
         "AC03MEDID*"))
         AND (cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data[d.seq].task_assay_mean != "AC03MEDID"))
       ORDER BY d.seq
       HEAD REPORT
        med_cnt = 0
       HEAD med_idx
        med_cnt = (med_cnt+ 1), stat = alterlist(cv_out->file[file_nbr].row,med_cnt), stat =
        alterlist(cv_out->file[file_nbr].row[med_cnt].field,file_data->file[file_nbr].position_cnt)
        IF (med_cnt > 1)
         stat = alterlist(cv_out->file[file_nbr].row,med_cnt), stat = alterlist(cv_out->file[file_nbr
          ].row[med_cnt].field,file_data->file[file_nbr].position_cnt)
         FOR (field_idx = 1 TO file_data->file[file_nbr].position_cnt)
           cv_out->file[file_nbr].row[med_cnt].field[field_idx].value = cv_out->file[file_nbr].row[1]
           .field[field_idx].value
         ENDFOR
        ENDIF
       DETAIL
        CASE (trim(display_name))
         OF "MEDID":
          cv_out->file[file_nbr].row[med_cnt].field[position_idx].value = cnvtstring(cnvtint(
            substring(10,3,cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data[d.seq].task_assay_mean)))
         OF "MEDNAME":
          IF (file_nbr > raw_const)
           cv_out->file[file_nbr].row[med_cnt].field[position_idx].value = uar_get_code_display(
            cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data[d.seq].task_assay_cd)
          ENDIF
         OF "MEDADMIN":
          IF (file_nbr > raw_const)
           cv_out->file[file_nbr].row[med_cnt].field[position_idx].value = cv_hrv_rec->harvest_rec[
           hrv_rec_nbr].abstr_data[d.seq].result_val
          ELSE
           cv_out->file[file_nbr].row[med_cnt].field[position_idx].value = cv_hrv_rec->harvest_rec[
           hrv_rec_nbr].abstr_data[d.seq].translated_value
          ENDIF
        ENDCASE
       FOOT  med_idx
        col 0
       WITH nocounter
      ;end select
      IF (med_cnt=0)
       SET stat = alterlist(cv_out->file[file_nbr].row,0)
      ENDIF
      SET file_nbr = (file_nbr+ raw_const)
    ENDFOR
   ENDIF
   SET file_nbr = file_lesion_nbr
   SET file_icdev_cnt = file_icdev_nbr
   SET file_les_cnt = file_lesion_nbr
   IF ((file_data->file[file_nbr].use=1))
    IF (raw_ind=1)
     SET max_loop = 2
    ELSE
     SET max_loop = 1
    ENDIF
    FOR (loop_idx = 1 TO max_loop)
      SELECT INTO "NL:"
       position_idx = xf.position, les_idx = d1.seq
       FROM cv_xref_field xf,
        (dummyt d1  WITH seq = value(cv_hrv_rec->max_lesion))
       PLAN (xf
        WHERE (xf.file_id=ofilerec->rec[file_nbr].file_id))
        JOIN (d1
        WHERE d1.seq <= size(cv_hrv_rec->harvest_rec[hrv_rec_nbr].proc_data[pci_proc_nbr].lesion,5))
       ORDER BY les_idx, position_idx
       HEAD REPORT
        l_hrv_les_abstr_idx = 0, l_hrv_dev_abstr_idx = 0, icdev_cnt = 0,
        les_cnt = size(cv_hrv_rec->harvest_rec[hrv_rec_nbr].proc_data[pci_proc_nbr].lesion,5), stat
         = alterlist(cv_out->file[file_nbr].row,les_cnt)
       HEAD les_idx
        stat = alterlist(cv_out->file[file_nbr].row[les_idx].field,file_data->file[file_nbr].
         position_cnt)
        IF (les_idx > 1)
         FOR (field_idx = 1 TO file_data->file[file_nbr].position_cnt)
           cv_out->file[file_nbr].row[les_idx].field[field_idx].value = cv_out->file[file_nbr].row[1]
           .field[field_idx].value
         ENDFOR
        ENDIF
        this_lesion_dev_cnt = size(cv_hrv_rec->harvest_rec[hrv_rec_nbr].proc_data[pci_proc_nbr].
         lesion[les_idx].icdevice,5)
        IF (this_lesion_dev_cnt > 0)
         stat = alterlist(cv_out->file[file_icdev_cnt].row,(icdev_cnt+ this_lesion_dev_cnt))
         FOR (icdev_idx = 1 TO this_lesion_dev_cnt)
           output_dev_idx = (icdev_cnt+ icdev_idx), stat = alterlist(cv_out->file[file_icdev_cnt].
            row[output_dev_idx].field,file_data->file[file_icdev_cnt].position_cnt)
           FOR (field_idx = 1 TO file_data->file[file_icdev_cnt].position_cnt)
             cv_out->file[file_icdev_cnt].row[output_dev_idx].field[field_idx].value = cv_out->file[
             file_icdev_cnt].row[1].field[field_idx].value
           ENDFOR
           this_device_abstr_cnt = size(cv_hrv_rec->harvest_rec[hrv_rec_nbr].proc_data[pci_proc_nbr].
            lesion[les_idx].icdevice[icdev_idx].icd_abstr_data,5)
           FOR (ic_position_idx = 1 TO file_data->file[file_icdev_cnt].position_cnt)
             CASE (trim(file_data->file[file_icdev_cnt].positions[ic_position_idx].display_name))
              OF "PROCCNT":
              OF "ADMITDT":
              OF "PATID":
              OF "PATMRN":
              OF "PATFIN":
               col 0
              OF "LESCNT":
               cv_out->file[file_icdev_cnt].row[output_dev_idx].field[ic_position_idx].value =
               cnvtstring(les_idx)
              OF "DEVCNT":
               cv_out->file[file_icdev_cnt].row[output_dev_idx].field[ic_position_idx].value =
               cnvtstring(icdev_idx)
              ELSE
               FOR (icdev_abstr_idx = 1 TO this_device_abstr_cnt)
                l_hrv_dev_abstr_idx = cv_hrv_rec->harvest_rec[hrv_rec_nbr].proc_data[pci_proc_nbr].
                lesion[les_idx].icdevice[icdev_idx].icd_abstr_data[icdev_abstr_idx].abstr_data_idx,
                IF ((file_data->file[file_icdev_cnt].positions[ic_position_idx].xref_id=cv_hrv_rec->
                harvest_rec[hrv_rec_nbr].abstr_data[l_hrv_dev_abstr_idx].xref_id))
                 IF (file_icdev_cnt > raw_const)
                  cv_out->file[file_icdev_cnt].row[output_dev_idx].field[ic_position_idx].value =
                  cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data[l_hrv_dev_abstr_idx].result_val
                 ELSE
                  cv_out->file[file_icdev_cnt].row[output_dev_idx].field[ic_position_idx].value =
                  cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data[l_hrv_dev_abstr_idx].
                  translated_value
                 ENDIF
                ENDIF
               ENDFOR
             ENDCASE
           ENDFOR
         ENDFOR
         icdev_cnt = (icdev_cnt+ this_lesion_dev_cnt)
        ENDIF
       DETAIL
        CASE (file_data->file[file_les_cnt].positions[position_idx].display_name)
         OF "PROCCNT":
         OF "ADMITDT":
         OF "PATID":
         OF "PATMRN":
         OF "PATFIN":
          col 0
         OF "LESCNT":
          cv_out->file[file_les_cnt].row[les_idx].field[position_idx].value = cnvtstring(les_idx)
         ELSE
          FOR (les_abstr_idx = 1 TO size(cv_hrv_rec->harvest_rec[hrv_rec_nbr].proc_data[pci_proc_nbr]
           .lesion[les_idx].les_abstr_data,5))
           l_hrv_les_abstr_idx = cv_hrv_rec->harvest_rec[hrv_rec_nbr].proc_data[pci_proc_nbr].lesion[
           les_idx].les_abstr_data[les_abstr_idx].abstr_data_idx,
           IF ((xf.xref_id=cv_hrv_rec->harvest_rec[hrv_rec_nbr].abstr_data[l_hrv_les_abstr_idx].
           xref_id))
            IF (file_nbr > raw_const)
             cv_out->file[file_nbr].row[les_idx].field[position_idx].value = cv_hrv_rec->harvest_rec[
             hrv_rec_nbr].abstr_data[l_hrv_les_abstr_idx].result_val
            ELSE
             cv_out->file[file_nbr].row[les_idx].field[position_idx].value = cv_hrv_rec->harvest_rec[
             hrv_rec_nbr].abstr_data[l_hrv_les_abstr_idx].translated_value
            ENDIF
           ENDIF
          ENDFOR
        ENDCASE
       FOOT  les_idx
        cv_out->file[file_nbr].row[les_idx].field[6].value = cnvtstring(les_idx)
       FOOT REPORT
        col 0
       WITH nocounter
      ;end select
      IF (icdev_cnt=0)
       SET stat = alterlist(cv_out->file[file_icdev_cnt].row,0)
      ENDIF
      SET file_nbr = (file_nbr+ raw_const)
      SET file_icdev_cnt = (file_icdev_cnt+ raw_const)
      SET file_les_cnt = (file_les_cnt+ raw_const)
    ENDFOR
   ENDIF
   SET myrow = fillstring(2000,"_")
   SET file_cnt = 0
   SET stat = alterlist(cv_hrv_rec->harvest_rec[hrv_rec_nbr].files,filecnt)
   FOR (file_nbr = 2 TO size(cv_out->file,5))
     IF ((file_nbr != (1+ raw_const)))
      CALL echo(build("Generating file_nbr=",file_nbr))
      SET file_cnt = file_nbr
      SET row_cnt = size(cv_out->file[file_nbr].row,5)
      SET delim_size = size(trim(ofilerec->rec[file_nbr].delimiter))
      IF ((cv_hrv_rec->max_file_rows < row_cnt))
       SET cv_hrv_rec->max_file_rows = row_cnt
      ENDIF
      IF (row_cnt > 0)
       SET cv_hrv_rec->harvest_rec[hrv_rec_nbr].files[file_cnt].dataset_file_id = ofilerec->rec[
       file_nbr].file_id
       SET stat = alterlist(cv_hrv_rec->harvest_rec[hrv_rec_nbr].files[file_cnt].file_row,row_cnt)
       FOR (row_idx = 1 TO row_cnt)
         IF ((file_data->file[file_nbr].position_cnt > 2))
          SET myrow = fillstring(10000,"_")
          SET char_pos = 1
          FOR (position = 3 TO file_data->file[file_nbr].position_cnt)
            SET len = movestring(ofilerec->rec[file_nbr].delimiter,1,myrow,char_pos,delim_size)
            SET char_pos = (char_pos+ len)
            SET len = size(trim(cv_out->file[file_nbr].row[row_idx].field[position].value))
            IF (len > 0)
             SET len = movestring(cv_out->file[file_nbr].row[row_idx].field[position].value,1,myrow,
              char_pos,len)
             SET char_pos = (char_pos+ len)
            ENDIF
          ENDFOR
          IF (char_pos > 1)
           SET cv_hrv_rec->harvest_rec[hrv_rec_nbr].files[file_cnt].file_row[row_idx].line =
           substring(1,(char_pos - 1),myrow)
          ELSE
           SET cv_hrv_rec->harvest_rec[hrv_rec_nbr].files[file_cnt].file_row[row_idx].line = "Error"
          ENDIF
         ELSE
          SET cv_hrv_rec->harvest_rec[hrv_rec_nbr].files[file_cnt].file_row[row_idx].line = "Error"
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
   SET stat = alterlist(cv_out->file,0)
 ENDFOR
 DECLARE cv_log_destroyhandle(dummy=i2) = null
 CALL cv_log_destroyhandle(0)
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message(build("Leaving ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
  CALL cv_log_message(build("****************","The Error Log File is :",cv_log_file_name))
  EXECUTE cv_log_flush_message
 ENDIF
 SUBROUTINE cv_log_destroyhandle(dummy)
   IF ( NOT (validate(cv_log_handle_cnt,0)))
    CALL echo("Error Handle not created!!!")
   ELSE
    SET cv_log_handle_cnt = (cv_log_handle_cnt - 1)
   ENDIF
 END ;Subroutine
 DECLARE cv_get_harvest_output_acc3_vrsn = vc WITH private, constant("001 BM9013 05/23/2007")
END GO
