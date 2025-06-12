CREATE PROGRAM daf_icd9_read_txtfnd_comment:dba
 RECORD reply(
   1 comment_list[*]
     2 data_id = f8
     2 cat_id = f8
     2 comment_type_flag = i2
     2 comment_state_flag = i2
     2 data_source = vc
     2 comment_col_name = vc
     2 comment_col_dt_tm = dq8
     2 comment_person_name = vc
     2 comment_create_date = dq8
     2 comment_text = vc
   1 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE data_type_flag = i2 WITH public, constant(1)
 DECLARE detail_type_flag = i2 WITH public, constant(2)
 DECLARE catid = f8 WITH public, noconstant(0.0)
 DECLARE errmsg = vc WITH public
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE replycnt = i4 WITH public, noconstant(0)
 IF ((request->search_id <= 0.0))
  SET reply->status_data.status = "F"
  SET reply->message = "No valid search_id was provided."
  GO TO exit_script
 ENDIF
 IF ((request->search_type_flag <= 0))
  SET reply->status_data.status = "F"
  SET reply->message = "No valid search_type_flag was provided."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  dtfc.dm_text_find_cat_id
  FROM dm_text_find_cat dtfc
  WHERE dtfc.find_category="ICD9"
   AND dtfc.active_ind=1
  DETAIL
   catid = dtfc.dm_text_find_cat_id
  WITH nocounter
 ;end select
 IF (catid=0.0)
  SET reply->status_data.status = "F"
  SET reply->message = concat("No category matching ",request->find_category," could be found")
  GO TO exit_script
 ENDIF
 IF ((request->search_type_flag=data_type_flag))
  IF ((request->full_history_ind=1))
   SELECT INTO "nl:"
    dtfc.dm_text_find_data_id, dtfc.dm_text_find_cat_id, dtfc.comment_type_flag,
    dtfc.comment_state_flag, dtfc.data_source, dtfc.comment_col_name,
    dtfc.comment_col_dt_tm, dtfc.comment_dt_tm, dtfc.comment_text,
    p.name_full_formatted
    FROM dm_text_find_comment dtfc,
     prsnl p
    WHERE (dtfc.dm_text_find_data_id=request->search_id)
     AND dtfc.dm_text_find_cat_id=catid
     AND dtfc.comment_prsnl_id=p.person_id
    ORDER BY dtfc.comment_dt_tm DESC
    DETAIL
     replycnt = (replycnt+ 1), stat = alterlist(reply->comment_list,replycnt), reply->comment_list[
     replycnt].data_id = dtfc.dm_text_find_data_id,
     reply->comment_list[replycnt].cat_id = dtfc.dm_text_find_cat_id, reply->comment_list[replycnt].
     comment_type_flag = dtfc.comment_type_flag, reply->comment_list[replycnt].comment_state_flag =
     dtfc.comment_state_flag,
     reply->comment_list[replycnt].data_source = dtfc.data_source, reply->comment_list[replycnt].
     comment_col_name = dtfc.comment_col_name, reply->comment_list[replycnt].comment_col_dt_tm =
     cnvtdatetime(dtfc.comment_col_dt_tm),
     reply->comment_list[replycnt].comment_person_name = p.name_full_formatted, reply->comment_list[
     replycnt].comment_create_date = cnvtdatetime(dtfc.comment_dt_tm), reply->comment_list[replycnt].
     comment_text = dtfc.comment_text
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET reply->status_data.status = "F"
    SET reply->message = concat("Failed reading all data comment rows:",errmsg)
    GO TO exit_script
   ENDIF
  ELSE
   SELECT INTO "nl:"
    dtfc.dm_text_find_data_id, dtfc.dm_text_find_cat_id, dtfc.comment_type_flag,
    dtfc.comment_state_flag, dtfc.data_source, dtfc.comment_col_name,
    dtfc.comment_col_dt_tm, dtfc.comment_dt_tm, dtfc.comment_text,
    p.name_full_formatted
    FROM dm_text_find_comment dtfc,
     prsnl p
    WHERE (dtfc.dm_text_find_data_id=request->search_id)
     AND dtfc.dm_text_find_cat_id=catid
     AND (dtfc.comment_dt_tm=
    (SELECT
     max(dtfc2.comment_dt_tm)
     FROM dm_text_find_comment dtfc2
     WHERE (dtfc2.dm_text_find_data_id=request->search_id)
      AND dtfc2.dm_text_find_cat_id=catid))
     AND dtfc.comment_prsnl_id=p.person_id
    DETAIL
     replycnt = (replycnt+ 1), stat = alterlist(reply->comment_list,replycnt), reply->comment_list[
     replycnt].data_id = dtfc.dm_text_find_data_id,
     reply->comment_list[replycnt].cat_id = dtfc.dm_text_find_cat_id, reply->comment_list[replycnt].
     comment_type_flag = dtfc.comment_type_flag, reply->comment_list[replycnt].comment_state_flag =
     dtfc.comment_state_flag,
     reply->comment_list[replycnt].data_source = dtfc.data_source, reply->comment_list[replycnt].
     comment_col_name = dtfc.comment_col_name, reply->comment_list[replycnt].comment_col_dt_tm =
     cnvtdatetime(dtfc.comment_col_dt_tm),
     reply->comment_list[replycnt].comment_person_name = p.name_full_formatted, reply->comment_list[
     replycnt].comment_create_date = cnvtdatetime(dtfc.comment_dt_tm), reply->comment_list[replycnt].
     comment_text = dtfc.comment_text
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET reply->status_data.status = "F"
    SET reply->message = concat("Failed reading latest data comment rows:",errmsg)
    GO TO exit_script
   ENDIF
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->message = "Successfully read all comment rows requested."
 ELSEIF ((request->search_type_flag=detail_type_flag))
  IF ((request->full_history_ind=1))
   SELECT INTO "nl:"
    dtfc.dm_text_find_data_id, dtfc.dm_text_find_cat_id, dtfc.comment_type_flag,
    dtfc.comment_state_flag, dtfc.data_source, dtfc.comment_col_name,
    dtfc.comment_col_dt_tm, dtfc.comment_dt_tm, dtfc.comment_text,
    p.name_full_formatted
    FROM dm_text_find_data dtfd,
     dm_text_find_comment dtfc,
     prsnl p
    WHERE (dtfd.dm_text_find_detail_id=request->search_id)
     AND dtfc.dm_text_find_data_id=dtfd.dm_text_find_data_id
     AND dtfc.dm_text_find_cat_id=catid
     AND dtfc.comment_prsnl_id=p.person_id
    ORDER BY dtfc.dm_text_find_data_id, dtfc.comment_dt_tm DESC
    DETAIL
     replycnt = (replycnt+ 1), stat = alterlist(reply->comment_list,replycnt), reply->comment_list[
     replycnt].data_id = dtfc.dm_text_find_data_id,
     reply->comment_list[replycnt].cat_id = dtfc.dm_text_find_cat_id, reply->comment_list[replycnt].
     comment_type_flag = dtfc.comment_type_flag, reply->comment_list[replycnt].comment_state_flag =
     dtfc.comment_state_flag,
     reply->comment_list[replycnt].data_source = dtfc.data_source, reply->comment_list[replycnt].
     comment_col_name = dtfc.comment_col_name, reply->comment_list[replycnt].comment_col_dt_tm =
     cnvtdatetime(dtfc.comment_col_dt_tm),
     reply->comment_list[replycnt].comment_person_name = p.name_full_formatted, reply->comment_list[
     replycnt].comment_create_date = cnvtdatetime(dtfc.comment_dt_tm), reply->comment_list[replycnt].
     comment_text = dtfc.comment_text
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET reply->status_data.status = "F"
    SET reply->message = concat("Failed reading all detail comment rows:",errmsg)
    GO TO exit_script
   ENDIF
  ELSE
   SELECT INTO "nl:"
    dtfc.dm_text_find_data_id, dtfc.dm_text_find_cat_id, dtfc.comment_type_flag,
    dtfc.comment_state_flag, dtfc.data_source, dtfc.comment_col_name,
    dtfc.comment_col_dt_tm, dtfc.comment_dt_tm, dtfc.comment_text,
    p.name_full_formatted
    FROM dm_text_find_data dtfd,
     dm_text_find_comment dtfc,
     prsnl p
    WHERE (dtfd.dm_text_find_detail_id=request->search_id)
     AND dtfc.dm_text_find_data_id=dtfd.dm_text_find_data_id
     AND dtfc.dm_text_find_cat_id=catid
     AND (dtfc.comment_dt_tm=
    (SELECT
     max(dtfc2.comment_dt_tm)
     FROM dm_text_find_comment dtfc2
     WHERE dtfc2.dm_text_find_data_id=dtfc.dm_text_find_data_id
      AND dtfc2.dm_text_find_cat_id=catid))
     AND dtfc.comment_prsnl_id=p.person_id
    ORDER BY dtfc.dm_text_find_data_id, dtfc.comment_dt_tm DESC
    DETAIL
     replycnt = (replycnt+ 1), stat = alterlist(reply->comment_list,replycnt), reply->comment_list[
     replycnt].data_id = dtfc.dm_text_find_data_id,
     reply->comment_list[replycnt].cat_id = dtfc.dm_text_find_cat_id, reply->comment_list[replycnt].
     comment_type_flag = dtfc.comment_type_flag, reply->comment_list[replycnt].comment_state_flag =
     dtfc.comment_state_flag,
     reply->comment_list[replycnt].data_source = dtfc.data_source, reply->comment_list[replycnt].
     comment_col_name = dtfc.comment_col_name, reply->comment_list[replycnt].comment_col_dt_tm =
     cnvtdatetime(dtfc.comment_col_dt_tm),
     reply->comment_list[replycnt].comment_person_name = p.name_full_formatted, reply->comment_list[
     replycnt].comment_create_date = cnvtdatetime(dtfc.comment_dt_tm), reply->comment_list[replycnt].
     comment_text = dtfc.comment_text
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET reply->status_data.status = "F"
    SET reply->message = concat("Failed reading latest detail comment rows:",errmsg)
    GO TO exit_script
   ENDIF
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->message = "Successfully read all comment rows requested."
 ELSE
  SET reply->status_data.status = "F"
  SET reply->message = "The provided search_type_flag value is not supported."
 ENDIF
#exit_script
END GO
