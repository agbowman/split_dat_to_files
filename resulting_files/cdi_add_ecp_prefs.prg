CREATE PROGRAM cdi_add_ecp_prefs
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
 DECLARE readme_status = c1 WITH public, noconstant("F")
 DECLARE new_pref_cnt = i4 WITH public, noconstant(0)
 DECLARE pref_cnt = i4 WITH public, constant(4)
 DECLARE g_cdi_domain = vc WITH public, constant("IMAGING DOCUMENT")
 DECLARE g_barcode = vc WITH public, constant("ECP BARCODE TYPE")
 DECLARE g_font = vc WITH public, constant("ECP FONT TYPE")
 DECLARE g_fontsize = vc WITH public, constant("ECP FONT SIZE")
 DECLARE g_orientation = vc WITH public, constant("ECP PAGE ORIENT")
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 info_name = vc
     2 info_number = f8
     2 info_char = vc
     2 exist_ind = i2
 )
 SET new_pref_cnt = pref_cnt
 SET stat = alterlist(temp->qual,pref_cnt)
 SET temp->qual[1].info_name = g_barcode
 SET temp->qual[1].info_number = 0
 SET temp->qual[1].exist_ind = 0
 SET temp->qual[2].info_name = g_font
 SET temp->qual[2].info_char = "Times"
 SET temp->qual[2].exist_ind = 0
 SET temp->qual[3].info_name = g_fontsize
 SET temp->qual[3].info_number = 11
 SET temp->qual[3].exist_ind = 0
 SET temp->qual[4].info_name = g_orientation
 SET temp->qual[4].info_number = 0
 SET temp->qual[4].exist_ind = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(pref_cnt)),
   dm_info di
  PLAN (d)
   JOIN (di
   WHERE di.info_domain=g_cdi_domain
    AND (di.info_name=temp->qual[d.seq].info_name))
  DETAIL
   temp->qual[d.seq].exist_ind = 1, new_pref_cnt = (new_pref_cnt - 1)
  WITH nocounter
 ;end select
 IF (new_pref_cnt=0)
  SET readme_status = "D"
  GO TO exit_program
 ENDIF
 INSERT  FROM (dummyt d  WITH seq = value(pref_cnt)),
   dm_info di
  SET di.info_domain = g_cdi_domain, di.info_name = temp->qual[d.seq].info_name, di.info_number =
   temp->qual[d.seq].info_number,
   di.info_char = temp->qual[d.seq].info_char, di.info_long_id = 0, di.updt_cnt = 0,
   di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0, di.updt_applctx = 0,
   di.updt_task = 0
  PLAN (d
   WHERE (temp->qual[d.seq].exist_ind=0))
   JOIN (di)
  WITH nocounter
 ;end insert
 IF (curqual=new_pref_cnt)
  SET readme_status = "S"
 ENDIF
#exit_program
 IF (readme_status="S")
  SET readme_data->status = "S"
  SET readme_data->message = "Readme succeeded.  Success inserting to the dm_info table."
  COMMIT
 ELSEIF (readme_status="D")
  SET readme_data->status = "S"
  SET readme_data->message = "Readme succeeded.  Rows already existed on the dm_info table."
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Readme failure.  Failure inserting into the dm_info table."
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 FREE RECORD temp
END GO
