CREATE PROGRAM dm2_const_load_dm_info:dba
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
 DECLARE check_dm_info_rows(con_count=i4) = i4
 DECLARE errmsg = c132
 DECLARE errcode = i4
 DECLARE const_check_cnt = i4
 DECLARE parse_str = c128
 SET const_check_cnt = size(requestin->list_0,5)
 SET readme_data->status = "F"
 SET readme_data->message = "Updating DM_INFO..."
 SET parse_str = fillstring(128," ")
 IF (const_check_cnt <= 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Failed to load records from dm2_obsolete_constraints.csv."
  GO TO exit_script
 ENDIF
 FOR (y = 1 TO const_check_cnt)
   SET parse_str = concat("execute dm_drop_obsolete_objects '",requestin->list_0[y].constraint_name,
    "','CONSTRAINT',1 go")
   SET errcode = 0
   SET errmsg = fillstring(132," ")
   CALL echo(parse_str)
   CALL parser(parse_str)
   IF (errcode != 0)
    SET readme_data->message = errmsg
    SET readme_data->status = "F"
    GO TO exit_script
   ENDIF
 ENDFOR
 IF (check_dm_info_rows(const_check_cnt)=0)
  SET readme_data->status = "S"
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Check failed. Rows in request != rows in DM_INFO."
 ENDIF
#exit_script
 IF ((readme_data->status="S"))
  SET readme_data->message = "DM_INFO has been updated successfully."
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 SUBROUTINE check_dm_info_rows(con_count)
   DECLARE after_cnt = i4
   SET after_cnt = 0
   SELECT DISTINCT INTO "nl:"
    dc.info_name
    FROM dm_info dc,
     (dummyt d  WITH seq = con_count)
    PLAN (d)
     JOIN (dc
     WHERE (requestin->list_0[d.seq].constraint_name=dc.info_name)
      AND dc.info_domain="OBSOLETE_CONSTRAINT")
    WITH nocounter
   ;end select
   SET after_cnt = curqual
   IF (after_cnt=con_count)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
END GO
