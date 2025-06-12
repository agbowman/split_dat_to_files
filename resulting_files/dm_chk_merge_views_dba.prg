CREATE PROGRAM dm_chk_merge_views:dba
 SET c_mod = "DM_CHK_MERGE_VIEWS 000"
 SET readme_id = 2183
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
 IF (validate(readme_data->readme_id,0)=0
  AND validate(readme_data->readme_id,1)=1)
  SET readme_data->readme_id = readme_id
  SET readme_data->description = "DM_CHK_MERGE_VIEWS"
 ENDIF
 DECLARE temp_msg = c255
 SET temp_msg = fillstring(255," ")
 FREE RECORD rec_view
 RECORD rec_view(
   1 qual[*]
     2 view_name = vc
 )
 DECLARE cnt = i4
 SET cnt = 0
 DECLARE view_ind = i4
 SET view_ind = 0
 SET stat = alterlist(rec_view->qual,50)
 SET cnt = (cnt+ 1)
 SET rec_view->qual[cnt].view_name = "BILL_ITEM_VIEW_CV_CV"
 SET cnt = (cnt+ 1)
 SET rec_view->qual[cnt].view_name = "BILL_ITEM_VIEW_OT_CV"
 SET cnt = (cnt+ 1)
 SET rec_view->qual[cnt].view_name = "BILL_ITEM_VIEW_CV_N"
 SET cnt = (cnt+ 1)
 SET rec_view->qual[cnt].view_name = "BILL_ITEM_VIEW_CV_OT"
 SET cnt = (cnt+ 1)
 SET rec_view->qual[cnt].view_name = "BILL_ITEM_VIEW_CV_NA"
 SET cnt = (cnt+ 1)
 SET rec_view->qual[cnt].view_name = "BILL_ITEM_VIEW_NA_CV"
 SET cnt = (cnt+ 1)
 SET rec_view->qual[cnt].view_name = "BILL_ITEM_VIEW_OT_NA"
 SET cnt = (cnt+ 1)
 SET rec_view->qual[cnt].view_name = "BILL_ITEM_VIEW_NA_OT"
 SET cnt = (cnt+ 1)
 SET rec_view->qual[cnt].view_name = "BILL_ITEM_VIEW_BI_NA"
 SET cnt = (cnt+ 1)
 SET rec_view->qual[cnt].view_name = "V500_EVENT_CODE_VIEW"
 SET cnt = (cnt+ 1)
 SET rec_view->qual[cnt].view_name = "DM_MERGE_CONSTRAINTS_VIEW"
 SET stat = alterlist(rec_view->qual,cnt)
 SET readme_data->status = "S"
 SET temp_msg = "All views found successfully."
 FOR (i = 1 TO cnt)
   SET view_ind = 0
   SELECT INTO "nl:"
    t.view_name
    FROM dba_views t
    WHERE (t.view_name=rec_view->qual[i].view_name)
    HEAD REPORT
     view_ind = 1
    WITH nocounter
   ;end select
   IF (view_ind=0)
    SET readme_data->status = "F"
    SET temp_msg = concat("View not found for ",rec_view->qual[i].view_name)
    SET i = cnt
   ENDIF
 ENDFOR
 SET readme_data->message = temp_msg
 EXECUTE dm_readme_status
 COMMIT
END GO
