CREATE PROGRAM dm_ins_mrg_trans_kid:dba
 IF (dimtc_tbl_name IN ("PERSON", "PERSON_NAME", "PERSON_ALIAS"))
  INSERT  FROM dm_merge_translate dmt
   (dmt.from_value, dmt.table_name, dmt.env_source_id,
   dmt.env_target_id, dmt.to_value, dmt.status_flg,
   dmt.error_nbr, dmt.error_msg, dmt.merge_id)(SELECT
    dcm_result1 = parser(build("t.",dimtc_col_name)), dimtc_tbl_name, dimtc_src_env_id,
    dimtc_tgt_env_id, dcm_result2 = parser(build("t.",dimtc_col_name)), 0,
    0, null, 0
    FROM (value(dimtc_tbl_name) t),
     prsnl pr
    WHERE parser(build("t.",dimtc_col_name,">",dimtc_sta_v))
     AND parser(build("t.",dimtc_col_name,"<=",dimtc_var_v))
     AND t.person_id=pr.person_id)
   WITH nocounter
  ;end insert
 ELSEIF (dimtc_tbl_name IN ("PHONE", "ADDRESS"))
  INSERT  FROM dm_merge_translate dmt
   (dmt.from_value, dmt.table_name, dmt.env_source_id,
   dmt.env_target_id, dmt.to_value, dmt.status_flg,
   dmt.error_nbr, dmt.error_msg, dmt.merge_id)(SELECT
    dcm_result1 = parser(build("t.",dimtc_col_name)), dimtc_tbl_name, dimtc_src_env_id,
    dimtc_tgt_env_id, dcm_result2 = parser(build("t.",dimtc_col_name)), 0,
    0, null, 0
    FROM (value(spec_tbl->list[spec_lp].table_name) t),
     prsnl pr
    WHERE parser(build("t.",dimtc_col_name," >",dimtc_sta_v))
     AND parser(build("t.",dimtc_col_name,"<=",dimtc_var_v))
     AND t.parent_entity_id=pr.person_id
     AND t.parent_entity_name IN ("PRSNL", "PERSON"))
   WITH nocounter
  ;end insert
 ELSE
  IF (dimtc_dis_ind=0)
   INSERT  FROM dm_merge_translate dmt
    (dmt.from_value, dmt.table_name, dmt.env_source_id,
    dmt.env_target_id, dmt.to_value, dmt.status_flg,
    dmt.error_nbr, dmt.error_msg, dmt.merge_id)(SELECT
     dcm_result1 = parser(build("t.",dimtc_col_name)), dimtc_tbl_name, dimtc_src_env_id,
     dimtc_tgt_env_id, dcm_result2 = parser(build("t.",dimtc_col_name)), 0,
     0, null, 0
     FROM (value(dimtc_tbl_name) t)
     WHERE parser(build("t.",dimtc_col_name,">",dimtc_sta_v))
      AND parser(build("t.",dimtc_col_name,"<=",dimtc_var_v)))
    WITH nocounter
   ;end insert
  ELSE
   INSERT  FROM dm_merge_translate dmt
    (dmt.from_value, dmt.table_name, dmt.env_source_id,
    dmt.env_target_id, dmt.to_value, dmt.status_flg,
    dmt.error_nbr, dmt.error_msg, dmt.merge_id)(SELECT DISTINCT
     dcm_result1 = parser(build("t.",dimtc_col_name)), dimtc_tbl_name, dimtc_src_env_id,
     dimtc_tgt_env_id, dcm_result2 = parser(build("t.",dimtc_col_name)), 0,
     0, null, 0
     FROM (value(dimtc_tbl_name) t)
     WHERE parser(build("t.",dimtc_col_name,">",dimtc_sta_v))
      AND parser(build("t.",dimtc_col_name,"<=",dimtc_var_v)))
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
END GO
