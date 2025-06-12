CREATE PROGRAM dcp_apache_dump_ra:dba
 DECLARE meaning_code(p1,p2) = f8
 DECLARE mrn_cd = f8
 DECLARE fin_cd = f8
 DECLARE out_row = vc
 DECLARE tmp_full_ra_dump_file_name = vc
 DECLARE tmp_full_rad_dump_file_name = vc
 DECLARE tmp_full_rao_dump_file_name = vc
 DECLARE tmp_full_rat_dump_file_name = vc
 DECLARE tmp_full_rae_dump_file_name = vc
 DECLARE tmp_ra_dump_file_name = vc
 DECLARE tmp_rad_dump_file_name = vc
 DECLARE tmp_rao_dump_file_name = vc
 DECLARE tmp_rat_dump_file_name = vc
 DECLARE tmp_rae_dump_file_name = vc
 DECLARE full_ra_dump_file_name = vc
 DECLARE full_rad_dump_file_name = vc
 DECLARE full_rao_dump_file_name = vc
 DECLARE full_rat_dump_file_name = vc
 DECLARE full_rae_dump_file_name = vc
 DECLARE test_file_name = vc
 DECLARE rename_ra_cmd = vc
 DECLARE rename_rad_cmd = vc
 DECLARE rename_rao_cmd = vc
 DECLARE rename_rat_cmd = vc
 DECLARE rename_rae_cmd = vc
 DECLARE delete_temp_file_cmd = vc
 DECLARE failed_text = vc WITH noconstant(fillstring(100," ")), protect
 DECLARE failed_ind = vc WITH noconstant("N"), public
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD rpt_params(
   1 org_id = f8
   1 unit = f8
 )
 RECORD pat_list(
   1 cnt = i4
   1 pat_data[*]
     2 active_ind = i2
     2 risk_adjustment_id = f8
     2 encntr_id = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 adm_doc_id = f8
     2 admit_age = i4
     2 admit_diagnosis = vc
     2 admit_source = vc
     2 admitsource_flag = i2
     2 aids_ind = i2
     2 ami_location = vc
     2 bed_count = i4
     2 body_system = vc
     2 cc_during_stay_ind = i2
     2 chronic_health_none_ind = i2
     2 chronic_health_unavail_ind = i2
     2 cirrhosis_ind = i2
     2 copd_flag = i2
     2 copd_ind = i2
     2 diabetes_ind = i2
     2 dialysis_ind = i2
     2 diedinhospital_ind = i2
     2 diedinicu_ind = i2
     2 disease_category_cd = vc
     2 ejectfx_fraction = f8
     2 electivesurgery_ind = i2
     2 gender_flag = i2
     2 hepaticfailure_ind = i2
     2 hosp_admit_dt_tm = dq8
     2 hrs_at_source = i4
     2 icu_admit_dt_tm = dq8
     2 icu_disch_dt_tm = dq8
     2 ima_ind = i2
     2 immunosuppression_ind = i2
     2 leukemia_ind = i2
     2 lymphoma_ind = i2
     2 metastaticcancer_ind = i2
     2 mi_within_6mo_ind = i2
     2 midur_ind = i2
     2 nbr_grafts_performed = i4
     2 person_id = f8
     2 ptca_device = vc
     2 readmit_ind = i2
     2 readmit_within_24hr_ind = i2
     2 region_flag = i2
     2 sv_graft_ind = i2
     2 teach_type_flag = i2
     2 therapy_level = i4
     2 thrombolytics_ind = i2
     2 updt_applctx = i4
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 valid_from_dt_tm = dq8
     2 valid_until_dt_tm = dq8
     2 var03hspxlos_value = f8
     2 xfer_within_48hr_ind = i2
     2 e_disch_dt_tm = dq8
     2 el_loc_nurse_unit_cd = vc
     2 icu_disch_nurse_unit = vc
     2 chronic_health_wt = i4
     2 age_wt = i4
     2 post_op_b = vc
     2 e_disch_to_loctn_cd = vc
     2 e_doc_service_cd = vc
     2 pa_mrn = vc
     2 fin_nbr = vc
     2 pat_name_first = vc
     2 pat_name_last = vc
     2 doc_name_first = vc
     2 doc_name_last = vc
     2 pat_birth_dt_tm = dq8
     2 hospital_name = vc
     2 organization_id = f8
     2 pat_race_cd = f8
     2 ra_visit_number = i4
     2 el_loc_nurse_unit_id = f8
 )
 RECORD units(
   1 cnt = i4
   1 tot_bed_count = i4
   1 unit[*]
     2 code = f8
     2 name = vc
     2 bed_count = i4
 )
 EXECUTE FROM 1000_init TO 1000_init_exit
 EXECUTE FROM 2000_load_ref TO 2000_load_ref_exit
 IF (failed_ind="Y")
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM 3000_load_dump_path TO 3000_load_dump_path_exit
 IF (failed_ind="Y")
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM 3200_check_for_files TO 3200_check_for_files_exit
 IF (failed_ind="Y")
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM 3500_update_dump_date TO 3500_update_dump_date_exit
 IF (failed_ind="Y")
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM 4000_build_pat_list TO 4000_build_pat_list_exit
 IF ((pat_list->cnt=0))
  CALL echo("pat_list->cnt = 0;;; EXITING DUMP PROGRAM")
  SET failed_ind = "Z"
  SET failed_text = "No eligible patients qualify for extract."
  GO TO 9999_exit_program
 ENDIF
 IF (failed_ind="Y")
  GO TO 9999_exit_program
 ENDIF
 CALL echo("before dumps")
 EXECUTE FROM 5000_create_dumps TO 5099_create_dumps_exit
 IF (failed_ind="Y")
  GO TO 9999_exit_program
 ENDIF
 CALL echo("after dumps, before rename")
 EXECUTE FROM 8000_rename_files TO 8000_rename_files_exit
 CALL echo("after rename")
 GO TO 9999_exit_program
#1000_init
 SET rpt_params->org_id = - (1)
 SET rpt_params->unit = - (1)
 SET last_dt_tm_dumped = cnvtdatetime(curdate,curtime3)
 SET date_record_exist = ""
 SET dump_path = fillstring(200," ")
 SET mrn_cd = meaning_code(319,"MRN")
 SET tmp_full_ra_dump_file_name = fillstring(200," ")
 SET tmp_full_rad_dump_file_name = fillstring(200," ")
 SET tmp_full_rao_dump_file_name = fillstring(200," ")
 SET tmp_full_rat_dump_file_name = fillstring(200," ")
 SET tmp_full_rae_dump_file_name = fillstring(200," ")
 SET tmp_ra_dump_file_name = fillstring(200," ")
 SET tmp_rad_dump_file_name = fillstring(200," ")
 SET tmp_rao_dump_file_name = fillstring(200," ")
 SET tmp_rat_dump_file_name = fillstring(200," ")
 SET tmp_rae_dump_file_name = fillstring(200," ")
 SET full_ra_dump_file_name = fillstring(200," ")
 SET full_rad_dump_file_name = fillstring(200," ")
 SET full_rao_dump_file_name = fillstring(200," ")
 SET full_rat_dump_file_name = fillstring(200," ")
 SET full_rae_dump_file_name = fillstring(200," ")
 SET reply->status_data.status = "S"
 SET mrn_cd = meaning_code(319,"MRN")
 SET fin_cd = meaning_code(319,"FIN NBR")
