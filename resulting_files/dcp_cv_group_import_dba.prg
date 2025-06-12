CREATE PROGRAM dcp_cv_group_import:dba
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
 SET readme_data->message = "Readme failure: starting dcp_cv_group_import script..."
 DECLARE rdm_rptcnt = i4
 SET rdm_rptcnt = 0
 FREE RECORD requestin
 RECORD requestin(
   1 list_0[*]
     2 parent_code_set = vc
     2 parent_cdf_mean = vc
     2 child_code_set = vc
     2 child_cdf_mean = vc
 )
 FREE RECORD request
 RECORD request(
   1 parent_qual[*]
     2 parent_code_set = i4
     2 parent_cdf_mean = c12
     2 parent_code_value = f8
     2 child_qual[*]
       3 child_code_set = i4
       3 child_cdf_mean = c12
       3 child_code_value = f8
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationstatus = c1
       3 operationname = c15
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET logical csv_name "cer_install:dcp_cust_col_import.csv"
 FREE DEFINE rtl2
 DEFINE rtl2 "csv_name"
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   rdm_line_data = fillstring(2000," "), rdm_first_one = "Y"
  DETAIL
   IF (rdm_first_one="N")
    rdm_length = textlen(trim(t.line)), rdm_rptcnt = (rdm_rptcnt+ 1)
    IF (mod(rdm_rptcnt,10)=1)
     rdm_stat = alterlist(requestin->list_0,(rdm_rptcnt+ 9))
    ENDIF
    rdm_line_data = t.line, rdm_field_number = 1, rdm_check_pos = 0
    WHILE (rdm_field_number <= 4)
      IF ('"'=substring(1,1,rdm_line_data))
       rdm_check_pos = findstring('",',rdm_line_data), rdm_found_field = substring(2,(rdm_check_pos
         - 2),rdm_line_data)
       IF (rdm_check_pos=0)
        rdm_check_pos = findstring('"',substring(2,rdm_length,rdm_line_data)), rdm_found_field =
        substring(2,(rdm_check_pos - 1),rdm_line_data)
        IF (rdm_check_pos=0)
         rdm_found_field = substring(2,rdm_length,rdm_line_data)
        ENDIF
       ENDIF
      ELSE
       rdm_check_pos = findstring(",",rdm_line_data), rdm_found_field = substring(1,(rdm_check_pos -
        1),rdm_line_data)
       IF (rdm_check_pos=0)
        rdm_found_field = substring(1,rdm_length,rdm_line_data)
       ENDIF
      ENDIF
      CASE (rdm_field_number)
       OF 1:
        requestin->list_0[rdm_rptcnt].parent_code_set = rdm_found_field
       OF 2:
        requestin->list_0[rdm_rptcnt].parent_cdf_mean = rdm_found_field
       OF 3:
        requestin->list_0[rdm_rptcnt].child_code_set = rdm_found_field
       OF 4:
        requestin->list_0[rdm_rptcnt].child_cdf_mean = rdm_found_field
      ENDCASE
      IF ('"'=substring(1,1,rdm_line_data))
       rdm_line_data = substring((rdm_check_pos+ 2),rdm_length,rdm_line_data)
      ELSE
       rdm_line_data = substring((rdm_check_pos+ 1),rdm_length,rdm_line_data)
      ENDIF
      rdm_field_number = (rdm_field_number+ 1)
    ENDWHILE
   ENDIF
   rdm_first_one = "N"
  FOOT REPORT
   stat = alterlist(requestin->list_0,rdm_rptcnt)
  WITH nocounter, maxcol = 2100
 ;end select
 SET cdf_mean = fillstring(12," ")
 SET chld_cdf_mean = fillstring(12," ")
 SET code_set = 0
 SET list_cnt = 0
 SET p_cnt = 0
 SET c_cnt = 0
 SET x = 0
 SET list_cnt = size(requestin->list_0,5)
 SET stat = alterlist(request->parent_qual,10)
 FOR (x = 1 TO list_cnt)
   IF ((((cdf_mean != requestin->list_0[x].parent_cdf_mean)) OR (code_set != cnvtint(requestin->
    list_0[x].parent_code_set))) )
    SET p_cnt = (p_cnt+ 1)
    IF (mod(p_cnt,10)=1)
     SET stat = alterlist(request->parent_qual,(p_cnt+ 10))
    ENDIF
    SET request->parent_qual[p_cnt].parent_code_set = cnvtint(requestin->list_0[x].parent_code_set)
    SET request->parent_qual[p_cnt].parent_cdf_mean = requestin->list_0[x].parent_cdf_mean
    SET cdf_mean = requestin->list_0[x].parent_cdf_mean
    SET code_set = cnvtint(requestin->list_0[x].parent_code_set)
    SET c_cnt = 0
   ENDIF
   SET c_cnt = (c_cnt+ 1)
   SET stat = alterlist(request->parent_qual[p_cnt].child_qual,c_cnt)
   SET request->parent_qual[p_cnt].child_qual[c_cnt].child_code_set = cnvtint(requestin->list_0[x].
    child_code_set)
   SET request->parent_qual[p_cnt].child_qual[c_cnt].child_cdf_mean = requestin->list_0[x].
   child_cdf_mean
   SET chld_cdf_mean = requestin->list_0[x].child_cdf_mean
   SET readme_data->message = build("PVReadMe 1099:Added CVGroup row for ",cdf_mean,"/",chld_cdf_mean,
    ".")
   COMMIT
 ENDFOR
 SET stat = alterlist(request->parent_qual,p_cnt)
 EXECUTE dcp_insert_cv_group
 IF ((reply->status_data.status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = "Readme failure: Error inserting into code_value_group table."
 ELSE
  SET readme_data->status = "S"
 ENDIF
 IF (list_cnt > 0)
  SET readme_data->message = build("PVReadMe 1099: ",list_cnt," rows added to code_value_group.")
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = build("PVReadMe 1099: No data in or cant find dcp_cust_col_import.csv.")
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 COMMIT
END GO
