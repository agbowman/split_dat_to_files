CREATE PROGRAM dm_ocd_schema_test:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cs_to_add = 0
 SET number_to_add = 0
 SET feature_num = 0
 SET desc = fillstring(50," ")
 SET reply->status_data.status = "F"
 SET afd_nbr = request->ocd_number
 SET cid = request->client_id
 SET desc = request->description
 SET rev_nbr = request->rev_number
 SET feature_num = request->feature_num
 IF ((request->create_flag=0))
  SELECT INTO "nl:"
   d.*
   FROM dm_alpha_features d
   WHERE d.alpha_feature_nbr=afd_nbr
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM dm_alpha_features
    SET alpha_feature_nbr = afd_nbr, description = desc, create_dt_tm = cnvtdatetime(request->
      create_dt_tm),
     sponsor_client_id = cid, rev_number = rev_nbr
    WITH nocounter
   ;end insert
  ELSE
   UPDATE  FROM dm_alpha_features
    SET description = desc, create_dt_tm = cnvtdatetime(request->create_dt_tm), sponsor_client_id =
     cid,
     rev_number = rev_nbr
    WHERE alpha_feature_nbr=afd_nbr
    WITH nocounter
   ;end update
  ENDIF
  EXECUTE dm_ocd_delete_temp_schema
  EXECUTE dm_ocd_delete_codesets
  DELETE  FROM dm_ocd_features
   WHERE alpha_feature_nbr=afd_nbr
   WITH nocounter
  ;end delete
  COMMIT
  SET tot_cs = 0
  SET tot_tbl = 0
  FOR (i = 1 TO feature_num)
    SET number_to_add = request->feature[i].qual_num
    SET cs_to_add = request->feature[i].cs_num
    SET tot_cs = (tot_cs+ cs_to_add)
    SET tot_tbl = (tot_tbl+ number_to_add)
    INSERT  FROM dm_ocd_features
     SET alpha_feature_nbr = afd_nbr, feature_number = request->feature[i].feature_number
     WITH nocounter
    ;end insert
    COMMIT
    IF (((number_to_add > 0) OR (cs_to_add > 0)) )
     UPDATE  FROM dm_ocd_features a
      SET a.schema_ind = 1
      WHERE a.alpha_feature_nbr=afd_nbr
       AND (a.feature_number=request->feature[i].feature_number)
      WITH nocounter
     ;end update
     COMMIT
    ENDIF
    COMMIT
    SET fnumber = request->feature[i].feature_number
    SET rev_date = cnvtdatetime(curdate,curtime3)
    SET sch_date = format(cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY HH:MM;;D")
    SELECT INTO "nl:"
     a.schema_date
     FROM dm_schema_version a
     WHERE a.schema_version=rev_nbr
     DETAIL
      rev_date = a.schema_date
     WITH nocounter
    ;end select
    FREE SET list
    RECORD list(
      1 qual[*]
        2 code_set = i4
      1 count = i4
    )
    SET list->count = 0
    SET stat = alterlist(list->qual,10)
    FOR (z = 1 TO cs_to_add)
      SET list->count = (list->count+ 1)
      IF (mod(list->count,10)=1)
       SET stat = alterlist(list->qual,(list->count+ 9))
      ENDIF
      SET list->qual[list->count].code_set = request->feature[i].cs[z].code_set
    ENDFOR
    EXECUTE dm_ocd_fill_codesets
    FREE SET tab_list
    RECORD tab_list(
      1 qual[*]
        2 table_name = vc
        2 old_ocd_number = i4
        2 col_knt = i4
        2 index_knt = i4
        2 cons_knt = i4
      1 count = i4
    )
    SET tab_list->count = 0
    SET stat = alterlist(tab_list->qual,10)
    FOR (x = 1 TO number_to_add)
      SET tab_list->count = (tab_list->count+ 1)
      IF (mod(tab_list->count,10)=1)
       SET stat = alterlist(tab_list->qual,(tab_list->count+ 9))
      ENDIF
      SET tab_list->qual[tab_list->count].table_name = request->feature[i].qual[x].table_name
      SET tab_list->qual[tab_list->count].old_ocd_number = request->feature[i].qual[x].old_ocd_number
      SET tab_list->qual[tab_list->count].col_knt = request->feature[i].qual[x].column_num
      SET tab_list->qual[tab_list->count].index_knt = request->feature[i].qual[x].index_num
      SET tab_list->qual[tab_list->count].cons_knt = request->feature[i].qual[x].cons_num
    ENDFOR
    EXECUTE dm_ocd_fill_test
  ENDFOR
  EXECUTE dm_ocd_delete_schema
  EXECUTE dm_fill_ocd_columns
 ENDIF
 EXECUTE dm_ocd_output_file
 SET reply->status_data.status = "S"
END GO
