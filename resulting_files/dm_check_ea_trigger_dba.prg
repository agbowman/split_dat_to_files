CREATE PROGRAM dm_check_ea_trigger:dba
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
 SET readme_data->status = "S"
 SET readme_data->message = "DM_ENTITY_ACTIVITY_TRIGGER Successful.  Count= "
 DECLARE v_count1 = i4
 RECORD trg(
   1 data[15]
     2 table_name = vc
     2 row_cnt = i4
 )
 SET trg->data[1].table_name = "ENCNTR_ALIAS"
 SET trg->data[1].row_cnt = 1
 SET trg->data[2].table_name = "ENCNTR_INFO"
 SET trg->data[2].row_cnt = 1
 SET trg->data[3].table_name = "ENCNTR_LEAVE"
 SET trg->data[3].row_cnt = 1
 SET trg->data[4].table_name = "ENCNTR_PRSNL_RELTN"
 SET trg->data[4].row_cnt = 1
 SET trg->data[5].table_name = "ENCOUNTER"
 SET trg->data[5].row_cnt = 1
 SET trg->data[6].table_name = "PERSON"
 SET trg->data[6].row_cnt = 1
 SET trg->data[7].table_name = "PERSON_ALIAS"
 SET trg->data[7].row_cnt = 1
 SET trg->data[8].table_name = "PERSON_NAME"
 SET trg->data[8].row_cnt = 1
 SET trg->data[9].table_name = "PERSON_ORG_RELTN"
 SET trg->data[9].row_cnt = 1
 SET trg->data[10].table_name = "PERSON_PATIENT"
 SET trg->data[10].row_cnt = 1
 SET trg->data[11].table_name = "PERSON_PERSON_RELTN"
 SET trg->data[11].row_cnt = 1
 SET trg->data[12].table_name = "PERSON_PLAN_RELTN"
 SET trg->data[12].row_cnt = 1
 SET trg->data[13].table_name = "PERSON_PRSNL_RELTN"
 SET trg->data[13].row_cnt = 1
 SET trg->data[14].table_name = "PHONE"
 SET trg->data[14].row_cnt = 1
 SET trg->data[15].table_name = "ADDRESS"
 SET trg->data[15].row_cnt = 1
 IF (currdb="DB2UDB")
  SELECT INTO "nl:"
   td.suffixed_table_name
   FROM dm_tables_doc td,
    (dummyt d  WITH seq = value(size(trg->data,5)))
   PLAN (d)
    JOIN (td
    WHERE td.table_name=trim(trg->data[d.seq].table_name))
   DETAIL
    trg->data[d.seq].table_name = td.suffixed_table_name
   WITH nocounter
  ;end select
 ENDIF
 FOR (trg_ndx = 1 TO size(trg->data,5))
   SET v_count1 = 0
   SELECT INTO "nl:"
    table_count = count(*)
    FROM dm_entity_activity_trigger deat
    WHERE (deat.table_name=trg->data[trg_ndx].table_name)
    DETAIL
     v_count1 = table_count
    WITH nocounter
   ;end select
   IF ((v_count1 != trg->data[trg_ndx].row_cnt))
    SET readme_data->status = "F"
    SET readme_data->message = concat("DM_ENTITY_ACTIVITY_TRIGGER: Expected ",trim(cnvtstring(trg->
       data[trg_ndx].row_cnt),3)," row(s)  for ",trim(trg->data[trg_ndx].table_name,3)," but found ",
     trim(cnvtstring(v_count1),3)," row(s)")
    SET trg_ndx = (size(trg->data,5)+ 1)
   ENDIF
 ENDFOR
 EXECUTE dm_readme_status
 FREE RECORD trg
END GO
