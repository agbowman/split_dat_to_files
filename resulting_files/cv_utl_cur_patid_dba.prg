CREATE PROGRAM cv_utl_cur_patid:dba
 PROMPT
  "Dataset_id = " = ""
 DECLARE cv_get_case_date_ec(dataset_id=f8) = f8
 DECLARE cv_get_code_by_dataset(dataset_id=f8,short_name=vc) = f8
 DECLARE cv_get_code_by(string_type=vc,code_set=i4,value=vc) = f8
 DECLARE l_case_date = vc WITH protect
 DECLARE l_case_date_dta = f8 WITH protect, noconstant(- (1.0))
 DECLARE l_case_date_ec = f8 WITH protect, noconstant(- (1.0))
 DECLARE get_code_ret = f8 WITH protect, noconstant(- (1.0))
 DECLARE dataset_prefix = vc WITH protect
 SUBROUTINE cv_get_case_date_ec(dataset_id_param)
   SET l_case_date = " "
   SET l_case_date_dta = - (1.0)
   SET l_case_date_ec = - (1.0)
   SELECT INTO "nl:"
    d.case_date_mean
    FROM cv_dataset d
    WHERE d.dataset_id=dataset_id_param
    DETAIL
     l_case_date = d.case_date_mean
    WITH nocounter
   ;end select
   IF (size(trim(l_case_date)) > 0)
    SET l_case_date_dta = cv_get_code_by("MEANING",14003,nullterm(l_case_date))
    IF (l_case_date_dta > 0.0)
     SELECT INTO "nl:"
      dta.event_cd
      FROM discrete_task_assay dta
      WHERE dta.task_assay_cd=l_case_date_dta
      DETAIL
       l_case_date_ec = dta.event_cd
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(l_case_date_ec)
 END ;Subroutine
 SUBROUTINE cv_get_code_by_dataset(dataset_id_param,short_name)
   SET dataset_prefix = " "
   SET get_code_ret = - (1.0)
   SELECT INTO "nl:"
    d.dataset_internal_name
    FROM cv_dataset d
    WHERE d.dataset_id=dataset_id_param
    DETAIL
     CASE (d.dataset_internal_name)
      OF "STS02":
       dataset_prefix = "ST02"
      ELSE
       dataset_prefix = d.dataset_internal_name
     ENDCASE
    WITH nocounter
   ;end select
   CALL echo(build("dataset_prefix:",dataset_prefix))
   IF (size(trim(dataset_prefix)) > 0)
    SELECT INTO "nl:"
     x.event_cd
     FROM cv_xref x
     WHERE x.xref_internal_name=concat(trim(dataset_prefix),"_",short_name)
     DETAIL
      get_code_ret = x.event_cd
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("get_code_ret:",get_code_ret))
   RETURN(get_code_ret)
 END ;Subroutine
 SUBROUTINE cv_get_code_by(string_type,code_set_param,value)
   SET get_code_ret = uar_get_code_by(nullterm(string_type),code_set_param,nullterm(trim(value)))
   IF (get_code_ret <= 0.0)
    CALL echo(concat("Failed uar_get_code_by(",string_type,",",trim(cnvtstring(code_set_param)),",",
      value,")"))
    SELECT
     IF (string_type="MEANING")
      WHERE cv.code_set=code_set_param
       AND cv.cdf_meaning=value
     ELSEIF (string_type="DISPLAYKEY")
      WHERE cv.code_set=code_set_param
       AND cv.display_key=value
     ELSEIF (string_type="DISPLAY")
      WHERE cv.code_set=code_set_param
       AND cv.display=value
     ELSEIF (string_type="DESCRIPTION")
      WHERE cv.code_set=code_set_param
       AND cv.description=value
     ELSE
      WHERE cv.code_value=0.0
     ENDIF
     INTO "nl:"
     FROM code_value cv
     DETAIL
      get_code_ret = cv.code_value
     WITH nocounter
    ;end select
    CALL echo(concat("code_value lookup result =",cnvtstring(get_code_ret)))
   ENDIF
   RETURN(get_code_ret)
 END ;Subroutine
 RECORD plist(
   1 qual[*]
     2 person_id = f8
     2 part_str = vc
     2 status = c1
     2 alias = vc
     2 action_ind = i2
 )
 DECLARE dataset_id = f8 WITH protect
 DECLARE pcnt = i4 WITH protect
 DECLARE person_idx = i4 WITH protect
 SET dataset_id = cnvtreal( $1)
 SELECT DISTINCT INTO "nl:"
  c.person_id
  FROM cv_case_dataset_r cdr,
   cv_case c
  PLAN (cdr
   WHERE cdr.dataset_id=dataset_id
    AND cnvtint(cdr.participant_nbr) > 0)
   JOIN (c
   WHERE c.cv_case_id=cdr.cv_case_id
    AND c.person_id > 0)
  HEAD REPORT
   pcnt = 0
  DETAIL
   pcnt = (pcnt+ 1)
   IF (mod(pcnt,10)=1)
    stat = alterlist(plist->qual,(pcnt+ 9))
   ENDIF
   plist->qual[pcnt].person_id = c.person_id, plist->qual[pcnt].part_str = cdr.participant_nbr
  FOOT REPORT
   stat = alterlist(plist->qual,pcnt)
  WITH nocounter
 ;end select
 IF (pcnt=0)
  CALL echo(build("No people with participant numbers found for dataset_id=",dataset_id))
  GO TO exit_script
 ENDIF
 RECORD request_patid(
   1 person_id = f8
   1 alias_pool_mean = vc
   1 alias = vc
   1 enable_insert_ind = i2
 )
 IF ( NOT (validate(reply_patid)))
  RECORD reply_patid(
    1 patid = vc
    1 action_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET request_patid->enable_insert_ind = 1
 FOR (person_idx = 1 TO pcnt)
   SET request_patid->person_id = plist->qual[person_idx].person_id
   SET request_patid->alias = trim(cnvtstring(plist->qual[person_idx].person_id))
   SET request_patid->alias_pool_mean = build("STSPID",plist->qual[person_idx].part_str)
   FREE RECORD reply_patid
   RECORD reply_patid(
     1 patid = vc
     1 action_ind = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   EXECUTE cv_get_harvest_patid
   SET plist->qual[person_idx].status = reply_patid->status_data.status
   SET plist->qual[person_idx].alias = reply_patid->patid
   SET plist->qual[person_idx].action_ind = reply_patid->action_ind
 ENDFOR
 CALL echorecord(plist)
 CALL echorecord(plist,"cer_temp:cv_inst_cur_patid.dat")
#exit_script
END GO
