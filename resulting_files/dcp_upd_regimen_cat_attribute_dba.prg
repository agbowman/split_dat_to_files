CREATE PROGRAM dcp_upd_regimen_cat_attribute:dba
 CALL echo("***")
 CALL echo("***   Starting DCP_UPD_REGIMEN_CAT_ATTRIBUTE")
 CALL echo("***")
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
 SET readme_data->message = "Readme Failed: Starting DCP_UPD_REGIMEN_CAT_ATTRIBUTE script"
 DECLARE separator = c1 WITH public
 DECLARE failed = c1 WITH public
 DECLARE file_exist = i2 WITH public, noconstant(0)
 DECLARE vl_len = i4 WITH public, noconstant(0)
 DECLARE ipos = i4 WITH public, noconstant(0)
 DECLARE npos = i4 WITH public, noconstant(0)
 DECLARE wknt = i4 WITH public, noconstant(0)
 DECLARE ierrcode = i4 WITH public, noconstant(0)
 DECLARE serrmsg = c132 WITH public
 SET ipos = 1
 SET separator = ","
 SET failed = "Y"
 SET serrmsg = fillstring(132," ")
 FREE RECORD srec
 RECORD srec(
   1 lines[*]
     2 attribute_display = c100
     2 attribute_mean = c12
     2 input_type_flag = i2
     2 code_set = i4
     2 active_ind = i2
     2 insert_ind = i2
     2 update_ind = i2
     2 regimen_cat_attribute_id = f8
 )
 CALL echo("***")
 CALL echo("***   Find cer_install:regimen_cat_attribute.csv")
 CALL echo("***")
 SET file_name = "cer_install:regimen_cat_attribute.csv"
 FREE SET file_logical
 SET logical file_logical "cer_install:regimen_cat_attribute.csv"
 SET file_exist = findfile(file_name)
 IF (file_exist != 1)
  SET readme_data->message = "Readme Failed: Unable to find cer_install:regimen_cat_attribute.csv"
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 "file_logical"
 CALL echo("***")
 CALL echo("***   Load install file content")
 CALL echo("***")
 SELECT INTO "nl:"
  the_line = r.line
  FROM rtl2t r
  HEAD REPORT
   rknt = 0
  DETAIL
   rknt = (rknt+ 1), stat = alterlist(srec->lines,rknt), npos = 0,
   wknt = 0, ipos = 1, vs_len = textlen(trim(the_line))
   WHILE (ipos <= vs_len
    AND wknt < 5)
     wknt = (wknt+ 1), npos = findstring(separator,the_line,ipos)
     IF (npos < 1
      AND wknt > 1)
      npos = (vs_len+ 1)
     ENDIF
     IF (npos < ipos)
      ipos = (vs_len+ 1)
     ELSE
      IF (wknt=1)
       srec->lines[rknt].attribute_display = substring(ipos,(npos - ipos),the_line)
      ELSEIF (wknt=2)
       srec->lines[rknt].attribute_mean = substring(ipos,(npos - ipos),the_line)
      ELSEIF (wknt=3)
       srec->lines[rknt].input_type_flag = cnvtint(substring(ipos,(npos - ipos),the_line))
      ELSEIF (wknt=4)
       srec->lines[rknt].code_set = cnvtint(substring(ipos,(npos - ipos),the_line))
      ELSEIF (wknt=5)
       srec->lines[rknt].active_ind = cnvtint(substring(ipos,(npos - ipos),the_line))
      ENDIF
      ipos = (npos+ 1)
     ENDIF
   ENDWHILE
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = serrmsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Check existing table entries")
 CALL echo("***")
 SELECT INTO "nl:"
  rca.regimen_cat_attribute_id, attribute_mean = trim(srec->lines[d.seq].attribute_mean)
  FROM (dummyt d  WITH seq = value(size(srec->lines,5))),
   regimen_cat_attribute rca
  PLAN (d
   WHERE d.seq > 0)
   JOIN (rca
   WHERE (rca.attribute_mean=srec->lines[d.seq].attribute_mean))
  DETAIL
   IF (rca.regimen_cat_attribute_id > 0)
    srec->lines[d.seq].insert_ind = 0, srec->lines[d.seq].update_ind = 1, srec->lines[d.seq].
    regimen_cat_attribute_id = rca.regimen_cat_attribute_id
   ELSE
    srec->lines[d.seq].insert_ind = 1, srec->lines[d.seq].update_ind = 0, srec->lines[d.seq].
    regimen_cat_attribute_id = 0
   ENDIF
  WITH nocounter, outerjoin(d)
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = serrmsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Populate the table")
 CALL echo("***")
 FOR (x = 1 TO value(size(srec->lines,5)))
   IF ((srec->lines[x].insert_ind=1))
    INSERT  FROM regimen_cat_attribute rca
     SET rca.regimen_cat_attribute_id = seq(reference_seq,nextval), rca.attribute_display = srec->
      lines[x].attribute_display, rca.attribute_mean = srec->lines[x].attribute_mean,
      rca.input_type_flag = srec->lines[x].input_type_flag, rca.code_set = srec->lines[x].code_set,
      rca.active_ind = srec->lines[x].active_ind,
      rca.updt_dt_tm = cnvtdatetime(curdate,curtime3), rca.updt_id = reqinfo->updt_id, rca.updt_task
       = reqinfo->updt_task,
      rca.updt_cnt = 0, rca.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET readme_data->message = serrmsg
     GO TO exit_script
    ENDIF
   ELSEIF ((srec->lines[x].update_ind=1)
    AND (srec->lines[x].regimen_cat_attribute_id > 0))
    UPDATE  FROM regimen_cat_attribute rca
     SET rca.attribute_display = srec->lines[x].attribute_display, rca.attribute_mean = srec->lines[x
      ].attribute_mean, rca.input_type_flag = srec->lines[x].input_type_flag,
      rca.code_set = srec->lines[x].code_set, rca.active_ind = srec->lines[x].active_ind, rca
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      rca.updt_id = reqinfo->updt_id, rca.updt_task = reqinfo->updt_task, rca.updt_cnt = (rca
      .updt_cnt+ 1),
      rca.updt_applctx = reqinfo->updt_applctx
     WHERE (rca.regimen_cat_attribute_id=srec->lines[x].regimen_cat_attribute_id)
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET readme_data->message = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET failed = "N"
#exit_script
 IF (failed="Y")
  ROLLBACK
 ELSE
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS : REGIMEN_CAT_ATTRIBUTE Updated"
 ENDIF
 EXECUTE dm_readme_status
 SET script_version = "000 03/08/10 EH4893"
 CALL echorecord(readme_data)
END GO
