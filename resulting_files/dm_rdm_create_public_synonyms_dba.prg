CREATE PROGRAM dm_rdm_create_public_synonyms:dba
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
 SET readme_data->message = "Failed: starting script dm_rdm_create_public_synonyms..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 FREE SET ml_sequences
 RECORD ml_sequences(
   1 qual[*]
     2 seq_name = vc
   1 qual_cnt = i2
 )
 SELECT DISTINCT INTO "nl:"
  c.sequence_name
  FROM dm_columns_doc c
  WHERE c.owner="V500"
   AND c.sequence_name > " "
   AND c.table_name IN (
  (SELECT
   t.table_name
   FROM dm_tables_doc t
   WHERE t.owner="V500"
    AND t.table_name=t.full_table_name
    AND t.data_model_section != "ADMINISTRATIF"
    AND t.data_model_section != "OUTCOMES*"))
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM all_synonyms asyn
   WHERE asyn.synonym_name=c.sequence_name
    AND asyn.owner="PUBLIC")))
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(ml_sequences->qual,(cnt+ 9))
   ENDIF
   ml_sequences->qual[cnt].seq_name = c.sequence_name
  FOOT REPORT
   stat = alterlist(ml_sequences->qual,cnt), ml_sequences->qual_cnt = cnt
  WITH nocounter
 ;end select
 IF (error(errmsg,0))
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to get sequences:",errmsg)
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO ml_sequences->qual_cnt)
   CALL parser(concat("rdb create or replace public synonym ",ml_sequences->qual[i].seq_name))
   CALL parser(concat("for ",ml_sequences->qual[i].seq_name))
   CALL parser("go")
   IF (error(errmsg,0))
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to add synonym ",ml_sequences->qual[i].seq_name,":",
     errmsg)
    GO TO exit_script
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Public synonyms created."
#exit_script
 FREE SET ml_sequences
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
