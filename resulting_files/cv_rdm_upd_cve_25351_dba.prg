CREATE PROGRAM cv_rdm_upd_cve_25351:dba
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
   1 qual[2]
     2 cki = vc
     2 display = vc
     2 display_key = vc
     2 cdf_meaning = vc
     2 definition = vc
     2 description = vc
     2 old_display = vc
     2 old_display_key = vc
 )
 SET hold->qual_knt = 2
 SET hold->qual[1].cki = "CKI.CODEVALUE!2655601"
 SET hold->qual[1].display = "CK-MB ULN (A2-120)"
 SET hold->qual[1].display_key = "CKMBULNA2120"
 SET hold->qual[1].cdf_meaning = "AC02OCKULN"
 SET hold->qual[1].definition = "CK-MB ULN (A2-120)"
 SET hold->qual[1].description = "CK-MB ULN (A2-120)"
 SET hold->qual[1].old_display = "CK-MB ULM (A2-120)"
 SET hold->qual[1].old_display_key = "CKMBULMA2120"
 SET hold->qual[2].cki = "CKI.CODEVALUE!2655667"
 SET hold->qual[2].display = "Stenosis % - RCA/PDA Right Domi (A2-72)"
 SET hold->qual[2].display_key = "STENOSISRCAPDARIGHTDOMIA272"
 SET hold->qual[2].cdf_meaning = "AC02VRCA"
 SET hold->qual[2].description = "Stenosis % - RCA/PDA Right Domi (A2-72)"
 SET hold->qual[2].definition = "Stenosis % - RCA/PDA Right Domi (A2-72)"
 SET hold->qual[2].old_display = "Stenosis % - RCA / PDA Left Domi (A2-72)"
 SET hold->qual[2].old_display_key = "STENOSISRCAPDALEFTDOMIA272"
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM code_value c,
   (dummyt d  WITH seq = value(hold->qual_knt))
  SET c.display = hold->qual[d.seq].display, c.display_key = hold->qual[d.seq].display_key, c
   .definition = hold->qual[d.seq].definition,
   c.cdf_meaning = hold->qual[d.seq].cdf_meaning, c.description = hold->qual[d.seq].description, c
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = 32964
  PLAN (d
   WHERE d.seq > 0)
   JOIN (c
   WHERE (c.cki=hold->qual[d.seq].cki)
    AND (c.display=hold->qual[d.seq].old_display)
    AND (c.display_key=hold->qual[d.seq].old_display_key))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_level = 1
  SET readme_data->message = build("CODE_VALUE:",serrmsg)
  GO TO exit_script
 ENDIF
 COMMIT
#exit_script
 IF (error_level > 0)
  ROLLBACK
  SET readme_data->status = "F"
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS : Code Value Table Updated"
 ENDIF
 EXECUTE dm_readme_status
 SET script_version = "MOD 001 10/28/03 BM9013"
END GO
