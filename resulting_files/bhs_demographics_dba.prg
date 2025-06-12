CREATE PROGRAM bhs_demographics:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 f_person_id = f8
   1 s_exist_fin = vc
   1 s_exist_cmrn = vc
   1 rows[*]
     2 s_desc = vc
     2 f_code_set = f8
     2 s_egate_value = vc
     2 f_code_value = f8
     2 s_display = vc
     2 n_exists = i2
     2 n_update = i2
     2 f_demo_id = f8
     2 n_email = i2
 ) WITH protect
 DECLARE mf_egate_cont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",73,"ADTEGATE"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE ms_acct_nbr = vc WITH protect, noconstant(" ")
 DECLARE ms_corp_nbr = vc WITH protect, noconstant(" ")
 DECLARE mn_updates = i2 WITH protect, noconstant(0)
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_wnerta_ind = i2 WITH protect, noconstant(0)
 IF (trim(corp_nbr) > " ")
  SET ms_corp_nbr = trim(corp_nbr,3)
 ENDIF
 SET ms_acct_nbr = trim(acct_nbr,3)
 IF (substring(1,1,acct_nbr)="0"
  AND textlen(acct_nbr) > 1)
  SET ms_acct_nbr = trim(acct_nbr)
  SET cnt = 0
  WHILE (substring(1,1,ms_acct_nbr)="0")
   SET cnt = (cnt+ 1)
   SET ms_acct_nbr = substring(2,(textlen(ms_acct_nbr) - 1),ms_acct_nbr)
  ENDWHILE
 ENDIF
 SELECT INTO "nl:"
  FROM person_alias pa
  PLAN (pa
   WHERE pa.active_ind=1
    AND pa.alias=ms_corp_nbr
    AND pa.person_alias_type_cd=mf_cmrn_cd)
  HEAD pa.person_id
   m_rec->f_person_id = pa.person_id
  WITH nocounter
 ;end select
 IF (trim(oen_reply->control_group[1].msh[1].sending_facility)="WNERTA")
  SET mn_wnerta_ind = 1
 ENDIF
 IF (mn_wnerta_ind=1)
  CALL echo("wnerta")
  SET stat = alterlist(m_rec->rows,2)
  SET m_rec->rows[1].s_desc = "race 1"
  SET m_rec->rows[1].s_egate_value = trim(oen_reply->person_group[1].pat_group[1].pid[1].race[1].
   identifier)
  SET m_rec->rows[1].f_code_set = 282
  SET m_rec->rows[2].s_desc = "hispanic ind"
  SET m_rec->rows[2].f_code_set = 0
  SET m_rec->rows[2].s_egate_value = trim(cnvtupper(oen_reply->person_group[1].pat_group[1].pid[1].
    ethnic_grp))
  SET m_rec->rows[2].s_display = m_rec->rows[2].s_egate_value
 ELSE
  SET stat = alterlist(m_rec->rows,8)
  SET m_rec->rows[1].s_desc = "language spoken"
  SET m_rec->rows[1].s_egate_value = trim(oen_reply->person_group[1].pat_group[1].pid[1].
   language_patient)
  SET m_rec->rows[1].f_code_set = 36
  SET m_rec->rows[2].s_desc = "language read"
  SET m_rec->rows[2].s_egate_value = trim(oen_reply->person_group[1].zu_group[1].zu1[1].status)
  SET m_rec->rows[2].f_code_set = 36
  SET m_rec->rows[3].s_desc = "race 1"
  SET m_rec->rows[3].s_egate_value = trim(oen_reply->person_group[1].pat_group[1].pid[1].race[1].
   identifier)
  SET m_rec->rows[3].f_code_set = 282
  SET m_rec->rows[4].s_desc = "race 2"
  SET m_rec->rows[4].s_egate_value = trim(oen_reply->person_group[1].zu_group[1].zu1[1].
   episode_start_dt_tm)
  SET m_rec->rows[4].f_code_set = 282
  SET m_rec->rows[5].s_desc = "hispanic ind"
  IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].ethnic_grp[1].identifier)=1)
   SET m_rec->rows[5].s_egate_value = trim(oen_reply->person_group[1].pat_group[1].pid[1].ethnic_grp[
    1].identifier,3)
  ELSE
   SET m_rec->rows[5].s_egate_value = trim(oen_reply->person_group[1].pat_group[1].pid[1].ethnic_grp,
    3)
  ENDIF
  SET m_rec->rows[5].s_display = m_rec->rows[5].s_egate_value
  SET m_rec->rows[5].f_code_set = 0
  SET m_rec->rows[6].s_desc = "ethnicity 1"
  SET m_rec->rows[6].s_egate_value = trim(oen_reply->person_group[1].zu_group[1].zu1[1].
   episode_end_dt_tm)
  SET m_rec->rows[6].f_code_set = 104490
  SET m_rec->rows[7].s_desc = "ethnicity 2"
  SET m_rec->rows[7].s_egate_value = trim(oen_reply->person_group[1].zu_group[1].zu1[1].management_cd
   .identifier)
  SET m_rec->rows[7].f_code_set = 104490
  SET m_rec->rows[8].s_desc = "religion"
  SET m_rec->rows[8].s_egate_value = trim(oen_reply->person_group[1].pat_group[1].pid[1].religion)
  SET m_rec->rows[8].f_code_set = 49
 ENDIF
 FOR (ml_cnt = 1 TO size(m_rec->rows,5))
   IF ((m_rec->rows[ml_cnt].f_code_set > 0.0)
    AND  NOT (trim(m_rec->rows[ml_cnt].s_egate_value) IN ("", " ", null)))
    SELECT INTO "nl:"
     FROM code_value_alias cva,
      code_value cv
     PLAN (cva
      WHERE (cva.code_set=m_rec->rows[ml_cnt].f_code_set)
       AND cva.contributor_source_cd=mf_egate_cont_cd
       AND (cva.alias=m_rec->rows[ml_cnt].s_egate_value))
      JOIN (cv
      WHERE cv.code_value=cva.code_value
       AND cv.active_ind=1
       AND cv.end_effective_dt_tm > sysdate)
     HEAD cv.code_value
      m_rec->rows[ml_cnt].f_code_value = cv.code_value, m_rec->rows[ml_cnt].s_display = trim(cv
       .display)
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF ((m_rec->f_person_id > 0.0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(m_rec->rows,5))),
    bhs_demographics b
   PLAN (d)
    JOIN (b
    WHERE (b.person_id=m_rec->f_person_id)
     AND b.active_ind=1
     AND b.contributor_source_cd=mf_egate_cont_cd
     AND (b.description=m_rec->rows[d.seq].s_desc))
   DETAIL
    IF ((((b.code_value != m_rec->rows[d.seq].f_code_value)) OR ((b.display != m_rec->rows[d.seq].
    s_display))) )
     ms_log = concat(ms_log," update: ",b.display," to ",m_rec->rows[d.seq].s_display,
      char(10))
     IF (trim(ms_acct_nbr) <= " ")
      ms_acct_nbr = trim(b.acct_nbr)
     ENDIF
     m_rec->rows[d.seq].n_update = 1, m_rec->rows[d.seq].f_demo_id = b.bhs_demographics_id,
     mn_updates = 1,
     m_rec->rows[d.seq].n_exists = 1
    ELSE
     ms_log = concat(ms_log," exists: ",m_rec->rows[d.seq].s_desc,char(10)), m_rec->rows[d.seq].
     n_exists = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (mn_updates=1
  AND mn_wnerta_ind=0)
  CALL echo("update")
  UPDATE  FROM bhs_demographics b,
    (dummyt d  WITH seq = value(size(m_rec->rows,5)))
   SET b.acct_nbr = ms_acct_nbr, b.code_value = m_rec->rows[d.seq].f_code_value, b.corp_nbr =
    ms_corp_nbr,
    b.display = m_rec->rows[d.seq].s_display, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = sysdate,
    b.updt_id = reqinfo->updt_id
   PLAN (d
    WHERE (m_rec->rows[d.seq].n_update=1)
     AND  NOT (trim(m_rec->rows[d.seq].s_display) IN (null, "", " ")))
    JOIN (b
    WHERE (b.bhs_demographics_id=m_rec->rows[d.seq].f_demo_id))
   WITH nocounter
  ;end update
 ENDIF
 CALL echo("insert")
 INSERT  FROM bhs_demographics b,
   (dummyt d  WITH seq = value(size(m_rec->rows,5)))
  SET b.active_ind = 1, b.acct_nbr = ms_acct_nbr, b.beg_effective_dt_tm = sysdate,
   b.bhs_demographics_id = seq(bhs_demo_seq,nextval), b.contributor_source_cd = mf_egate_cont_cd, b
   .corp_nbr = ms_corp_nbr,
   b.description = m_rec->rows[d.seq].s_desc, b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), b
   .person_id = m_rec->f_person_id,
   b.updt_cnt = 0, b.updt_dt_tm = sysdate, b.updt_id = reqinfo->updt_id,
   b.display = m_rec->rows[d.seq].s_display, b.code_value = m_rec->rows[d.seq].f_code_value
  PLAN (d
   WHERE (m_rec->rows[d.seq].n_exists=0)
    AND  NOT (trim(m_rec->rows[d.seq].s_display) IN (null, " ", "")))
   JOIN (b)
  WITH nocounter
 ;end insert
 COMMIT
#exit_script
 CALL echoxml(m_rec,"jason_xml.dat")
 CALL echoxml(oen_reply,"jason_xml2.dat")
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
