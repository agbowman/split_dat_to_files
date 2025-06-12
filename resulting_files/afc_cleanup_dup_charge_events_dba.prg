CREATE PROGRAM afc_cleanup_dup_charge_events:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SELECT INTO "nl:"
  ui.index_name
  FROM user_indexes ui,
   user_ind_columns uic
  WHERE ui.table_name="CHARGE_EVENT"
   AND ui.uniqueness="UNIQUE"
   AND ui.table_name=uic.table_name
   AND ui.index_name=uic.index_name
   AND uic.column_name IN ("EXT_M_EVENT_ID", "EXT_M_EVENT_CONT_CD", "EXT_P_EVENT_ID",
  "EXT_P_EVENT_CONT_CD", "EXT_I_EVENT_ID",
  "EXT_I_EVENT_CONT_CD", "EXT_I_REFERENCE_ID")
  WITH nocounter
 ;end select
 IF (curqual=7)
  SET readme_data->message = "The index already exists!"
  SET readme_data->status = "S"
 ELSE
  SET readme_data->message = "The index doesn't exist, running cleanup."
  SET beg_dt_tm = concat(format(curdate,"MMM DD, YYYY;;D"),format(curtime," - HH:MM:SS;;S"))
  SET more_dups = 1
  SET dups_found = 0
  FREE SET events
  RECORD events(
    1 list[*]
      2 m_id = f8
      2 m_cd = f8
      2 p_id = f8
      2 p_cd = f8
      2 i_id = f8
      2 i_cd = f8
      2 i_ref_id = f8
      2 row_num = i2
  )
  FREE SET del_events
  RECORD del_events(
    1 list[*]
      2 charge_event_id = f8
  )
  SET g_ordered = 0.0
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=13029
    AND c.cdf_meaning="ORDERED"
    AND c.active_ind=1
   DETAIL
    g_ordered = c.code_value
   WITH nocounter
  ;end select
  SET max_ce_id = 0.0
  SELECT INTO "nl:"
   max_id = max(ce.charge_event_id)
   FROM charge_event ce
   DETAIL
    max_ce_id = max_id
   WITH nocounter
  ;end select
  SET beg_range = 0
  SET end_range = 0
  WHILE (more_dups=1)
    IF (beg_range > 0)
     SET beg_range = (end_range - 1000)
    ELSE
     SET beg_range = end_range
    ENDIF
    IF (beg_range > 0)
     SET end_range += 10000
    ELSE
     SET end_range = 1000
    ENDIF
    IF ((end_range > (max_ce_id+ 10000)))
     SET more_dups = 0
    ENDIF
    SET stat = alterlist(events->list,0)
    SET c_id = 0
    SET m_id = 0
    SET m_cd = 0
    SET p_id = 0
    SET p_cd = 0
    SET i_id = 0
    SET i_cd = 0
    SET i_ref_id = 0
    SET readme_data->message = build("Checking for duplicates ",dups_found," found so far.")
    SET cnt = 0
    SET added = 0
    DECLARE cnt2 = i4
    SET cnt2 = 0
    SELECT DISTINCT INTO "nl:"
     c1.*
     FROM charge_event c1,
      charge_event c2
     PLAN (c1
      WHERE c1.charge_event_id > beg_range
       AND c1.charge_event_id < end_range)
      JOIN (c2
      WHERE c1.rowid != c2.rowid
       AND c1.ext_m_event_id=c2.ext_m_event_id
       AND c1.ext_m_event_cont_cd=c2.ext_m_event_cont_cd
       AND c1.ext_p_event_id=c2.ext_p_event_id
       AND c1.ext_p_event_cont_cd=c2.ext_p_event_cont_cd
       AND c1.ext_i_event_id=c2.ext_i_event_id
       AND c1.ext_i_event_cont_cd=c2.ext_i_event_cont_cd
       AND c1.ext_i_reference_id=c2.ext_i_reference_id)
     DETAIL
      cnt += 1, stat = alterlist(events->list,cnt), events->list[cnt].m_id = c1.ext_m_event_id,
      events->list[cnt].m_cd = c1.ext_m_event_cont_cd, events->list[cnt].p_id = c1.ext_p_event_id,
      events->list[cnt].p_cd = c1.ext_p_event_cont_cd,
      events->list[cnt].i_id = c1.ext_i_event_id, events->list[cnt].i_cd = c1.ext_i_event_cont_cd,
      events->list[cnt].i_ref_id = c1.ext_i_reference_id,
      events->list[cnt].row_num = cnt
     WITH nocounter
    ;end select
    DECLARE loop = i4
    SET dups_found += cnt
    IF (size(events->list,5) <= 0)
     SET readme_data->message = build("No dups found in the range ",beg_range," - ",end_range)
    ELSE
     FOR (loop = 1 TO cnt)
       SET cnt2 = 0
       SET stat = alterlist(del_events->list,cnt2)
       SELECT INTO "nl:"
        ce.ext_m_event_id, ce.ext_m_event_cont_cd, ce.ext_p_event_id,
        ce.ext_p_event_cont_cd, ce.ext_i_event_id, ce.ext_i_event_cont_cd,
        ce.ext_i_reference_id, ce.charge_event_id
        FROM charge_event ce
        WHERE (ce.ext_m_event_id=events->list[loop].m_id)
         AND (ce.ext_m_event_cont_cd=events->list[loop].m_cd)
         AND (ce.ext_p_event_id=events->list[loop].p_id)
         AND (ce.ext_p_event_cont_cd=events->list[loop].p_cd)
         AND (ce.ext_i_event_id=events->list[loop].i_id)
         AND (ce.ext_i_event_cont_cd=events->list[loop].i_cd)
         AND (ce.ext_i_reference_id=events->list[loop].i_ref_id)
        DETAIL
         cnt2 += 1, stat = alterlist(del_events->list,cnt2), del_events->list[cnt2].charge_event_id
          = ce.charge_event_id
        WITH nocounter
       ;end select
       SET charge_event_id = 0.0
       SELECT INTO "nl:"
        cea.charge_event_id
        FROM charge_event_act cea,
         (dummyt d  WITH seq = value(size(del_events->list,5)))
        PLAN (d)
         JOIN (cea
         WHERE (cea.charge_event_id=del_events->list[d.seq].charge_event_id)
          AND cea.cea_type_cd=g_ordered)
        DETAIL
         charge_event_id = cea.charge_event_id
        WITH nocounter
       ;end select
       IF (charge_event_id <= 0)
        SET charge_event_id = del_events->list[1].charge_event_id
       ENDIF
       UPDATE  FROM charge c,
         (dummyt d  WITH seq = value(size(del_events->list,5)))
        SET c.charge_event_id = charge_event_id
        PLAN (d
         WHERE (del_events->list[d.seq].charge_event_id != charge_event_id))
         JOIN (c
         WHERE (c.charge_event_id=del_events->list[d.seq].charge_event_id))
        WITH nocounter
       ;end update
       UPDATE  FROM charge_event_act cea,
         (dummyt d  WITH seq = value(size(del_events->list,5)))
        SET cea.charge_event_id = charge_event_id
        PLAN (d
         WHERE (del_events->list[d.seq].charge_event_id != charge_event_id))
         JOIN (cea
         WHERE (cea.charge_event_id=del_events->list[d.seq].charge_event_id))
        WITH nocounter
       ;end update
       UPDATE  FROM charge_event_mod cem,
         (dummyt d  WITH seq = value(size(del_events->list,5)))
        SET cem.charge_event_id = charge_event_id
        PLAN (d
         WHERE (del_events->list[d.seq].charge_event_id != charge_event_id))
         JOIN (cem
         WHERE (cem.charge_event_id=del_events->list[d.seq].charge_event_id))
        WITH nocounter
       ;end update
       DELETE  FROM charge_event c,
         (dummyt d  WITH seq = value(size(del_events->list,5)))
        SET c.seq = 1
        PLAN (d
         WHERE (del_events->list[d.seq].charge_event_id != charge_event_id))
         JOIN (c
         WHERE (c.charge_event_id=del_events->list[d.seq].charge_event_id))
        WITH nocounter
       ;end delete
       COMMIT
     ENDFOR
    ENDIF
  ENDWHILE
  SET readme_data->status = "S"
  CALL echo(". . . Finished")
  CALL echo(concat("Beg Time: ",beg_dt_tm))
  CALL echo(concat("End Time: ",format(curdate,"MMM DD, YYYY;;D"),format(curtime," - HH:MM:SS;;S")))
 ENDIF
 EXECUTE dm_readme_status
END GO
