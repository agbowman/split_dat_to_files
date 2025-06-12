CREATE PROGRAM cco_rpt_von_extract_prompt:dba
 PROMPT
  "Output Summary to File/Printer/MINE" = "MINE",
  "Select Organization to Extract:" = 0,
  "Standard Extract or All Records Extract" = "REGULAR",
  "Test Extract or Submission Extract" = "SUBMIT"
  WITH outputto, org_id, extract_type,
  test_extract
 DECLARE initialize(p1) = null WITH protect
 DECLARE meaning_code(p1,p2) = f8 WITH protect
 DECLARE load_pat_data(p_org_id) = null WITH protect
 DECLARE create_file(p1) = i2 WITH protect
 DECLARE load_org(p1) = null WITH protect
 DECLARE print_report(p1) = null WITH protect
 DECLARE load_event_data(p1) = null WITH protect
 DECLARE get_cev_value(p_person_id,p_cki,p_seq,p_default) = vc WITH protect
 DECLARE rename_files(p1) = i2 WITH protect
 DECLARE print_error_rpt(perror) = null WITH protect
 DECLARE update_rar(p1) = vc WITH protect
 DECLARE update_patients(p1) = null WITH protect
 DECLARE find_file(p1) = vc WITH protect
 DECLARE get_bd_desc(p_person_id,p_cki,p_seq_num,p_default) = vc WITH protect
 DECLARE check_path(p1) = vc WITH protect
 DECLARE check_permissions(p1) = vc WITH protect
 DECLARE v_rename_cmd = vc WITH noconstant(fillstring(100," ")), protect
 DECLARE v_extract_type = vc WITH noconstant(fillstring(100," ")), protect
 DECLARE v_test_extract = vc WITH noconstant(fillstring(100," ")), protect
 DECLARE v_org_id = f8 WITH noconstant(- (1.0)), protect
 DECLARE v_outdev = vc WITH protect
 DECLARE v_out_row = vc
 DECLARE v_extract_path = vc WITH noconstant(fillstring(200," ")), protect
 DECLARE v_filenum = vc WITH noconstant("xxx"), protect
 DECLARE i_filenum = i2 WITH noconstant(- (1)), protect
 DECLARE v_hospnum = vc WITH noconstant("xxxx"), protect
 DECLARE v_file_name = vc WITH noconstant(fillstring(200," ")), protect
 DECLARE v_path_file_name = vc WITH noconstant(fillstring(200," ")), protect
 DECLARE v_dat_file_name = vc WITH noconstant(fillstring(200," ")), protect
 DECLARE v_csv_file_name = vc WITH noconstant(fillstring(200," ")), protect
 DECLARE v_von_app_cd = f8 WITH noconstant(0.0), protect
 DECLARE v_org_name = vc WITH protect
 DECLARE inerror_cd = f8 WITH noconstant(0.0), protect
 DECLARE delete_temp_file_cmd = vc
 DECLARE test_file_name = vc
 DECLARE c_application = vc WITH constant("Cerner Millennium"), protect
 DECLARE c_version = vc WITH constant("HNAM 2005.03"), protect
 DECLARE c_curdate_disp = vc WITH constant(format(cnvtdatetime(curdate,0),"mm/dd/yyyy;;d")), protect
 DECLARE c_curdatetime_disp = vc WITH constant(format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME")
  ), protect
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD pat_list(
   1 cnt = i2
   1 pat_data[*]
     2 name = vc
     2 person_id = f8
     2 cco_encounter_id = f8
     2 id = i4
     2 byear = i2
     2 bwgt = i4
     2 gaweeks = i2
     2 gadays = i2
     2 deldie = i2
     2 locate = i2
     2 dayadmiss = i2
     2 hisp = i2
     2 newrace = i2
     2 pcare = i2
     2 aster = i2
     2 vagdel = i2
     2 sex = i2
     2 mult = i2
     2 nbirths = i2
     2 ap1 = i2
     2 ap5 = i2
     2 drox = i2
     2 drbm = i2
     2 dret = i2
     2 drep = i2
     2 drcc = i2
     2 ebseps = i2
     2 newox28 = i2
     2 usound1 = i2
     2 ugrade1 = i2
     2 die12 = i2
     2 oxy = i2
     2 vent = i2
     2 hfv = i2
     2 cpap = i2
     2 cpapes = i2
     2 drsurf = i2
     2 surfx = i2
     2 surf1dhr = i4
     2 surf1dim = i2
     2 ox36 = i2
     2 sterbpd = i2
     2 indometh = i2
     2 srglig = i2
     2 necsurg = i2
     2 ropsurg = i2
     2 othsurg = i2
     2 rds = i2
     2 pntx = i2
     2 pda = i2
     2 nec = i2
     2 giperf = i2
     2 lbpath = i2
     2 cnegstaph = i2
     2 fungal = i2
     2 pvl = i2
     2 eyex = i2
     2 istage = i2
     2 cmal = i2
     2 bdcd1 = i2
     2 bdcd2 = i2
     2 bdcd3 = i2
     2 bdcd4 = i2
     2 bdcd5 = i2
     2 bdefect = c255
     2 entfeed = i2
     2 oxfinal = i2
     2 acfinal = i2
     2 fdisp = i2
     2 dwgt = i4
     2 los1 = i4
     2 transcode = i2
     2 xfer_out = i2
     2 f2disp = i2
     2 rbyday28 = i2
     2 f3disp = i2
     2 f3wgt = i4
     2 udisp = i2
     2 lostot = i2
     2 durvent = i2
     2 ventdays = i4
     2 ecmop = i2
     2 ecmowd = i2
     2 ntrcoxt = i2
     2 ntrcoxwd = i2
     2 carsrgp = i2
     2 carsrgpwd = i2
     2 hypoiep = i2
     2 hypoies = i2
     2 mecasp = i2
     2 trcsucma = i2
     2 seizure = i2
 )
 CALL initialize("junk")
 IF (v_org_id=0)
  CALL print_report("org_id = 0")
 ELSE
  CALL load_org("")
  IF (v_test_extract="SUBMIT")
   IF (check_path(v_extract_path)="F")
    CALL print_error_rpt(build("EXTRACT PATH CANNOT BE ACCESSED:",v_extract_path))
    GO TO 9999_exit_program
   ENDIF
   IF (check_permissions(v_extract_path)="F")
    CALL print_error_rpt(build("EXTRACT PATH CANNOT BE WRITTEN TO:",v_extract_path))
    GO TO 9999_exit_program
   ENDIF
   IF (find_file("")="F")
    CALL print_error_rpt(build("SUBMISSION FILE ALREADY EXISTS:",v_csv_file_name))
    GO TO 9999_exit_program
   ENDIF
  ENDIF
  CALL load_pat_data(v_org_id)
  IF ((pat_list->cnt > 0))
   CALL load_event_data("junk")
   IF (create_file("Junk")=1)
    CALL print_error_rpt(build("ERROR CREATING FILE:",v_csv_file_name))
    GO TO 9999_exit
   ENDIF
   IF (rename_files("")=1)
    IF (v_test_extract="SUBMIT")
     IF (update_rar("")="FAIL")
      CALL print_error_rpt("UPDATE RAR FAILED")
     ENDIF
     CALL update_patients("")
     COMMIT
    ENDIF
    CALL print_report("")
   ELSE
    CALL print_error_rpt(build("FILE RENAME FAILED:",v_rename_cmd))
   ENDIF
  ELSE
   CALL print_no_pat_report("NO ELIGIBLE PATIENTS")
  ENDIF
 ENDIF
