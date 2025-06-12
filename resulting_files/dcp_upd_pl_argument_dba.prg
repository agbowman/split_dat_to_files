CREATE PROGRAM dcp_upd_pl_argument:dba
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
 RECORD temp1(
   1 encntr_filter[*]
     2 encntr_class_cd = f8
     2 encntr_filter_id = f8
     2 encntr_type_cd = f8
     2 patient_list_id = f8
 )
 RECORD temp2(
   1 list[*]
     2 patient_list_id = f8
     2 list_type = vc
     2 argument_id = f8
 )
 SET modify = predeclare
 DECLARE rdm_errcode = i4 WITH noconstant(0)
 DECLARE rdm_errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE readme_status = c1 WITH noconstant("S")
 SET rdm_errcode = error(rdm_errmsg,1)
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE count2 = i4 WITH noconstant(0)
 DECLARE count3 = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE careteamcd = f8 WITH noconstant(0.0)
 DECLARE providergrpcd = f8 WITH noconstant(0.0)
 DECLARE visitreltncd = f8 WITH noconstant(0.0)
 DECLARE ltreltncd = f8 WITH noconstant(0.0)
 DECLARE reltncd = f8 WITH noconstant(0.0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=27360
  DETAIL
   IF (cv.cdf_meaning="VRELTN")
    visitreltncd = cv.code_value
   ELSEIF (cv.cdf_meaning="LRELTN")
    ltreltncd = cv.code_value
   ELSEIF (cv.cdf_meaning="RELTN")
    reltncd = cv.code_value
   ELSEIF (cv.cdf_meaning="CARETEAM")
    careteamcd = cv.code_value
   ELSEIF (cv.cdf_meaning="PROVIDERGRP")
    providergrpcd = cv.code_value
   ENDIF
  WITH constant
 ;end select
 SELECT INTO "nl:"
  FROM dcp_patient_list pl
  PLAN (pl
   WHERE pl.patient_list_type_cd IN (visitreltncd, ltreltncd)
    AND  NOT ( EXISTS (
   (SELECT
    pa.argument_name
    FROM dcp_pl_argument pa
    WHERE pa.patient_list_id=pl.patient_list_id
     AND ((pa.argument_name="visit_reltn_cd") OR (pa.argument_name="lifetime_reltn_cd")) ))))
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(temp1->encntr_filter,(count1+ 9))
   ENDIF
   temp2->list[count3].patient_list_id = pl.patient_list_id, temp2->list[count3].list_type = pl
   .patient_list_type_cd
  FOOT REPORT
   stat = alterlist(temp2->list,count1)
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
  INSERT  FROM dcp_pl_argument pa
   SET pa.argument_id = seq("dcp_patient_list_sew",nextval), pa.patient_list_id = temp2->list[x].
    patient_list_id, pa.parent_entity_name = "CODE_VALUE",
    pa.argument_value = 0, pa.parent_entity_id = 0, pa.argument_name =
    IF ((temp2->list[x].patient_list_type_cd=visitreltncd)) "visit_reltn_cd"
    ELSE "life_reltn_cd"
    ENDIF
    ,
    pa.updt_applctx = reqinfo->updt_applctx, pa.updt_cnt = 0, pa.updt_dt_tm = cnvtdate(curdate,
     curtime3),
    pa.updt_id = reqinfo->updt_id, pa.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (mod(x,1000)=1)
   SET readme_status = "S"
   SET reply->status_data.status = "S"
   SET readme_data->message = "Commit part of the loop."
   COMMIT
   EXECUTE dm_readme_status
  ENDIF
 ENDFOR
 WHILE (curqual > 0)
  UPDATE  FROM dcp_patient_list pl
   SET pl.patient_list_type_cd = reltncd
   WHERE ((pl.patient_list_type_cd=visitreltncd) OR (pl.patient_list_type_cd=ltreltncd))
   WITH noconstant, maxqual(1000)
  ;end update
  IF (curqual > 0)
   SET readme_status = "S"
   SET reply->status_data.status = "S"
   SET readme_data->message = "Commit part of the loop."
   COMMIT
   EXECUTE dm_readme_status
  ENDIF
 ENDWHILE
 SELECT INTO "nl:"
  FROM dcp_pl_encntr_filter ef
  WHERE ef.encntr_filter_id > 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(temp1->encntr_filter,(count1+ 9))
   ENDIF
   temp1->encntr_filter[count1].encntr_class_cd = ef.encntr_class_cd, temp1->encntr_filter[count1].
   encntr_filter_id = ef.encntr_filter_id, temp1->encntr_filter[count1].encntr_type_cd = ef
   .encntr_type_cd,
   temp1->encntr_filter[count1].patient_list_id = ef.patient_list_id
  FOOT REPORT
   stat = alterlist(temp1->encntr_filter,count1)
  WITH nocounter
 ;end select
 IF (count1 > 0)
  FOR (count2 = 1 TO count1)
   INSERT  FROM dcp_pl_argument pa
    SET pa.argument_id = temp1->encntr_filter[count2].encntr_filter_id, pa.argument_name =
     IF ((temp1->encntr_filter[count2].encntr_type_cd > 0)) "encntr_type_cd"
     ELSE "encntr_class_cd"
     ENDIF
     , pa.parent_entity_id =
     IF ((temp1->encntr_filter[count2].encntr_type_cd > 0)) temp1->encntr_filter[count2].
      encntr_type_cd
     ELSE temp1->encntr_filter[count2].encntr_class_cd
     ENDIF
     ,
     pa.patient_list_id = temp1->encntr_filter[count2].patient_list_id, pa.parent_entity_name =
     "CODE_VALUE", pa.argument_value = 0,
     pa.updt_applctx = reqinfo->updt_applctx, pa.updt_cnt = 0, pa.updt_dt_tm = cnvtdate(curdate,
      curtime3),
     pa.updt_id = reqinfo->updt_id, pa.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (mod(count2,1000)=1)
    SET readme_status = "S"
    SET reply->status_data.status = "S"
    SET readme_data->message = "Commit part of the loop."
    COMMIT
    EXECUTE dm_readme_status
   ENDIF
  ENDFOR
 ENDIF
 WHILE (curqual > 0)
  UPDATE  FROM dcp_pl_arugment pa
   SET pa.argument_name = "careteam_id"
   WHERE pa.patient_list_id IN (
   (SELECT
    pl.patient_list_id
    FROM dcp_patient_list pl
    WHERE pl.patient_list_type_cd=careteamcd
     AND pa.argument_name="prsnl_group_id"))
   WITH nocounter, maxqual(1000)
  ;end update
  IF (curqual > 0)
   SET readme_status = "S"
   SET reply->status_data.status = "S"
   SET readme_data->message = "Commit part of the loop."
   COMMIT
   EXECUTE dm_readme_status
  ENDIF
 ENDWHILE
 WHILE (curqual > 0)
  UPDATE  FROM dcp_pl_arugment pa
   SET pa.argument_name = "provider_group_id"
   WHERE pa.patient_list_id IN (
   (SELECT
    pl.patient_list_id
    FROM dcp_patient_list pl
    WHERE pl.patient_list_type_cd=providergrpcd
     AND pa.argument_name="prsnl_group_id"))
   WITH noconstant, maxqual(1000)
  ;end update
  IF (curqual > 0)
   SET readme_status = "S"
   SET reply->status_data.status = "S"
   SET readme_data->message = "Commit part of the loop."
   COMMIT
   EXECUTE dm_readme_status
  ENDIF
 ENDWHILE
 FREE RECORD temp1
 FREE RECORD temp2
 IF ((reply->status_data.status="F"))
  SET readme_status = "F"
  SET rdm_errmsg = "dcp_bld_query_type script failed"
 ELSEIF ((reply->status_data.status="Z"))
  SET readme_status = "Q"
 ELSE
  SET readme_status = "S"
 ENDIF
 IF (validate(readme_data->readme_id,0) > 0)
  IF (readme_status="F")
   SET readme_data->status = "F"
   SET readme_data->message = rdm_errmsg
   ROLLBACK
  ELSEIF (readme_status="S")
   SET readme_data->status = "S"
   SET readme_data->message = "Successfully created provider group query type."
   COMMIT
  ELSEIF (readme_status="Q")
   SET readme_data->status = "S"
   SET readme_data->message = "The query type code already existed."
   ROLLBACK
  ENDIF
  EXECUTE dm_readme_status
 ELSE
  IF (((readme_status="F") OR (readme_status="Q")) )
   ROLLBACK
  ELSEIF (readme_status="S")
   COMMIT
  ENDIF
 ENDIF
END GO