#1000_init_exit
#2000_load_ref
 SELECT INTO "nl:"
  FROM risk_adjustment_ref rar,
   location l,
   location_group l1,
   location_group l2
  PLAN (rar
   WHERE rar.active_ind=1
    AND (rar.organization_id=rpt_params->org_id))
   JOIN (l
   WHERE l.organization_id=rar.organization_id
    AND l.icu_ind=1)
   JOIN (l1
   WHERE l1.active_ind=1
    AND l1.parent_loc_cd=l.location_cd
    AND l1.root_loc_cd=0)
   JOIN (l2
   WHERE l2.active_ind=1
    AND l2.parent_loc_cd=l1.child_loc_cd
    AND l2.root_loc_cd=0)
  ORDER BY rar.organization_id, l.location_cd
  HEAD REPORT
   unit_cnt = 0, tot_bed_cnt = 0, unit_bed_cnt = 0
  HEAD l.location_cd
   unit_cnt = (unit_cnt+ 1), stat = alterlist(units->unit,unit_cnt), units->unit[unit_cnt].code = l
   .location_cd,
   units->unit[unit_cnt].name = uar_get_code_display(l.location_cd), unit_bed_cnt = 0
  DETAIL
   tot_bed_cnt = (tot_bed_cnt+ 1), unit_bed_cnt = (unit_bed_cnt+ 1)
  FOOT  l.location_cd
   units->unit[unit_cnt].bed_count = unit_bed_cnt
  FOOT REPORT
   units->tot_bed_count = tot_bed_cnt, units->cnt = unit_cnt
  WITH nocounter
 ;end select
 SET loc_in_clause = fillstring(5000," ")
 IF ((units->cnt > 0))
  SET loc_in_clause = concat(" el.loc_nurse_unit_cd in (",trim(cnvtstring(units->unit[1].code)))
  FOR (cnt = 2 TO units->cnt)
    SET loc_in_clause = concat(trim(loc_in_clause),",",trim(cnvtstring(units->unit[cnt].code)))
  ENDFOR
  SET loc_in_clause = concat(trim(loc_in_clause),")")
 ELSEIF ((units->cnt=0))
  SET loc_in_clause = concat(trim(loc_in_clause),"0=0")
 ENDIF
 SET failed_ind = "N"
#2000_load_ref_exit
#3000_load_dump_path
 SET update_count = 0
 SET got_path = 0
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="APACHE"
    AND di.info_name="APACHE RA DUMP DATE-PATH")
  DETAIL
   last_dt_tm_dumped = di.info_date, dump_path = trim(di.info_char), update_count = di.updt_cnt,
   got_path = 1
  WITH nocounter
 ;end select
 IF (got_path=0)
  SET failed_ind = "Y"
  SET failed_text =
  "Unable to load extract location from dm_info table. Rerun DCP_APACHE_DM_INFO prompt program"
 ENDIF
 CALL echo(build("date last dumped = ",last_dt_tm_dumped))
 IF (size(trim(dump_path)) < 1)
  SET failed_ind = "Y"
  SET failed_text = concat("APACHE BO Extract location not defined")
 ELSE
  SET status = 0
  IF (((cursys="VMS") OR (cursys="AXP")) )
   SET loc_cmd = concat("set def ",trim(dump_path))
  ELSE
   SET loc_cmd = concat("cd ",trim(dump_path))
  ENDIF
  CALL echo(build("loc_cmd=",loc_cmd))
  SET cmd_siz = size(loc_cmd)
  SET loc_result = dcl(loc_cmd,cmd_siz,status)
  CALL echo(build("cmd_siz=",cmd_siz))
  CALL echo(build("loc_result=",loc_result))
  IF (loc_result != 1)
   SET failed_ind = "Y"
   SET failed_text = concat("APACHE BO Extract location not accessable. Path=",dump_path)
  ENDIF
 ENDIF
#3000_load_dump_path_exit
#3200_check_for_files
 IF (((cursys="VMS") OR (cursys="AXP")) )
  SET tmp_ra_dump_file_name = build(dump_path,"TMP_APACHE_RA_DUMP")
  SET tmp_rad_dump_file_name = build(dump_path,"TMP_APACHE_RAD_DUMP")
  SET tmp_rao_dump_file_name = build(dump_path,"TMP_APACHE_RAO_DUMP")
  SET tmp_rat_dump_file_name = build(dump_path,"TMP_APACHE_RAT_DUMP")
  SET tmp_rae_dump_file_name = build(dump_path,"TMP_APACHE_RAE_DUMP")
  SET tmp_full_ra_dump_file_name = build(dump_path,"TMP_APACHE_RA_DUMP.DAT")
  SET tmp_full_rad_dump_file_name = build(dump_path,"TMP_APACHE_RAD_DUMP.DAT")
  SET tmp_full_rao_dump_file_name = build(dump_path,"TMP_APACHE_RAO_DUMP.DAT")
  SET tmp_full_rat_dump_file_name = build(dump_path,"TMP_APACHE_RAT_DUMP.DAT")
  SET tmp_full_rae_dump_file_name = build(dump_path,"TMP_APACHE_RAE_DUMP.DAT")
  SET full_ra_dump_file_name = build(dump_path,"APACHE_RA_DUMP.DAT")
  SET full_rad_dump_file_name = build(dump_path,"APACHE_RAD_DUMP.DAT")
  SET full_rao_dump_file_name = build(dump_path,"APACHE_RAO_DUMP.DAT")
  SET full_rat_dump_file_name = build(dump_path,"APACHE_RAT_DUMP.DAT")
  SET full_rae_dump_file_name = build(dump_path,"APACHE_RAE_DUMP.DAT")
  SET test_file_name = build(dump_path,"APACHE_TEST_FILE.DAT")
 ELSE
  SET tmp_ra_dump_file_name = build(dump_path,"/tmp_apache_ra_dump")
  SET tmp_rad_dump_file_name = build(dump_path,"/tmp_apache_rad_dump")
  SET tmp_rao_dump_file_name = build(dump_path,"/tmp_apache_rao_dump")
  SET tmp_rat_dump_file_name = build(dump_path,"/tmp_apache_rat_dump")
  SET tmp_rae_dump_file_name = build(dump_path,"/tmp_apache_rae_dump")
  SET tmp_full_ra_dump_file_name = build(dump_path,"/tmp_apache_ra_dump.dat")
  SET tmp_full_rad_dump_file_name = build(dump_path,"/tmp_apache_rad_dump.dat")
  SET tmp_full_rao_dump_file_name = build(dump_path,"/tmp_apache_rao_dump.dat")
  SET tmp_full_rat_dump_file_name = build(dump_path,"/tmp_apache_rat_dump.dat")
  SET tmp_full_rae_dump_file_name = build(dump_path,"/tmp_apache_rae_dump.dat")
  SET full_ra_dump_file_name = build(dump_path,"/apache_ra_dump.dat")
  SET full_rad_dump_file_name = build(dump_path,"/apache_rad_dump.dat")
  SET full_rao_dump_file_name = build(dump_path,"/apache_rao_dump.dat")
  SET full_rat_dump_file_name = build(dump_path,"/apache_rat_dump.dat")
  SET full_rae_dump_file_name = build(dump_path,"/apache_rae_dump.dat")
  SET test_file_name = build(dump_path,"/apache_test_file.dat")
 ENDIF
 SELECT INTO value(test_file_name)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   "works"
  WITH nocounter, append
 ;end select
 IF (curqual=0)
  CALL echo("failed")
  SET failed_ind = "Y"
  SET failed_text = build("User lacks permission to write to extract location=",dump_path)
 ELSE
  CALL echo("worked")
 ENDIF
 IF (failed_ind="N")
  SET ra_file_exist = findfile(value(full_ra_dump_file_name))
  IF (ra_file_exist=1)
   CALL echo(build(full_ra_dump_file_name," EXISTS - EXITING EXTRACT PROCESS!!"))
   SET failed_ind = "Y"
   SET failed_text = "APACHE_RA_DUMP.DAT exists in target directory - exiting extract process"
  ELSE
   CALL echo("couldn't find RA dump file")
  ENDIF
 ENDIF
 IF (failed_ind="N")
  SET rad_file_exist = findfile(value(full_rad_dump_file_name))
  IF (rad_file_exist=1)
   CALL echo(build(full_rad_dump_file_name," EXISTS - EXITING EXTRACT PROCESS!!"))
   SET failed_ind = "Y"
   SET failed_text = "APACHE_RAD_DUMP.DAT exists in target directory - exiting extract process"
  ELSE
   CALL echo("couldn't find RAD dump file")
  ENDIF
 ENDIF
 IF (failed_ind="N")
  SET rao_file_exist = findfile(value(full_rao_dump_file_name))
  IF (rao_file_exist=1)
   CALL echo(build(full_rao_dump_file_name," EXISTS - EXITING EXTRACT PROCESS!!"))
   SET failed_ind = "Y"
   SET failed_text = "APACHE_RAO_DUMP.DAT exists in target directory - exiting extract process"
  ELSE
   CALL echo("couldn't find RAO dump file")
  ENDIF
 ENDIF
 IF (failed_ind="N")
  SET rat_file_exist = findfile(value(full_rat_dump_file_name))
  IF (rat_file_exist=1)
   CALL echo(build(full_rat_dump_file_name," EXISTS - EXITING EXTRACT PROCESS!!"))
   SET failed_ind = "Y"
   SET failed_text = "APACHE_RAT_DUMP.DAT exists in target directory - exiting extract process"
  ELSE
   CALL echo("couldn't find RAT dump file")
  ENDIF
 ENDIF
 IF (failed_ind="N")
  SET rae_file_exist = findfile(value(full_rae_dump_file_name))
  IF (rae_file_exist=1)
   CALL echo(build(full_rae_dump_file_name," EXISTS - EXITING EXTRACT PROCESS!!"))
   SET failed_ind = "Y"
   SET failed_text = "APACHE_RAE_DUMP.DAT exists in target directory - exiting extract process"
  ELSE
   CALL echo("couldn't find RAE dump file")
  ENDIF
 ENDIF
