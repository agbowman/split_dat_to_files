CREATE PROGRAM dm_create_synonyms:dba
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
 FREE RECORD syn
 RECORD syn(
   1 syn_cnt = i4
   1 s[*]
     2 obj_name = vc
   1 str = vc
 )
 SET syn->syn_cnt = 0
 SET stat = alterlist(syn->s,0)
 SET syn_emsg = fillstring(132," ")
 SET syn_ecode = 0
 SELECT INTO "nl:"
  FROM user_tables u
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM all_synonyms a
   WHERE a.owner="PUBLIC"
    AND a.synonym_name=u.table_name)))
  ORDER BY u.table_name
  HEAD REPORT
   cnt = 0
  DETAIL
   syn->syn_cnt = (syn->syn_cnt+ 1), stat = alterlist(syn->s,syn->syn_cnt), cnt = syn->syn_cnt,
   syn->s[cnt].obj_name = u.table_name
  WITH nocounter
 ;end select
 FOR (si = 1 TO syn->syn_cnt)
   EXECUTE dm_create_object_synonym syn->s[si].obj_name, "TABLE"
   SET syn_ecode = error(syn_emsg,1)
   IF (syn_ecode != 0)
    SET readme_data->status = "F"
    SET readme_data->message = syn_emsg
    GO TO exit_script
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Synonyms created successfully."
#exit_script
 EXECUTE dm_readme_status
END GO
