CREATE PROGRAM cps_readme_nomen_cat_list:dba
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
 FREE SET n
 RECORD n(
   1 p_cnt = i4
   1 p[*]
     2 parent_category_id = f8
     2 last_seq = i4
     2 c_cnt = i4
     2 c[*]
       3 nomen_cat_list_id = f8
       3 list_sequence = i4
 )
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET error_level = 0
 SET readme_data->message = concat("CPS_README_NOMEN_CAT_LIST BEG : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SET ierrcode = 0
 CALL parser("rdb alter table NOMEN_CAT_LIST add (LIST_SEQUENCE NUMBER  DEFAULT 0) go")
 EXECUTE oragen3 "NOMEN_CAT_LIST"
 SET ierrcode = 0
 SELECT INTO "NL:"
  FROM nomen_cat_list n
  WHERE n.nomen_cat_list_id > 0
  ORDER BY n.parent_category_id
  HEAD REPORT
   p = 0, c = 0, last_seq = 0
  HEAD n.parent_category_id
   c = 0, p = (p+ 1), stat = alterlist(n->p,p),
   n->p[p].parent_category_id = n.parent_category_id, last_seq = 0
  DETAIL
   IF (n.list_sequence > last_seq)
    last_seq = n.list_sequence
   ENDIF
   IF (n.list_sequence < 1)
    c = (c+ 1), stat = alterlist(n->p[p].c,c), n->p[p].c[c].nomen_cat_list_id = n.nomen_cat_list_id,
    n->p[p].c[c].list_sequence = c
   ENDIF
  FOOT  n.parent_category_id
   n->p[p].c_cnt = c, n->p[p].last_seq = last_seq
  FOOT REPORT
   n->p_cnt = p
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: A script error occurred building the update list"
  SET error_level = 1
  GO TO exit_script
 ENDIF
 FOR (p = 1 TO n->p_cnt)
   FOR (c = 1 TO n->p[p].c_cnt)
     SET ierrcode = 0
     UPDATE  FROM nomen_cat_list n
      SET n.list_sequence = (n->p[p].last_seq+ c)
      WHERE (n.nomen_cat_list_id=n->p[p].c[c].nomen_cat_list_id)
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET readme_data->message = build(
       " ERROR :: A script error occurred updating the list_sequence for nomen_cat_list_id :",n->p[p]
       .c[c].nomen_cat_list_id)
      SET error_level = 1
      GO TO exit_script
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 IF (error_level=1)
  SET status_msg = "FAILURE"
  ROLLBACK
  SET readme_data->status = "F"
 ELSE
  COMMIT
  SET status_msg = "SUCCESS"
  SET readme_data->status = "S"
 ENDIF
 SET readme_data->message = concat("CPS_README_NOMEN_CAT_LIST BEG : ",trim(status_msg)," ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 COMMIT
END GO
