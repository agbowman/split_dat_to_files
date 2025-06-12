CREATE PROGRAM bhs_immun_cd_maint:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Add or Remove codes from list?:" = 0,
  "List Name" = "",
  "New List Name" = "",
  "In list" = 0,
  "Add Immunizations:" = 0,
  "Codes currently in list:" = 0
  WITH outdev, n_add_remove, s_list,
  s_new_list, f_cur_cds, f_add_cds,
  f_rmv_cds
 FREE RECORD m_info
 RECORD m_info(
   1 f_grouper_id = f8
   1 s_list = vc
   1 s_listkey = vc
   1 recs[*]
     2 f_event_cd = f8
     2 f_event_cd_list_id = f8
     2 n_exists = i2
 ) WITH protect
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mn_immun_cd_param = i2 WITH protect, constant(6)
 DECLARE mn_list_cd_param = i2 WITH protect, constant(7)
 DECLARE mn_add_cds = i2 WITH protect, constant(1)
 DECLARE mn_remove_cds = i2 WITH protect, constant(2)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_data_type = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE mn_read_param = i2 WITH protect, noconstant(0)
 DECLARE ml_grouper_id = i4 WITH protect, noconstant(0)
 CALL echo(build2("n_add_remove: ", $N_ADD_REMOVE))
 IF (( $N_ADD_REMOVE=mn_add_cds))
  CALL echo("insert")
  SET mn_read_param = mn_immun_cd_param
 ELSEIF (( $N_ADD_REMOVE=mn_remove_cds))
  CALL echo("delete")
  SET mn_read_param = mn_list_cd_param
 ENDIF
 IF (trim( $S_NEW_LIST) > " ")
  SET m_info->s_list = trim( $S_NEW_LIST)
  SET m_info->s_listkey = trim(cnvtupper( $S_NEW_LIST))
 ELSEIF (trim( $S_LIST) > " ")
  SET m_info->s_list = trim( $S_LIST)
  SET m_info->s_listkey = trim(cnvtupper( $S_LIST))
 ELSE
  SET ms_log = "no list - exit"
  GO TO exit_script
 ENDIF
 CALL echo(build2("List Name: ",m_info->s_list))
 SET ms_data_type = reflect(parameter(mn_read_param,0))
 IF (substring(1,1,ms_data_type) != "L")
  SET ms_tmp = trim(cnvtstring(parameter(mn_read_param,1)))
  IF ( NOT (trim(ms_tmp) IN (null, "", " ", "0")))
   SET stat = alterlist(m_info->recs,1)
   SET m_info->recs[1].f_event_cd = cnvtreal(ms_tmp)
  ELSE
   SET ms_log = build2(ms_data_type,"no valid event_cds - exit")
   GO TO exit_script
  ENDIF
 ELSE
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
    SET ms_tmp = trim(cnvtstring(parameter(mn_read_param,ml_cnt)))
    SET stat = alterlist(m_info->recs,ml_cnt)
    SET m_info->recs[ml_cnt].f_event_cd = cnvtreal(ms_tmp)
  ENDFOR
 ENDIF
 CALL echorecord(m_info)
 IF (( $N_ADD_REMOVE=mn_add_cds))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(m_info->recs,5))),
    bhs_event_cd_list b
   PLAN (d)
    JOIN (b
    WHERE b.active_ind=0
     AND (b.event_cd=m_info->recs[d.seq].f_event_cd)
     AND (b.listkey=m_info->s_listkey)
     AND b.view_ind=1)
   DETAIL
    m_info->recs[d.seq].n_exists = 1, m_info->recs[d.seq].f_event_cd_list_id
   WITH nocounter
  ;end select
 ENDIF
 IF (( $N_ADD_REMOVE=mn_remove_cds))
  UPDATE  FROM (dummyt d  WITH seq = value(size(m_info->recs,5))),
    bhs_event_cd_list b
   SET b.active_ind = 0, b.updt_dt_tm = sysdate, b.updt_id = 9999
   PLAN (d)
    JOIN (b
    WHERE (b.event_cd=m_info->recs[d.seq].f_event_cd)
     AND b.active_ind=1
     AND (b.listkey=m_info->s_listkey)
     AND b.view_ind=1)
   WITH nocounter
  ;end update
  COMMIT
 ELSE
  SET ms_log = "updating rows"
  UPDATE  FROM (dummyt d  WITH seq = value(size(m_info->recs,5))),
    bhs_event_cd_list b
   SET b.active_ind = 1, b.updt_dt_tm = sysdate, b.updt_id = 9999
   PLAN (d
    WHERE (m_info->recs[d.seq].n_exists=1))
    JOIN (b
    WHERE (b.event_cd_list_id=m_info->recs[d.seq].f_event_cd_list_id))
   WITH nocounter
  ;end update
  COMMIT
  SET ms_log = "inserting rows"
  SELECT
   b.grouper_id
   FROM bhs_event_cd_list b
   WHERE b.grouper="ICU_MP"
    AND b.view_ind=1
   DETAIL
    ml_grouper_id = b.grouper_id
   WITH nocounter
  ;end select
  IF (curqual < 1)
   CALL echo("not found")
   SELECT
    pl_id = max(b.grouper_id)
    FROM bhs_event_cd_list b
    DETAIL
     ml_grouper_id = (pl_id+ 1)
    WITH nocounter
   ;end select
  ENDIF
  CALL echo(build2("grouper_id: ",ml_grouper_id))
  INSERT  FROM (dummyt d  WITH seq = value(size(m_info->recs,5))),
    bhs_event_cd_list b
   SET b.active_ind = 1, b.event_cd_list_id = seq(bhs_eks_seq,nextval), b.event_cd = m_info->recs[d
    .seq].f_event_cd,
    b.grouper_id = ml_grouper_id, b.grouper = "ICU_MP", b.list = m_info->s_list,
    b.listkey = m_info->s_listkey, b.updt_dt_tm = sysdate, b.updt_id = 9999
   PLAN (d
    WHERE (m_info->recs[d.seq].n_exists=0))
    JOIN (b)
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
#exit_script
 IF (size(m_info->recs,5) > 0)
  SELECT INTO value( $OUTDEV)
   FROM (dummyt d  WITH seq = value(size(m_info->recs,5)))
   HEAD REPORT
    ms_tmp = fillstring(50,"-"), row + 1, col 0,
    "List Name: ", m_info->s_list, row + 1,
    col 0, ms_tmp, row + 1,
    col 0, "DISPLAY", col 50,
    "DISPLAYKEY", col 100, "CODE_VALUE",
    row + 1, ms_tmp
   DETAIL
    ms_tmp = substring(1,49,m_info->s_list), row + 1, col 0,
    ms_tmp, ms_tmp = substring(1,49,m_info->s_listkey), col 50,
    ms_tmp, ms_tmp = trim(cnvtstring(m_info->recs[d.seq].f_event_cd)), col 100,
    ms_tmp
   FOOT REPORT
    row + 1, col 60, "***END***"
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   HEAD REPORT
    col 0, "No Data Found", row + 1,
    col 0, ms_log
   WITH nocounter
  ;end select
 ENDIF
END GO
