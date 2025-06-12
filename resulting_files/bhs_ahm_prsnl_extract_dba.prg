CREATE PROGRAM bhs_ahm_prsnl_extract:dba
 FREE RECORD temp_rec
 RECORD temp_rec(
   1 list[*]
     2 pos_cd = f8
 )
 FREE RECORD temp_email
 RECORD temp_email(
   1 list[*]
     2 user_id = vc
     2 user_email = vc
     2 department = vc
     2 upn = vc
 )
 DECLARE provider_cnt = i4
 DECLARE temp = vc
 DECLARE output = vc
 DECLARE p_cnt = i4
 DECLARE ms_res_str = vc
 DECLARE ndx = i4
 DECLARE ndx2 = i4
 DECLARE temp_email_cnt = i4
 DECLARE temp_pos = i4
 DECLARE temp_pos2 = i4
 DECLARE temp_pos3 = i4
 DECLARE temp_pos4 = i4
 DECLARE temp_pos5 = i4
 DECLARE temp_pos6 = i4
 DECLARE temp_pos7 = i4
 DECLARE temp_pos8 = i4
 DECLARE temp_pos9 = i4
 DECLARE temp_pos10 = i4
 DECLARE temp_email_pos = i4
 DECLARE temp_email_addr = vc
 DECLARE temp_email_addr2 = vc
 DECLARE temp_dept = vc
 DECLARE temp_username = vc
 DECLARE ms_dclcom = vc
 DECLARE ml_stat = i4
 SET provider_cnt = size(requestin->list_0,5)
 SET output = "bhs_ahm_prsnl_extract.csv"
 FREE DEFINE rtl2
 DEFINE rtl2 "bhscust:ahmemp.txt"
 SELECT INTO "nl:"
  FROM rtl2t t
  WHERE t.line > " "
  DETAIL
   temp_pos = 0, temp_pos2 = 0, temp_pos3 = 0,
   temp_pos4 = 0, temp_pos5 = 0, temp_pos6 = 0,
   temp_pos7 = 0, temp_pos8 = 0, temp_pos9 = 0,
   temp_pos10 = 0, temp_pos11 = 0, temp_pos12 = 0,
   temp_email_cnt += 1, temp_pos = findstring('"',t.line), temp_pos2 = findstring('"',t.line,(
    temp_pos+ 1)),
   temp_pos3 = findstring('"',t.line,(temp_pos2+ 1)), temp_pos4 = findstring('"',t.line,(temp_pos3+ 1
    )), temp_pos5 = findstring('"',t.line,(temp_pos4+ 1)),
   temp_pos6 = findstring('"',t.line,(temp_pos5+ 1)), temp_pos7 = findstring('"',t.line,(temp_pos6+ 1
    )), temp_pos8 = findstring('"',t.line,(temp_pos7+ 1)),
   temp_pos9 = findstring('"',t.line,(temp_pos8+ 1)), temp_pos10 = findstring('"',t.line,(temp_pos9+
    1)), temp_pos11 = findstring('"',t.line,(temp_pos10+ 1)),
   temp_pos12 = findstring('"',t.line,(temp_pos11+ 1)), stat = alterlist(temp_email->list,
    temp_email_cnt), temp_email->list[temp_email_cnt].user_id = cnvtupper(substring(2,((temp_pos2 -
     temp_pos) - 1),t.line)),
   temp_email->list[temp_email_cnt].department = substring((temp_pos7+ 1),((temp_pos8 - temp_pos7) -
    1),t.line), temp_email->list[temp_email_cnt].user_email = substring((temp_pos9+ 1),((temp_pos10
     - temp_pos9) - 1),t.line), temp_email->list[temp_email_cnt].upn = substring((temp_pos11+ 1),((
    temp_pos12 - temp_pos11) - 1),t.line)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=88
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate
    AND cv.display_key="*RESIDENT*")
  HEAD REPORT
   p_cnt = 0
  DETAIL
   p_cnt += 1, stat = alterlist(temp_rec->list,p_cnt), temp_rec->list[p_cnt].pos_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO value(output)
  textlen_p_username = textlen(p.username)
  FROM prsnl p,
   prsnl_alias pa,
   (dummyt d  WITH seq = value(provider_cnt))
  PLAN (d)
   JOIN (pa
   WHERE pa.prsnl_alias_type_cd=64094777.0
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND (pa.alias=requestin->list_0[d.seq].npi_number))
   JOIN (p
   WHERE p.person_id=pa.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
  ORDER BY p.person_id
  HEAD REPORT
   col 0,
   '"username","last_name","first_name","credentials","department","email","phone","provider_identifier","resident_ind","npi"'
  DETAIL
   temp_email_pos = locateval(ndx2,1,temp_email_cnt,cnvtupper(p.username),temp_email->list[ndx2].
    user_id)
   IF (temp_email_pos > 0)
    temp_email_addr = trim(replace(temp_email->list[temp_email_pos].user_email,'"',"",2),3)
   ELSE
    temp_email_addr = p.email
   ENDIF
   temp_dept = trim(requestin->list_0[d.seq].practice_name,3)
   IF (findstring("BAYSTATE",temp_dept)=1)
    temp_dept = substring(10,size(temp_dept),temp_dept)
   ENDIF
   ms_res_str = ""
   IF (locateval(ndx,1,p_cnt,p.position_cd,temp_rec->list[ndx].pos_cd) > 0)
    ms_res_str = "Resident"
   ENDIF
   row + 1, row + 1
   IF (findstring("RF",p.username) != 1
    AND findstring("NA",p.username) != 1
    AND findstring("TERM",p.username) != 1
    AND findstring("MSOTERM",p.username) != 1
    AND findstring("MSO_TERM",p.username) != 1
    AND findstring("SPND",p.username) != 1
    AND findstring("SUSPMSO",p.username) != 1
    AND findstring("MSO_SUSP",p.username) != 1
    AND findstring("MSOSUSP",p.username) != 1
    AND p.username > " ")
    IF (temp_email_pos > 0)
     IF (findstring("@",temp_email->list[temp_email_pos].upn) > 0)
      temp_email->list[temp_email_pos].upn = substring(1,(findstring("@",temp_email->list[
        temp_email_pos].upn) - 1),temp_email->list[temp_email_pos].upn)
     ENDIF
     IF (textlen_p_username > 0
      AND p.username != null)
      IF (textlen(temp_email->list[temp_email_pos].upn) > 0)
       temp_username = concat(trim(p.username,3),",",temp_email->list[temp_email_pos].upn)
      ENDIF
     ELSE
      temp_username = temp_email->list[temp_email_pos].upn
     ENDIF
    ELSE
     temp_username = trim(p.username,3)
    ENDIF
    temp = concat('"',temp_username,'",','"',trim(requestin->list_0[d.seq].last_name,3),
     '",','"',trim(requestin->list_0[d.seq].first_name,3),'",','"',
     trim(requestin->list_0[d.seq].title1,3),'",','"',temp_dept,'",',
     '"',temp_email_addr,'",','"',trim(requestin->list_0[d.seq].provider_phone,3),
     '",','"',trim(requestin->list_0[d.seq].bhs_dr_number,3),'",','"',
     trim(ms_res_str),'",','"',trim(requestin->list_0[d.seq].npi_number,3),'"'), col 0, temp
   ENDIF
  WITH format = variable, separator = " ", maxrow = 1,
   maxcol = 250
 ;end select
 CALL echo("--- TEST ---")
 CALL echo(provider_cnt)
 CALL echo("------------")
 DECLARE test_cnt = i4
 SELECT INTO "nl:"
  FROM prsnl p,
   prsnl_alias pa,
   (dummyt d  WITH seq = provider_cnt)
  PLAN (d)
   JOIN (pa
   WHERE pa.prsnl_alias_type_cd=64094777.0
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND (pa.alias=requestin->list_0[d.seq].npi_number))
   JOIN (p
   WHERE p.person_id=pa.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
  DETAIL
   test_cnt += 1
  WITH nocounter
 ;end select
 CALL echo("****************")
 CALL echo(test_cnt)
 CALL echo("*****************")
 SET ms_dclcom = concat(
  "$cust_script/bhs_sftp_file.ksh bhartifact@transfer.baystatehealth.org $CCLUSERDIR/",output)
 SET ml_stat = - (1)
 CALL echo(build("FTP Command: ",ms_dclcom))
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 CALL echo(build("FTP Status (1=success, 0=fail): ",ml_stat))
#exit_program
 FREE RECORD temp_rec
 FREE RECORD temp_email
END GO
