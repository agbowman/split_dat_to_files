CREATE PROGRAM afc_replace_oi_quotes:dba
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
 SET readme_data->message = "Executing afc_replace_oi_quotes."
 RDB asis ( "alter session set nls_sort='BINARY'" )
 END ;Rdb
 FREE SET omf_temp
 RECORD omf_temp(
   1 data[*]
     2 indicator_cd = f8
     2 column_str = vc
 )
 FREE SET omf_temp_dblq
 RECORD omf_temp_dblq(
   1 data[*]
     2 indicator_cd = f8
     2 column_str = vc
 )
 SET v_dbl = '"'
 SET v_sgl = "'"
 SET v_cnt = 0
 CALL echo(build("v_dbl = ",v_dbl))
 CALL echo(build("v_sgl = ",v_sgl))
 SELECT INTO "nl:"
  oi.column_str, oi.indicator_cd
  FROM omf_indicator oi
  WHERE  NOT (oi.indicator_cd IN (
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=14265
    AND cv.cdf_meaning="INDICATOR"
    AND  NOT (cv.display_key IN ("PVTDAUSTARTDAYOFMONTH", "PVTDAUSTARTDAYOFWEEK", "PVTRAUENDDATE",
   "PVTRAUENDDAYOFMONTH", "PVTRAUENDHOUR",
   "PVTRAUENDTIME", "PVTRAUSTARTDATE", "PVTRAUSTARTDAYOFMONTH", "PVTRAUSTARTDAYOFWEEK",
   "PVTRAUSTARTHOUR",
   "PVTRAUSTARTTIME")))))
   AND findstring(oi.column_str,"'") > 0
  DETAIL
   v_cnt = (v_cnt+ 1)
   IF (mod(v_cnt,50)=1)
    stat = alterlist(omf_temp->data,(v_cnt+ 50))
   ENDIF
   omf_temp->data[v_cnt].indicator_cd = oi.indicator_cd, omf_temp->data[v_cnt].column_str = replace(
    oi.column_str,v_sgl,v_dbl,0)
  FOOT REPORT
   stat = alterlist(omf_temp->data,v_cnt)
  WITH nocounter
 ;end select
 UPDATE  FROM omf_indicator oi,
   (dummyt d1  WITH seq = value(size(omf_temp->data,5)))
  SET oi.column_str = omf_temp->data[d1.seq].column_str
  PLAN (d1)
   JOIN (oi
   WHERE (oi.indicator_cd=omf_temp->data[d1.seq].indicator_cd))
 ;end update
 COMMIT
 CALL echo("Updated all non 'PVT*' indicators on omf_indicator")
 SET v_cnt = 0
 SET stat = alterlist(omf_temp->data,0)
 SELECT INTO "nl:"
  oi.column_str, oi.indicator_cd
  FROM omf_indicator oi,
   code_value cv
  WHERE oi.indicator_cd=cv.code_value
   AND cv.code_set=14265
   AND cv.cdf_meaning="INDICATOR"
   AND cv.display_key IN ("PVTDAUSTARTDAYOFMONTH", "PVTDAUSTARTDAYOFWEEK", "PVTRAUENDDATE",
  "PVTRAUENDDAYOFMONTH", "PVTRAUENDHOUR",
  "PVTRAUENDTIME", "PVTRAUSTARTDATE", "PVTRAUSTARTDAYOFMONTH", "PVTRAUSTARTDAYOFWEEK",
  "PVTRAUSTARTHOUR",
  "PVTRAUSTARTTIME")
  DETAIL
   v_cnt = (v_cnt+ 1)
   IF (mod(v_cnt,10)=1)
    stat = alterlist(omf_temp->data,(v_cnt+ 10))
   ENDIF
   stat = alterlist(omf_temp->data,v_cnt), omf_temp->data[v_cnt].indicator_cd = oi.indicator_cd,
   omf_temp->data[v_cnt].column_str = replace(oi.column_str,"^sq^",v_sgl,0),
   omf_temp->data[v_cnt].column_str = replace(omf_temp->data[v_cnt].column_str,"^dq^",v_dbl,0)
  WITH nocounter
 ;end select
 UPDATE  FROM omf_indicator oi,
   (dummyt d1  WITH seq = value(size(omf_temp->data,5)))
  SET oi.column_str = omf_temp->data[d1.seq].column_str
  PLAN (d1)
   JOIN (oi
   WHERE (oi.indicator_cd=omf_temp->data[d1.seq].indicator_cd))
 ;end update
 COMMIT
 SET readme_data->message = "Updated all 'PVT*' indicators on omf_indicator (single & double quotes)"
 SET readme_data->status = "S"
 EXECUTE dm_readme_status
END GO
