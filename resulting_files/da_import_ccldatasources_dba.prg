CREATE PROGRAM da_import_ccldatasources:dba
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
 SET readme_data->message = "Error starting da_import_ccldatasources"
 DECLARE sys_guid() = c32
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE errormessage = vc WITH protect, noconstant("")
 DECLARE querytypecode = f8 WITH protect, noconstant(0.0)
 DECLARE discernownergroupcode = f8 WITH protect, noconstant(0.0)
 DECLARE domaintypecode = f8 WITH protect, noconstant(0.0)
 DECLARE actualdomaintype = f8 WITH protect, noconstant(0.0)
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE qcount = i4 WITH protect, noconstant(0)
 DECLARE domainid = f8 WITH protect, noconstant(0.0)
 DECLARE domainactvind = i2 WITH protect, noconstant(0)
 DECLARE domaindeprecatedind = i2 WITH protect, noconstant(0)
 DECLARE ccldomainuuid = vc WITH protect, noconstant("1f6af620-2571-40e8-a951-a48e034f778c")
 DECLARE iterator = i2 WITH protect, noconstant(0)
 DECLARE locatedindex = i2 WITH protect, noconstant(0)
 DECLARE versiontext = c8 WITH protect, constant("001.000")
 DECLARE uuid = c36 WITH protect, noconstant("")
 DECLARE objname = vc WITH protect, noconstant("")
 FREE RECORD datasourcestoimport
 RECORD datasourcestoimport(
   1 ccldatasource[*]
     2 active_ind = i2
     2 active_status_prsnl_id = dq8
     2 object_description = vc
     2 ccl_group = i4
     2 fullobjectname = vc
     2 object_name = vc
     2 updt_applctx = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
 )
 FREE RECORD duplicatequerynames
 RECORD duplicatequerynames(
   1 daquery[*]
     2 query_id = f8
     2 query_uuid = vc
     2 query_type_cd = f8
     2 query_name = vc
     2 actv_ind = i2
     2 domainid = f8
     2 deprecatedindex = i2
 )
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!4110073019"
   AND cv.active_ind=1
  DETAIL
   querytypecode = cv.code_value
  WITH nocounter
 ;end select
 IF (((error(errormessage,0) != 0) OR (curqual=0)) )
  SET readme_data->status = "F"
  SET readme_data->message = concat("Lookup failed for query type code: ",errormessage)
  GO TO exit_now
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!4110097245"
   AND cv.active_ind=1
  DETAIL
   domaintypecode = cv.code_value
  WITH nocounter
 ;end select
 IF (((error(errormessage,0) != 0) OR (curqual=0)) )
  SET readme_data->status = "F"
  SET readme_data->message = concat("Lookup failed for domain type code: ",errormessage)
  GO TO exit_now
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!4100380044"
   AND cv.active_ind=1
  DETAIL
   discernownergroupcode = cv.code_value
  WITH nocounter
 ;end select
 IF (((error(errormessage,0) != 0) OR (curqual=0)) )
  SET readme_data->status = "F"
  SET readme_data->message = concat("Lookup failed for Discern owner group code: ",errormessage)
  GO TO exit_now
 ENDIF
 SELECT INTO "nl:"
  FROM da_domain d
  WHERE d.domain_uuid="1f6af620-2571-40e8-a951-a48e034f778c"
  DETAIL
   domainid = d.da_domain_id, domainactvind = d.active_ind, domaindeprecatedind = d.deprecated_ind,
   actualdomaintype = d.domain_type_cd
  WITH nocounter
 ;end select
 IF (error(errormessage,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Lookup of CCL data source business domain failed: ",errormessage
   )
  GO TO exit_now
 ELSEIF (domainid != 0
  AND domainactvind=1
  AND actualdomaintype != domaintypecode)
  SET readme_data->status = "S"
  SET readme_data->message = concat("CCL data source domain UUID exists with invalid domain type=",
   build(actualdomaintype),", domainId=",build(domainid))
  GO TO exit_now
 ENDIF
 IF (((domainactvind=0) OR (domaindeprecatedind != 0))
  AND domainid != 0)
  CALL echo(concat("Update row with da_domain_id=",build(domainid)))
  UPDATE  FROM da_domain d
   SET d.active_ind = 1, d.domain_type_cd = domaintypecode, d.deprecated_ind = 0,
    d.updt_id = reqinfo->updt_id, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = (d.updt_cnt+ 1
    ),
    d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_task = reqinfo->updt_task
   WHERE d.da_domain_id=domainid
   WITH nocounter
  ;end update
  IF (error(errormessage,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Could not update row for da_domain_id=",build(domainid),": ",
    errormessage)
   GO TO exit_now
  ENDIF
 ENDIF
 IF (domainid=0)
  SELECT INTO "nl:"
   newdomainid = seq(da_seq,nextval)
   FROM dual
   DETAIL
    domainid = newdomainid
   WITH nocounter
  ;end select
  IF (error(errormessage,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = "Could not create new domain ID"
   GO TO exit_now
  ENDIF
  INSERT  FROM da_domain d
   SET d.da_domain_id = domainid, d.active_ind = 1, d.core_ind = 1,
    d.deprecated_ind = 0, d.domain_desc = "All CCL data sources available to Discern Analytics 2.0",
    d.domain_name = "CCL Data Sources",
    d.domain_name_key = "CCLDATASOURCES", d.domain_options_txt_id = 0.00, d.domain_type_cd =
    domaintypecode,
    d.domain_uuid = ccldomainuuid, d.extended_ind = 0, d.owner_group_cd = discernownergroupcode,
    d.timer_name = " ", d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0,
    d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->
    updt_task,
    d.version_txt = "1.0"
   WITH nocounter
  ;end insert
  IF (((error(errormessage,0) != 0) OR (curqual=0)) )
   SET readme_data->status = "F"
   SET readme_data->message = concat("Could not insert row for CCL data source domain: ",errormessage
    )
   GO TO exit_now
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  cclobj.object_id, cclobj.active_ind, cclobj.active_status_cd,
  cclobj.ccl_group, cclobj.driver_object_id, cclobj.file_name,
  cclobj.object_description, cclobj.object_name, cclobj.object_type,
  cclobj.report_name
  FROM ccl_report_object cclobj
  WHERE cclobj.object_type IN ("ODADSAPI", "ODATEXT")
   AND cclobj.active_ind=1
  HEAD REPORT
   stat = alterlist(datasourcestoimport->ccldatasource,10), count = 0
  DETAIL
   count += 1
   IF (mod(count,10)=0)
    stat = alterlist(datasourcestoimport->ccldatasource,(count+ 10))
   ENDIF
   datasourcestoimport->ccldatasource[count].active_ind = cclobj.active_ind, datasourcestoimport->
   ccldatasource[count].active_status_prsnl_id = cclobj.active_status_prsnl_id, datasourcestoimport->
   ccldatasource[count].object_description = cclobj.object_description,
   datasourcestoimport->ccldatasource[count].object_name = cclobj.object_name, datasourcestoimport->
   ccldatasource[count].ccl_group = cclobj.ccl_group, datasourcestoimport->ccldatasource[count].
   fullobjectname = getfullobjectname(datasourcestoimport->ccldatasource[count].object_name,
    datasourcestoimport->ccldatasource[count].ccl_group),
   datasourcestoimport->ccldatasource[count].updt_applctx = cclobj.updt_applctx, datasourcestoimport
   ->ccldatasource[count].updt_cnt = cclobj.updt_cnt, datasourcestoimport->ccldatasource[count].
   updt_dt_tm = cclobj.updt_dt_tm,
   datasourcestoimport->ccldatasource[count].updt_id = cclobj.updt_id, datasourcestoimport->
   ccldatasource[count].updt_task = cclobj.updt_task
  FOOT REPORT
   stat = alterlist(datasourcestoimport->ccldatasource,count)
  WITH nocounter
 ;end select
 IF (error(errormessage,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Could not query CCL_REPORT_OBJECT: ",errormessage)
  GO TO exit_now
 ENDIF
 CALL echo(concat("Found ",build(size(datasourcestoimport->ccldatasource,5)),
   " CCL data sources to convert."))
 IF (size(datasourcestoimport->ccldatasource,5) > 0)
  SELECT INTO "nl:"
   FROM da_query q,
    (dummyt d  WITH seq = size(datasourcestoimport->ccldatasource,5))
   PLAN (d)
    JOIN (q
    WHERE (q.query_name=datasourcestoimport->ccldatasource[d.seq].fullobjectname)
     AND q.owner_prsnl_id=0
     AND q.public_ind=1)
   DETAIL
    IF (qcount=size(duplicatequerynames->daquery,5))
     stat = alterlist(duplicatequerynames->daquery,(qcount+ 10))
    ENDIF
    qcount += 1, duplicatequerynames->daquery[qcount].query_id = q.da_query_id, duplicatequerynames->
    daquery[qcount].query_name = q.query_name,
    duplicatequerynames->daquery[qcount].query_type_cd = q.query_type_cd, duplicatequerynames->
    daquery[qcount].actv_ind = q.active_ind, duplicatequerynames->daquery[qcount].domainid = q
    .da_domain_id,
    duplicatequerynames->daquery[qcount].deprecatedindex = q.deprecated_ind
   FOOT REPORT
    stat = alterlist(duplicatequerynames->daquery,qcount)
   WITH nocounter
  ;end select
  IF (error(errormessage,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("DA_QUERY table check failed: ",errormessage)
   GO TO exit_now
  ENDIF
  CALL echo(concat("Found ",build(size(duplicatequerynames->daquery,5)),
    " data sources already on DA_QUERY."))
  FOR (count = 1 TO size(datasourcestoimport->ccldatasource,5))
    SET objname = datasourcestoimport->ccldatasource[count].fullobjectname
    SET locatedindex = locateval(iterator,1,size(duplicatequerynames->daquery,5),objname,
     duplicatequerynames->daquery[iterator].query_name)
    IF (locatedindex=0)
     CALL echo(concat("Insert new DA_QUERY row for ",datasourcestoimport->ccldatasource[count].
       fullobjectname))
     SELECT INTO "nl:"
      newguid = transformguid(sys_guid())
      FROM dual
      DETAIL
       uuid = newguid
      WITH nocounter
     ;end select
     IF (error(errormessage,0) != 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat("Could not create a new uuid: ",errormessage)
      GO TO exit_now
     ENDIF
     INSERT  FROM da_query q
      SET q.da_query_id = seq(da_seq,nextval), q.active_ind = 1, q.active_status_prsnl_id = reqinfo->
       updt_id,
       q.core_ind = 0, q.create_dt_tm = cnvtdatetime(sysdate), q.create_prsnl_id = reqinfo->updt_id,
       q.da_domain_id = domainid, q.deprecated_ind = 0, q.extended_ind = 0,
       q.filter_prompt_ind = 0, q.last_updt_dt_tm = cnvtdatetime(sysdate), q.last_updt_user_id =
       reqinfo->updt_id,
       q.owner_group_cd = 0.00, q.owner_prsnl_id = 0, q.public_ind = 1,
       q.query_desc = datasourcestoimport->ccldatasource[count].object_description, q.query_name =
       datasourcestoimport->ccldatasource[count].fullobjectname, q.query_name_key = cnvtupper(
        cnvtalphanum(trim(datasourcestoimport->ccldatasource[count].fullobjectname,4))),
       q.query_text_id = 0, q.query_type_cd = querytypecode, q.query_uuid = uuid,
       q.version_txt = versiontext, q.updt_applctx = reqinfo->updt_applctx, q.updt_cnt = 0,
       q.updt_dt_tm = cnvtdatetime(sysdate), q.updt_id = reqinfo->updt_id, q.updt_task = reqinfo->
       updt_task
      WITH nocounter
     ;end insert
     IF (((error(errormessage,0) != 0) OR (curqual=0)) )
      SET readme_data->status = "F"
      SET readme_data->message = concat("Could not insert DA_QUERY row for ",datasourcestoimport->
       ccldatasource[count].fullobjectname,": ",errormessage)
      GO TO exit_now
     ENDIF
    ELSEIF ((duplicatequerynames->daquery[locatedindex].query_type_cd=querytypecode)
     AND (duplicatequerynames->daquery[locatedindex].actv_ind=0))
     CALL echo(concat("Update DA_QUERY row ",build(duplicatequerynames->daquery[locatedindex].
        query_id)," for ",datasourcestoimport->ccldatasource[count].fullobjectname))
     UPDATE  FROM da_query q
      SET q.active_ind = 1, q.active_status_prsnl_id = reqinfo->updt_id, q.query_desc =
       datasourcestoimport->ccldatasource[count].object_description,
       q.deprecated_ind = 0, q.da_domain_id = domainid, q.last_updt_dt_tm = cnvtdatetime(sysdate),
       q.last_updt_user_id = reqinfo->updt_id, q.updt_applctx = reqinfo->updt_applctx, q.updt_cnt = (
       q.updt_cnt+ 1),
       q.updt_dt_tm = cnvtdatetime(sysdate), q.updt_id = reqinfo->updt_id, q.updt_task = reqinfo->
       updt_task
      WHERE (q.da_query_id=duplicatequerynames->daquery[locatedindex].query_id)
      WITH nocounter
     ;end update
     IF (error(errormessage,0) != 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat("Could not update DA_QUERY row for ",datasourcestoimport->
       ccldatasource[count].fullobjectname," (da_query_id=",build(duplicatequerynames->daquery[
        locatedindex].query_id),"): ",
       errormessage)
      GO TO exit_now
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = concat("CCL data sources imported without error.")
 COMMIT
 GO TO exit_now
 SUBROUTINE (transformguid(guid=c32) =c36)
   DECLARE frmt = c36
   SET frmt = cnvtlower(concat(substring(1,8,guid),"-",substring(9,4,guid),"-",substring(13,4,guid),
     "-",substring(17,4,guid),"-",substring(21,12,guid)))
   RETURN(frmt)
 END ;Subroutine
 SUBROUTINE (getfullobjectname(objectname=vc(ref),group=i4) =vc)
   IF (group=0)
    RETURN(concat(cnvtupper(objectname),":DBA"))
   ELSE
    RETURN(concat(cnvtupper(objectname),":GROUP",trim(cnvtstring(group),3)))
   ENDIF
 END ;Subroutine
#exit_now
 FREE RECORD datasourcestoimport
 FREE RECORD duplicatequerynames
 IF ((readme_data->status != "S"))
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
