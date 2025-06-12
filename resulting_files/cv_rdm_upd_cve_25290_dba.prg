CREATE PROGRAM cv_rdm_upd_cve_25290:dba
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
 DECLARE serrmsg = c132 WITH public, noconstant(fillstring(132," "))
 DECLARE ierrcode = i4 WITH public, noconstant(0)
 DECLARE error_level = i2 WITH public, noconstant(0)
 FREE RECORD hold
 RECORD hold(
   1 qual_knt = i4
   1 qual[5]
     2 code_value = f8
     2 cki = vc
     2 field_value = vc
 )
 SET hold->qual_knt = 5
 SET hold->qual[1].cki = "CKI.CODEVALUE!2803647"
 SET hold->qual[1].field_value = "N"
 SET hold->qual[2].cki = "CKI.CODEVALUE!2803648"
 SET hold->qual[2].field_value = "A"
 SET hold->qual[3].cki = "CKI.CODEVALUE!2803649"
 SET hold->qual[3].field_value = "N"
 SET hold->qual[4].cki = "CKI.CODEVALUE!2803650"
 SET hold->qual[4].field_value = "S"
 SET hold->qual[5].cki = "CKI.CODEVALUE!2811216"
 SET hold->qual[5].field_value = "S"
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM code_value c,
   (dummyt d  WITH seq = value(hold->qual_knt))
  PLAN (d)
   JOIN (c
   WHERE (c.cki=hold->qual[d.seq].cki))
  DETAIL
   hold->qual[d.seq].code_value = c.code_value
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_level = 1
  SET readme_data->message = build("CODE_VALUE:",serrmsg)
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM code_value_extension c,
   (dummyt d  WITH seq = value(hold->qual_knt))
  SET c.field_value = hold->qual[d.seq].field_value, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c
   .updt_cnt = (c.updt_cnt+ 1),
   c.updt_applctx = 32964
  PLAN (d
   WHERE d.seq > 0)
   JOIN (c
   WHERE (c.code_value=hold->qual[d.seq].code_value))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_level = 1
  SET readme_data->message = build("CODE_VALUE_EXTENSION:",serrmsg)
  GO TO exit_script
 ENDIF
 COMMIT
#exit_script
 IF (error_level > 0)
  ROLLBACK
  SET readme_data->status = "F"
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS : Code Value Extensions Updated"
 ENDIF
 EXECUTE dm_readme_status
 SET script_version = "MOD 000 09/05/03 JF7198"
END GO
