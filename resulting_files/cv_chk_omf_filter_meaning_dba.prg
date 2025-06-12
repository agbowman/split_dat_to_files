CREATE PROGRAM cv_chk_omf_filter_meaning:dba
 SET error_msg = fillstring(200," ")
 SET failure = "F"
 SET v_count1 = 0
 SET v_cnt_indicator = 108
 SET v_indicator_flag = 0
 SELECT INTO "nl:"
  table_count = count(*)
  FROM omf_filter_meaning ofm
  WHERE ofm.filter_meaning IN ("CV_*")
  DETAIL
   v_count1 = table_count
  WITH nocounter
 ;end select
 IF (v_count1 < v_cnt_indicator)
  SET failure = "T"
  SET v_indicator_flag = 1
 ENDIF
 IF (failure="T")
  SET error_msg = "Incorrect counts found on the following tables: "
  IF (v_indicator_flag=1)
   SET error_msg = concat(trim(error_msg,3),",cv_omf_filter_meaning")
  ENDIF
  CALL echo(error_msg)
 ELSE
  CALL echo("CVNet OMF Filter Meanings successfully loaded!")
 ENDIF
END GO
