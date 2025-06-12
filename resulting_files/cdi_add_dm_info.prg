CREATE PROGRAM cdi_add_dm_info
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
 DECLARE old_pref_cnt = i4 WITH public, noconstant(0)
 DECLARE pref_cnt = i4 WITH public, constant(6)
 DECLARE g_cdi_domain = vc WITH public, constant("IMAGING DOCUMENT")
 DECLARE g_translog = vc WITH public, constant("TRANSACTION LOGGING")
 DECLARE g_compsign = vc WITH public, constant("COMP SIGN TEXT")
 DECLARE g_reqsign = vc WITH public, constant("REQ SIGN TEXT")
 DECLARE g_cleananno = vc WITH public, constant("CLEAN ANNOS")
 DECLARE g_docalias = vc WITH public, constant("DOC TYPE ALIAS")
 DECLARE g_pendsign = vc WITH public, constant("PEND SIGN TEXT")
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 info_name = vc
     2 info_number = f8
     2 info_char = vc
     2 info_date = dq8
     2 exist_ind = i2
 )
 SET stat = alterlist(temp->qual,pref_cnt)
 SET temp->qual[1].info_name = g_translog
 SET temp->qual[1].info_number = 0
 SET temp->qual[1].exist_ind = 0
 SET temp->qual[2].info_name = g_compsign
 SET temp->qual[2].info_char = "Signed By:"
 SET temp->qual[2].exist_ind = 0
 SET temp->qual[3].info_name = g_reqsign
 SET temp->qual[3].info_char = "Requested Sign For:"
 SET temp->qual[3].exist_ind = 0
 SET temp->qual[4].info_name = g_cleananno
 SET temp->qual[4].info_number = 1
 SET temp->qual[4].exist_ind = 0
 SET temp->qual[5].info_name = g_docalias
 SET temp->qual[5].info_number = 0
 SET temp->qual[5].exist_ind = 0
 SET temp->qual[6].info_name = g_pendsign
 SET temp->qual[6].info_char = "Pending Sign For:"
 SET temp->qual[6].exist_ind = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(pref_cnt)),
   dm_info di
  PLAN (d)
   JOIN (di
   WHERE di.info_domain=g_cdi_domain
    AND (di.info_name=temp->qual[d.seq].info_name))
  DETAIL
   temp->qual[d.seq].exist_ind = 1, old_pref_cnt = (old_pref_cnt+ 1)
  WITH nocounter
 ;end select
 SET new_pref_cnt = (pref_cnt - old_pref_cnt)
 IF (new_pref_cnt=0)
  SET readme_status = "D"
  GO TO exit_program
 ENDIF
 INSERT  FROM (dummyt d  WITH seq = value(pref_cnt)),
   dm_info di
  SET di.info_domain = g_cdi_domain, di.info_name = temp->qual[d.seq].info_name, di.info_number =
   temp->qual[d.seq].info_number,
   di.info_char = temp->qual[d.seq].info_char, di.info_date = cnvtdatetime(temp->qual[d.seq].
    info_date), di.info_long_id = 0,
   di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0,
   di.updt_applctx = 0, di.updt_task = 0
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
