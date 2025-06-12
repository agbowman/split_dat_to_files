CREATE PROGRAM bhs_ins_pat_portal_stat:dba
 DECLARE ms_status = vc WITH protect, constant(trim(cnvtupper(requestin->list_0[1].status)))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE ms_portal_desc = vc WITH protect, constant("PORTAL_STATUS")
 DECLARE mf_mdoc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",73,"MDOCGENERIC"))
 CALL echo(build2("mf_cmrn_cd: ",mf_cmrn_cd))
 CALL echo(build2("mf_MDOC_CD: ",mf_mdoc_cd))
 DECLARE ms_cmrn = vc WITH protect, noconstant(trim(requestin->list_0[1].cmrn))
 DECLARE ms_ret_stat = vc WITH protect, noconstant("Fail")
 DECLARE mf_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_upd_row_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_file_ind = i4 WITH protect, noconstant(0)
 WHILE (substring(1,1,ms_cmrn)="0")
   SET ms_cmrn = trim(substring(2,textlen(ms_cmrn),ms_cmrn))
 ENDWHILE
 IF (findfile("bhs_portal_activate_pat_out.csv") > 0)
  SET ml_file_ind = 1
 ENDIF
 SELECT INTO "bhs_portal_activate_pat_out.csv"
  FROM person_alias pa,
   person p
  PLAN (pa
   WHERE pa.alias=ms_cmrn
    AND pa.person_alias_type_cd=mf_cmrn_cd
    AND pa.active_ind=1)
   JOIN (p
   WHERE p.person_id=pa.person_id
    AND p.active_ind=1)
  HEAD REPORT
   IF (ml_file_ind=0)
    col 0, '"STATUS","CMRN","FIRSTNAME","LASTNAME","FIRSTNAME_DB","LASTNAME_DB"'
   ENDIF
  HEAD pa.alias
   mf_person_id = pa.person_id, ms_tmp = concat('"',trim(requestin->list_0[1].status),'","',trim(
     requestin->list_0[1].cmrn),'","',
    trim(requestin->list_0[1].firstname),'","',trim(requestin->list_0[1].lastname),'","',trim(p
     .name_first_key),
    '","',trim(p.name_last_key),'"'), row + 1,
   col 0, ms_tmp
  WITH nocounter, format = variable, maxrow = 1,
   append
 ;end select
 IF (((curqual < 1) OR (mf_person_id=0.0)) )
  SET ms_log = "Error: Failed to find person for CMRN"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_demographics b
  PLAN (b
   WHERE b.person_id=mf_person_id
    AND b.corp_nbr=ms_cmrn
    AND b.active_ind=1
    AND b.description=ms_portal_desc
    AND b.contributor_source_cd=mf_mdoc_cd)
  DETAIL
   mf_upd_row_id = b.bhs_demographics_id
  WITH nocounter
 ;end select
 IF (mf_upd_row_id > 0.0)
  UPDATE  FROM bhs_demographics b
   SET b.display = ms_status, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = sysdate,
    b.updt_id = reqinfo->updt_id
   WHERE b.bhs_demographics_id=mf_upd_row_id
   WITH nocounter
  ;end update
  COMMIT
  IF (curqual > 0)
   SET ms_log = concat("Updated portal status row for CMRN: ",ms_cmrn)
  ELSE
   SET ms_log = concat("Failed to update portal status row for CMRN: ",ms_cmrn)
   GO TO exit_script
  ENDIF
 ELSE
  INSERT  FROM bhs_demographics b
   SET b.active_ind = 1, b.acct_nbr = "", b.beg_effective_dt_tm = sysdate,
    b.bhs_demographics_id = seq(bhs_demo_seq,nextval), b.contributor_source_cd = mf_mdoc_cd, b
    .corp_nbr = ms_cmrn,
    b.description = ms_portal_desc, b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), b.person_id
     = mf_person_id,
    b.updt_cnt = 0, b.updt_dt_tm = sysdate, b.updt_id = reqinfo->updt_id,
    b.display = ms_status, b.code_value = 0
   WITH nocounter
  ;end insert
  COMMIT
  IF (curqual > 0)
   SET ms_log = concat("Inserted portal status row for CMRN: ",ms_cmrn)
  ELSE
   SET ms_log = concat("Failed to insert portal status row for CMRN: ",ms_cmrn)
   GO TO exit_script
  ENDIF
 ENDIF
 SET ms_ret_stat = "Success"
#exit_script
 SET ms_tmp = concat('[{"Status":"',ms_ret_stat,'","StatusDetail":"',ms_log,'"}]')
 CALL echo(ms_tmp)
 SET _memory_reply_string = ms_tmp
END GO
