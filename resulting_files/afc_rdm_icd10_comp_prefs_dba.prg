CREATE PROGRAM afc_rdm_icd10_comp_prefs:dba
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
 SET readme_data->message = "Readme afc_rdm_ICD10_comp_prefs failed."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE infodomain = vc WITH protect, constant("CHARGE SERVICES")
 DECLARE infoname = vc WITH protect, constant("ICD10 COMPLIANCE DATE")
 DECLARE count = i2 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(1)
 DECLARE createicd10compdaterow(logical_domain_id=f8) = null
 FREE RECORD activelogicaldomainid
 RECORD activelogicaldomainid(
   1 activeidlist[*]
     2 logical_domain_id = f8
 )
 SELECT INTO "nl:"
  FROM logical_domain ld
  WHERE ld.active_ind=1
  DETAIL
   count = (count+ 1), stat = alterlist(activelogicaldomainid->activeidlist,count),
   activelogicaldomainid->activeidlist[count].logical_domain_id = ld.logical_domain_id
  WITH nocounter
 ;end select
 CALL echorecord(activelogicaldomainid)
 IF (size(activelogicaldomainid->activeidlist,5)=0)
  SET stat = alterlist(activelogicaldomainid->activeidlist,1)
  SET activelogicaldomainid->activeidlist[count].logical_domain_id = 0.0
 ENDIF
 IF (locateval(num,start,size(activelogicaldomainid->activeidlist,5),0.0,activelogicaldomainid->
  activeidlist[num].logical_domain_id) <= 0)
  SET count = (size(activelogicaldomainid->activeidlist,5)+ 1)
  SET stat = alterlist(activelogicaldomainid->activeidlist,count)
  SET activelogicaldomainid->activeidlist[count].logical_domain_id = 0.0
 ENDIF
 FOR (num1 = 1 TO size(activelogicaldomainid->activeidlist,5))
   CALL createicd10compdaterow(activelogicaldomainid->activeidlist[num1].logical_domain_id)
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme updated ICD10 COMPLIANCE DATE."
 GO TO exit_script
 SUBROUTINE createicd10compdaterow(logical_domain_id)
   SET exist_flag = 0
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=infodomain
     AND di.info_name=infoname
     AND di.info_domain_id=logical_domain_id
    DETAIL
     exist_flag = 1
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = build(errmsg,"Failed to get existing row for ICD10 COMPLIANCE DATE.")
    GO TO exit_script
   ENDIF
   IF (exist_flag=0)
    INSERT  FROM dm_info di
     SET di.info_domain = infodomain, di.info_name = infoname, di.info_date = cnvtdatetime(
       "01-OCT-2013 00:00:00.00"),
      di.info_domain_id = logical_domain_id, di.info_long_id = 0, di.updt_cnt = 0,
      di.updt_applctx = 0, di.updt_task = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      di.updt_id = 0
     WITH nocounter
    ;end insert
    IF (error(errmsg,0) != 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = build(errmsg,"Failed to get existing row for ICD10 COMPLIANCE DATE.")
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 FREE RECORD activelogicaldomainid
END GO