#3200_check_for_files_exit
#3500_update_dump_date
 IF (dump_path != "")
  EXECUTE gm_dm_info2388_def "U"
  DECLARE gm_u_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  DECLARE gm_u_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  DECLARE gm_u_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  DECLARE gm_u_dm_info2388_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  SUBROUTINE gm_u_dm_info2388_f8(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "info_number":
      IF (null_ind=1)
       SET gm_u_dm_info2388_req->info_numberf = 2
      ELSE
       SET gm_u_dm_info2388_req->info_numberf = 1
      ENDIF
      SET gm_u_dm_info2388_req->qual[iqual].info_number = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_numberw = 1
      ENDIF
     OF "info_long_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_dm_info2388_req->info_long_idf = 1
      SET gm_u_dm_info2388_req->qual[iqual].info_long_id = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_long_idw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_u_dm_info2388_i4(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "updt_cnt":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_dm_info2388_req->updt_cntf = 1
      SET gm_u_dm_info2388_req->qual[iqual].updt_cnt = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->updt_cntw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_u_dm_info2388_dq8(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "info_date":
      IF (null_ind=1)
       SET gm_u_dm_info2388_req->info_datef = 2
      ELSE
       SET gm_u_dm_info2388_req->info_datef = 1
      ENDIF
      SET gm_u_dm_info2388_req->qual[iqual].info_date = cnvtdatetime(ival)
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_datew = 1
      ENDIF
     OF "updt_dt_tm":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_dm_info2388_req->updt_dt_tmf = 1
      SET gm_u_dm_info2388_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->updt_dt_tmw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_u_dm_info2388_vc(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "info_domain":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_dm_info2388_req->info_domainf = 1
      SET gm_u_dm_info2388_req->qual[iqual].info_domain = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_domainw = 1
      ENDIF
     OF "info_name":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_dm_info2388_req->info_namef = 1
      SET gm_u_dm_info2388_req->qual[iqual].info_name = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_namew = 1
      ENDIF
     OF "info_char":
      IF (null_ind=1)
       SET gm_u_dm_info2388_req->info_charf = 2
      ELSE
       SET gm_u_dm_info2388_req->info_charf = 1
      ENDIF
      SET gm_u_dm_info2388_req->qual[iqual].info_char = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_charw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SET gm_u_dm_info2388_req->allow_partial_ind = 1
  SET gm_u_dm_info2388_req->force_updt_ind = 1
  SET gm_u_dm_info2388_req->info_domainw = 1
  SET gm_u_dm_info2388_req->info_namew = 1
  SET gm_u_dm_info2388_req->info_datew = 0
  SET gm_u_dm_info2388_req->info_charw = 0
  SET gm_u_dm_info2388_req->info_numberw = 0
  SET gm_u_dm_info2388_req->info_long_idw = 0
  SET gm_u_dm_info2388_req->updt_applctxw = 0
  SET gm_u_dm_info2388_req->updt_dt_tmw = 0
  SET gm_u_dm_info2388_req->updt_cntw = 0
  SET gm_u_dm_info2388_req->updt_idw = 0
  SET gm_u_dm_info2388_req->updt_taskw = 0
  SET gm_u_dm_info2388_req->info_domainf = 0
  SET gm_u_dm_info2388_req->info_namef = 0
  SET gm_u_dm_info2388_req->info_datef = 1
  SET gm_u_dm_info2388_req->info_charf = 0
  SET gm_u_dm_info2388_req->info_numberf = 0
  SET gm_u_dm_info2388_req->info_long_idf = 0
  SET gm_u_dm_info2388_req->updt_cntf = 0
  SET stat = alterlist(gm_u_dm_info2388_req->qual,1)
  SET gm_u_dm_info2388_req->qual[1].info_domain = "APACHE"
  SET gm_u_dm_info2388_req->qual[1].info_name = "APACHE RA DUMP DATE-PATH"
  SET gm_u_dm_info2388_req->qual[1].info_date = cnvtdatetime(curdate,curtime3)
  EXECUTE gm_u_dm_info2388  WITH replace(request,gm_u_dm_info2388_req), replace(reply,
   gm_u_dm_info2388_rep)
  CALL echorecord(gm_u_dm_info2388_rep)
  IF ((gm_u_dm_info2388_rep->qual[1].status=1))
   CALL echo("need to commit")
   SET reqinfo->commit_ind = 1
   COMMIT
  ELSE
   SET reqinfo->commit_ind = 0
   CALL echo("no commit")
  ENDIF
  FREE RECORD gm_u_dm_info2388_req
  FREE RECORD gm_u_dm_info2388_rep
  CALL echorecord(reply)
 ELSE
  SET failed_ind = "Y"
  SET failed_text =
  "no APACHE dump date data in DM_INFO info table.  Rerun DCP_APACHE_DM_INFO prompt"
 ENDIF
 CALL echo(build("dump path =",dump_path))
#3500_update_dump_date_exit
#4000_build_pat_list
 SET deceased_cd = 0.0
 SET expired_cd = 0.0
 SET deceased_cd = meaning_code(19,"DECEASED")
 SET expired_cd = meaning_code(19,"EXPIRED")
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   encounter e,
   encntr_alias ea,
   person p,
   organization o
  PLAN (e
   WHERE e.disch_dt_tm IS NOT null
    AND e.active_ind=1)
   JOIN (ra
   WHERE e.encntr_id=ra.encntr_id
    AND ra.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=ra.encntr_id
    AND ea.encntr_alias_type_cd=mrn_cd
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
    AND ea.active_ind=1)
   JOIN (p
   WHERE p.person_id=ra.person_id
    AND p.active_ind=1)
   JOIN (o
   WHERE o.organization_id=e.organization_id
    AND o.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,1000)=1)
    stat = alterlist(pat_list->pat_data,(cnt+ 999))
   ENDIF
   pat_list->pat_data[cnt].active_ind = ra.active_ind, pat_list->pat_data[cnt].risk_adjustment_id =
   ra.risk_adjustment_id, pat_list->pat_data[cnt].encntr_id = ra.encntr_id,
   pat_list->pat_data[cnt].active_status_dt_tm = ra.active_status_dt_tm, pat_list->pat_data[cnt].
   active_status_prsnl_id = ra.active_status_prsnl_id, pat_list->pat_data[cnt].adm_doc_id = ra
   .adm_doc_id,
   pat_list->pat_data[cnt].admit_age = ra.admit_age, pat_list->pat_data[cnt].admit_diagnosis = ra
   .admit_diagnosis, pat_list->pat_data[cnt].el_loc_nurse_unit_cd = uar_get_code_display(ra
    .admit_icu_cd),
   pat_list->pat_data[cnt].admit_source = ra.admit_source, pat_list->pat_data[cnt].admitsource_flag
    = ra.admitsource_flag, pat_list->pat_data[cnt].aids_ind = ra.aids_ind,
   pat_list->pat_data[cnt].ami_location = ra.ami_location, pat_list->pat_data[cnt].bed_count = ra
   .bed_count, pat_list->pat_data[cnt].body_system = ra.body_system,
   pat_list->pat_data[cnt].cc_during_stay_ind = ra.cc_during_stay_ind, pat_list->pat_data[cnt].
   chronic_health_none_ind = ra.chronic_health_none_ind, pat_list->pat_data[cnt].
   chronic_health_unavail_ind = ra.chronic_health_unavail_ind,
   pat_list->pat_data[cnt].cirrhosis_ind = ra.cirrhosis_ind, pat_list->pat_data[cnt].copd_flag = ra
   .copd_flag, pat_list->pat_data[cnt].copd_ind = ra.copd_ind,
   pat_list->pat_data[cnt].diabetes_ind = ra.diabetes_ind, pat_list->pat_data[cnt].dialysis_ind = ra
   .dialysis_ind, pat_list->pat_data[cnt].diedinicu_ind = ra.diedinicu_ind
   IF (ra.diedinicu_ind=1)
    pat_list->pat_data[cnt].diedinhospital_ind = 1
   ELSE
    IF (e.disch_disposition_cd IN (deceased_cd, expired_cd))
     pat_list->pat_data[cnt].diedinhospital_ind = 1
    ELSE
     pat_list->pat_data[cnt].diedinhospital_ind = 0
    ENDIF
    IF (p.deceased_dt_tm <= e.disch_dt_tm
     AND p.deceased_dt_tm >= e.reg_dt_tm)
     pat_list->pat_data[cnt].diedinhospital_ind = 1
    ENDIF
   ENDIF
   pat_list->pat_data[cnt].disease_category_cd = uar_get_code_display(ra.disease_category_cd),
   pat_list->pat_data[cnt].ejectfx_fraction = ra.ejectfx_fraction, pat_list->pat_data[cnt].
   electivesurgery_ind = ra.electivesurgery_ind,
   pat_list->pat_data[cnt].gender_flag = ra.gender_flag, pat_list->pat_data[cnt].hepaticfailure_ind
    = ra.hepaticfailure_ind, pat_list->pat_data[cnt].hosp_admit_dt_tm = ra.hosp_admit_dt_tm,
   pat_list->pat_data[cnt].hrs_at_source = ra.hrs_at_source, pat_list->pat_data[cnt].icu_admit_dt_tm
    = ra.icu_admit_dt_tm, pat_list->pat_data[cnt].icu_disch_dt_tm = ra.icu_disch_dt_tm,
   pat_list->pat_data[cnt].ima_ind = ra.ima_ind, pat_list->pat_data[cnt].immunosuppression_ind = ra
   .immunosuppression_ind, pat_list->pat_data[cnt].leukemia_ind = ra.leukemia_ind,
   pat_list->pat_data[cnt].lymphoma_ind = ra.lymphoma_ind, pat_list->pat_data[cnt].
   metastaticcancer_ind = ra.metastaticcancer_ind, pat_list->pat_data[cnt].mi_within_6mo_ind = ra
   .mi_within_6mo_ind,
   pat_list->pat_data[cnt].midur_ind = ra.midur_ind, pat_list->pat_data[cnt].nbr_grafts_performed =
   ra.nbr_grafts_performed, pat_list->pat_data[cnt].person_id = ra.person_id,
   pat_list->pat_data[cnt].ptca_device = ra.ptca_device, pat_list->pat_data[cnt].readmit_ind = ra
   .readmit_ind, pat_list->pat_data[cnt].readmit_within_24hr_ind = ra.readmit_within_24hr_ind,
   pat_list->pat_data[cnt].region_flag = ra.region_flag, pat_list->pat_data[cnt].sv_graft_ind = ra
   .sv_graft_ind, pat_list->pat_data[cnt].teach_type_flag = ra.teach_type_flag,
   pat_list->pat_data[cnt].therapy_level = ra.therapy_level, pat_list->pat_data[cnt].
   thrombolytics_ind = ra.thrombolytics_ind, pat_list->pat_data[cnt].updt_applctx = ra.updt_applctx,
   pat_list->pat_data[cnt].updt_cnt = ra.updt_cnt, pat_list->pat_data[cnt].updt_dt_tm = ra.updt_dt_tm,
   pat_list->pat_data[cnt].updt_id = ra.updt_id,
   pat_list->pat_data[cnt].updt_task = ra.updt_task, pat_list->pat_data[cnt].valid_from_dt_tm = ra
   .valid_from_dt_tm, pat_list->pat_data[cnt].valid_until_dt_tm = ra.valid_until_dt_tm,
   pat_list->pat_data[cnt].var03hspxlos_value = ra.var03hspxlos_value, pat_list->pat_data[cnt].
   xfer_within_48hr_ind = ra.xfer_within_48hr_ind, pat_list->pat_data[cnt].e_disch_dt_tm = e
   .disch_dt_tm,
   pat_list->pat_data[cnt].icu_disch_nurse_unit = fillstring(30,""), pat_list->pat_data[cnt].
   chronic_health_wt = - (1), pat_list->pat_data[cnt].age_wt = - (1),
   pat_list->pat_data[cnt].post_op_b = " ", pat_list->pat_data[cnt].e_disch_to_loctn_cd =
   uar_get_code_display(e.disch_to_loctn_cd)
   IF (trim(pat_list->pat_data[cnt].e_disch_to_loctn_cd,3)="")
    IF ((((pat_list->pat_data[cnt].diedinhospital_ind=1)) OR ((pat_list->pat_data[cnt].diedinicu_ind=
    1))) )
     pat_list->pat_data[cnt].e_disch_to_loctn_cd = "DEATH"
    ENDIF
   ENDIF
   IF ((pat_list->pat_data[cnt].diedinicu_ind=1))
    pat_list->pat_data[cnt].icu_disch_nurse_unit = "DEATH"
   ENDIF
   pat_list->pat_data[cnt].e_doc_service_cd = uar_get_code_display(ra.med_service_cd), pat_list->
   pat_data[cnt].pa_mrn = ea.alias, pat_list->pat_data[cnt].pat_name_first = p.name_first_key,
   pat_list->pat_data[cnt].pat_name_last = p.name_last_key, pat_list->pat_data[cnt].pat_birth_dt_tm
    = p.birth_dt_tm, pat_list->pat_data[cnt].pat_race_cd = p.race_cd,
   pat_list->pat_data[cnt].organization_id = e.organization_id, pat_list->pat_data[cnt].hospital_name
    = o.org_name, pat_list->pat_data[cnt].el_loc_nurse_unit_id = ra.admit_icu_cd
  FOOT REPORT
   pat_list->cnt = cnt, stat = alterlist(pat_list->pat_data,cnt)
  WITH nocounter
 ;end select
 CALL echo(build("pat_list->cnt=",pat_list->cnt))
 DECLARE num = i4
 DECLARE pos = i4
 DECLARE batch_size = i4 WITH noconstant(0)
 DECLARE loop_cnt = i4 WITH noconstant(0)
 DECLARE nstart = i4 WITH noconstant(0)
 DECLARE new_list_size = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE pos = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 SET batch_size = 200
 SET loop_cnt = ceil((cnvtreal(pat_list->cnt)/ batch_size))
 SET nstart = 1
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(pat_list->pat_data,new_list_size)
 FOR (idx = (pat_list->cnt+ 1) TO new_list_size)
   SET pat_list->pat_data[idx].encntr_id = pat_list->pat_data[pat_list->cnt].encntr_id
 ENDFOR
 IF ((pat_list->cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loop_cnt)),
    encntr_alias ea
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (ea
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),ea.encntr_id,pat_list->pat_data[num].encntr_id
     )
     AND ea.encntr_alias_type_cd=fin_cd
     AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ea.active_ind=1)
   DETAIL
    pos = locateval(num,1,pat_list->cnt,ea.encntr_id,pat_list->pat_data[num].encntr_id)
    WHILE (pos > 0)
     pat_list->pat_data[pos].fin_nbr = ea.alias,pos = locateval(num,(pos+ 1),pat_list->cnt,ea
      .encntr_id,pat_list->pat_data[num].encntr_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = pat_list->cnt),
    person p
   PLAN (d)
    JOIN (p
    WHERE (p.person_id=pat_list->pat_data[d.seq].adm_doc_id)
     AND p.active_ind=1)
   ORDER BY d.seq
   DETAIL
    pat_list->pat_data[d.seq].doc_name_first = p.name_first_key, pat_list->pat_data[d.seq].
    doc_name_last = p.name_last_key
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = pat_list->cnt),
    encntr_loc_hist el,
    location l
   PLAN (d)
    JOIN (el
    WHERE (el.encntr_id=pat_list->pat_data[d.seq].encntr_id)
     AND el.transaction_dt_tm >= cnvtdatetime(pat_list->pat_data[d.seq].icu_admit_dt_tm))
    JOIN (l
    WHERE l.location_cd=el.loc_nurse_unit_cd
     AND l.active_ind=1)
   ORDER BY el.transaction_dt_tm
   DETAIL
    IF (l.icu_ind=0)
     IF (trim(pat_list->pat_data[d.seq].icu_disch_nurse_unit,3)=trim("",3))
      pat_list->pat_data[d.seq].icu_disch_nurse_unit = uar_get_code_display(el.loc_nurse_unit_cd)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pat_list->cnt),
   risk_adjustment ra
  PLAN (d)
   JOIN (ra
   WHERE ra.active_ind=1
    AND (ra.encntr_id=pat_list->pat_data[d.seq].encntr_id)
    AND ra.icu_admit_dt_tm <= cnvtdatetime(pat_list->pat_data[d.seq].icu_admit_dt_tm))
  HEAD REPORT
   pat_list->pat_data[d.seq].ra_visit_number = 0
  DETAIL
   pat_list->pat_data[d.seq].ra_visit_number = (pat_list->pat_data[d.seq].ra_visit_number+ 1)
  WITH nocounter
 ;end select
