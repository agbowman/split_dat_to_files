CREATE PROGRAM cps_cnvt_inbox_folders:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
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
 FREE SET hold
 RECORD hold(
   1 det_knt = i4
   1 det[*]
     2 det_id = f8
     2 folder_knt = i4
     2 folder[*]
       3 number = i2
       3 name = vc
       3 val = c2
 )
 SET error_level = 0
 SET readme_data->message = concat("CPS_CNVT_INBOX_FOLDERS  BEG : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  nvp1.parent_entity_id, folder_name = trim(cv.description)
  FROM name_value_prefs nvp1,
   code_value cv,
   (dummyt d  WITH seq = 1),
   name_value_prefs nvp2
  PLAN (nvp1
   WHERE nvp1.parent_entity_name="DETAIL_PREFS"
    AND nvp1.pvc_name="ITEM_FOLDER*"
    AND nvp1.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=cnvtreal(trim(nvp1.pvc_value)))
   JOIN (d)
   JOIN (nvp2
   WHERE nvp2.parent_entity_id=nvp1.parent_entity_id
    AND nvp2.parent_entity_name="DETAIL_PREFS"
    AND nvp2.pvc_name="INBOX_FOLDER*")
  ORDER BY nvp1.parent_entity_id
  HEAD REPORT
   knt = 0, stat = alterlist(hold->det,10)
  HEAD nvp1.parent_entity_id
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(hold->det,(knt+ 9))
   ENDIF
   hold->det[knt].det_id = nvp1.parent_entity_id, fknt = 0, stat = alterlist(hold->det[knt].folder,10
    )
  DETAIL
   fknt = (fknt+ 1)
   IF (mod(fknt,10)=1
    AND fknt != 1)
    stat = alterlist(hold->det[knt].folder,(fknt+ 9))
   ENDIF
   item_len = textlen(trim(nvp1.pvc_name)), hold->det[knt].folder[fknt].number = cnvtint(substring(12,
     item_len,nvp1.pvc_name)), hold->det[knt].folder[fknt].name = build("INBOX_FOLDER",hold->det[knt]
    .folder[fknt].number)
   CASE (folder_name)
    OF "E-mail":
     hold->det[knt].folder[fknt].val = "0"
    OF "Orders":
     hold->det[knt].folder[fknt].val = "1"
    OF "Phone Messages":
     hold->det[knt].folder[fknt].val = "2"
    OF "Documents to Dictate":
     hold->det[knt].folder[fknt].val = "3"
    OF "Documents to Sign":
     hold->det[knt].folder[fknt].val = "4"
    OF "Documents to Review":
     hold->det[knt].folder[fknt].val = "5"
    OF "Results to Endorse":
     hold->det[knt].folder[fknt].val = "6"
    OF "New Results":
     hold->det[knt].folder[fknt].val = "7"
    OF "Forwarded Documents to Sign":
     hold->det[knt].folder[fknt].val = "8"
    OF "Forwarded Documents to Review":
     hold->det[knt].folder[fknt].val = "9"
    OF "Forwarded Results to Endorse":
     hold->det[knt].folder[fknt].val = "10"
    OF "Forwarded Results to Review":
     hold->det[knt].folder[fknt].val = "11"
    OF "Consult Orders":
     hold->det[knt].folder[fknt].val = "12"
    OF "Others":
     hold->det[knt].folder[fknt].val = "13"
    OF "Sign":
     hold->det[knt].folder[fknt].val = "14"
    OF "Review":
     hold->det[knt].folder[fknt].val = "15"
    OF "Endorse":
     hold->det[knt].folder[fknt].val = "16"
    OF "Documents":
     hold->det[knt].folder[fknt].val = "17"
    OF "Results":
     hold->det[knt].folder[fknt].val = "18"
    OF "Forwarded Items":
     hold->det[knt].folder[fknt].val = "19"
    OF "Messages":
     hold->det[knt].folder[fknt].val = "20"
    OF "Untitled":
     hold->det[knt].folder[fknt].val = "21"
    OF "My Folder":
     hold->det[knt].folder[fknt].val = "22"
    ELSE
     hold->det[knt].folder[fknt].val = " ",hold->det[knt].folder[fknt].name = "None"
   ENDCASE
  FOOT  nvp1.parent_entity_id
   hold->det[knt].folder_knt = fknt, stat = alterlist(hold->det[knt].folder,fknt)
  FOOT REPORT
   hold->det_knt = knt, stat = alterlist(hold->det,knt)
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: Finding old preferences"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET error_level = 1
  GO TO exit_script
 ENDIF
 IF ((hold->det_knt < 1))
  SET readme_data->message = "INFO :: No preferences found that needed to be converted"
  EXECUTE dm_readme_status
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO hold->det_knt)
   IF ((hold->det[i].folder_knt > 0))
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM name_value_prefs nvp,
      (dummyt d  WITH seq = value(hold->det[i].folder_knt))
     SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "DETAIL_PREFS",
      nvp.parent_entity_id = hold->det[i].det_id,
      nvp.pvc_name = hold->det[i].folder[d.seq].name, nvp.pvc_value = hold->det[i].folder[d.seq].val,
      nvp.sequence = 0,
      nvp.active_ind = 1, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = 0.0,
      nvp.updt_task = 0, nvp.updt_applctx = 0, nvp.updt_cnt = 0
     PLAN (d
      WHERE d.seq > 0
       AND (hold->det[i].folder[d.seq].name != "None"))
      JOIN (nvp
      WHERE 0=0)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET readme_data->message = "ERROR :: Inserting converted preferences"
     EXECUTE dm_readme_status
     SET readme_data->message = trim(serrmsg)
     EXECUTE dm_readme_status
     SET error_level = 1
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_level=1)
  ROLLBACK
  SET status_msg = "FAILURE"
  SET readme_data->status = "F"
 ELSE
  COMMIT
  SET status_msg = "SUCCESS"
  SET readme_data->status = "S"
 ENDIF
 SET readme_data->message = concat("CPS_CNVT_INBOX_FOLDERS  END : ",trim(status_msg),"  ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 COMMIT
 SET script_version = "MOD 002 09/18/01 SF3151"
END GO
