CREATE PROGRAM ags_extract_phr_members:dba
 PROMPT
  "JOB_ID (0.0) = " = 0,
  "CLIENT_MNEMONIC ('NONE') = " = "NONE",
  "DEBUG MODE (0 = Off, 1 = On) = " = 0
  WITH djob_id, sclient_mnemonic, idebug_mode
 CALL echo("***")
 CALL echo("***   BEG :: AGS_EXTRACT_PHR_MEMBERS")
 CALL echo("***")
 DECLARE define_logging_sub = i2 WITH protect, noconstant(false)
 IF ((validate(failed,- (1))=- (1)))
  EXECUTE cclseclogin2
  CALL echo("***")
  CALL echo("***   Declare Common Variables")
  CALL echo("***")
  IF ((validate(false,- (1))=- (1)))
   DECLARE false = i2 WITH public, noconstant(0)
  ENDIF
  IF ((validate(true,- (1))=- (1)))
   DECLARE true = i2 WITH public, noconstant(1)
  ENDIF
  DECLARE gen_nbr_error = i2 WITH public, noconstant(3)
  DECLARE insert_error = i2 WITH public, noconstant(4)
  DECLARE update_error = i2 WITH public, noconstant(5)
  DECLARE delete_error = i2 WITH public, noconstant(6)
  DECLARE select_error = i2 WITH public, noconstant(7)
  DECLARE lock_error = i2 WITH public, noconstant(8)
  DECLARE input_error = i2 WITH public, noconstant(9)
  DECLARE exe_error = i2 WITH public, noconstant(10)
  DECLARE failed = i2 WITH public, noconstant(false)
  DECLARE table_name = c50 WITH public, noconstant(" ")
  DECLARE serrmsg = vc WITH public, noconstant(" ")
  DECLARE ierrcode = i2 WITH public, noconstant(0)
  FREE RECORD reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  CALL echo("***")
  CALL echo("***   BEG LOGGING")
  CALL echo("***")
  FREE RECORD email
  RECORD email(
    1 qual_knt = i4
    1 qual[*]
      2 address = vc
      2 send_flag = i2
  )
  DECLARE eknt = i4 WITH public, noconstant(0)
  FREE RECORD log
  RECORD log(
    1 qual_knt = i4
    1 qual[*]
      2 smsgtype = c12
      2 dmsg_dt_tm = dq8
      2 smsg = vc
  )
  DECLARE handle_logging(slog_file=vc,semail=vc,istatus_flag=i4) = null WITH protect
  DECLARE sstatus_file_name = vc WITH protect, noconstant(concat("ags_extract_phr_members_",format(
     cnvtdatetime(curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "BEG >> AGS_EXTRACT_PHR_MEMBERS"
  SET define_logging_sub = true
 ELSE
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "BEG >> AGS_EXTRACT_PHR_MEMBERS"
  CALL echo("***")
  CALL echo("***   Common Variables/Records Declared in calling program")
  CALL echo("***")
 ENDIF
 DECLARE the_job_id = f8 WITH protect, noconstant(0.0)
 SET the_job_id =  $DJOB_ID
 DECLARE the_client_mnemonic = vc WITH protect, noconstant("")
 SET the_client_mnemonic = trim( $SCLIENT_MNEMONIC,3)
 DECLARE the_debug_mode = i2 WITH protect, noconstant(0)
 SET the_debug_mode =  $IDEBUG_MODE
 IF (the_debug_mode < 1)
  SET trace = noechorecord
  SET trace = nocost
  SET trace = nocallecho
  SET message = noinformation
 ENDIF
 DECLARE floor_data_id = f8 WITH protect, noconstant(0.0)
 DECLARE b_data_id = f8 WITH protect, noconstant(0.0)
 DECLARE e_data_id = f8 WITH protect, noconstant(0.0)
 DECLARE m_data_id = f8 WITH protect, noconstant(0.0)
 DECLARE interval_size = i4 WITH protect, noconstant(50000)
 FREE RECORD temp_rec
 RECORD temp_rec(
   1 qual_knt = i4
   1 qual[*]
     2 person_id = f8
     2 first_name = vc
     2 middle_name = vc
     2 last_name = vc
     2 gender = c1
     2 birthdate = c10
     2 country = vc
     2 home_address_1 = vc
     2 home_address_2 = vc
     2 city = vc
     2 state = vc
     2 zip_code = vc
     2 email_address = vc
     2 social_security = vc
     2 username = vc
     2 password = c8
     2 identify = c1
     2 associate_id = c1
     2 client_mnem = vc
     2 emplid = vc
     2 dependent = c1
     2 benef = c1
     2 asthma = c1
     2 asthma_care_coordinator = c1
     2 asthma_proxy = c1
     2 chf = c1
     2 chf_care_coordinator = c1
     2 chf_proxy = c1
     2 diabetes = c1
     2 diabetes_care_coordinator = c1
     2 diabetes_proxy = c1
     2 sleep = c1
     2 sleep_care_coordinator = c1
     2 sleep_proxy = c1
 )
 DECLARE phr_member_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MESSAGING"))
 DECLARE male_sex_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",57,"MALE"))
 DECLARE female_sex_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",57,"FEMALE"))
 DECLARE exp_size = i4 WITH protect, noconstant(250)
 DECLARE exp_total = i4 WITH protect, noconstant(0)
 DECLARE exp_beg = i4 WITH protect, noconstant(1)
 DECLARE exp_end = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE ssn_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE home_address_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE temp_line = vc WITH protect, noconstant("")
 DECLARE phr_export_member_file = vc WITH protect, noconstant("")
 DECLARE rmv_vms_file_name = vc WITH protect, noconstant("")
 DECLARE b_seq_nbr = i4 WITH protect, noconstant(1)
 DECLARE e_seq_nbr = i4 WITH protect, noconstant(0)
 DECLARE m_seq_nbr = i4 WITH protect, noconstant(0)
 DECLARE file_seq_size = i4 WITH protect, constant(999)
 DECLARE file_wknt = i4 WITH protect, noconstant(0)
 CALL echo("***")
 CALL echo("***   Log Parameters")
 CALL echo("***")
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("JOB_ID = ",trim(cnvtstring(the_job_id)))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("CLIENT_MNEMONIC = ",trim(the_client_mnemonic))
 CALL echo("***")
 CALL echo("***   Check Validate Code Values")
 CALL echo("***")
 IF (phr_member_cd < 1)
  SET failed = select_error
  SET table_name = "GET PHR_MEMBER_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "PHR_MEMBER_CD :: Select Error :: CODE_VALUE for CDF_MEANING MESSAGING invalid from CODE_SET 4"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (male_sex_cd < 1)
  SET failed = select_error
  SET table_name = "GET MALE_SEX_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "MALE_SEX_CD :: Select Error :: CODE_VALUE for CDF_MEANING MALE invalid from CODE_SET 57"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (female_sex_cd < 1)
  SET failed = select_error
  SET table_name = "GET FEMALE_SEX_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "FEMALE_SEX_CD :: Select Error :: CODE_VALUE for CDF_MEANING FEMALE invalid from CODE_SET 57"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (ssn_type_cd < 1)
  SET failed = select_error
  SET table_name = "GET SSN_TYPE_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "SSN_TYPE_CD :: Select Error :: CODE_VALUE for CDF_MEANING SSN invalid from CODE_SET 4"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (home_address_cd < 1)
  SET failed = select_error
  SET table_name = "GET HOME_ADDRESS_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "HOME_ADDRESS_CD :: Select Error :: CODE_VALUE for CDF_MEANING HOME invalid from CODE_SET 212"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Check THE_CLIENT_MNEMONIC")
 CALL echo("***")
 IF (((the_client_mnemonic="NONE") OR ( NOT (size(trim(the_client_mnemonic)) > 0))) )
  SET failed = input_error
  SET table_name = "PARAMETER VALIDATION"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("INVALID THE_CLIENT_MNEMONIC :: Input Error :: ",trim(
    the_client_mnemonic))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Starting Numbers")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT
  IF (the_job_id > 0)
   PLAN (a
    WHERE a.ags_job_id=the_job_id
     AND a.person_id > 0)
  ELSE
   PLAN (a
    WHERE a.person_id > 0)
  ENDIF
  INTO "nl:"
  the_min = min(a.ags_person_data_id), the_max = max(a.ags_person_data_id)
  FROM ags_person_data a
  HEAD REPORT
   x = 1
  DETAIL
   x = 1
  FOOT REPORT
   floor_data_id = the_min, b_data_id = the_min, m_data_id = the_max
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "AGS_PERSON_DATA"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("AGS_PERSON_DATA :: Select Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (((b_data_id+ interval_size) > m_data_id))
  SET e_data_id = m_data_id
 ELSE
  SET e_data_id = (b_data_id+ interval_size)
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("B_DATA_ID = ",trim(cnvtstring(b_data_id)))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("M_DATA_ID = ",trim(cnvtstring(m_data_id)))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("FLOOR_DATA_ID = ",trim(cnvtstring(floor_data_id)))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("INTERVAL_SIZE = ",trim(cnvtstring(interval_size)))
 CALL echo("***")
 CALL echo("***   Process Data Set")
 CALL echo("***")
 WHILE (b_data_id <= e_data_id)
   CALL echo("***")
   CALL echo(concat("***   PROCESSING :: B_DATA_ID = ",trim(cnvtstring(b_data_id))," :: E_DATA_ID = ",
     trim(cnvtstring(e_data_id))," :: M_DATA_ID = ",
     trim(cnvtstring(m_data_id))," :: FLOOR_DATA_ID = ",trim(cnvtstring(floor_data_id))))
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("BEG PROCESSING : B_DATA_ID = ",trim(cnvtstring(
      b_data_id))," : E_DATA_ID = ",trim(cnvtstring(e_data_id))," : M_DATA_ID = ",
    trim(cnvtstring(m_data_id)))
   CALL echo("***")
   CALL echo("***   Determine Working Person List")
   CALL echo("***")
   SET stat = initrec(temp_rec)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM ags_person_data a1,
     person p,
     ags_person_data a2,
     person_alias pa
    PLAN (a1
     WHERE a1.ags_person_data_id >= b_data_id
      AND a1.ags_person_data_id <= e_data_id
      AND a1.person_id > 0)
     JOIN (p
     WHERE p.person_id=a1.person_id
      AND size(trim(p.name_first)) > 0
      AND size(trim(p.name_last)) > 0
      AND p.abs_birth_dt_tm > cnvtdatetime("01-JAN-1800")
      AND p.sex_cd IN (male_sex_cd, female_sex_cd))
     JOIN (a2
     WHERE a2.ags_person_data_id >= outerjoin(floor_data_id)
      AND a2.ags_person_data_id < outerjoin(b_data_id)
      AND a2.person_id=outerjoin(a1.person_id))
     JOIN (pa
     WHERE pa.person_id=outerjoin(p.person_id)
      AND pa.person_alias_type_cd=outerjoin(phr_member_cd)
      AND pa.active_ind=outerjoin(1))
    ORDER BY p.person_id
    HEAD REPORT
     aknt = 0, stat = alterlist(temp_rec->qual,10)
    HEAD p.person_id
     IF (pa.person_alias_id < 1
      AND a2.ags_person_data_id < 1)
      aknt = (aknt+ 1)
      IF (mod(aknt,10)=1
       AND aknt != 1)
       stat = alterlist(temp_rec->qual,(aknt+ 9))
      ENDIF
      temp_rec->qual[aknt].person_id = p.person_id, temp_rec->qual[aknt].first_name = trim(p
       .name_first), temp_rec->qual[aknt].middle_name = trim(p.name_middle),
      temp_rec->qual[aknt].last_name = trim(p.name_last)
      IF (p.sex_cd=male_sex_cd)
       temp_rec->qual[aknt].gender = "M"
      ELSE
       temp_rec->qual[aknt].gender = "F"
      ENDIF
      temp_rec->qual[aknt].birthdate = format(cnvtdatetime(p.abs_birth_dt_tm),"mm/dd/yyyy;;q"),
      temp_rec->qual[aknt].email_address = "@.", temp_rec->qual[aknt].username = concat(substring(1,1,
        temp_rec->qual[aknt].first_name),trim(temp_rec->qual[aknt].last_name),"0000"),
      temp_rec->qual[aknt].password = format(cnvtdatetime(p.abs_birth_dt_tm),"MMDDYYYY;;q"), temp_rec
      ->qual[aknt].identify = "N", temp_rec->qual[aknt].client_mnem = the_client_mnemonic,
      temp_rec->qual[aknt].emplid = trim(cnvtstring(p.person_id)), temp_rec->qual[aknt].asthma = "N",
      temp_rec->qual[aknt].asthma_proxy = "N",
      temp_rec->qual[aknt].chf = "N", temp_rec->qual[aknt].chf_proxy = "N", temp_rec->qual[aknt].
      diabetes = "N",
      temp_rec->qual[aknt].diabetes_proxy = "N", temp_rec->qual[aknt].sleep = "N", temp_rec->qual[
      aknt].sleep_proxy = "N"
     ENDIF
    FOOT REPORT
     temp_rec->qual_knt = aknt, stat = alterlist(temp_rec->qual,aknt)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "PERSON"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("PERSON :: Select Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   IF ((temp_rec->qual_knt > 0))
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "INFO"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("Processing ",trim(cnvtstring(temp_rec->qual_knt)),
     " person(s)")
    CALL echo("***")
    CALL echo("***   Get SSN")
    CALL echo("***")
    SET exp_size = 250
    SET exp_total = (temp_rec->qual_knt+ (exp_size - mod(temp_rec->qual_knt,exp_size)))
    SET exp_beg = 1
    SET exp_end = 250
    SET num = 0
    SET stat = alterlist(temp_rec->qual,exp_total)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM person_alias pa,
      (dummyt d  WITH seq = value((exp_total/ exp_size)))
     PLAN (d
      WHERE assign(exp_beg,evaluate(d.seq,1,1,(exp_beg+ exp_size)))
       AND assign(exp_end,(exp_beg+ (exp_size - 1))))
      JOIN (pa
      WHERE expand(num,exp_beg,exp_end,pa.person_id,temp_rec->qual[num].person_id,
       exp_size)
       AND pa.person_alias_type_cd=ssn_type_cd
       AND pa.active_ind=1
       AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     ORDER BY pa.person_id, pa.beg_effective_dt_tm DESC
     HEAD pa.person_id
      IF (pa.person_id > 0)
       pos = 0, pos = locateval(num,1,temp_rec->qual_knt,pa.person_id,temp_rec->qual[num].person_id)
       IF (pos > 0)
        i_str_len = 0
        IF (size(trim(pa.alias)) > 0)
         temp_rec->qual[pos].social_security = trim(pa.alias), i_str_len = textlen(pa.alias)
         IF (i_str_len >= 4)
          temp_rec->qual[pos].username = concat(substring(1,1,temp_rec->qual[pos].first_name),trim(
            temp_rec->qual[pos].last_name),substring(((i_str_len - 4)+ 1),4,trim(pa.alias)))
         ELSEIF (i_str_len=3)
          temp_rec->qual[pos].username = concat(substring(1,1,temp_rec->qual[pos].first_name),trim(
            temp_rec->qual[pos].last_name),"0",trim(pa.alias))
         ELSEIF (i_str_len=2)
          temp_rec->qual[pos].username = concat(substring(1,1,temp_rec->qual[pos].first_name),trim(
            temp_rec->qual[pos].last_name),"00",trim(pa.alias))
         ELSEIF (i_str_len=1)
          temp_rec->qual[pos].username = concat(substring(1,1,temp_rec->qual[pos].first_name),trim(
            temp_rec->qual[pos].last_name),"000",trim(pa.alias))
         ELSE
          temp_rec->qual[pos].username = temp_rec->qual[pos].username
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "SSN PERSON_ALIAS"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("SSN PERSON_ALIAS :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET stat = alterlist(temp_rec->qual,temp_rec->qual_knt)
    CALL echo("***")
    CALL echo("***   Get Address")
    CALL echo("***")
    SET exp_size = 250
    SET exp_total = (temp_rec->qual_knt+ (exp_size - mod(temp_rec->qual_knt,exp_size)))
    SET exp_beg = 1
    SET exp_end = 250
    SET num = 0
    SET stat = alterlist(temp_rec->qual,exp_total)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM address a,
      (dummyt d  WITH seq = value((exp_total/ exp_size)))
     PLAN (d
      WHERE assign(exp_beg,evaluate(d.seq,1,1,(exp_beg+ exp_size)))
       AND assign(exp_end,(exp_beg+ (exp_size - 1))))
      JOIN (a
      WHERE expand(num,exp_beg,exp_end,a.parent_entity_id,temp_rec->qual[num].person_id,
       exp_size)
       AND a.parent_entity_name="PERSON"
       AND a.address_type_cd=home_address_cd
       AND a.active_ind=1
       AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     ORDER BY a.parent_entity_id, a.beg_effective_dt_tm DESC
     HEAD a.parent_entity_id
      pos = 0, pos = locateval(num,1,temp_rec->qual_knt,a.parent_entity_id,temp_rec->qual[num].
       person_id)
      IF (pos > 0)
       IF (a.country_cd > 0)
        temp_rec->qual[pos].country = trim(uar_get_code_display(a.country_cd))
       ELSE
        temp_rec->qual[pos].country = trim(a.country)
       ENDIF
       temp_rec->qual[pos].home_address_1 = trim(a.street_addr), temp_rec->qual[pos].home_address_2
        = trim(a.street_addr2), temp_rec->qual[pos].city = trim(a.city)
       IF (a.state_cd > 0)
        temp_rec->qual[pos].state = trim(uar_get_code_display(a.state_cd))
       ELSE
        temp_rec->qual[pos].state = trim(a.state)
       ENDIF
       temp_rec->qual[pos].zip_code = a.zipcode
      ENDIF
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "SSN PERSON_ALIAS"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("SSN PERSON_ALIAS :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET stat = alterlist(temp_rec->qual,temp_rec->qual_knt)
    CALL echo("***")
    CALL echo("***   Build Export File")
    CALL echo("***")
    SET b_seq_nbr = 1
    SET m_seq_nbr = temp_rec->qual_knt
    IF (((b_seq_nbr+ file_seq_size) > m_seq_nbr))
     SET e_seq_nbr = m_seq_nbr
    ELSE
     SET e_seq_nbr = (b_seq_nbr+ file_seq_size)
    ENDIF
    WHILE (b_seq_nbr <= e_seq_nbr)
      SET file_wknt = (file_wknt+ 1)
      SET phr_export_member_file = concat("ccluserdir:ags_phr_exp_",trim(cnvtstring(the_job_id)),"_",
       trim(cnvtstring(file_wknt)),".csv")
      IF (cursys="VMS")
       SET rm_vms_file_name = concat(trim(phr_export_member_file),";*")
       SET stat = remove(rm_vms_file_name)
      ELSE
       SET stat = remove(phr_export_member_file)
      ENDIF
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "INFO"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("OUTPUT FILE : ",trim(phr_export_member_file))
      CALL echo("***")
      CALL echo(concat("***   OUTPUT FILE : ",trim(phr_export_member_file)))
      CALL echo("***")
      FREE SET output_file
      SET logical output_file value(nullterm(trim(phr_export_member_file)))
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      SELECT INTO output_file
       FROM (dummyt d  WITH seq = value(temp_rec->qual_knt))
       PLAN (d
        WHERE d.seq >= b_seq_nbr
         AND d.seq <= e_seq_nbr)
       HEAD REPORT
        temp_line = ""
       DETAIL
        temp_line = "", temp_line = concat('"',trim(temp_rec->qual[d.seq].first_name),'","',trim(
          temp_rec->qual[d.seq].middle_name),'","',
         trim(temp_rec->qual[d.seq].last_name),'","',trim(temp_rec->qual[d.seq].gender),'","',trim(
          temp_rec->qual[d.seq].birthdate),
         '","',trim(temp_rec->qual[d.seq].country),'","',trim(temp_rec->qual[d.seq].home_address_1),
         '","',
         trim(temp_rec->qual[d.seq].home_address_2),'","',trim(temp_rec->qual[d.seq].city),'","',trim
         (temp_rec->qual[d.seq].state),
         '","',trim(temp_rec->qual[d.seq].zip_code),'","',trim(temp_rec->qual[d.seq].email_address),
         '","',
         trim(temp_rec->qual[d.seq].social_security),'","',trim(temp_rec->qual[d.seq].username),'","',
         trim(temp_rec->qual[d.seq].password),
         '","',trim(temp_rec->qual[d.seq].identify),'","',trim(temp_rec->qual[d.seq].associate_id),
         '","',
         trim(temp_rec->qual[d.seq].client_mnem),'","',trim(temp_rec->qual[d.seq].emplid),'","',trim(
          temp_rec->qual[d.seq].dependent),
         '","',trim(temp_rec->qual[d.seq].benef),'","',trim(temp_rec->qual[d.seq].asthma),'","',
         trim(temp_rec->qual[d.seq].asthma_care_coordinator),'","',trim(temp_rec->qual[d.seq].
          asthma_proxy),'","',trim(temp_rec->qual[d.seq].chf),
         '","',trim(temp_rec->qual[d.seq].chf_care_coordinator),'","',trim(temp_rec->qual[d.seq].
          chf_proxy),'","',
         trim(temp_rec->qual[d.seq].diabetes),'","',trim(temp_rec->qual[d.seq].
          diabetes_care_coordinator),'","',trim(temp_rec->qual[d.seq].diabetes_proxy),
         '","',trim(temp_rec->qual[d.seq].sleep),'","',trim(temp_rec->qual[d.seq].
          sleep_care_coordinator),'","',
         trim(temp_rec->qual[d.seq].sleep_proxy),'"'), col 0,
        temp_line, row + 1
       WITH nocounter, nullreport, formfeed = none,
        format = crstream, maxcol = 1676, maxrow = 1
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = select_error
       SET table_name = "MAKE PHR EXP FILE"
       SET ilog_status = 1
       SET log->qual_knt = (log->qual_knt+ 1)
       SET stat = alterlist(log->qual,log->qual_knt)
       SET log->qual[log->qual_knt].smsgtype = "ERROR"
       SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
       SET log->qual[log->qual_knt].smsg = concat("MAKE PHR EXP FILE :: Script Failure :: ",trim(
         serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
      FREE SET output_file
      SET b_seq_nbr = (e_seq_nbr+ 1)
      IF (b_seq_nbr > m_data_id)
       SET e_seq_nbr = 0
      ELSEIF (((b_seq_nbr+ file_seq_size) > m_seq_nbr))
       SET e_seq_nbr = m_seq_nbr
      ELSE
       SET e_seq_nbr = (b_seq_nbr+ file_seq_size)
      ENDIF
    ENDWHILE
   ELSE
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "INFO"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = "No Eligible Persons Found"
   ENDIF
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("END PROCESSING : B_DATA_ID = ",trim(cnvtstring(
      b_data_id))," : E_DATA_ID = ",trim(cnvtstring(e_data_id))," : M_DATA_ID = ",
    trim(cnvtstring(m_data_id)))
   SET b_data_id = (e_data_id+ 1)
   IF (b_data_id > m_data_id)
    SET e_data_id = 0.0
   ELSEIF (((b_data_id+ interval_size) > m_data_id))
    SET e_data_id = m_data_id
   ELSE
    SET e_data_id = (b_data_id+ interval_size)
   ENDIF
 ENDWHILE
 IF (define_logging_sub=true)
  SUBROUTINE handle_logging(slog_file,semail,istatus)
    CALL echo("***")
    CALL echo(build("***   sLog_file :",slog_file))
    CALL echo(build("***   sEmail    :",semail))
    CALL echo(build("***   iStatus   :",istatus))
    CALL echo("***")
    FREE SET output_log
    SET logical output_log value(nullterm(concat("cer_log:",trim(cnvtlower(slog_file)))))
    SELECT INTO output_log
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      out_line = fillstring(254," "), sstatus = fillstring(25," ")
     DETAIL
      FOR (idx = 1 TO log->qual_knt)
        out_line = trim(substring(1,254,concat(format(log->qual[idx].smsgtype,"#######")," :: ",
           format(log->qual[idx].dmsg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")," :: ",trim(log->qual[idx].
            smsg))))
        IF ((idx=log->qual_knt))
         IF (istatus=0)
          sstatus = "SUCCESS"
         ELSEIF (istatus=1)
          sstatus = "FAILURE"
         ELSE
          sstatus = "SUCCESS - With Warnings"
         ENDIF
         out_line = trim(substring(1,254,concat(trim(out_line),"  *** ",trim(sstatus)," ***")))
        ENDIF
        col 0, out_line
        IF ((idx != log->qual_knt))
         row + 1
        ENDIF
      ENDFOR
     WITH nocounter, nullreport, formfeed = none,
      format = crstream, append, maxcol = 255,
      maxrow = 1
    ;end select
    IF ((email->qual_knt > 0))
     DECLARE msgpriority = i4 WITH public, noconstant(5)
     DECLARE sendto = vc WITH public, noconstant(trim(semail))
     DECLARE sender = vc WITH public, noconstant("sf3151")
     DECLARE subject = vc WITH public, noconstant("")
     DECLARE msgclass = vc WITH public, noconstant("IPM.NOTE")
     DECLARE msgtext = vc WITH public, noconstant("")
     IF (istatus=0)
      SET subject = concat("SUCCESS - ",trim(slog_file))
      SET msgtext = concat("SUCCESS - ",trim(slog_file))
     ELSEIF (istatus=1)
      SET subject = concat("FAILURE - ",trim(slog_file))
      SET msgtext = concat("FAILURE - ",trim(slog_file))
     ELSE
      SET subject = concat("SUCCESS (with Warnings) - ",trim(slog_file))
      SET msgtext = concat("SUCCESS (with Warnings) - ",trim(slog_file))
     ENDIF
     FOR (eidx = 1 TO email->qual_knt)
       IF ((email->qual[eidx].send_flag=0))
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
       IF ((email->qual[eidx].send_flag=1)
        AND istatus != 1)
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
       IF ((email->qual[eidx].send_flag=2)
        AND istatus=1)
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
#exit_script
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
 IF (failed != false)
  ROLLBACK
  CALL echo("***")
  CALL echo("***   failed != FALSE")
  CALL echo("***")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "INPUT ERROR"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GEN_SEQ_NBR"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
  ELSEIF (failed=lock_error)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  CALL echo("***")
  CALL echo("***   else (failed != FALSE)")
  CALL echo("***")
  SET reply->status_data.status = "S"
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "END >> AGS_EXTRACT_PHR_MEMBERS"
 IF (the_debug_mode < 1)
  SET trace = echorecord
  SET trace = cost
  SET trace = callecho
  SET message = information
 ENDIF
 IF (define_logging_sub=true)
  CALL echo("***")
  CALL echo("***   END LOGGING")
  CALL echo("***")
  CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
  SET s_log_name = sstatus_file_name
  CALL echo("***")
  CALL echo(build("***   Log File: cer_log >",s_log_name))
  CALL echo("***")
 ENDIF
 CALL echo("***")
 CALL echo("***   END :: AGS_EXTRACT_PHR_MEMBERS")
 CALL echo("***")
 SET script_ver = "000   05/01/06"
END GO