#4000_build_pat_list_exit
#5000_create_dumps
 SELECT INTO value(tmp_ra_dump_file_name)
  FROM (dummyt d  WITH seq = pat_list->cnt)
  HEAD REPORT
   out_row = fillstring(5900," "), out_row = build(
    "RA_ACTIVE_IND|RA_RISK_ADJUSTMENT_ID|RA_ENCNTR_ID|RA_ACTIVE_STATUS_DT_TM|RA_ACTIVE_STATUS_PRSNL_ID|"
    ), out_row = build(out_row,
    "RA_ADM_DOC_ID|RA_ADMIT_AGE|RA_ADMIT_DIAGNOSIS|RA_ADMIT_SOURCE|RA_ADMITSOURCE_FLAG|"),
   out_row = build(out_row,
    "RA_AIDS_IND|RA_AMI_LOCATION|RA_BED_COUNT|RA_BODY_SYSTEM|RA_CC_DURING_STAY_IND|"), out_row =
   build(out_row,
    "RA_CHRONIC_HEALTH_NONE_IND|RA_CHRONIC_HEALTH_UNAVAIL_IND|RA_CIRRHOSIS_IND|RA_COPD_FLAG|"),
   out_row = build(out_row,
    "RA_COPD_IND|RA_DIABETES_IND|RA_DIALYSIS_IND|RA_DIEDINHOSPITAL_IND|RA_DIEDINICU_IND|"),
   out_row = build(out_row,
    "RA_DISEASE_CATEGORY_CD|RA_EJECTFX_FRACTION|RA_ELECTIVESURGERY_IND|RA_GENDER_FLAG|"), out_row =
   build(out_row,"RA_HEPATICFAILURE_IND|RA_HOSP_ADMIT_DT_TM|RA_HRS_AT_SOURCE|RA_ICU_ADMIT_DT_TM|"),
   out_row = build(out_row,"RA_ICU_DISCH_DT_TM|RA_IMA_IND|RA_IMMUNOSUPPRESSION_IND|"),
   out_row = build(out_row,
    "RA_LEUKEMIA_IND|RA_LYMPHOMA_IND|RA_METASTATICCANCER_IND|RA_MI_WITHIN_6MO_IND|"), out_row = build
   (out_row,"RA_MIDUR_IND|RA_NBR_GRAFTS_PERFORMED|RA_PERSON_ID|RA_PTCA_DEVICE|"), out_row = build(
    out_row,"RA_READMIT_IND|RA_READMIT_WITHIN_24HR_IND|RA_REGION_FLAG|"),
   out_row = build(out_row,
    "RA_SV_GRAFT_IND|RA_TEACH_TYPE_FLAG|RA_THERAPY_LEVEL|RA_THROMBOLYTICS_IND|"), out_row = build(
    out_row,"RA_UPDT_APPLCTX|RA_UPDT_CNT|RA_UPDT_DT_TM|"), out_row = build(out_row,
    "RA_UPDT_ID|RA_UPDT_TASK|RA_VALID_FROM_DT_TM|"),
   out_row = build(out_row,"RA_VALID_UNTIL_DT_TM|RA_VAR03HSPXLOS_VALUE|"), out_row = build(out_row,
    "RA_XFER_WITHIN_48HR_IND|E_DISCH_DT_TM|EL_LOC_NURSE_UNIT_CD|"), out_row = build(out_row,
    "RA_CHRONIC_HEALTH_WT|RA_AGE_WT|RA_POST_OP_B|"),
   out_row = build(out_row,
    "E_DISCH_TO_LOCTN_CD|ICU_DISCHARGE_LOCATION|E_DOC_SERVICE_CD|PA_MRN|FIN_NBR|"), out_row = build(
    out_row,"PAT_NAME_FIRST|PAT_NAME_LAST|DOC_NAME_FIRST|DOC_NAME_LAST|"), out_row = build(out_row,
    "P_BIRTH_DT_TM|O_ORGANIZATION_NAME|O_ORGANIZATION_ID|P_RACE_CD|P_RACE_CD_DISPLAY|"),
   out_row = build(out_row,"RA_VISIT_NUMBER|EL_LOC_NURSE_UNIT_ID"), out_row
  DETAIL
   out_row = fillstring(5900," "), row + 1, out_row = build(pat_list->pat_data[d.seq].active_ind,"|"),
   out_row = build(out_row,trim(format(pat_list->pat_data[d.seq].risk_adjustment_id,
      "#################"),3),"|"), out_row = build(out_row,trim(format(pat_list->pat_data[d.seq].
      encntr_id,"#################"),3),"|"), out_row = build(out_row,format(pat_list->pat_data[d.seq
     ].active_status_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"),
   out_row = build(out_row,trim(format(pat_list->pat_data[d.seq].active_status_prsnl_id,
      "#################"),3),"|"), out_row = build(out_row,trim(format(pat_list->pat_data[d.seq].
      adm_doc_id,"#################"),3),"|"), out_row = build(out_row,pat_list->pat_data[d.seq].
    admit_age,"|"),
   out_row = build(out_row,trim(pat_list->pat_data[d.seq].admit_diagnosis),"|"), out_row = build(
    out_row,trim(pat_list->pat_data[d.seq].admit_source),"|"), out_row = build(out_row,pat_list->
    pat_data[d.seq].admitsource_flag,"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].aids_ind,"|"), out_row = build(out_row,trim(
     pat_list->pat_data[d.seq].ami_location),"|"), out_row = build(out_row,pat_list->pat_data[d.seq].
    bed_count,"|"),
   out_row = build(out_row,trim(pat_list->pat_data[d.seq].body_system),"|"), out_row = build(out_row,
    pat_list->pat_data[d.seq].cc_during_stay_ind,"|"), out_row = build(out_row,pat_list->pat_data[d
    .seq].chronic_health_none_ind,"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].chronic_health_unavail_ind,"|"), out_row = build
   (out_row,pat_list->pat_data[d.seq].cirrhosis_ind,"|"), out_row = build(out_row,pat_list->pat_data[
    d.seq].copd_flag,"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].copd_ind,"|"), out_row = build(out_row,pat_list
    ->pat_data[d.seq].diabetes_ind,"|"), out_row = build(out_row,pat_list->pat_data[d.seq].
    dialysis_ind,"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].diedinhospital_ind,"|"), out_row = build(out_row,
    pat_list->pat_data[d.seq].diedinicu_ind,"|"), out_row = build(out_row,pat_list->pat_data[d.seq].
    disease_category_cd,"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].ejectfx_fraction,"|"), out_row = build(out_row,
    pat_list->pat_data[d.seq].electivesurgery_ind,"|"), out_row = build(out_row,pat_list->pat_data[d
    .seq].gender_flag,"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].hepaticfailure_ind,"|"), out_row = build(out_row,
    format(pat_list->pat_data[d.seq].hosp_admit_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"), out_row =
   build(out_row,pat_list->pat_data[d.seq].hrs_at_source,"|"),
   out_row = build(out_row,format(pat_list->pat_data[d.seq].icu_admit_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"
     ),"|"), out_row = build(out_row,format(pat_list->pat_data[d.seq].icu_disch_dt_tm,
     "DD-MMM-YYYY HH:MM:SS;;D"),"|"), out_row = build(out_row,pat_list->pat_data[d.seq].ima_ind,"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].immunosuppression_ind,"|"), out_row = build(
    out_row,pat_list->pat_data[d.seq].leukemia_ind,"|"), out_row = build(out_row,pat_list->pat_data[d
    .seq].lymphoma_ind,"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].metastaticcancer_ind,"|"), out_row = build(
    out_row,pat_list->pat_data[d.seq].mi_within_6mo_ind,"|"), out_row = build(out_row,pat_list->
    pat_data[d.seq].midur_ind,"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].nbr_grafts_performed,"|"), out_row = build(
    out_row,trim(format(pat_list->pat_data[d.seq].person_id,"#################"),3),"|"), out_row =
   build(out_row,trim(pat_list->pat_data[d.seq].ptca_device),"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].readmit_ind,"|"), out_row = build(out_row,
    pat_list->pat_data[d.seq].readmit_within_24hr_ind,"|"), out_row = build(out_row,pat_list->
    pat_data[d.seq].region_flag,"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].sv_graft_ind,"|"), out_row = build(out_row,
    pat_list->pat_data[d.seq].teach_type_flag,"|"), out_row = build(out_row,pat_list->pat_data[d.seq]
    .therapy_level,"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].thrombolytics_ind,"|"), out_row = build(out_row,
    pat_list->pat_data[d.seq].updt_applctx,"|"), out_row = build(out_row,pat_list->pat_data[d.seq].
    updt_cnt,"|"),
   out_row = build(out_row,format(pat_list->pat_data[d.seq].updt_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"
    ), out_row = build(out_row,trim(format(pat_list->pat_data[d.seq].updt_id,"#################"),3),
    "|"), out_row = build(out_row,pat_list->pat_data[d.seq].updt_task,"|"),
   out_row = build(out_row,format(pat_list->pat_data[d.seq].valid_from_dt_tm,
     "DD-MMM-YYYY HH:MM:SS;;D"),"|"), out_row = build(out_row,format(pat_list->pat_data[d.seq].
     valid_until_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"), out_row = build(out_row,pat_list->pat_data[d
    .seq].var03hspxlos_value,"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].xfer_within_48hr_ind,"|"), out_row = build(
    out_row,format(pat_list->pat_data[d.seq].e_disch_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"), out_row
    = build(out_row,pat_list->pat_data[d.seq].el_loc_nurse_unit_cd,"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].chronic_health_wt,"|"), out_row = build(out_row,
    pat_list->pat_data[d.seq].age_wt,"|"), out_row = build(out_row,pat_list->pat_data[d.seq].
    post_op_b,"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].e_disch_to_loctn_cd,"|")
   IF (trim(pat_list->pat_data[d.seq].icu_disch_nurse_unit,3)=trim("",3))
    out_row = build(out_row,pat_list->pat_data[d.seq].e_disch_to_loctn_cd,"|")
   ELSE
    out_row = build(out_row,pat_list->pat_data[d.seq].icu_disch_nurse_unit,"|")
   ENDIF
   out_row = build(out_row,pat_list->pat_data[d.seq].e_doc_service_cd,"|"), out_row = build(out_row,
    pat_list->pat_data[d.seq].pa_mrn,"|"), out_row = build(out_row,pat_list->pat_data[d.seq].fin_nbr,
    "|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].pat_name_first,"|"), out_row = build(out_row,
    pat_list->pat_data[d.seq].pat_name_last,"|"), out_row = build(out_row,pat_list->pat_data[d.seq].
    doc_name_first,"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].doc_name_last,"|"), out_row = build(out_row,
    format(pat_list->pat_data[d.seq].pat_birth_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"), out_row = build
   (out_row,pat_list->pat_data[d.seq].hospital_name,"|"),
   out_row = build(out_row,trim(format(pat_list->pat_data[d.seq].organization_id,"#################"),
     3),"|"), out_row = build(out_row,trim(format(pat_list->pat_data[d.seq].pat_race_cd,
      "#################"),3),"|"), out_row = build(out_row,uar_get_code_display(pat_list->pat_data[d
     .seq].pat_race_cd),"|"),
   out_row = build(out_row,pat_list->pat_data[d.seq].ra_visit_number,"|"), out_row = build(out_row,
    trim(format(pat_list->pat_data[d.seq].el_loc_nurse_unit_id,"#################"),3)), out_row
  WITH maxcol = 6000, formfeed = none, format = variable,
   maxrow = 1
 ;end select
 SELECT INTO value(tmp_rad_dump_file_name)
  FROM risk_adjustment_day rad,
   risk_adjustment ra,
   encounter e,
   (dummyt d  WITH seq = pat_list->cnt)
  PLAN (d)
   JOIN (ra
   WHERE (ra.risk_adjustment_id=pat_list->pat_data[d.seq].risk_adjustment_id)
    AND ra.active_ind=1)
   JOIN (rad
   WHERE ra.risk_adjustment_id=rad.risk_adjustment_id
    AND rad.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.active_ind=1
    AND e.disch_dt_tm IS NOT null)
  ORDER BY rad.risk_adjustment_id, rad.cc_day, rad.updt_dt_tm,
   0
  HEAD REPORT
   out_row = fillstring(5900," "), out_row = build(
    "RAD_ACTIVE_IND|RAD_RISK_ADJUSTMENT_DAY_ID|RAD_RISK_ADJUSTMENT_ID|RAD_ACTIVETX_IND|"), out_row =
   build(out_row,"RAD_ACTIVE_STATUS_CD|RAD_ACTIVE_STATUS_DT_TM|RAD_ACTIVE_STATUS_PRSNL_ID|"),
   out_row = build(out_row,"RAD_ALBUMIN_CE_ID|RAD_APACHE_III_SCORE|RAD_APS_DAY1|RAD_APS_SCORE|"),
   out_row = build(out_row,"RAD_APS_YESTERDAY|RAD_BILIRUBIN_CE_ID|RAD_BUN_CE_ID|"), out_row = build(
    out_row,"RAD_CC_BEG_DT_TM|RAD_CC_DAY|"),
   out_row = build(out_row,"RAD_CC_END_DT_TM|RAD_CREATININE_CE_ID|"), out_row = build(out_row,
    "RAD_FIO2_CE_ID|RAD_GLUCOSE_CE_ID|RAD_HEARTRATE_CE_ID|RAD_HEMATOCRIT_CE_ID|"), out_row = build(
    out_row,"RAD_INTUBATED_IND|RAD_MEAN_BLOOD_PRESSURE|RAD_MEDS_IND|RAD_OUTCOME_STATUS|"),
   out_row = build(out_row,"RAD_PAO2_CE_ID|RAD_PA_LINE_TODAY_IND|RAD_PCO2_CE_ID|RAD_PHYS_RES_PTS|"),
   out_row = build(out_row,"RAD_PH_CE_ID|RAD_RESP_CE_ID|"), out_row = build(out_row,
    "RAD_SODIUM_CE_ID|RAD_TEMP_CE_ID|RAD_UPDT_APPLCTX|"),
   out_row = build(out_row,"RAD_UPDT_CNT|RAD_UPDT_DT_TM|RAD_UPDT_ID|"), out_row = build(out_row,
    "RAD_URINE_OUTPUT|RAD_VALID_FROM_DT_TM|"), out_row = build(out_row,
    "RAD_UPDT_TASK|RAD_VALID_UNTIL_DT_TM|RAD_VENT_IND|"),
   out_row = build(out_row,"RAD_VENT_TODAY_IND|RAD_WBC_CE_ID|RAD_WORST_ALBUMIN_RESULT|"), out_row =
   build(out_row,"RAD_WORST_BILIRUBIN_RESULT|RAD_WORST_BUN_RESULT|RAD_WORST_CREATININE_RESULT|"),
   out_row = build(out_row,
    "RAD_WORST_GCS_MOTOR_SCORE|RAD_WORST_GCS_VERBAL_SCORE|RAD_WORST_GLUCOSE_RESULT|"),
   out_row = build(out_row,"RAD_WORST_FIO2_RESULT|RAD_WORST_GCS_EYE_SCORE|RAD_WORST_HEART_RATE|"),
   out_row = build(out_row,
    "RAD_WORST_HEMATOCRIT|RAD_WORST_PAO2_RESULT|RAD_WORST_PCO2_RESULT|RAD_WORST_PH_RESULT|"), out_row
    = build(out_row,"RAD_WORST_RESP_RESULT|RAD_WORST_SODIUM_RESULT|RAD_WORST_TEMP|"),
   out_row = build(out_row,"RAD_WORST_WBC_RESULT|RAD_POTASSIUM_CE_ID|RAD_WORST_POTASSIUM_RESULT"),
   out_row
  DETAIL
   row + 1, out_row = fillstring(5900," "), out_row = build(rad.active_ind,"|",trim(format(rad
      .risk_adjustment_day_id,"#################"),3),"|"),
   out_row = build(out_row,trim(format(rad.risk_adjustment_id,"#################"),3),"|",rad
    .activetx_ind,"|"), out_row = build(out_row,rad.active_status_cd,"|"), out_row = build(out_row,
    format(rad.active_status_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"),
   out_row = build(out_row,trim(format(rad.active_status_prsnl_id,"#################"),3),"|"),
   out_row = build(out_row,rad.albumin_ce_id,"|",rad.apache_iii_score,"|",
    rad.aps_day1,"|",rad.aps_score,"|"), out_row = build(out_row,rad.aps_yesterday,"|",rad
    .bilirubin_ce_id,"|",
    rad.bun_ce_id,"|"),
   out_row = build(out_row,format(rad.cc_beg_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"), out_row = build(
    out_row,trim(format(rad.cc_day,"#####"),3),"|"), out_row = build(out_row,format(rad.cc_end_dt_tm,
     "DD-MMM-YYYY HH:MM:SS;;D"),"|",rad.creatinine_ce_id,"|"),
   out_row = build(out_row,rad.fio2_ce_id,"|",rad.glucose_ce_id,"|",
    rad.heartrate_ce_id,"|",rad.hematocrit_ce_id,"|"), out_row = build(out_row,rad.intubated_ind,"|",
    rad.mean_blood_pressure,"|",
    rad.meds_ind,"|",rad.outcome_status,"|"), out_row = build(out_row,rad.pao2_ce_id,"|",rad
    .pa_line_today_ind,"|",
    rad.pco2_ce_id,"|",rad.phys_res_pts,"|"),
   out_row = build(out_row,rad.ph_ce_id,"|",rad.resp_ce_id,"|"), out_row = build(out_row,rad
    .sodium_ce_id,"|",rad.temp_ce_id,"|",
    rad.updt_applctx,"|"), out_row = build(out_row,rad.updt_cnt,"|",format(rad.updt_dt_tm,
     "DD-MMM-YYYY HH:MM:SS;;D"),"|"),
   out_row = build(out_row,trim(format(rad.updt_id,"#################"),3),"|"), out_row = build(
    out_row,rad.urine_output,"|",format(rad.valid_from_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"), out_row
    = build(out_row,rad.updt_task,"|",format(rad.valid_until_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"),
   out_row = build(out_row,rad.vent_ind,"|"), out_row = build(out_row,rad.vent_today_ind,"|",rad
    .wbc_ce_id,"|",
    rad.worst_albumin_result,"|"), out_row = build(out_row,rad.worst_bilirubin_result,"|",rad
    .worst_bun_result,"|",
    rad.worst_creatinine_result,"|"),
   out_row = build(out_row,rad.worst_gcs_motor_score,"|",rad.worst_gcs_verbal_score,"|",
    rad.worst_glucose_result,"|"), out_row = build(out_row,rad.worst_fio2_result,"|",rad
    .worst_gcs_eye_score,"|",
    rad.worst_heart_rate,"|"), out_row = build(out_row,rad.worst_hematocrit,"|",rad.worst_pao2_result,
    "|",
    rad.worst_pco2_result,"|"),
   out_row = build(out_row,rad.worst_ph_result,"|"), out_row = build(out_row,rad.worst_resp_result,
    "|",rad.worst_sodium_result,"|",
    rad.worst_temp,"|"), out_row = build(out_row,rad.worst_wbc_result,"|",rad.potassium_ce_id,"|",
    rad.worst_potassium_result),
   out_row
  WITH maxcol = 6000, formfeed = none, format = variable,
   maxrow = 1
 ;end select
 SELECT INTO value(tmp_rae_dump_file_name)
  FROM risk_adjustment_event rae,
   risk_adjustment ra,
   encounter e
  PLAN (ra
   WHERE ra.active_ind=1)
   JOIN (rae
   WHERE ra.risk_adjustment_id=rae.risk_adjustment_id
    AND rae.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.disch_dt_tm IS NOT null
    AND e.active_ind=1)
  HEAD REPORT
   out_row = fillstring(5900," "), out_row = build(
    "RAE_ACTIVE_IND|RAE_RISK_ADJUSTMENT_EVENT_ID|RAE_RISK_ADJUSTMENT_ID|"), out_row = build(out_row,
    "RAE_ACTIVE_STATUS_CD|RAE_ACTIVE_STATUS_DT_TM|"),
   out_row = build(out_row,"RAE_ACTIVE_STATUS_PRSNL_ID|RAE_BEG_EFFECTIVE_DT_TM|"), out_row = build(
    out_row,"RAE_CONSEQUENTIAL_IND|RAE_END_EFFECTIVE_DT_TM|"), out_row = build(out_row,
    "RAE_PREVENTABLE_IND|"),
   out_row = build(out_row,"RAE_SENTINEL_EVENT_CATEGORY_CD|RAE_SENTINEL_EVENT_CODE_CD|"), out_row =
   build(out_row,"RAE_SENTINEL_EVENT_COMMENT|RAE_SENTINEL_EVENT_UNIT|RAE_UPDT_APPLCTX|"), out_row =
   build(out_row,"RAE_UPDT_CNT|RAE_UPDT_DT_TM|RAE_UPDT_ID|"),
   out_row = build(out_row,"RAE_UPDT_TASK"), out_row
  DETAIL
   row + 1, out_row = fillstring(5900," "), out_row = build(rae.active_ind,"|",trim(format(rae
      .risk_adjustment_event_id,"#################"),3),"|"),
   out_row = build(out_row,trim(format(rae.risk_adjustment_id,"#################"),3),"|"), out_row
    = build(out_row,rae.active_status_cd,"|",format(rae.active_status_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"
     ),"|"), out_row = build(out_row,trim(format(rae.active_status_prsnl_id,"#################"),3),
    "|"),
   out_row = build(out_row,format(rae.beg_effective_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"), out_row =
   build(out_row,rae.consequential_ind,"|",format(rae.end_effective_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),
    "|"), out_row = build(out_row,rae.preventable_ind,"|"),
   out_row = build(out_row,uar_get_code_display(rae.sentinel_event_category_cd),"|"), out_row = build
   (out_row,uar_get_code_display(rae.sentinel_event_code_cd),"|"), out_row = build(out_row,rae
    .sentinel_event_comment,"|",rae.sentinel_event_unit,"|",
    rae.updt_applctx,"|"),
   out_row = build(out_row,rae.updt_cnt,"|",format(rae.updt_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"),
   out_row = build(out_row,trim(format(rae.updt_id,"#################"),3),"|"), out_row = build(
    out_row,rae.updt_task),
   out_row
  WITH maxcol = 6000, formfeed = none, format = variable,
   maxrow = 1
 ;end select
 SELECT INTO value(tmp_rao_dump_file_name)
  FROM risk_adjustment_outcomes rao,
   risk_adjustment_day rad,
   risk_adjustment ra,
   encounter e
  PLAN (ra
   WHERE ra.active_ind=1)
   JOIN (rad
   WHERE ra.risk_adjustment_id=rad.risk_adjustment_id
    AND rad.active_ind=1)
   JOIN (rao
   WHERE rad.risk_adjustment_day_id=rao.risk_adjustment_day_id
    AND rao.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.disch_dt_tm IS NOT null
    AND e.active_ind=1)
  HEAD REPORT
   out_row = fillstring(5900," "), out_row = build(
    "RAO_ACTIVE_IND|RAO_RISK_ADJUSTMENT_DAY_ID|RAO_RISK_ADJUSTMENT_OUTCOMES_ID|"), out_row = build(
    out_row,"RAO_ACTIVE_STATUS_CD|RAO_ACTIVE_STATUS_DT_TM|"),
   out_row = build(out_row,"RAO_ACTIVE_STATUS_PRSNL_ID|RAO_EQUATION_NAME|RAO_OUTCOME_VALUE|"),
   out_row = build(out_row,"RAO_UPDT_APPLCTX|"), out_row = build(out_row,
    "RAO_UPDT_CNT|RAO_UPDT_DT_TM|RAO_UPDT_ID|"),
   out_row = build(out_row,"RAO_UPDT_TASK|RAO_VALID_FROM_DT_TM|"), out_row = build(out_row,
    "RAO_VALID_UNTIL_DT_TM|RA_RISK_ADJUSTMENT_ID|RA_CC_DAY"), out_row
  DETAIL
   row + 1, out_row = fillstring(5900," "), out_row = build(rao.active_ind,"|",trim(format(rao
      .risk_adjustment_day_id,"#################"),3),"|"),
   out_row = build(out_row,trim(format(rao.risk_adjustment_outcomes_id,"#################"),3),"|"),
   out_row = build(out_row,rao.active_status_cd,"|",format(rao.active_status_dt_tm,
     "DD-MMM-YYYY HH:MM:SS;;D"),"|"), out_row = build(out_row,trim(format(rao.active_status_prsnl_id,
      "#################"),3),"|",rao.equation_name,"|"),
   out_row = build(out_row,rao.outcome_value,"|"), out_row = build(out_row,rao.updt_applctx,"|"),
   out_row = build(out_row,rao.updt_cnt,"|",format(rao.updt_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"),
   out_row = build(out_row,trim(format(rao.updt_id,"#################"),3),"|"), out_row = build(
    out_row,rao.updt_task,"|",format(rao.valid_from_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"), out_row =
   build(out_row,format(rao.valid_until_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"),
   out_row = build(out_row,trim(format(rad.risk_adjustment_id,"#################"),3),"|"), out_row
    = build(out_row,rad.cc_day), out_row
  WITH maxcol = 6000, formfeed = none, format = variable,
   maxrow = 1
 ;end select
 SELECT INTO value(tmp_rat_dump_file_name)
  FROM risk_adj_tiss rat,
   risk_adjustment ra,
   encounter e
  PLAN (ra
   WHERE ra.active_ind=1)
   JOIN (rat
   WHERE ra.risk_adjustment_id=rat.risk_adjustment_id
    AND rat.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.disch_dt_tm IS NOT null
    AND e.active_ind=1)
  HEAD REPORT
   out_row = fillstring(5900," "), out_row = build(
    "RAT_ACTIVE_IND|RAT_RISK_ADJUSTMENT_ID|RAT_RISK_ADJ_TISS_ID|"), out_row = build(out_row,
    "RAT_ACTIVE_STATUS_CD|RAT_ACTIVE_STATUS_DT_TM|RAT_ACTIVE_STATUSPRSNL_ID|"),
   out_row = build(out_row,"RAT_TISS_BEG_DT_TM|RAT_TISS_CD|RAT_TISS_END_DT_TM|"), out_row = build(
    out_row,"RAT_UPDT_APPLCTX|RAT_UPDT_CNT|RAT_UPDT_DT_TM|RAT_UPDT_ID|"), out_row = build(out_row,
    "RAT_UPDT_TASK|"),
   out_row
  DETAIL
   row + 1, out_row = fillstring(5900," "), out_row = build(rat.active_ind,"|",trim(format(rat
      .risk_adjustment_id,"###########"),3),"|"),
   out_row = build(out_row,trim(format(rat.risk_adj_tiss_id,"#################"),3),"|",rat
    .active_status_cd,"|"), out_row = build(out_row,format(rat.active_status_dt_tm,
     "DD-MMM-YYYY HH:MM:SS;;D"),"|"), out_row = build(out_row,trim(format(rat.active_status_prsnl_id,
      "#################"),3),"|"),
   out_row = build(out_row,format(rat.tiss_beg_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"), out_row = build
   (out_row,uar_get_code_display(rat.tiss_cd),"|"), out_row = build(out_row,format(rat.tiss_end_dt_tm,
     "DD-MMM-YYYY HH:MM:SS;;D"),"|",rat.updt_applctx,"|",
    rat.updt_cnt,"|"),
   out_row = build(out_row,format(rat.updt_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"|"), out_row = build(
    out_row,trim(format(rat.updt_id,"#################"),3)), out_row = build(out_row,"|"),
   out_row = build(out_row,rat.updt_task), out_row
  WITH maxcol = 6000, formfeed = none, format = variable,
   maxrow = 1
 ;end select
#5099_create_dumps_exit
#8000_rename_files
 IF (((cursys="VMS") OR (cursys="AXP")) )
  SET rename_ra_cmd = concat("rename ",tmp_full_ra_dump_file_name," ",full_ra_dump_file_name)
  SET rename_rad_cmd = concat("rename ",tmp_full_rad_dump_file_name," ",full_rad_dump_file_name)
  SET rename_rao_cmd = concat("rename ",tmp_full_rao_dump_file_name," ",full_rao_dump_file_name)
  SET rename_rat_cmd = concat("rename ",tmp_full_rat_dump_file_name," ",full_rat_dump_file_name)
  SET rename_rae_cmd = concat("rename ",tmp_full_rae_dump_file_name," ",full_rae_dump_file_name)
 ELSE
  SET rename_ra_cmd = concat("mv ",tmp_full_ra_dump_file_name," ",full_ra_dump_file_name)
  SET rename_rad_cmd = concat("mv ",tmp_full_rad_dump_file_name," ",full_rad_dump_file_name)
  SET rename_rao_cmd = concat("mv ",tmp_full_rao_dump_file_name," ",full_rao_dump_file_name)
  SET rename_rat_cmd = concat("mv ",tmp_full_rat_dump_file_name," ",full_rat_dump_file_name)
  SET rename_rae_cmd = concat("mv ",tmp_full_rae_dump_file_name," ",full_rae_dump_file_name)
 ENDIF
 SET len_ra_cmd = size(rename_ra_cmd)
 SET len_rad_cmd = size(rename_rad_cmd)
 SET len_rao_cmd = size(rename_rao_cmd)
 SET len_rat_cmd = size(rename_rat_cmd)
 SET len_rae_cmd = size(rename_rae_cmd)
 SET status = 0
 SET ra_data = dcl(rename_ra_cmd,len_ra_cmd,status)
 SET rad_data = dcl(rename_rad_cmd,len_rad_cmd,status)
 SET rao_data = dcl(rename_rao_cmd,len_rao_cmd,status)
 SET rat_data = dcl(rename_rat_cmd,len_rat_cmd,status)
 SET rae_data = dcl(rename_rae_cmd,len_rae_cmd,status)
 SET del_data = remove(test_file_name)
 CALL echo(build("del_data=",del_data))
 IF (ra_data != 1)
  CALL echo(build("ERROR RENAMING RA DUMP FILE!!!",rename_ra_cmd))
  SET failed_ind = "Y"
  SET failed_text = "ERROR RENAMING TEMP DUMP FILES!!!"
 ENDIF
 IF (rad_data != 1)
  CALL echo("ERROR RENAMING RAD DUMP FILE!!!")
  SET failed_ind = "Y"
  SET failed_text = "ERROR RENAMING TEMP DUMP FILES!!!"
 ENDIF
 IF (rao_data != 1)
  CALL echo("ERROR RENAMING RAO DUMP FILE!!!")
  SET failed_ind = "Y"
  SET failed_text = "ERROR RENAMING TEMP DUMP FILES!!!"
 ENDIF
 IF (rat_data != 1)
  CALL echo("ERROR RENAMING RAT DUMP FILE!!!")
  SET failed_ind = "Y"
  SET failed_text = "ERROR RENAMING TEMP DUMP FILES!!!"
 ENDIF
 IF (rae_data != 1)
  CALL echo("ERROR RENAMING RAE DUMP FILE!!!")
  SET failed_ind = "Y"
  SET failed_text = "ERROR RENAMING TEMP DUMP FILES!!!"
 ENDIF
 IF (del_data != 1)
  CALL echo("ERRROR DELETING TEMP FILE!!")
 ENDIF
#8000_rename_files_exit
#9999_exit_program
 IF (failed_ind="Y")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "QUERY"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_APACHE_DUMP_RA"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = failed_text
 ELSEIF (failed_ind="Z")
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "QUERY"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_APACHE_DUMP_RA"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = failed_text
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
