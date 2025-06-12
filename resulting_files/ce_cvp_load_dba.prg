CREATE PROGRAM ce_cvp_load:dba
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
 SET readme_data->message = "Readme Failed: Starting script ce_cvp_load.prg..."
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE i = i4 WITH protect, noconstant(0)
 FREE RECORD copyrequestin
 RECORD copyrequestin(
   1 list_0[*]
     2 entityname = vc
     2 fieldname = vc
     2 exists_ind = i4
 )
 SET stat = alterlist(copyrequestin->list_0,size(requestin->list_0,5))
 FOR (i = 1 TO size(requestin->list_0,5))
   SET copyrequestin->list_0[i].entityname = requestin->list_0[i].entityname
   SET copyrequestin->list_0[i].fieldname = requestin->list_0[i].fieldname
   SET copyrequestin->list_0[i].exists_ind = 0
 ENDFOR
 SELECT INTO "nl:"
  cvp.entity_name, cvp.field_name
  FROM ce_version_parms cvp,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d)
   JOIN (cvp
   WHERE (cvp.entity_name=copyrequestin->list_0[d.seq].entityname)
    AND (cvp.field_name=copyrequestin->list_0[d.seq].fieldname))
  DETAIL
   copyrequestin->list_0[d.seq].exists_ind = 1
  WITH nocounter
 ;end select
 INSERT  FROM ce_version_parms cvp,
   (dummyt d  WITH seq = value(size(copyrequestin->list_0,5)))
  SET cvp.entity_name = copyrequestin->list_0[d.seq].entityname, cvp.field_name = copyrequestin->
   list_0[d.seq].fieldname, cvp.updt_cnt = 0,
   cvp.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (copyrequestin->list_0[d.seq].exists_ind=0))
   JOIN (cvp)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: ce_cvp_load: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Batch Data Loaded Successfully"
#exit_script
END GO