#9999_exit_program
 SET v_org_id = 0
 SUBROUTINE initialize(p1)
   SET v_outdev =  $OUTPUTTO
   SET v_org_id =  $ORG_ID
   SET v_extract_type =  $EXTRACT_TYPE
   SET v_test_extract =  $TEST_EXTRACT
   SET v_von_app_cd = meaning_code(400700,"VON")
   SET inerror_cd = meaning_code(8,"INERROR")
 END ;Subroutine
 SUBROUTINE load_org(p1)
   SELECT INTO "nl:"
    FROM risk_adjustment_ref rar,
     organization o
    PLAN (rar
     WHERE rar.organization_id=v_org_id
      AND rar.active_ind=1)
     JOIN (o
     WHERE o.organization_id=rar.organization_id
      AND o.active_ind=1)
    DETAIL
     v_extract_path = rar.extract_path, v_filenum = format((rar.last_file_number+ 1),"###;P0"),
     i_filenum = (rar.last_file_number+ 1),
     v_hospnum = rar.hospital_code
     IF (((cursys="VMS") OR (cursys="AXP")) )
      v_file_name = build("H",v_hospnum,"EDS",v_filenum), test_file_name = cnvtlower(build(
        v_extract_path,"apache_test_file.dat"))
     ELSE
      v_file_name = cnvtlower(build("/H",v_hospnum,"EDS",v_filenum)), test_file_name = cnvtlower(
       build(v_extract_path,"/apache_test_file.dat"))
     ENDIF
     IF (v_test_extract="TEST")
      v_file_name = cnvtlower(build(v_file_name,"_TEST"))
     ENDIF
     v_path_file_name = cnvtlower(build(v_extract_path,v_file_name)), v_dat_file_name = cnvtlower(
      build(v_path_file_name,".dat")), v_csv_file_name = cnvtlower(build(v_path_file_name,".csv")),
     v_org_name = o.org_name
     IF (((cursys="VMS") OR (cursys="AXP")) )
      v_rename_cmd = concat("rename ",v_dat_file_name," ",v_csv_file_name)
     ELSE
      vthis_file_name = cnvtlower(v_dat_file_name), v_rename_cmd = cnvtlower(concat("mv -f ",
        vthis_file_name," ",v_csv_file_name))
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE update_rar(p1)
  UPDATE  FROM risk_adjustment_ref rar
   SET rar.last_extract_dt_tm = cnvtdatetime(curdate,curtime3), rar.last_file_number = i_filenum, rar
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    rar.updt_cnt = (rar.updt_cnt+ 1)
   WHERE rar.organization_id=v_org_id
    AND rar.active_ind=1
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL echo("UPDATE RAR FAILED")
   RETURN("FAIL")
  ELSE
   CALL echo("UPDATE RAR GOOD")
   RETURN("OK")
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE update_patients(p1)
  DECLARE loop_cnt = i2 WITH protect
  FOR (loop_cnt = 1 TO pat_list->cnt)
    UPDATE  FROM cco_encounter coe
     SET coe.extract_flag = 1, coe.extract_dt_tm = cnvtdatetime(curdate,curtime3), coe.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      coe.updt_id = reqinfo->updt_id, coe.updt_task = reqinfo->updt_task, coe.updt_applctx = reqinfo
      ->updt_applctx,
      coe.updt_cnt = (coe.updt_cnt+ 1)
     WHERE (coe.cco_encounter_id=pat_list->pat_data[loop_cnt].cco_encounter_id)
      AND coe.active_ind=1
     WITH nocounter
    ;end update
  ENDFOR
 END ;Subroutine
 SUBROUTINE check_path(p_extract_path)
   IF (size(trim(p_extract_path)) < 1)
    CALL echo("VON EXTRACT PATH NOT SET")
    RETURN("F")
   ELSE
    SET status = 0
    IF (((cursys="VMS") OR (cursys="AXP")) )
     SET loc_cmd = concat("set def ",trim(p_extract_path))
    ELSE
     SET loc_cmd = concat("cd ",trim(p_extract_path))
    ENDIF
    CALL echo(build("loc_cmd=",loc_cmd))
    SET cmd_siz = size(loc_cmd)
    SET loc_result = dcl(loc_cmd,cmd_siz,status)
    CALL echo(build("cmd_siz=",cmd_siz))
    CALL echo(build("loc_result=",loc_result))
    IF (loc_result != 1)
     CALL echo(build("VON Extract location not accessable. Path=",p_extract_path))
     RETURN("F")
    ELSE
     RETURN("S")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE check_permissions(p_extract_path)
  SELECT INTO value(test_file_name)
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    v_rename_cmd
   WITH nocounter, append
  ;end select
  IF (curqual=0)
   CALL echo("failed")
   SET failed_text = build("User lacks permission to write to extract location=",p_extract_path)
   RETURN("F")
  ELSE
   IF (((cursys="VMS") OR (cursys="AXP")) )
    SET test_file_name = concat(test_file_name,";*")
   ENDIF
   SET del_data = remove(test_file_name)
   RETURN("S")
  ENDIF
 END ;Subroutine
 SUBROUTINE find_file(p1)
   DECLARE v_file_exists = i2
   SET v_file_exists = findfile(value(v_csv_file_name))
   IF (v_file_exists=1)
    CALL echo(build(v_csv_file_name," EXISTS - EXITING EXTRACT PROCESS!!"))
    RETURN("F")
   ELSE
    CALL echo("couldn't find VON dump file")
    RETURN("S")
   ENDIF
 END ;Subroutine
 SUBROUTINE rename_files(p1)
   DECLARE v_len_cmd = i2 WITH noconstant(0), protect
   DECLARE v_rename_stat = i2 WITH noconstant(0), public
   DECLARE v_status = i4 WITH noconstant(0), protect
   DECLARE vthis_file_name = vc WITH noconstant(fillstring(100," ")), protect
   SET v_len_cmd = size(trim(v_rename_cmd))
   CALL echo(build("v_LEN_CMD=",v_len_cmd))
   SET v_status = 0
   IF (((cursys="VMS") OR (cursys="AXP")) )
    SET v_rename_stat = dcl(v_rename_cmd,v_len_cmd,v_status)
   ELSE
    SET v_rename_stat = dcl(concat(" ",v_rename_cmd),(v_len_cmd+ 1),v_status)
   ENDIF
   CALL echo(build("v_RENAME_STAT=",v_rename_stat))
   IF (v_rename_stat != 1)
    CALL echo(build("ERROR RENAMING VON EXTRACT FILE!!!",v_rename_cmd))
    SET v_rename_cmd = build(v_rename_cmd,"-",v_len_cmd,"-",v_rename_stat)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   DECLARE mc_code = f8 WITH noconstant(0.0), protect
   DECLARE mc_text = vc WITH noconstant(fillstring(12," ")), protect
   DECLARE mc_stat = i2 WITH noconstant(0), protect
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
 SUBROUTINE load_pat_data(p_orgid)
   DECLARE parse_string = vc WITH protect
   DECLARE parse_string2 = vc WITH protect
   IF (v_extract_type="REGULAR")
    SET parse_string = "coe.extract_flag = 0"
    SET parse_string2 = "coe.record_status_flag in (1,2)"
   ELSEIF (v_extract_type="FULL")
    SET parse_string = "coe.extract_flag in (0,1)"
    SET parse_string2 = "coe.record_status_flag in (1,2)"
   ELSEIF (v_extract_type="TEST")
    SET parse_string = "coe.extract_flag in (0,1)"
    SET parse_string2 = "coe.record_status_flag > -1"
   ELSE
    SET parse_string = "1=2"
    SET parse_string2 = "1=2"
   ENDIF
   SELECT INTO "nl:"
    FROM cco_encounter coe,
     encounter e,
     person p
    PLAN (coe
     WHERE coe.cco_source_app_cd=v_von_app_cd
      AND parser(parse_string2)
      AND parser(parse_string)
      AND coe.active_ind=1)
     JOIN (e
     WHERE e.encntr_id=coe.encntr_id
      AND e.organization_id=p_orgid
      AND e.active_ind=1)
     JOIN (p
     WHERE p.person_id=coe.person_id
      AND p.active_ind=1)
    HEAD REPORT
     von_cnt = 0
    DETAIL
     von_cnt = (von_cnt+ 1)
     IF (mod(von_cnt,10)=1)
      stat = alterlist(pat_list->pat_data,(von_cnt+ 9))
     ENDIF
     pat_list->pat_data[von_cnt].name = p.name_full_formatted, pat_list->pat_data[von_cnt].person_id
      = p.person_id, pat_list->pat_data[von_cnt].cco_encounter_id = coe.cco_encounter_id,
     pat_list->pat_data[von_cnt].id = coe.patient_identifier, pat_list->pat_data[von_cnt].byear =
     year(p.birth_dt_tm), pat_list->pat_data[von_cnt].bwgt = - (1),
     pat_list->pat_data[von_cnt].gaweeks = - (1), pat_list->pat_data[von_cnt].gadays = - (1),
     pat_list->pat_data[von_cnt].deldie = coe.diedindelroom_ind,
     pat_list->pat_data[von_cnt].locate = - (1), pat_list->pat_data[von_cnt].dayadmiss = (
     datetimediff(coe.hosp_admit_dt_tm,p.birth_dt_tm,1)+ 1), pat_list->pat_data[von_cnt].hisp = coe
     .mothers_ethnicity,
     pat_list->pat_data[von_cnt].newrace = coe.mothers_race, pat_list->pat_data[von_cnt].pcare = - (1
     ), pat_list->pat_data[von_cnt].aster = - (1),
     pat_list->pat_data[von_cnt].vagdel = - (1), pat_list->pat_data[von_cnt].sex = coe.gender_flag,
     pat_list->pat_data[von_cnt].mult = - (1),
     pat_list->pat_data[von_cnt].nbirths = - (1), pat_list->pat_data[von_cnt].ap1 = - (1), pat_list->
     pat_data[von_cnt].ap5 = - (1),
     pat_list->pat_data[von_cnt].drox = - (1), pat_list->pat_data[von_cnt].drbm = - (1), pat_list->
     pat_data[von_cnt].dret = - (1),
     pat_list->pat_data[von_cnt].drep = - (1), pat_list->pat_data[von_cnt].drcc = - (1), pat_list->
     pat_data[von_cnt].ebseps = - (1),
     pat_list->pat_data[von_cnt].newox28 = - (1), pat_list->pat_data[von_cnt].usound1 = - (1),
     pat_list->pat_data[von_cnt].ugrade1 = - (1),
     pat_list->pat_data[von_cnt].die12 = coe.diedinicu_ind, pat_list->pat_data[von_cnt].oxy = - (1),
     pat_list->pat_data[von_cnt].vent = - (1),
     pat_list->pat_data[von_cnt].hfv = - (1), pat_list->pat_data[von_cnt].cpap = - (1), pat_list->
     pat_data[von_cnt].cpapes = - (1),
     pat_list->pat_data[von_cnt].drsurf = - (1), pat_list->pat_data[von_cnt].surfx = - (1), pat_list
     ->pat_data[von_cnt].surf1dhr = - (1),
     pat_list->pat_data[von_cnt].surf1dim = - (1), pat_list->pat_data[von_cnt].ox36 = - (1), pat_list
     ->pat_data[von_cnt].sterbpd = - (1),
     pat_list->pat_data[von_cnt].indometh = - (1), pat_list->pat_data[von_cnt].srglig = - (1),
     pat_list->pat_data[von_cnt].necsurg = - (1),
     pat_list->pat_data[von_cnt].ropsurg = - (1), pat_list->pat_data[von_cnt].othsurg = - (1),
     pat_list->pat_data[von_cnt].rds = - (1),
     pat_list->pat_data[von_cnt].pntx = - (1), pat_list->pat_data[von_cnt].pda = - (1), pat_list->
     pat_data[von_cnt].nec = - (1),
     pat_list->pat_data[von_cnt].giperf = - (1), pat_list->pat_data[von_cnt].lbpath = - (1), pat_list
     ->pat_data[von_cnt].cnegstaph = - (1),
     pat_list->pat_data[von_cnt].fungal = - (1), pat_list->pat_data[von_cnt].pvl = - (1), pat_list->
     pat_data[von_cnt].eyex = - (1),
     pat_list->pat_data[von_cnt].istage = - (1), pat_list->pat_data[von_cnt].cmal = - (1), pat_list->
     pat_data[von_cnt].bdcd1 = - (1),
     pat_list->pat_data[von_cnt].bdcd2 = - (1), pat_list->pat_data[von_cnt].bdcd3 = - (1), pat_list->
     pat_data[von_cnt].bdcd4 = - (1),
     pat_list->pat_data[von_cnt].bdcd5 = - (1), pat_list->pat_data[von_cnt].bdefect = fillstring(255,
      " "), pat_list->pat_data[von_cnt].entfeed = - (1),
     pat_list->pat_data[von_cnt].oxfinal = - (1), pat_list->pat_data[von_cnt].acfinal = - (1),
     pat_list->pat_data[von_cnt].fdisp = - (1),
     pat_list->pat_data[von_cnt].dwgt = - (1)
     IF ((pat_list->pat_data[von_cnt].deldie=1))
      pat_list->pat_data[von_cnt].los1 = 777
     ELSE
      pat_list->pat_data[von_cnt].los1 = (datetimediff(coe.initial_disch_dt_tm,coe.hosp_admit_dt_tm,1
       )+ 1)
     ENDIF
     pat_list->pat_data[von_cnt].transcode = - (1), pat_list->pat_data[von_cnt].f2disp = - (1),
     pat_list->pat_data[von_cnt].rbyday28 = 7,
     pat_list->pat_data[von_cnt].f3wgt = - (1)
     IF ((pat_list->pat_data[von_cnt].fdisp IN (1, 3, 5)))
      pat_list->pat_data[von_cnt].lostot = 777
     ELSEIF ((pat_list->pat_data[von_cnt].fdisp IN (2, 9)))
      pat_list->pat_data[von_cnt].lostot = 999
     ELSE
      pat_list->pat_data[von_cnt].lostot = (datetimediff(coe.final_disch_dt_tm,coe.hosp_admit_dt_tm,1
       )+ 1)
     ENDIF
     pat_list->pat_data[von_cnt].durvent = - (1), pat_list->pat_data[von_cnt].ventdays = - (1),
     pat_list->pat_data[von_cnt].ecmop = - (1),
     pat_list->pat_data[von_cnt].ecmowd = - (1), pat_list->pat_data[von_cnt].ntrcoxt = - (1),
     pat_list->pat_data[von_cnt].ntrcoxwd = - (1),
     pat_list->pat_data[von_cnt].carsrgp = - (1), pat_list->pat_data[von_cnt].carsrgpwd = - (1),
     pat_list->pat_data[von_cnt].hypoiep = - (1),
     pat_list->pat_data[von_cnt].hypoies = - (1), pat_list->pat_data[von_cnt].mecasp = - (1),
     pat_list->pat_data[von_cnt].trcsucma = - (1),
     pat_list->pat_data[von_cnt].seizure = - (1)
    FOOT REPORT
     stat = alterlist(pat_list->pat_data,von_cnt), pat_list->cnt = von_cnt
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_cev_value(p_person_id,p_cki,p_seq,p_default)
   DECLARE v_code_value = f8 WITH noconstant(- (1.0)), protect
   DECLARE ret_string = vc WITH noconstant(fillstring(20," ")), protect
   SET v_code_value = uar_get_code_by_cki(nullterm(p_cki))
   IF (v_code_value > 0)
    SELECT INTO "nl:"
     FROM cco_event cev
     WHERE cev.person_id=p_person_id
      AND cev.event_cd=v_code_value
      AND cev.clinical_seq=p_seq
      AND cev.active_ind=1
     DETAIL
      IF ((cnvtreal(cev.event_tag)=- (1.0)))
       ret_string = cnvtstring(p_default)
      ELSE
       ret_string = cev.event_tag
      ENDIF
     WITH nocounter
    ;end select
    RETURN(ret_string)
   ELSE
    RETURN(p_default)
   ENDIF
 END ;Subroutine
 SUBROUTINE load_event_data(p1)
  DECLARE pt_cnt = i2 WITH noconstant(0), protect
  FOR (pt_cnt = 1 TO pat_list->cnt)
    SET pat_list->pat_data[pt_cnt].bwgt = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!7365",1,99999))
    SET pat_list->pat_data[pt_cnt].gaweeks = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8089",1,99))
    SET pat_list->pat_data[pt_cnt].gadays = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8090",1,99))
    SET pat_list->pat_data[pt_cnt].locate = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8092",1,0))
    IF ((pat_list->pat_data[pt_cnt].locate=0))
     SET pat_list->pat_data[pt_cnt].dayadmiss = 77
    ENDIF
    SET pat_list->pat_data[pt_cnt].pcare = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8096",1,9))
    SET pat_list->pat_data[pt_cnt].aster = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8097",1,9))
    SET pat_list->pat_data[pt_cnt].vagdel = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!7215",1,9))
    SET pat_list->pat_data[pt_cnt].mult = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8098",1,9))
    SET pat_list->pat_data[pt_cnt].nbirths = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8099",1,99))
    SET pat_list->pat_data[pt_cnt].ap1 = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8100",1,99))
    SET pat_list->pat_data[pt_cnt].ap5 = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8101",1,99))
    SET pat_list->pat_data[pt_cnt].drox = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8102",1,9))
    SET pat_list->pat_data[pt_cnt].drbm = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8102",2,9))
    SET pat_list->pat_data[pt_cnt].dret = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8102",3,9))
    SET pat_list->pat_data[pt_cnt].drep = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8102",4,9))
    SET pat_list->pat_data[pt_cnt].drcc = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8102",5,9))
    SET pat_list->pat_data[pt_cnt].ebseps = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8311",1,9))
    SET pat_list->pat_data[pt_cnt].newox28 = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!6267",1,9))
    SET pat_list->pat_data[pt_cnt].usound1 = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8315",1,9))
    SET pat_list->pat_data[pt_cnt].ugrade1 = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8379",1,9))
    SET pat_list->pat_data[pt_cnt].oxy = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!3333",1,9))
    SET pat_list->pat_data[pt_cnt].vent = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!3333",2,9))
    SET pat_list->pat_data[pt_cnt].hfv = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!3333",3,9))
    SET pat_list->pat_data[pt_cnt].cpap = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8105",1,9))
    SET pat_list->pat_data[pt_cnt].cpapes = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!7676",1,9))
    SET pat_list->pat_data[pt_cnt].drsurf = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8106",1,9))
    SET pat_list->pat_data[pt_cnt].surfx = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "MUL.ORD!d00777",1,9))
    SET pat_list->pat_data[pt_cnt].surf1dhr = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"MUL.ORD!d00777",2,9999))
    SET pat_list->pat_data[pt_cnt].surf1dim = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"MUL.ORD!d00777",3,99))
    SET pat_list->pat_data[pt_cnt].ox36 = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8103",1,9))
    SET pat_list->pat_data[pt_cnt].sterbpd = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8330",1,9))
    SET pat_list->pat_data[pt_cnt].indometh = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"MUL.ORD!d00777",1,9))
    SET pat_list->pat_data[pt_cnt].srglig = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8381",1,9))
    SET pat_list->pat_data[pt_cnt].necsurg = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8381",2,9))
    SET pat_list->pat_data[pt_cnt].ropsurg = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8381",3,9))
    SET pat_list->pat_data[pt_cnt].othsurg = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8381",4,9))
    SET pat_list->pat_data[pt_cnt].rds = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8385",1,9))
    SET pat_list->pat_data[pt_cnt].pntx = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8386",1,9))
    SET pat_list->pat_data[pt_cnt].pda = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8387",1,9))
    SET pat_list->pat_data[pt_cnt].nec = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8388",1,9))
    SET pat_list->pat_data[pt_cnt].giperf = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8389",1,9))
    SET pat_list->pat_data[pt_cnt].lbpath = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8312",1,9))
    SET pat_list->pat_data[pt_cnt].cnegstaph = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8392",1,9))
    SET pat_list->pat_data[pt_cnt].fungal = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8394",1,9))
    SET pat_list->pat_data[pt_cnt].pvl = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8396",1,9))
    SET pat_list->pat_data[pt_cnt].eyex = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8397",1,9))
    SET pat_list->pat_data[pt_cnt].istage = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8398",1,9))
    SET pat_list->pat_data[pt_cnt].cmal = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8399",1,9))
    SET pat_list->pat_data[pt_cnt].bdcd1 = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8399",2,9999))
    SET pat_list->pat_data[pt_cnt].bdcd2 = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8399",3,9999))
    SET pat_list->pat_data[pt_cnt].bdcd3 = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8399",4,9999))
    SET pat_list->pat_data[pt_cnt].bdcd4 = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8399",5,9999))
    SET pat_list->pat_data[pt_cnt].bdcd5 = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8399",6,9999))
    SET pat_list->pat_data[pt_cnt].bdefect = get_bd_desc(pat_list->pat_data[pt_cnt].person_id,
     "CKI.EC!8399",1,"77")
    SET pat_list->pat_data[pt_cnt].entfeed = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8128",1,9))
    SET pat_list->pat_data[pt_cnt].oxfinal = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8127",1,9))
    SET pat_list->pat_data[pt_cnt].acfinal = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8127",2,9))
    SET pat_list->pat_data[pt_cnt].fdisp = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8130",1,9))
    SET pat_list->pat_data[pt_cnt].dwgt = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!4051",1,99999))
    SET pat_list->pat_data[pt_cnt].transcode = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8129",1,9))
    SET pat_list->pat_data[pt_cnt].f2disp = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8400",1,9))
    SET pat_list->pat_data[pt_cnt].rbyday28 = 7
    SET pat_list->pat_data[pt_cnt].f3wgt = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!4051",2,99999))
    SET pat_list->pat_data[pt_cnt].durvent = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!7672",1,9))
    SET pat_list->pat_data[pt_cnt].ventdays = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!7991",1,9999))
    SET pat_list->pat_data[pt_cnt].ecmop = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].person_id,
      "CKI.EC!8404",1,9))
    SET pat_list->pat_data[pt_cnt].ecmowd = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8405",1,9))
    SET pat_list->pat_data[pt_cnt].ntrcoxt = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8107",1,9))
    SET pat_list->pat_data[pt_cnt].ntrcoxwd = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8412",1,9))
    SET pat_list->pat_data[pt_cnt].carsrgp = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8406",1,9))
    SET pat_list->pat_data[pt_cnt].carsrgpwd = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8407",1,9))
    SET pat_list->pat_data[pt_cnt].hypoiep = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8408",1,9))
    SET pat_list->pat_data[pt_cnt].hypoies = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8409",1,9))
    SET pat_list->pat_data[pt_cnt].mecasp = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8402",1,9))
    SET pat_list->pat_data[pt_cnt].trcsucma = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8403",1,9))
    SET pat_list->pat_data[pt_cnt].seizure = cnvtint(get_cev_value(pat_list->pat_data[pt_cnt].
      person_id,"CKI.EC!8108",1,9))
    IF ((pat_list->pat_data[pt_cnt].deldie=1))
     SET pat_list->pat_data[von_cnt].ebseps = 7
     SET pat_list->pat_data[pt_cnt].newox28 = 7
     SET pat_list->pat_data[pt_cnt].usound1 = 7
     SET pat_list->pat_data[pt_cnt].ugrade1 = 7
     SET pat_list->pat_data[pt_cnt].die12 = 7
     SET pat_list->pat_data[pt_cnt].oxy = 7
     SET pat_list->pat_data[pt_cnt].vent = 7
     SET pat_list->pat_data[pt_cnt].hfv = 7
     SET pat_list->pat_data[pt_cnt].cpap = 7
     SET pat_list->pat_data[pt_cnt].cpapes = 7
     SET pat_list->pat_data[pt_cnt].ox36 = 7
     SET pat_list->pat_data[pt_cnt].sterbpd = 7
     SET pat_list->pat_data[pt_cnt].indometh = 7
     SET pat_list->pat_data[pt_cnt].srglig = 7
     SET pat_list->pat_data[pt_cnt].necsurg = 7
     SET pat_list->pat_data[pt_cnt].ropsurg = 7
     SET pat_list->pat_data[pt_cnt].othsurg = 7
     SET pat_list->pat_data[pt_cnt].rds = 7
     SET pat_list->pat_data[pt_cnt].pntx = 7
     SET pat_list->pat_data[pt_cnt].pda = 7
     SET pat_list->pat_data[pt_cnt].nec = 7
     SET pat_list->pat_data[pt_cnt].giperf = 7
     SET pat_list->pat_data[pt_cnt].lbpath = 7
     SET pat_list->pat_data[pt_cnt].cnegstaph = 7
     SET pat_list->pat_data[pt_cnt].fungal = 7
     SET pat_list->pat_data[pt_cnt].pvl = 7
     SET pat_list->pat_data[pt_cnt].eyex = 7
     SET pat_list->pat_data[pt_cnt].istage = 7
     SET pat_list->pat_data[pt_cnt].entfeed = 7
     SET pat_list->pat_data[pt_cnt].oxfinal = 7
     SET pat_list->pat_data[pt_cnt].acfinal = 7
     SET pat_list->pat_data[pt_cnt].fdisp = 7
     SET pat_list->pat_data[pt_cnt].dwgt = 77777
     SET pat_list->pat_data[pt_cnt].los1 = 777
     SET pat_list->pat_data[pt_cnt].durvent = 7
     SET pat_list->pat_data[pt_cnt].ventdays = 7777
     SET pat_list->pat_data[pt_cnt].ecmop = 7
     SET pat_list->pat_data[pt_cnt].ecmowd = 7
     SET pat_list->pat_data[pt_cnt].ntrcoxt = 7
     SET pat_list->pat_data[pt_cnt].ntrcoxwd = 7
     SET pat_list->pat_data[pt_cnt].carsrgp = 7
     SET pat_list->pat_data[pt_cnt].carsrgpwd = 7
     SET pat_list->pat_data[pt_cnt].hypoiep = 7
     SET pat_list->pat_data[pt_cnt].hypoies = 7
     SET pat_list->pat_data[pt_cnt].seizure = 7
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].mult=0))
     SET pat_list->pat_data[pt_cnt].nbirths = 77
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].usound1 IN (0, 7)))
     SET pat_list->pat_data[pt_cnt].ugrade1 = 7
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].cpap IN (0, 7)))
     SET pat_list->pat_data[pt_cnt].cpapes = 7
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].cpap=9))
     SET pat_list->pat_data[pt_cnt].cpapes = 9
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].surfx=0))
     SET pat_list->pat_data[pt_cnt].surf1dhr = 7777
     SET pat_list->pat_data[pt_cnt].surf1dim = 77
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].surfx=9))
     SET pat_list->pat_data[pt_cnt].surf1dhr = 9999
     SET pat_list->pat_data[pt_cnt].surf1dim = 99
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].eyex IN (0, 7)))
     SET pat_list->pat_data[pt_cnt].istage = 7
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].eyex=9))
     SET pat_list->pat_data[pt_cnt].istage = 9
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].cmal=0))
     SET pat_list->pat_data[pt_cnt].bdcd1 = 7777
     SET pat_list->pat_data[pt_cnt].bdcd2 = 7777
     SET pat_list->pat_data[pt_cnt].bdcd3 = 7777
     SET pat_list->pat_data[pt_cnt].bdcd4 = 7777
     SET pat_list->pat_data[pt_cnt].bdcd5 = 7777
     SET pat_list->pat_data[pt_cnt].bdefect = "77"
    ELSEIF ((pat_list->pat_data[pt_cnt].cmal=9))
     SET pat_list->pat_data[pt_cnt].bdcd1 = 9999
     SET pat_list->pat_data[pt_cnt].bdcd2 = 9999
     SET pat_list->pat_data[pt_cnt].bdcd3 = 9999
     SET pat_list->pat_data[pt_cnt].bdcd4 = 9999
     SET pat_list->pat_data[pt_cnt].bdcd5 = 9999
     SET pat_list->pat_data[pt_cnt].bdefect = "99"
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].fdisp IN (1, 3, 5, 7)))
     SET pat_list->pat_data[pt_cnt].transcode = 7
     SET pat_list->pat_data[pt_cnt].xfer_out = 7
     SET pat_list->pat_data[pt_cnt].f2disp = 7
    ELSEIF ((pat_list->pat_data[pt_cnt].fdisp=9))
     SET pat_list->pat_data[pt_cnt].transcode = 9
     SET pat_list->pat_data[pt_cnt].xfer_out = 9
     SET pat_list->pat_data[pt_cnt].f2disp = 9
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].f2disp IN (1, 2, 3, 5, 7)))
     SET pat_list->pat_data[pt_cnt].rbyday28 = 7
     SET pat_list->pat_data[pt_cnt].f3disp = 7
    ELSEIF ((pat_list->pat_data[pt_cnt].f2disp=9))
     SET pat_list->pat_data[pt_cnt].rbyday28 = 9
     SET pat_list->pat_data[pt_cnt].f3disp = 9
     SET pat_list->pat_data[pt_cnt].udisp = 9
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].f2disp IN (1, 3, 5, 7)))
     SET pat_list->pat_data[pt_cnt].udisp = 7
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].f3disp=7))
     SET pat_list->pat_data[pt_cnt].f3wgt = 7777
    ELSEIF ((pat_list->pat_data[pt_cnt].f3disp=9))
     SET pat_list->pat_data[pt_cnt].f3wgt = 9999
     SET pat_list->pat_data[pt_cnt].udisp = 9
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].f3disp IN (1, 3, 5)))
     SET pat_list->pat_data[pt_cnt].udisp = 7
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].fdisp IN (1, 3, 5)))
     SET pat_list->pat_data[pt_cnt].lostot = 777
    ELSEIF ((pat_list->pat_data[pt_cnt].fdisp=9))
     SET pat_list->pat_data[pt_cnt].lostot = 999
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].durvent IN (0, 1, 2, 7)))
     SET pat_list->pat_data[pt_cnt].ventdays = 7
    ELSEIF ((pat_list->pat_data[pt_cnt].durvent=9))
     SET pat_list->pat_data[pt_cnt].ventdays = 9
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].ecmop IN (0, 7)))
     SET pat_list->pat_data[pt_cnt].ecmowd = 7
    ELSEIF ((pat_list->pat_data[pt_cnt].ecmop=9))
     SET pat_list->pat_data[pt_cnt].ecmowd = 9
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].ntrcoxt IN (0, 7)))
     SET pat_list->pat_data[pt_cnt].ntrcoxwd = 7
    ELSEIF ((pat_list->pat_data[pt_cnt].ntrcoxt=9))
     SET pat_list->pat_data[pt_cnt].ntrcoxwd = 9
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].carsrgp IN (0, 7)))
     SET pat_list->pat_data[pt_cnt].carsrgpwd = 7
    ELSEIF ((pat_list->pat_data[pt_cnt].carsrgp=9))
     SET pat_list->pat_data[pt_cnt].carsrgpwd = 9
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].hypoiep IN (0, 7)))
     SET pat_list->pat_data[pt_cnt].hypoies = 7
    ELSEIF ((pat_list->pat_data[pt_cnt].hypoiep=9))
     SET pat_list->pat_data[pt_cnt].hypoies = 9
    ENDIF
    IF ((pat_list->pat_data[pt_cnt].mecasp=0))
     SET pat_list->pat_data[pt_cnt].trcsucma = 7
    ELSEIF ((pat_list->pat_data[pt_cnt].mecasp=9))
     SET pat_list->pat_data[pt_cnt].trcsucma = 9
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_bd_desc(p_person_id,p_cki,p_seq_num,p_default)
   DECLARE v_event_cd = f8 WITH constant(uar_get_code_by_cki(nullterm(p_cki))), protect
   DECLARE lt_string = vc WITH noconstant(fillstring(255," ")), protect
   DECLARE v_lt_size = i2 WITH noconstant(0), protect
   SET lt_string = p_default
   SELECT INTO "nl:"
    FROM cco_event cev,
     long_text lt
    PLAN (cev
     WHERE cev.person_id=p_person_id
      AND cev.event_cd=v_event_cd
      AND cev.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
      AND cev.view_level=1
      AND cev.publish_flag=1
      AND cev.result_status_cd != inerror_cd
      AND cev.clinical_seq=p_seq_num
      AND cev.active_ind=1)
     JOIN (lt
     WHERE lt.parent_entity_id=cev.cco_event_id
      AND lt.parent_entity_name="CCO_EVENT"
      AND lt.active_ind=1)
    DETAIL
     CALL echo("got long text"),
     CALL echo(build("lt.long_text=",trim(substring(1,255,lt.long_text)))), v_lt_size = size(trim(
       substring(1,255,lt.long_text)),1)
     IF (v_lt_size > 0)
      lt_string = trim(substring(1,255,lt.long_text))
     ENDIF
    WITH nocounter
   ;end select
   RETURN(lt_string)
 END ;Subroutine
 SUBROUTINE create_file(p1)
  SELECT INTO value(v_path_file_name)
   FROM (dummyt d  WITH seq = pat_list->cnt)
   HEAD REPORT
    out_row = fillstring(5900," "), out_row = build("FILENUM,FILEDATE,DELETED,APPLICATION,VERSION,"),
    out_row = build(out_row,
     "HOSPNO,ID,BYEAR,BWGT,GAWEEKS,GADAYS,DELDIE,LOCATE,DAYADMISS,HISP,NEWRACE,"),
    out_row = build(out_row,"PCARE,ASTER,VAGDEL,SEX,MULT,NBIRTHS,AP1,AP5,DROX,DRBM,DRET,DREP,DRCC,"),
    out_row = build(out_row,
     "EBSEPS,NEWOX28,USOUND1,UGRADE1,DIE12,OXY,VENT,HFV,CPAP,CPAPES,DRSURF,SURFX,"), out_row = build(
     out_row,"SURF1DHR,SURF1DMIN,OX36,STERBPD,INDOMETH,SRGLIG,NECSURG,ROPSURG,OTHSURG,RDS,"),
    out_row = build(out_row,"PNTX,PDA,NEC,GIPERF,LBPATH,CNEGSTAPH,FUNGAL,PVL,EYEX,ISTAGE,CMAL,BDCD1,"
     ), out_row = build(out_row,
     "BDCD2,BDCD3,BDCD4,BDCD5,BDEFECT,ENTFEED,OXFINAL,ACFINAL,FDISP,DWGT,LOS1,"), out_row = build(
     out_row,"TRANSCODE,XFER_OUT,F2DISP,RBYDAY28,F3DISP,F3WGT,UDISP,LOSTOT,DURVENT,"),
    out_row = build(out_row,"VENTDAYS,ECMOP,ECMOWD,NTRCOXT,NTRCOXWD,CARSRGP,CARSRGWD,HYPOIEP,"),
    out_row = build(out_row,"HYPOIES,MECASP,TRCSUCMA,SEIZURE"), out_row
   DETAIL
    out_row = fillstring(5900," "), row + 1, out_row = build(v_filenum,",",c_curdate_disp,","," ",
     ",",c_application,",",c_version,","),
    out_row = build(out_row,v_hospnum,","), out_row = build(out_row,pat_list->pat_data[d.seq].id,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].byear,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].bwgt,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].gaweeks,","), out_row = build(out_row,pat_list->pat_data[d.seq].gadays,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].deldie,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].locate,","), out_row = build(out_row,pat_list->pat_data[d.seq].dayadmiss,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].hisp,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].newrace,","), out_row = build(out_row,pat_list->pat_data[d.seq].pcare,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].aster,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].vagdel,","), out_row = build(out_row,pat_list->pat_data[d.seq].sex,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].mult,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].nbirths,","), out_row = build(out_row,pat_list->pat_data[d.seq].ap1,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].ap5,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].drox,","), out_row = build(out_row,pat_list->pat_data[d.seq].drbm,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].dret,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].drep,","), out_row = build(out_row,pat_list->pat_data[d.seq].drcc,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].ebseps,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].newox28,","), out_row = build(out_row,pat_list->pat_data[d.seq].usound1,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].ugrade1,","), out_row = build(out_row,pat_list
     ->pat_data[d.seq].die12,","), out_row = build(out_row,pat_list->pat_data[d.seq].oxy,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].vent,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].hfv,","), out_row = build(out_row,pat_list->pat_data[d.seq].cpap,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].cpapes,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].drsurf,","), out_row = build(out_row,pat_list->pat_data[d.seq].surfx,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].surf1dhr,","), out_row = build(out_row,pat_list
     ->pat_data[d.seq].surf1dim,","), out_row = build(out_row,pat_list->pat_data[d.seq].ox36,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].sterbpd,","), out_row = build(out_row,pat_list
     ->pat_data[d.seq].indometh,","), out_row = build(out_row,pat_list->pat_data[d.seq].srglig,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].necsurg,","), out_row = build(out_row,pat_list
     ->pat_data[d.seq].ropsurg,","), out_row = build(out_row,pat_list->pat_data[d.seq].othsurg,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].rds,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].pntx,","), out_row = build(out_row,pat_list->pat_data[d.seq].pda,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].nec,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].giperf,","), out_row = build(out_row,pat_list->pat_data[d.seq].lbpath,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].cnegstaph,","), out_row = build(out_row,
     pat_list->pat_data[d.seq].fungal,","), out_row = build(out_row,pat_list->pat_data[d.seq].pvl,","
     ),
    out_row = build(out_row,pat_list->pat_data[d.seq].eyex,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].istage,","), out_row = build(out_row,pat_list->pat_data[d.seq].cmal,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].bdcd1,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].bdcd2,","), out_row = build(out_row,pat_list->pat_data[d.seq].bdcd3,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].bdcd4,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].bdcd5,","), out_row = build(out_row,char(34),pat_list->pat_data[d.seq].bdefect,
     char(34),","),
    out_row = build(out_row,pat_list->pat_data[d.seq].entfeed,","), out_row = build(out_row,pat_list
     ->pat_data[d.seq].oxfinal,","), out_row = build(out_row,pat_list->pat_data[d.seq].acfinal,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].fdisp,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].dwgt,","), out_row = build(out_row,pat_list->pat_data[d.seq].los1,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].transcode,","), out_row = build(out_row,
     pat_list->pat_data[d.seq].xfer_out,","), out_row = build(out_row,pat_list->pat_data[d.seq].
     f2disp,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].rbyday28,","), out_row = build(out_row,pat_list
     ->pat_data[d.seq].f3disp,","), out_row = build(out_row,pat_list->pat_data[d.seq].f3wgt,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].udisp,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].lostot,","), out_row = build(out_row,pat_list->pat_data[d.seq].durvent,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].ventdays,","), out_row = build(out_row,pat_list
     ->pat_data[d.seq].ecmop,","), out_row = build(out_row,pat_list->pat_data[d.seq].ecmowd,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].ntrcoxt,","), out_row = build(out_row,pat_list
     ->pat_data[d.seq].ntrcoxwd,","), out_row = build(out_row,pat_list->pat_data[d.seq].carsrgp,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].carsrgpwd,","), out_row = build(out_row,
     pat_list->pat_data[d.seq].hypoiep,","), out_row = build(out_row,pat_list->pat_data[d.seq].
     hypoies,","),
    out_row = build(out_row,pat_list->pat_data[d.seq].mecasp,","), out_row = build(out_row,pat_list->
     pat_data[d.seq].trcsucma,","), out_row = build(out_row,pat_list->pat_data[d.seq].seizure),
    out_row
   WITH maxcol = 6000, formfeed = none, format = variable,
    maxrow = 1
  ;end select
  IF (curqual=0)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE print_no_pat_report(pmessage)
   SELECT INTO  $OUTPUTTO
    FROM (dummyt d  WITH seq = pat_list->cnt)
    HEAD PAGE
     row + 1, col 1, c_curdatetime_disp,
     col 50, "By Module: CCO_RPT_VON_EXTRACT_PROMPT", row + 1,
     CALL center("Cerner Millennium",0,80), row + 1,
     CALL center("Critical Outcomes",0,80),
     row + 1,
     CALL center("*** Vermont Oxford Network ***",0,80), row + 1,
     vtitle = build("Extract Report -",pmessage),
     CALL center(vtitle,0,80), row + 1,
     row + 1,
     CALL center(v_org_name,0,80), row + 2,
     col 1, "EXTRACT FILE NAME= N/A", row + 1,
     line = fillstring(80,"-"), col 1, line,
     row + 1
    DETAIL
     col 1, pmessage, row + 1
    WITH nocounter, format, separator = " "
   ;end select
 END ;Subroutine
 SUBROUTINE print_report(p1)
   SELECT INTO  $OUTPUTTO
    FROM (dummyt d  WITH seq = pat_list->cnt)
    HEAD PAGE
     row + 1, col 1, c_curdatetime_disp,
     col 50, "By Module: CCO_RPT_VON_EXTRACT_PROMPT", row + 1,
     CALL center("Cerner Millennium",0,80), row + 1,
     CALL center("Critical Outcomes",0,80),
     row + 1,
     CALL center("*** Vermont Oxford Network ***",0,80), row + 1,
     CALL center("Extract Report",0,80), row + 1,
     CALL center(v_org_name,0,80),
     row + 2, extract_line = build("EXTRACT FILE NAME=",v_csv_file_name), extract_line,
     row + 1, count_line = build("Total Records in Extract=",pat_list->cnt), count_line,
     row + 2, col 2, "PATIENT NAME",
     row + 1, line = fillstring(80,"-"), col 1,
     line, row + 1
    DETAIL
     cnt_line = build("#",d.seq), col 2, cnt_line,
     col 10, pat_list->pat_data[d.seq].name, row + 1
    WITH nocounter, format, separator = " "
   ;end select
 END ;Subroutine
 SUBROUTINE print_error_rpt(p_text)
   SELECT INTO  $OUTPUTTO
    FROM (dummyt d  WITH seq = 1)
    HEAD PAGE
     row + 1, col 1, c_curdatetime_disp,
     col 50, "By Module: CCO_RPT_VON_EXTRACT_PROMPT", row + 1,
     CALL center("Cerner Millennium",0,80), row + 1,
     CALL center("Critical Outcomes",0,80),
     row + 1,
     CALL center("*** Vermont Oxford Network ***",0,80), row + 1,
     CALL center("Extract Error Report",0,80), row + 2,
     CALL center(v_org_name,0,80),
     row + 2, row + 1, line = fillstring(80,"-"),
     col 1, line, row + 1
    DETAIL
     col 1, "ERROR = ", p_text,
     row + 1
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
