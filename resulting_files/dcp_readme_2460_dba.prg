CREATE PROGRAM dcp_readme_2460:dba
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
 RECORD listqual(
   1 listqual_cnt = i4
   1 owners[*]
     2 patient_list_id = f8
     2 owner_prsnl_id = f8
 )
 SET modify = predeclare
 DECLARE lreltn_cd = f8 WITH noconstant(0.0)
 DECLARE vreltn_cd = f8 WITH noconstant(0.0)
 DECLARE cnt = i4 WITH noconstant(0)
 SELECT INTO "nl"
  FROM code_value cv
  WHERE cv.code_set=27360
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   IF (cv.cdf_meaning="LRELTN")
    lreltn_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="VRELTN")
    vreltn_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl"
  FROM dcp_patient_list pl,
   (dummyt d  WITH seq = 1),
   dcp_pl_argument dpa
  PLAN (pl
   WHERE pl.patient_list_type_cd IN (lreltn_cd, vreltn_cd))
   JOIN (d)
   JOIN (dpa
   WHERE dpa.patient_list_id=pl.patient_list_id
    AND dpa.argument_name="prsnl_id")
  HEAD REPORT
   cnt = cnt
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(listqual->owners,5))
    stat = alterlist(listqual->owners,(cnt+ 10))
   ENDIF
   listqual->owners[cnt].patient_list_id = pl.patient_list_id, listqual->owners[cnt].owner_prsnl_id
    = pl.owner_prsnl_id
  FOOT REPORT
   listqual->listqual_cnt = cnt, stat = alterlist(listqual->owners,listqual->listqual_cnt)
  WITH outerjoin = d, dontexist
 ;end select
 IF ((listqual->listqual_cnt=0))
  GO TO exit_script
 ENDIF
 INSERT  FROM dcp_pl_argument pla,
   (dummyt d1  WITH seq = value(listqual->listqual_cnt))
  SET pla.argument_id = seq(dcp_patient_list_seq,nextval), pla.argument_name = "prsnl_id", pla
   .parent_entity_id = listqual->owners[d1.seq].owner_prsnl_id,
   pla.parent_entity_name = "PERSON", pla.patient_list_id = listqual->owners[d1.seq].patient_list_id,
   pla.sequence = 1,
   pla.updt_applctx = 0, pla.updt_cnt = 0, pla.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pla.updt_id = 0, pla.updt_task = 0
  PLAN (d1)
   JOIN (pla)
  WITH counter
 ;end insert
 IF (curqual=0)
  SET readme_data->message = "Table insert failed."
  SET readme_data->status = "F"
  ROLLBACK
  GO TO end_script
 ENDIF
#exit_script
 IF ((listqual->listqual_cnt=0))
  SET readme_data->message = "No lists qualified for an update."
  SET readme_data->status = "S"
 ELSEIF ((listqual->listqual_cnt > 0))
  SET readme_data->message = build(listqual->listqual_cnt," rows were inserted.")
  SET readme_data->status = "S"
  COMMIT
 ENDIF
#end_script
 SET modify = nopredeclare
 EXECUTE dm_readme_status
END GO
