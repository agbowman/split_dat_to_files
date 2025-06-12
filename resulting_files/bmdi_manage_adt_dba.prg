CREATE PROGRAM bmdi_manage_adt:dba
 DECLARE readconfig(dummy) = i2
 IF (validate(info_domain,999)=999)
  DECLARE info_domain = vc WITH protect, noconstant("bmdi_manage_adt")
 ENDIF
 IF (validate(info_name,999)=999)
  DECLARE info_name = vc WITH protect, noconstant("LOG_MSGVIEW")
 ENDIF
 IF (validate(log_msgview,999)=999)
  DECLARE log_msgview = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(execmsgrtl,999)=999)
  DECLARE execmsgrtl = i2 WITH protect, constant(1)
 ENDIF
 IF (validate(emsglog_commit,999)=999)
  DECLARE emsglog_commit = i4 WITH protect, constant(0)
 ENDIF
 IF (validate(emsglvl_debug,999)=999)
  DECLARE emsglvl_debug = i4 WITH protect, constant(4)
 ENDIF
 IF (validate(msg_debug,999)=999)
  DECLARE msg_debug = i4 WITH protect, noconstant(0)
 ENDIF
 IF (validate(msg_default,999)=999)
  DECLARE msg_default = i4 WITH protect, noconstant(0)
 ENDIF
 RECORD reply(
   1 association_id = f8
   1 status = i2
   1 ierrnum = i2
   1 serrmsg = vc
   1 status_flag = i2
   1 status_message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD request_copy(
   1 qual[*]
     2 person_id = f8
     2 device_alias = c40
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 mode = i2
     2 device_cd = f8
     2 location_cd = f8
     2 start_dt_tm = dq8
     2 stop_dt_tm = dq8
     2 assoc_prsnl_id = f8
     2 dissoc_prsnl_id = f8
     2 upd_status_cd = f8
     2 hint_id = f8
     2 monitored_device_id = f8
     2 resource_loc_cd = f8
 )
 RECORD insert_check(
   1 exist_cnt = i2
   1 statactiveassociationexists = c2
   1 statstubrowexists = c2
 )
 SET insert_check->exist_cnt = 0
 SET insert_check->statactiveassociationexists = "F"
 SET insert_check->statstubrowexists = "F"
 CALL readconfig(0)
 SET serrmsg = fillstring(132," ")
 SET reply->status_data.status = "F"
 SET failure = "F"
 DECLARE statinsert = c2 WITH private, noconstant("F")
 DECLARE statactiveassociationexists = c2 WITH private, noconstant("F")
 DECLARE statstubrowexists = c2 WITH private, noconstant("F")
 DECLARE mon_device_key = c1 WITH noconstant("F")
 DECLARE cnt = i2 WITH private, noconstant(0)
 DECLARE alternate_device_cd = f8 WITH noconstant(0.0)
 DECLARE count = i2 WITH private, noconstant(0)
 DECLARE ind = i2 WITH private, noconstant(0)
 DECLARE personassoc = i2
 DECLARE parententity = i2
 DECLARE association_dt_tm = dq8
 DECLARE active_ind = i2
 DECLARE parent_entity_id = f8 WITH noconstant(0.0)
 DECLARE custom_options = vc
 DECLARE logical_domain_id = f8 WITH noconstant(0.0)
 DECLARE device_cd1 = f8 WITH noconstant(0.0)
 DECLARE location_cd1 = f8 WITH noconstant(0.0)
 DECLARE resource_loc_cd1 = f8 WITH noconstant(0.0)
 DECLARE alternate_device_cd1 = f8 WITH noconstant(0.0)
 DECLARE monitored_device_id1 = f8 WITH noconstant(0.0)
 DECLARE request_id = i4 WITH protect, constant(1250501)
 DECLARE ibusstatus = c2 WITH noconstant("F")
 DECLARE device_id = vc
 DECLARE status = c2
 CALL msgwrite("Entered script BMDI Manage ADT..")
 RECORD verified_check(
   1 exist_cnt = i2
   1 unverified_cd = f8
   1 retrospectiv_cd = f8
 )
 SET verified_check->unverified_cd = uar_get_code_by("MEANING",359578,"UNVERIFIED")
 SET verified_check->retrospectiv_cd = uar_get_code_by("MEANING",359578,"RETROSPECTIV")
 IF ((request->mode=2))
  SET request->mode = 8
 ENDIF
 SELECT INTO "nl:"
  FROM strt_model_custom smc
  WHERE smc.strt_model_id=0
   AND smc.strt_config_id=1282105
   AND process_flag=10
  DETAIL
   custom_options = smc.custom_option
  WITH nocounter
 ;end select
 IF (curqual=1)
  IF (substring(1,1,custom_options)="1")
   SET mon_device_key = "T"
  ELSE
   SET mon_device_key = "F"
  ENDIF
 ENDIF
 SET request->upd_status_cd = 0.00
 CALL echorecord(request)
 IF ((request->mode=0))
  SELECT
   IF (mon_device_key="T")INTO "nl:"
    FROM bmdi_acquired_data_track badt
    WHERE (badt.monitored_device_id=request->monitored_device_id)
     AND badt.dis_association_dt_tm=null
   ELSE INTO "nl:"
    FROM bmdi_acquired_data_track badt
    WHERE (badt.device_cd=request->device_cd)
     AND (badt.location_cd=request->location_cd)
     AND (badt.resource_loc_cd=request->resource_loc_cd)
     AND badt.dis_association_dt_tm=null
   ENDIF
   HEAD REPORT
    insert_check->exist_cnt = 0
   DETAIL
    IF (badt.person_id=0
     AND badt.parent_entity_id=0)
     insert_check->statstubrowexists = "T", insert_check->exist_cnt += 1
    ELSEIF (badt.active_ind=1)
     insert_check->statactiveassociationexists = "T", insert_check->exist_cnt += 1
    ENDIF
   FOOT REPORT
    CALL echo(build("insert_check->exist_cnt = ",insert_check->exist_cnt))
   WITH nocounter
  ;end select
  IF ((insert_check->exist_cnt=0))
   SET statinsert = "T"
   CALL echo(build("Confirmed neither stub row nor associated row exists for device_cd= ",request->
     device_cd,"location_cd=",request->location_cd,"resource_loc_cd=",
     request->resource_loc_cd,"Inserting stub row"))
   CALL sub_insert_badt(statinsert)
  ELSE
   IF ((insert_check->statactiveassociationexists="T"))
    CALL echo(build("Active association already exists for the device_cd:",request->device_cd,
      " at location_cd:",request->location_cd))
   ELSE
    CALL echo(build("Stub row already exists for the device_cd:",request->device_cd,
      " at location_cd:",request->location_cd))
   ENDIF
  ENDIF
 ELSEIF ((((request->mode=1)) OR ((request->mode=3))) )
  CALL echo(build("size of device_alias(=",request->device_alias,") is ",size(request->device_alias,4
     )))
  IF ((request->device_cd <= 0)
   AND size(request->device_alias,4) > 0)
   CALL echo(build("DUP size of device_alias(=",request->device_alias,") is ",size(request->
      device_alias,4)))
   IF ((((request->person_id > 0)) OR ((request->parent_entity_id > 0))) )
    CALL msgwrite("On ADT feed Assocation Mode with logical_domain match")
    SELECT INTO "nl:"
     FROM person p1
     WHERE (p1.person_id=request->person_id)
     DETAIL
      logical_domain_id = p1.logical_domain_id
     WITH nocounter
    ;end select
    CALL msgwrite(build2("Patient's logical domain ID= ",logical_domain_id))
    SELECT INTO "nl:"
     FROM service_resource svc,
      organization org,
      logical_domain ld,
      bmdi_monitored_device bmd
     WHERE (bmd.device_alias=request->device_alias)
      AND bmd.device_cd=svc.service_resource_cd
      AND org.organization_id=svc.organization_id
      AND ld.logical_domain_id=org.logical_domain_id
      AND ld.logical_domain_id=logical_domain_id
      AND ld.active_ind=1
     DETAIL
      device_cd1 = bmd.device_cd, location_cd1 = bmd.location_cd, resource_loc_cd1 = bmd
      .resource_loc_cd,
      alternate_device_cd1 = bmd.alternate_device_cd, monitored_device_id1 = bmd.monitored_device_id
     WITH nocounter
    ;end select
    CALL msgwrite(build2("curqual= ",curqual))
    IF (curqual=1)
     SET request->device_cd = device_cd1
     SET request->location_cd = location_cd1
     SET request->resource_loc_cd = resource_loc_cd1
     SET alternate_device_cd = alternate_device_cd1
     SET request->monitored_device_id = monitored_device_id1
    ELSEIF (curqual=0)
     CALL echo("Device alias not found.")
     CALL msgwrite("Device alias not found ...")
     SET failure = "N"
     GO TO get_data_failure
    ELSEIF (curqual > 1)
     CALL echo("Duplicate Device alias are found in single logical domain.")
     CALL msgwrite("Duplicate Device alias are found in single logical domain")
     SET failure = "D"
     GO TO get_data_failure
    ENDIF
    CALL echo(build("size of device_alias(=",request->device_alias,") is ",size(request->device_alias,
       4)))
    CALL echo(build("device_cd = ",request->device_cd,"location_cd = ",request->location_cd))
    CALL echorecord(request)
    IF ((request->mode=3))
     SELECT INTO "nl:"
      FROM bmdi_acquired_data_track badt
      WHERE (request->device_cd=badt.device_cd)
       AND (request->location_cd=badt.location_cd)
       AND (request->resource_loc_cd=badt.resource_loc_cd)
       AND badt.active_ind=1
      DETAIL
       request->parent_entity_id = badt.parent_entity_id, request->parent_entity_name = badt
       .parent_entity_name
      WITH nocounter
     ;end select
    ENDIF
    IF ((request->parent_entity_id > 0.0))
     CALL msgwrite("On ADT feed Assocation Mode 3..")
     SELECT INTO "nl:"
      FROM sa_anesthesia_record sar,
       surgical_case sc
      WHERE (sar.sa_anesthesia_record_id=request->parent_entity_id)
       AND sar.surgical_case_id=sc.surg_case_id
       AND (request->person_id != sc.person_id)
      DETAIL
       CALL echo(build("Surgery Person ID : ",sc.person_id)),
       CALL msgwrite(build2("Surgery Person ID:",sc.person_id))
      WITH nocounter
     ;end select
     IF (curqual=1)
      CALL echo("Patient Assocation conflict happened.")
      CALL msgwrite("Patient Assocation conflict happened")
      SET failure = "C"
      GO TO get_data_failure
     ENDIF
    ENDIF
    CALL echo(build("alternate_device_cd = ",alternate_device_cd))
    IF ((request->device_cd > 0.0)
     AND (request->location_cd > 0.0))
     IF (alternate_device_cd <= 0)
      CALL echo(build(" Updating for association: device_cd = ",request->device_cd,"person_id = ",
        request->person_id,"parent_entity_id = ",
        request->parent_entity_id))
      CALL sub_update_badt(request->mode)
     ELSE
      CALL echo(build("Calling bmdi_assoc_device as alternate_device_cd is set"))
      CALL sub_assoc(request->mode)
     ENDIF
    ELSE
     CALL echo(build("Invalid entries for association: device_alias = ",request->device_alias,
       " is not valid"))
     SET failure = "N"
     GO TO get_data_failure
    ENDIF
   ELSE
    CALL echo(build("Invalid entries for association: person_id = ",request->person_id,
      " and parent_entity_id = ",request->parent_entity_id))
   ENDIF
  ELSE
   IF ((request->device_cd > 0))
    CALL echo(build("device_cd = ",request->device_cd,"location_cd = ",request->location_cd))
    IF ((request->location_cd > 0))
     IF ((((request->person_id > 0)) OR ((request->parent_entity_id > 0))) )
      CALL echo(build(" Updating for association: device_cd = ",request->device_cd,"person_id = ",
        request->person_id,"parent_entity_id = ",
        request->parent_entity_id))
      SELECT INTO "nl:"
       FROM bmdi_acquired_data_track badt
       WHERE (request->device_cd=badt.device_cd)
        AND badt.active_ind=1
       DETAIL
        request->parent_entity_id = badt.parent_entity_id, request->parent_entity_name = badt
        .parent_entity_name
       WITH nocounter
      ;end select
      IF ((request->parent_entity_id > 0.0))
       CALL msgwrite("On ADT feed Assocation Mode 3. In else")
       SELECT INTO "nl:"
        FROM sa_anesthesia_record sar,
         surgical_case sc
        WHERE (sar.sa_anesthesia_record_id=request->parent_entity_id)
         AND sar.surgical_case_id=sc.surg_case_id
         AND (request->person_id != sc.person_id)
        DETAIL
         CALL echo(build("Surgery Person ID : ",sc.person_id)),
         CALL msgwrite(build2("Surgery Person ID :",sc.person_id))
        WITH nocounter
       ;end select
       IF (curqual=1)
        CALL echo("Patient Assocation conflict happened.")
        CALL msgwrite("Patient Assocation conflict happened..")
        SET failure = "C"
        GO TO get_data_failure
       ENDIF
      ENDIF
      CALL sub_update_badt(request->mode)
     ELSE
      CALL echo(build("Invalid entries for association: Either person_id = ",request->person_id,
        " or parent_entity_id = ",request->parent_entity_id," should be valid"))
     ENDIF
    ELSE
     CALL echo(build("Invalid entries for association: For device_alias = ",request->device_alias,
       "location_cd = ",request->location_cd," should be valid"))
    ENDIF
   ELSE
    CALL echo(build("Invalid entries for association: device_alias = ",request->device_alias,
      "device_cd = ",request->device_cd," should be valid"))
    CALL echo("Need a valid device_cd or valid device_alias to get device_cd")
   ENDIF
  ENDIF
 ELSEIF ((((request->mode=2)) OR ((request->mode=6))) )
  SET personassoc = 0
  SELECT INTO "nl:"
   FROM bmdi_monitored_device bmd
   WHERE (bmd.device_alias=request->device_alias)
   DETAIL
    request->device_cd = bmd.device_cd, alternate_device_cd = bmd.alternate_device_cd, request->
    monitored_device_id = bmd.monitored_device_id,
    request->device_cd = bmd.device_cd, request->location_cd = bmd.location_cd, request->
    resource_loc_cd = bmd.resource_loc_cd
   WITH nocounter
  ;end select
  CALL echorecord(request)
  IF (alternate_device_cd <= 0)
   CALL echo("Updating for dissociation")
   IF (mon_device_key="T")
    CALL sub_update_badt_mon_device(request->mode)
   ELSE
    CALL sub_update_badt(request->mode)
   ENDIF
   IF (ibusstatus="Z")
    CALL echo("Inserting stub row after updating for dissociation")
    IF ((((request->mode=2)) OR ((request->mode=6)
     AND failure != "U")) )
     SET statinsert = "T"
     CALL sub_insert_badt(statinsert)
    ENDIF
   ENDIF
  ELSE
   CALL echo(build("Calling bmdi_dissoc_device as alternate_device_cd is set"))
   CALL sub_dissoc(request->mode)
  ENDIF
 ELSEIF ((request->mode=5))
  CALL echo(build("size of device_alias(=",request->device_alias,") is ",size(request->device_alias,4
     )))
  IF ((request->device_cd <= 0)
   AND size(request->device_alias,4) > 0)
   CALL echo(build("DUP size of device_alias(=",request->device_alias,") is ",size(request->
      device_alias,4)))
   IF ((((request->person_id > 0)) OR ((request->parent_entity_id > 0))) )
    SELECT INTO "nl:"
     FROM bmdi_monitored_device bmd
     WHERE (bmd.device_alias=request->device_alias)
     DETAIL
      request->device_cd = bmd.device_cd, request->location_cd = bmd.location_cd, request->
      resource_loc_cd = bmd.resource_loc_cd,
      alternate_device_cd = bmd.alternate_device_cd, request->monitored_device_id = bmd
      .monitored_device_id
     WITH nocounter
    ;end select
    CALL echo(build("size of device_alias(=",request->device_alias,") is ",size(request->device_alias,
       4)))
    CALL echo(build("device_cd = ",request->device_cd,"location_cd = ",request->location_cd))
    CALL echo(build("resource_loc_cd = ",request->resource_loc_cd))
    SELECT
     IF (mon_device_key="T")INTO "nl:"
      FROM bmdi_acquired_data_track badt
      WHERE (request->monitored_device_id=badt.monitored_device_id)
       AND badt.active_ind=1
     ELSE INTO "nl:"
      FROM bmdi_acquired_data_track badt
      WHERE (request->device_cd=badt.device_cd)
       AND (request->location_cd=badt.location_cd)
       AND (request->resource_loc_cd=badt.resource_loc_cd)
       AND badt.active_ind=1
     ENDIF
     DETAIL
      request->person_id = badt.person_id
     WITH nocounter
    ;end select
    IF ((request->person_id > 0.0))
     CALL msgwrite("In Anesthesia Association case mode 5... ")
     CALL msgwrite(build2("iView/Fetalink Person ID :",request->person_id))
     SELECT INTO "nl:"
      FROM sa_anesthesia_record sar,
       surgical_case sc
      WHERE (sar.sa_anesthesia_record_id=request->parent_entity_id)
       AND sar.surgical_case_id=sc.surg_case_id
       AND (request->person_id != sc.person_id)
      DETAIL
       CALL echo(build("Surgery Person ID : ",sc.person_id)),
       CALL msgwrite(build2("Surgery Person ID :",sc.person_id))
      WITH nocounter
     ;end select
     IF (curqual=1)
      CALL echo("Patient Assocation conflict happened.")
      CALL msgwrite("Patient Assocation conflict happened. ")
      SET failure = "C"
      GO TO get_data_failure
     ENDIF
    ENDIF
    CALL echorecord(request)
    CALL echo(build("alternate_device_cd = ",alternate_device_cd))
    IF ((request->device_cd > 0.0)
     AND (request->resource_loc_cd > 0.0))
     IF (alternate_device_cd <= 0)
      CALL echo(build(" Updating for association: device_cd = ",request->device_cd,"person_id = ",
        request->person_id,"parent_entity_id = ",
        request->parent_entity_id))
      IF (mon_device_key="T")
       CALL sub_update_badt_mon_device(request->mode)
      ELSE
       CALL sub_update_badt(request->mode)
      ENDIF
     ELSE
      CALL echo(build("Calling bmdi_assoc_device as alternate_device_cd is set"))
      CALL sub_assoc(request->mode)
     ENDIF
    ELSE
     CALL echo(build("Invalid entries for association: device_alias = ",request->device_alias,
       " is not valid"))
    ENDIF
   ELSE
    CALL echo(build("Invalid entries for association: person_id = ",request->person_id,
      " and parent_entity_id = ",request->parent_entity_id))
   ENDIF
  ELSE
   SELECT INTO "nl:"
    FROM bmdi_monitored_device bmd
    WHERE (bmd.device_alias=request->device_alias)
    DETAIL
     request->device_cd = bmd.device_cd, request->location_cd = bmd.location_cd, request->
     resource_loc_cd = bmd.resource_loc_cd,
     alternate_device_cd = bmd.alternate_device_cd, request->monitored_device_id = bmd
     .monitored_device_id
    WITH nocounter
   ;end select
   SELECT
    IF (mon_device_key="T")INTO "nl:"
     FROM bmdi_acquired_data_track badt
     WHERE (request->monitored_device_id=badt.monitored_device_id)
      AND badt.active_ind=1
    ELSE INTO "nl:"
     FROM bmdi_acquired_data_track badt
     WHERE (request->device_cd=badt.device_cd)
      AND (request->location_cd=badt.location_cd)
      AND (request->resource_loc_cd=badt.resource_loc_cd)
      AND badt.active_ind=1
    ENDIF
    DETAIL
     request->person_id = badt.person_id
    WITH nocounter
   ;end select
   IF ((request->person_id > 0.0))
    CALL msgwrite("In Anesthesia Association case mode 5 else case")
    CALL msgwrite(build2("iView/Fetalink Person ID :",request->person_id))
    SELECT INTO "nl:"
     FROM sa_anesthesia_record sar,
      surgical_case sc
     WHERE (sar.sa_anesthesia_record_id=request->parent_entity_id)
      AND sar.surgical_case_id=sc.surg_case_id
      AND (request->person_id != sc.person_id)
     DETAIL
      CALL echo(build("Surgery Person ID : ",sc.person_id)),
      CALL msgwrite(build2("Surgery Person ID :",sc.person_id))
     WITH nocounter
    ;end select
    IF (curqual=1)
     CALL echo("Patient Assocation conflict happened.")
     CALL msgwrite("Patient Assocation conflict happened. ")
     SET failure = "C"
     GO TO get_data_failure
    ENDIF
   ENDIF
   IF ((request->device_cd > 0))
    CALL echo(build("device_cd = ",request->device_cd,"location_cd = ",request->location_cd))
    CALL echo(build("resource_loc_cd = ",request->resource_loc_cd))
    IF ((request->resource_loc_cd > 0))
     IF ((((request->person_id > 0)) OR ((request->parent_entity_id > 0))) )
      CALL echo(build(" Updating for association: device_cd = ",request->device_cd,"person_id = ",
        request->person_id,"parent_entity_id = ",
        request->parent_entity_id))
      CALL sub_update_badt(request->mode)
     ELSE
      CALL echo(build("Invalid entries for association: Either person_id = ",request->person_id,
        " or parent_entity_id = ",request->parent_entity_id," should be valid"))
     ENDIF
    ELSE
     CALL echo(build("Invalid entries for association: For device_alias = ",request->device_alias,
       "resource_loc_cd = ",request->resource_loc_cd," should be valid"))
    ENDIF
   ELSE
    CALL echo(build("Invalid entries for association: device_alias = ",request->device_alias,
      "device_cd = ",request->device_cd," should be valid"))
    CALL echo("Need a valid device_cd or valid device_alias to get device_cd")
   ENDIF
  ENDIF
 ELSEIF ((request->mode=7))
  SELECT INTO "nl:"
   FROM bmdi_monitored_device bmd
   WHERE (bmd.resource_loc_cd=request->resource_loc_cd)
   HEAD REPORT
    count = 0, stat = alterlist(request_copy->qual,10)
   DETAIL
    count += 1
    IF (mod(count,10)=1
     AND count != 1)
     stat = alterlist(request_copy->qual,(count+ 9))
    ENDIF
    request_copy->qual[count].device_cd = bmd.device_cd, request_copy->qual[count].
    monitored_device_id = bmd.monitored_device_id, request_copy->qual[count].device_alias = bmd
    .device_alias,
    request_copy->qual[count].location_cd = bmd.location_cd
   FOOT REPORT
    stat = alterlist(request_copy->qual,count)
   WITH nocounter
  ;end select
  SET count = size(request_copy->qual,5)
  FOR (ind = 1 TO count)
    SET request->device_cd = request_copy->qual[ind].device_cd
    SET request->monitored_device_id = request_copy->qual[ind].monitored_device_id
    SET request->device_alias = request_copy->qual[ind].device_alias
    SET request->location_cd = request_copy->qual[ind].location_cd
    CALL echorecord(request)
    CALL echo(build("Updating for dissociation - record ",ind," for resource_loc_cd: ",request->
      resource_loc_cd))
    CALL sub_update_badt(request->mode)
    CALL echo(build("Inserting stub row after updating for record ",ind," for resource_loc_cd: ",
      request->resource_loc_cd))
    SET statinsert = "T"
    SELECT INTO "nl:"
     FROM bmdi_acquired_data_track badt
     WHERE (((badt.device_cd=request->device_cd)
      AND (badt.resource_loc_cd=request->resource_loc_cd)
      AND badt.person_id=0
      AND badt.parent_entity_id=0) OR ((badt.device_cd=request->device_cd)
      AND (badt.resource_loc_cd=request->resource_loc_cd)
      AND badt.active_ind=1))
     HEAD REPORT
      insert_check->exist_cnt = 0
     DETAIL
      IF (badt.person_id=0
       AND badt.parent_entity_id=0)
       insert_check->statstubrowexists = "T", insert_check->exist_cnt += 1
      ELSEIF (badt.active_ind=1)
       insert_check->statactiveassociationexists = "T", insert_check->exist_cnt += 1
      ENDIF
     FOOT REPORT
      CALL echo(build("insert_check->exist_cnt = ",insert_check->exist_cnt))
     WITH nocounter
    ;end select
    IF ((insert_check->exist_cnt=0))
     SET statinsert = "T"
     CALL echo(build("Confirmed neither stub row nor associated row exists for device_cd= ",request->
       device_cd,"resource_loc_cd=",request->resource_loc_cd,"Inserting stub row"))
     CALL sub_insert_badt(statinsert)
    ELSE
     IF ((insert_check->statactiveassociationexists="T"))
      CALL echo(build("Active association already exists for the device_cd:",request->device_cd,
        " at resource_loc_cd:",request->resource_loc_cd))
     ELSE
      CALL echo(build("Stub row already exists for the device_cd:",request->device_cd,
        " at resource_loc_cd:",request->resource_loc_cd))
     ENDIF
    ENDIF
  ENDFOR
 ELSEIF ((((request->mode=8)) OR ((request->mode=4))) )
  CALL echo("Pass 1 ")
  SET parententity = 0
  SELECT INTO "nl:"
   FROM bmdi_monitored_device bmd
   WHERE (bmd.device_alias=request->device_alias)
   DETAIL
    request->device_cd = bmd.device_cd, request->location_cd = bmd.location_cd, request->
    resource_loc_cd = bmd.resource_loc_cd,
    request->monitored_device_id = bmd.monitored_device_id
   WITH nocounter
  ;end select
  CALL echorecord(request)
  CALL echo("Updating for dissociation1")
  CALL sub_update_badt(request->mode)
  CALL echo("Inserting stub row after updating for dissociation1")
  SET statinsert = "T"
  CALL sub_insert_badt(statinsert)
 ELSEIF ((request->mode=9))
  CALL echo("Called by bmdi_add_adt_stub script for first time to update monitored_device_id")
  CALL sub_update_badt(request->mode)
 ENDIF
 SUBROUTINE (sub_insert_badt(statinsert=c2) =i4)
  RECORD insert_request(
    1 association_id = f8
    1 statusinsert = i2
    1 ierrnum = i2
    1 serrmsg = vc
  )
  CASE (statinsert)
   OF "T":
    SELECT INTO "nl:"
     nextseqnum = seq(bmdi_seq,nextval)"##################;RP0"
     FROM dual
     DETAIL
      insert_request->association_id = cnvtreal(nextseqnum)
     WITH nocounter
    ;end select
    IF (personassoc=0
     AND parententity=0)
     SET active_ind = 0
     SET association_dt_tm = cnvtdatetime(sysdate)
    ELSE
     SET active_ind = 1
    ENDIF
    IF (personassoc=0)
     SET request->person_id = 0
    ELSE
     SET personassoc = 0
    ENDIF
    IF (parententity=0)
     SET request->parent_entity_id = 0
     SET request->parent_entity_name = " "
    ELSE
     SET parententity = 0
    ENDIF
    IF (mon_device_key="T")
     CALL echo("Inside SubInsertBadt will insert mon_device in BADT ")
     CALL echo(build("request->monitored_device_id = ",request->monitored_device_id))
     INSERT  FROM bmdi_acquired_data_track badt
      SET badt.association_id = insert_request->association_id, badt.device_cd = request->device_cd,
       badt.location_cd = request->location_cd,
       badt.resource_loc_cd = request->resource_loc_cd, badt.association_dt_tm = cnvtdatetime(
        association_dt_tm), badt.person_id = request->person_id,
       badt.parent_entity_id = request->parent_entity_id, badt.parent_entity_name = request->
       parent_entity_name, badt.active_ind = active_ind,
       badt.updt_dt_tm = cnvtdatetime(sysdate), badt.updt_cnt = 0, badt.updt_id = reqinfo->updt_id,
       badt.updt_task = reqinfo->updt_task, badt.updt_applctx = reqinfo->updt_applctx, badt
       .monitored_device_id = request->monitored_device_id
      WITH status(insert_request->statusinsert,insert_request->ierrnum,insert_request->serrmsg)
     ;end insert
     CALL echo(build("curqual = ",curqual))
     IF (curqual=1)
      SET reply->status_data.status = "S"
      SET reply->association_id = insert_request->association_id
     ENDIF
    ELSE
     CALL echo("Inside SubInsertBadt will NOT insert mon_device in BADT ")
     INSERT  FROM bmdi_acquired_data_track badt
      SET badt.association_id = insert_request->association_id, badt.device_cd = request->device_cd,
       badt.location_cd = request->location_cd,
       badt.resource_loc_cd = request->resource_loc_cd, badt.association_dt_tm = cnvtdatetime(
        association_dt_tm), badt.person_id = request->person_id,
       badt.parent_entity_id = request->parent_entity_id, badt.parent_entity_name = request->
       parent_entity_name, badt.active_ind = active_ind,
       badt.updt_dt_tm = cnvtdatetime(sysdate), badt.updt_cnt = 0, badt.updt_id = reqinfo->updt_id,
       badt.updt_task = reqinfo->updt_task, badt.updt_applctx = reqinfo->updt_applctx
      WITH status(insert_request->statusinsert,insert_request->ierrnum,insert_request->serrmsg)
     ;end insert
     CALL echo(build("curqual = ",curqual))
     IF (curqual=1)
      SET reply->status_data.status = "S"
      SET reply->association_id = insert_request->association_id
     ENDIF
    ENDIF
    IF (curqual=0)
     SET reply->status = insert_request->statusinsert
     SET reply->ierrnum = insert_request->ierrnum
     SET reply->serrmsg = insert_request->serrmsg
     IF (validate(error)=1)
      SET ierrcode = error(serrmsg,1)
     ELSE
      SET ierrcode = 0
     ENDIF
     SET failure = "T"
     GO TO get_data_failure
    ENDIF
    CALL echorecord(insert_request)
   OF "F":
    CALL echo(build("No action at this time for statInsert = ",statinsert))
  ENDCASE
 END ;Subroutine
 SUBROUTINE (sub_update_badt(mode=i2) =i4)
  RECORD update_request(
    1 statusupdate = i2
    1 ierrnum = i2
    1 serrmsg = vc
    1 upd_status_cd = f8
    1 monitored_device_id = f8
  )
  IF (mode=1)
   CALL echorecord(reqinfo)
   CALL echorecord(request)
   UPDATE  FROM bmdi_acquired_data_track badt
    SET badt.association_dt_tm = cnvtdatetime(sysdate), badt.person_id = request->person_id, badt
     .active_ind = 1,
     badt.updt_dt_tm = cnvtdatetime(sysdate), badt.updt_cnt = (badt.updt_cnt+ 1), badt.updt_id =
     reqinfo->updt_id,
     badt.updt_task = reqinfo->updt_task, badt.updt_applctx = reqinfo->updt_applctx
    WHERE (badt.device_cd=request->device_cd)
     AND (badt.location_cd=request->location_cd)
     AND badt.person_id=0.0
    WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
   ;end update
   CALL echorecord(update_request)
   CALL echo(build("curqual = ",curqual))
   IF (curqual=1)
    SET reply->status_data.status = "S"
   ENDIF
   IF (curqual=0)
    SET reply->status = update_request->statusupdate
    SET reply->ierrnum = update_request->ierrnum
    SET reply->serrmsg = update_request->serrmsg
    IF (validate(error)=1)
     SET ierrcode = error(serrmsg,1)
    ELSE
     SET ierrcode = 0
    ENDIF
    SET failure = "U"
    GO TO get_data_failure
   ENDIF
  ELSEIF (mode=2)
   CALL echorecord(reqinfo)
   SELECT INTO "nl:"
    FROM bmdi_acquired_data_track badt
    WHERE (badt.person_id=request->person_id)
     AND badt.active_ind=1
    DETAIL
     request->device_cd = badt.device_cd, request->location_cd = badt.location_cd
    WITH nocounter
   ;end select
   CALL echorecord(request)
   UPDATE  FROM bmdi_acquired_data_track badt
    SET badt.dis_association_dt_tm = cnvtdatetime(sysdate), badt.active_ind = 0, badt.updt_dt_tm =
     cnvtdatetime(sysdate),
     badt.updt_cnt = (badt.updt_cnt+ 1), badt.updt_id = reqinfo->updt_id, badt.updt_task = reqinfo->
     updt_task,
     badt.updt_applctx = reqinfo->updt_applctx
    WHERE (badt.person_id=request->person_id)
     AND badt.active_ind=1
    WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
   ;end update
   CALL echo(build("curqual = ",curqual))
   IF (curqual=1)
    SET reply->status_data.status = "S"
   ENDIF
   IF (curqual=0)
    SET reply->status = update_request->statusupdate
    SET reply->ierrnum = update_request->ierrnum
    SET reply->serrmsg = update_request->serrmsg
    IF (validate(error)=1)
     SET ierrcode = error(serrmsg,1)
    ELSE
     SET ierrcode = 0
    ENDIF
    SET failure = "U"
    GO TO get_data_failure
   ENDIF
  ELSEIF (mode=3)
   CALL echorecord(reqinfo)
   CALL echorecord(request)
   IF ((request->stop_dt_tm > 0))
    UPDATE  FROM bmdi_acquired_data_track badt
     SET badt.association_dt_tm = cnvtdatetime(request->start_dt_tm), badt.person_id = request->
      person_id, badt.parent_entity_id = (request->parent_entity_id+ 0),
      badt.parent_entity_name = request->parent_entity_name, badt.assoc_prsnl_id = request->
      assoc_prsnl_id, badt.hint_id = request->hint_id,
      badt.upd_status_cd = request->upd_status_cd, badt.active_ind = 1, badt.updt_dt_tm =
      cnvtdatetime(sysdate),
      badt.updt_cnt = (badt.updt_cnt+ 1), badt.updt_id = reqinfo->updt_id, badt.updt_task = reqinfo->
      updt_task,
      badt.updt_applctx = reqinfo->updt_applctx
     WHERE (badt.device_cd=request->device_cd)
      AND (badt.location_cd=request->location_cd)
      AND badt.person_id=0.0
      AND (badt.parent_entity_id=request->parent_entity_id)
      AND badt.dis_association_dt_tm=null
     WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
    ;end update
    CALL echorecord(update_request)
    CALL echo(build("update bmdi_acquired_data_track curqual = ",curqual))
    IF (curqual=1)
     UPDATE  FROM bmdi_acquired_results bar
      SET bar.verified_ind = 0, bar.verified_dt_tm = null, bar.event_id = 0.0,
       bar.person_id = request->person_id, bar.updt_dt_tm = cnvtdatetime(sysdate), bar.updt_cnt = (
       bar.updt_cnt+ 1),
       bar.updt_id = reqinfo->updt_id, bar.updt_task = reqinfo->updt_task, bar.updt_applctx = reqinfo
       ->updt_applctx
      WHERE (bar.monitored_device_id=request->monitored_device_id)
       AND bar.clinical_dt_tm >= cnvtdatetime(request->start_dt_tm)
       AND bar.clinical_dt_tm < cnvtdatetime(request->stop_dt_tm)
       AND (bar.person_id != request->person_id)
      WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
     ;end update
     CALL echorecord(update_request)
     CALL echo(build("update bmdi_acquired_results curqual = ",curqual))
     IF (validate(ierrcode,0) > 0)
      SET failure = "U"
      GO TO get_data_failure
     ENDIF
     SET reply->status_data.status = "S"
    ELSE
     SET reply->status = update_request->statusupdate
     SET reply->ierrnum = update_request->ierrnum
     SET reply->serrmsg = update_request->serrmsg
     IF (validate(error)=1)
      SET ierrcode = error(serrmsg,1)
     ELSE
      SET ierrcode = 0
     ENDIF
     SET failure = "U"
     GO TO get_data_failure
    ENDIF
   ELSE
    UPDATE  FROM bmdi_acquired_data_track badt
     SET badt.association_dt_tm = cnvtdatetime(request->start_dt_tm), badt.person_id = request->
      person_id, badt.parent_entity_id = (request->parent_entity_id+ 0),
      badt.parent_entity_name = request->parent_entity_name, badt.assoc_prsnl_id = request->
      assoc_prsnl_id, badt.hint_id = request->hint_id,
      badt.active_ind = 1, badt.updt_dt_tm = cnvtdatetime(sysdate), badt.updt_cnt = (badt.updt_cnt+ 1
      ),
      badt.updt_id = reqinfo->updt_id, badt.updt_task = reqinfo->updt_task, badt.updt_applctx =
      reqinfo->updt_applctx
     WHERE (badt.device_cd=request->device_cd)
      AND (badt.location_cd=request->location_cd)
      AND badt.person_id=0.0
      AND (badt.parent_entity_id=request->parent_entity_id)
      AND badt.dis_association_dt_tm=null
     WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
    ;end update
    CALL echorecord(update_request)
    CALL echo(build("update bmdi_acquired_data_track curqual = ",curqual))
    IF (curqual=1)
     SET reply->status_data.status = "S"
    ENDIF
    IF (curqual=0)
     SET reply->status = update_request->statusupdate
     SET reply->ierrnum = update_request->ierrnum
     SET reply->serrmsg = update_request->serrmsg
     IF (validate(error)=1)
      SET ierrcode = error(serrmsg,1)
     ELSE
      SET ierrcode = 0
     ENDIF
     SET failure = "U"
     GO TO get_data_failure
    ENDIF
   ENDIF
  ELSEIF (mode=4)
   CALL echorecord(reqinfo)
   CALL echorecord(request)
   SELECT INTO "nl:"
    FROM bmdi_acquired_data_track badt
    WHERE (badt.device_cd=request->device_cd)
     AND (badt.location_cd=request->location_cd)
     AND badt.active_ind=1
    DETAIL
     parent_entity_id = badt.parent_entity_id
     IF (badt.parent_entity_id > 0)
      request->parent_entity_id = badt.parent_entity_id, request->parent_entity_name = badt
      .parent_entity_name, association_dt_tm = badt.association_dt_tm,
      parententity = 1
     ELSE
      request->parent_entity_id = 0, request->parent_entity_name = " "
     ENDIF
    WITH nocounter
   ;end select
   IF ((request->stop_dt_tm > 0))
    UPDATE  FROM bmdi_acquired_data_track badt
     SET badt.dis_association_dt_tm = cnvtdatetime(request->start_dt_tm), badt.dissoc_prsnl_id =
      request->dissoc_prsnl_id, badt.upd_status_cd = request->upd_status_cd,
      badt.active_ind = 0, badt.updt_dt_tm = cnvtdatetime(sysdate), badt.updt_cnt = (badt.updt_cnt+ 1
      ),
      badt.updt_id = reqinfo->updt_id, badt.updt_task = reqinfo->updt_task, badt.updt_applctx =
      reqinfo->updt_applctx
     WHERE (badt.device_cd=request->device_cd)
      AND (badt.location_cd=request->location_cd)
      AND badt.active_ind=1
     WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
    ;end update
    CALL echo(build("curqual = ",curqual))
    IF (curqual=1)
     UPDATE  FROM bmdi_acquired_results bar
      SET bar.verified_ind = 0, bar.verified_dt_tm = null, bar.event_id = 0.0,
       bar.person_id = 0.0, bar.updt_dt_tm = cnvtdatetime(sysdate), bar.updt_cnt = (bar.updt_cnt+ 1),
       bar.updt_id = reqinfo->updt_id, bar.updt_task = reqinfo->updt_task, bar.updt_applctx = reqinfo
       ->updt_applctx
      WHERE (bar.monitored_device_id=request->monitored_device_id)
       AND bar.clinical_dt_tm >= cnvtdatetime(request->start_dt_tm)
       AND bar.clinical_dt_tm < cnvtdatetime(request->stop_dt_tm)
      WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
     ;end update
     CALL echorecord(update_request)
     CALL echo(build("update bmdi_acquired_results curqual = ",curqual))
     IF (validate(ierrcode,0) > 0)
      SET failure = "U"
      GO TO get_data_failure
     ENDIF
     SET reply->status_data.status = "S"
    ELSE
     SET reply->status = update_request->statusupdate
     SET reply->ierrnum = update_request->ierrnum
     SET reply->serrmsg = update_request->serrmsg
     IF (validate(error)=1)
      SET ierrcode = error(serrmsg,1)
     ELSE
      SET ierrcode = 0
     ENDIF
     SET failure = "U"
     GO TO get_data_failure
    ENDIF
   ELSE
    IF ((request->start_dt_tm > 0))
     UPDATE  FROM bmdi_acquired_data_track badt
      SET badt.dis_association_dt_tm = cnvtdatetime(request->start_dt_tm), badt.dissoc_prsnl_id =
       request->dissoc_prsnl_id, badt.active_ind = 0,
       badt.updt_dt_tm = cnvtdatetime(sysdate), badt.updt_cnt = (badt.updt_cnt+ 1), badt.updt_id =
       reqinfo->updt_id,
       badt.updt_task = reqinfo->updt_task, badt.updt_applctx = reqinfo->updt_applctx
      WHERE (badt.device_cd=request->device_cd)
       AND (badt.location_cd=request->location_cd)
       AND badt.active_ind=1
      WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
     ;end update
    ELSE
     UPDATE  FROM bmdi_acquired_data_track badt
      SET badt.dis_association_dt_tm = cnvtdatetime(sysdate), badt.dissoc_prsnl_id = request->
       dissoc_prsnl_id, badt.active_ind = 0,
       badt.updt_dt_tm = cnvtdatetime(sysdate), badt.updt_cnt = (badt.updt_cnt+ 1), badt.updt_id =
       reqinfo->updt_id,
       badt.updt_task = reqinfo->updt_task, badt.updt_applctx = reqinfo->updt_applctx
      WHERE (badt.device_cd=request->device_cd)
       AND (badt.location_cd=request->location_cd)
       AND badt.active_ind=1
      WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
     ;end update
    ENDIF
    CALL echo(build("curqual = ",curqual))
    IF (curqual=1)
     SET reply->status_data.status = "S"
    ENDIF
    IF (curqual=0)
     SET reply->status = update_request->statusupdate
     SET reply->ierrnum = update_request->ierrnum
     SET reply->serrmsg = update_request->serrmsg
     IF (validate(error)=1)
      SET ierrcode = error(serrmsg,1)
     ELSE
      SET ierrcode = 0
     ENDIF
     SET failure = "U"
     GO TO get_data_failure
    ENDIF
   ENDIF
  ELSEIF (mode=5)
   CALL echorecord(reqinfo)
   CALL echorecord(request)
   UPDATE  FROM bmdi_acquired_data_track badt
    SET badt.association_dt_tm = cnvtdatetime(sysdate), badt.person_id = request->person_id, badt
     .parent_entity_id = (request->parent_entity_id+ 0),
     badt.parent_entity_name = request->parent_entity_name, badt.active_ind = 1, badt.updt_dt_tm =
     cnvtdatetime(sysdate),
     badt.updt_cnt = (badt.updt_cnt+ 1), badt.updt_id = reqinfo->updt_id, badt.updt_task = reqinfo->
     updt_task,
     badt.updt_applctx = reqinfo->updt_applctx
    WHERE (badt.device_cd=request->device_cd)
     AND (badt.resource_loc_cd=request->resource_loc_cd)
     AND badt.parent_entity_id=0.0
     AND (badt.location_cd=request->location_cd)
     AND (badt.person_id=request->person_id)
    WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
   ;end update
   CALL echorecord(update_request)
   CALL echo(build("curqual = ",curqual))
   IF (curqual=1)
    SET reply->status_data.status = "S"
   ENDIF
   IF (curqual=0)
    SET reply->status = update_request->statusupdate
    SET reply->ierrnum = update_request->ierrnum
    SET reply->serrmsg = update_request->serrmsg
    IF (validate(error)=1)
     SET ierrcode = error(serrmsg,1)
    ELSE
     SET ierrcode = 0
    ENDIF
    SET failure = "U"
    GO TO get_data_failure
   ENDIF
  ELSEIF (mode=6)
   CALL echorecord(reqinfo)
   SET parent_entity_id = 0
   SELECT INTO "nl:"
    FROM bmdi_acquired_data_track badt
    WHERE (badt.device_cd=request->device_cd)
     AND (badt.resource_loc_cd=request->resource_loc_cd)
     AND (badt.location_cd=request->location_cd)
     AND badt.active_ind=1
    DETAIL
     parent_entity_id = badt.parent_entity_id
     IF (badt.person_id > 0)
      personassoc = 1, request->person_id = badt.person_id, association_dt_tm = badt
      .association_dt_tm
     ELSE
      request->person_id = 0
     ENDIF
    WITH nocounter
   ;end select
   IF ((request->person_id > 0.0)
    AND (request->parent_entity_id=0))
    CALL msgwrite("In Anesthesia Dissociation or Force Dissociation ")
    CALL msgwrite(build2("iView/Fetalink Person ID :",request->person_id,"Surgery Case ID :",request
      ->parent_entity_id))
    SELECT INTO "nl:"
     FROM di_client_config dcc
     WHERE (dcc.device_name=request->device_alias)
      AND dcc.active_ind=1
     DETAIL
      device_id = dcc.subscription_name
     WITH nocounter
    ;end select
    IF (curqual=1)
     SET ibusstatus = perform239ejscall(request->device_alias,device_id)
     SET request->person_id = 0.0
     CALL echo(build("iBusStatus12: ",ibusstatus))
     CALL msgwrite(build2("iBusStatus :",ibusstatus))
    ELSE
     SET ibusstatus = "Z"
     SET request->person_id = 0.0
     CALL echo("Unable to find the DCC entry for iBUS..")
    ENDIF
   ELSE
    SET ibusstatus = "Z"
    CALL echo("Invalid person and parent entity id received..")
   ENDIF
   IF (ibusstatus="Z")
    CALL echo(build("request->parent_entity_id: ",request->parent_entity_id))
    IF ((((request->parent_entity_id=0)) OR ((request->parent_entity_id=parent_entity_id))) )
     SELECT INTO "nl:"
      FROM bmdi_acquired_data_track badt
      WHERE (badt.device_cd=request->device_cd)
       AND (badt.resource_loc_cd=request->resource_loc_cd)
       AND (badt.location_cd=request->location_cd)
       AND badt.active_ind=1
      WITH nocounter
     ;end select
     CALL echo(build("curqual in update badt = ",curqual))
     CALL msgwrite("Selecting the row if still active in Mill table")
     CALL msgwrite(build2("curqual in update badt:",curqual))
     IF (curqual=1)
      CALL msgwrite("Updating the active row in Mill table.")
      CALL echorecord(request)
      UPDATE  FROM bmdi_acquired_data_track badt
       SET badt.dis_association_dt_tm = cnvtdatetime(sysdate), badt.active_ind = 0, badt.updt_dt_tm
         = cnvtdatetime(sysdate),
        badt.updt_cnt = (badt.updt_cnt+ 1), badt.updt_id = reqinfo->updt_id, badt.updt_task = reqinfo
        ->updt_task,
        badt.updt_applctx = reqinfo->updt_applctx
       WHERE (badt.device_cd=request->device_cd)
        AND (badt.resource_loc_cd=request->resource_loc_cd)
        AND (badt.location_cd=request->location_cd)
        AND badt.active_ind=1
       WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
      ;end update
      CALL echo(build("curqual = ",curqual))
      IF (curqual=1)
       SET reply->status_data.status = "S"
      ENDIF
      IF (curqual=0)
       SET reply->status = update_request->statusupdate
       SET reply->ierrnum = update_request->ierrnum
       SET reply->serrmsg = update_request->serrmsg
       IF (validate(error)=1)
        SET ierrcode = error(serrmsg,1)
       ELSE
        SET ierrcode = 0
       ENDIF
       SET failure = "U"
       GO TO get_data_failure
      ENDIF
     ELSEIF (curqual=0)
      SET reply->status_data.status = "S"
      CALL msgwrite("Returning the SUCCESS status to ANES App. ")
      GO TO exit_script
     ENDIF
    ELSE
     SET failure = "U"
    ENDIF
   ENDIF
  ELSEIF (mode=7)
   CALL echorecord(reqinfo)
   UPDATE  FROM bmdi_acquired_data_track badt
    SET badt.dis_association_dt_tm = cnvtdatetime(sysdate), badt.active_ind = 0, badt.updt_dt_tm =
     cnvtdatetime(sysdate),
     badt.updt_cnt = (badt.updt_cnt+ 1), badt.updt_id = reqinfo->updt_id, badt.updt_task = reqinfo->
     updt_task,
     badt.updt_applctx = reqinfo->updt_applctx
    WHERE (badt.resource_loc_cd=request->resource_loc_cd)
     AND badt.active_ind=1
    WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
   ;end update
   CALL echo(build("curqual = ",curqual))
   IF (curqual=1)
    SET reply->status_data.status = "S"
   ENDIF
   IF (curqual=0)
    SET reply->status = update_request->statusupdate
    SET reply->ierrnum = update_request->ierrnum
    SET reply->serrmsg = update_request->serrmsg
    SET failure = "U"
    GO TO get_data_failure
   ENDIF
  ELSEIF (mode=8)
   CALL echorecord(reqinfo)
   UPDATE  FROM bmdi_acquired_data_track badt
    SET badt.dis_association_dt_tm = cnvtdatetime(sysdate), badt.active_ind = 0, badt.updt_dt_tm =
     cnvtdatetime(sysdate),
     badt.updt_cnt = (badt.updt_cnt+ 1), badt.updt_id = reqinfo->updt_id, badt.updt_task = reqinfo->
     updt_task,
     badt.updt_applctx = reqinfo->updt_applctx
    WHERE (badt.location_cd=request->location_cd)
     AND (badt.device_cd=request->device_cd)
     AND badt.active_ind=1
    WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
   ;end update
   CALL echo(build("curqual = ",curqual))
   IF (curqual=1)
    SET reply->status_data.status = "S"
   ENDIF
   IF (curqual=0)
    SET reply->status = update_request->statusupdate
    SET reply->ierrnum = update_request->ierrnum
    SET reply->serrmsg = update_request->serrmsg
    SET failure = "U"
    GO TO get_data_failure
   ENDIF
  ELSEIF (mode=9)
   CALL echorecord(reqinfo)
   CALL echorecord(request)
   CALL echo("Inside Mode 9 of Insert BADT")
   UPDATE  FROM bmdi_acquired_data_track badt
    SET badt.monitored_device_id = request->monitored_device_id, badt.updt_dt_tm = cnvtdatetime(
      sysdate), badt.updt_cnt = (badt.updt_cnt+ 1),
     badt.updt_id = reqinfo->updt_id, badt.updt_task = reqinfo->updt_task, badt.updt_applctx =
     reqinfo->updt_applctx
    WHERE (badt.device_cd=request->device_cd)
     AND (badt.location_cd=request->location_cd)
     AND (badt.resource_loc_cd=request->resource_loc_cd)
    WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
   ;end update
   CALL echorecord(update_request)
   CALL echo(build("curqual = ",curqual))
   IF (curqual=1)
    SET reply->status_data.status = "S"
   ENDIF
   IF (curqual=0)
    SET reply->status = update_request->statusupdate
    SET reply->ierrnum = update_request->ierrnum
    SET reply->serrmsg = update_request->serrmsg
    IF (validate(error)=1)
     SET ierrcode = error(serrmsg,1)
    ELSE
     SET ierrcode = 0
    ENDIF
    SET failure = "U"
    GO TO get_data_failure
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE (sub_assoc(mode=i2) =i4)
   RECORD req_assoc_device(
     1 assoc_list[*]
       2 device_category_cd = f8
       2 device_alias = vc
       2 device_cd = f8
       2 person_alias_list[*]
         3 alias = vc
         3 person_alias_type_cd = f8
       2 encntr_alias_list[*]
         3 alias = vc
         3 encntr_alias_type_cd = f8
       2 person_name = vc
       2 person_id = f8
       2 encntr_id = f8
       2 person_weight = vc
       2 weight_units_cd = f8
       2 person_height = vc
       2 height_units_cd = f8
       2 person_gender_cd = f8
       2 person_birth_dt_tm = dq8
       2 association_dt_tm = dq8
       2 association_prsnl_id = f8
       2 location_cd = f8
       2 updt_cnt = i4
   )
   RECORD rep_assoc_device(
     1 assoc_list[*]
       2 device_category_cd = f8
       2 device_alias = vc
       2 device_cd = f8
       2 device_id = f8
       2 alternate_device_cd = f8
       2 location_cd = f8
       2 person_name = vc
       2 person_name_middle = vc
       2 person_name_last = vc
       2 person_name_first = vc
       2 person_id = f8
       2 encntr_id = f8
       2 association_id = f8
       2 assoc_person_r_id = f8
       2 strmesg = vc
       2 status_flag = i2
       2 status_message = vc
     1 statusupdate = i2
     1 ierrnum = i2
     1 serrmsg = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET stat = alterlist(req_assoc_device->assoc_list,1)
   SET req_assoc_device->assoc_list[1].device_alias = request->device_alias
   SET req_assoc_device->assoc_list[1].person_id = request->person_id
   SET stat = alterlist(req_assoc_device->assoc_list[1].person_alias_list,1)
   SET stat = alterlist(req_assoc_device->assoc_list[1].encntr_alias_list,1)
   SELECT INTO "nl:"
    FROM person p,
     person_alias pa
    PLAN (p
     WHERE (p.person_id=request->person_id)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (pa
     WHERE (pa.person_id= Outerjoin(p.person_id))
      AND (pa.active_ind= Outerjoin(1))
      AND (pa.person_alias_type_cd= Outerjoin(value(uar_get_code_by("MEANING",4,"MRN")))) )
    DETAIL
     req_assoc_device->assoc_list[1].person_birth_dt_tm = cnvtdatetime(p.birth_dt_tm),
     req_assoc_device->assoc_list[1].person_gender_cd = p.sex_cd, req_assoc_device->assoc_list[1].
     person_alias_list[1].person_alias_type_cd = pa.person_alias_type_cd,
     req_assoc_device->assoc_list[1].person_alias_list[1].alias = pa.alias
    WITH nocounter
   ;end select
   IF ((request->encntr_id > 0))
    SET req_assoc_device->assoc_list[1].encntr_id = request->encntr_id
    SELECT INTO "nl:"
     FROM encounter e,
      encntr_alias ea
     PLAN (e
      WHERE (e.encntr_id=request->encntr_id)
       AND e.active_ind=1
       AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND e.end_effective_dt_tm >= cnvtdatetime(sysdate))
      JOIN (ea
      WHERE ea.encntr_id=e.encntr_id
       AND ea.active_ind=1
       AND ea.encntr_alias_type_cd=value(uar_get_code_by("MEANING",319,"FIN NBR")))
     DETAIL
      req_assoc_device->assoc_list[1].encntr_alias_list[1].encntr_alias_type_cd = ea
      .encntr_alias_type_cd, req_assoc_device->assoc_list[1].encntr_alias_list[1].alias = ea.alias
     WITH nocounter
    ;end select
   ENDIF
   SET req_assoc_device->assoc_list[1].association_dt_tm = cnvtdatetime(sysdate)
   SET req_assoc_device->assoc_list[1].association_prsnl_id = reqinfo->updt_id
   CALL echorecord(req_assoc_device)
   EXECUTE bmdi_assoc_device  WITH replace("REQUEST","REQ_ASSOC_DEVICE"), replace("REPLY",
    "REP_ASSOC_DEVICE")
   CALL echorecord(rep_assoc_device)
   IF ((rep_assoc_device->status_data.status != "S"))
    SET reply->status = rep_assoc_device->statusupdate
    SET reply->ierrnum = rep_assoc_device->ierrnum
    SET reply->serrmsg = rep_assoc_device->serrmsg
    SET reply->status_flag = rep_assoc_device->assoc_list[1].status_flag
    SET reply->status_message = rep_assoc_device->assoc_list[1].status_message
    SET failure = "U"
    GO TO get_data_failure
   ENDIF
 END ;Subroutine
 SUBROUTINE (sub_update_badt_mon_device(mode=i2) =i4)
  RECORD update_request(
    1 statusupdate = i2
    1 ierrnum = i2
    1 serrmsg = vc
    1 upd_status_cd = f8
    1 monitored_device_id = f8
  )
  IF (mode=5)
   CALL echorecord(reqinfo)
   CALL echorecord(request)
   UPDATE  FROM bmdi_acquired_data_track badt
    SET badt.association_dt_tm = cnvtdatetime(sysdate), badt.person_id = request->person_id, badt
     .parent_entity_id = (request->parent_entity_id+ 0),
     badt.parent_entity_name = request->parent_entity_name, badt.active_ind = 1, badt.updt_dt_tm =
     cnvtdatetime(sysdate),
     badt.updt_cnt = (badt.updt_cnt+ 1), badt.updt_id = reqinfo->updt_id, badt.updt_task = reqinfo->
     updt_task,
     badt.updt_applctx = reqinfo->updt_applctx
    WHERE (badt.monitored_device_id=request->monitored_device_id)
     AND badt.dis_association_dt_tm=null
     AND badt.parent_entity_id=0.0
     AND (badt.location_cd=request->location_cd)
     AND (badt.person_id=request->person_id)
    WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
   ;end update
   CALL echorecord(update_request)
   CALL echo(build("curqual = ",curqual))
   IF (curqual=1)
    SET reply->status_data.status = "S"
   ENDIF
   IF (curqual=0)
    SET reply->status = update_request->statusupdate
    SET reply->ierrnum = update_request->ierrnum
    SET reply->serrmsg = update_request->serrmsg
    IF (validate(error)=1)
     SET ierrcode = error(serrmsg,1)
    ELSE
     SET ierrcode = 0
    ENDIF
    SET failure = "U"
    GO TO get_data_failure
   ENDIF
  ELSEIF (mode=6)
   CALL echorecord(reqinfo)
   SET parent_entity_id = 0
   SELECT INTO "nl:"
    FROM bmdi_acquired_data_track badt
    WHERE (badt.monitored_device_id=request->monitored_device_id)
     AND (badt.location_cd=request->location_cd)
     AND badt.active_ind=1
    DETAIL
     parent_entity_id = badt.parent_entity_id
     IF (badt.person_id > 0)
      personassoc = 1, request->person_id = badt.person_id, association_dt_tm = badt
      .association_dt_tm
     ELSE
      request->person_id = 0
     ENDIF
    WITH nocounter
   ;end select
   IF ((request->person_id > 0.0)
    AND (request->parent_entity_id=0))
    CALL msgwrite("On Anesthesia disassociation or Force dis-assocation.")
    CALL msgwrite(build2("Person ID is active in BADT :",request->person_id))
    SELECT INTO "nl:"
     FROM di_client_config dcc
     WHERE (dcc.device_name=request->device_alias)
      AND dcc.active_ind=1
     DETAIL
      device_id = dcc.subscription_name
     WITH nocounter
    ;end select
    IF (curqual=1)
     SET ibusstatus = perform239ejscall(request->device_alias,device_id)
     SET request->person_id = 0.0
     CALL echo(build("iBusStatus1.2: ",ibusstatus))
     CALL msgwrite(build2("iBusStatus :",ibusstatus))
    ELSE
     SET ibusstatus = "Z"
     SET request->person_id = 0.0
     CALL echo("iBus entry is not found in DCC table..")
    ENDIF
   ELSE
    SET ibusstatus = "Z"
    CALL echo("Invalid person and parent entity id..")
   ENDIF
   IF (ibusstatus="Z")
    IF ((((request->parent_entity_id=0)) OR ((request->parent_entity_id=parent_entity_id))) )
     CALL msgwrite("On selecting the assoc row is active or not")
     SELECT INTO "nl:"
      FROM bmdi_acquired_data_track badt
      WHERE (badt.monitored_device_id=request->monitored_device_id)
       AND badt.active_ind=1
      WITH nocounter
     ;end select
     CALL echo(build("curqual by mon_device = ",curqual))
     CALL msgwrite(build2("curqual :",curqual))
     IF (curqual=1)
      CALL echorecord(request)
      UPDATE  FROM bmdi_acquired_data_track badt
       SET badt.dis_association_dt_tm = cnvtdatetime(sysdate), badt.active_ind = 0, badt.updt_dt_tm
         = cnvtdatetime(sysdate),
        badt.updt_cnt = (badt.updt_cnt+ 1), badt.updt_id = reqinfo->updt_id, badt.updt_task = reqinfo
        ->updt_task,
        badt.updt_applctx = reqinfo->updt_applctx
       WHERE (badt.monitored_device_id=request->monitored_device_id)
        AND badt.active_ind=1
       WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
      ;end update
      CALL echo(build("curqual = ",curqual))
      IF (curqual=1)
       SET reply->status_data.status = "S"
      ENDIF
      IF (curqual=0)
       SET reply->status = update_request->statusupdate
       SET reply->ierrnum = update_request->ierrnum
       SET reply->serrmsg = update_request->serrmsg
       IF (validate(error)=1)
        SET ierrcode = error(serrmsg,1)
       ELSE
        SET ierrcode = 0
       ENDIF
       SET failure = "U"
       GO TO get_data_failure
      ENDIF
     ELSEIF (curqual=0)
      SET reply->status_data.status = "S"
      CALL msgwrite("Replying the SUCCESS status to ANES app. ")
      GO TO exit_script
     ELSEIF (curqual > 1)
      SET failure = "U"
      CALL msgwrite("Replying the Update Fail status due to bad data. ")
      GO TO get_data_failure
     ENDIF
    ELSE
     SET failure = "U"
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE (sub_dissoc(mode=i2) =i4)
   RECORD req_dissoc_device(
     1 dissoc_list[*]
       2 device_category_cd = f8
       2 device_alias = vc
       2 device_cd = f8
       2 person_id = f8
       2 encntr_id = f8
       2 association_id = f8
       2 assoc_person_r_id = f8
       2 dis_association_dt_tm = dq8
       2 dis_association_prsnl_id = f8
       2 updt_cnt = f8
   )
   RECORD rep_dissoc_device(
     1 assoc_list[*]
       2 device_category_cd = f8
       2 device_alias = vc
       2 device_id = f8
       2 person_name = vc
       2 person_id = f8
       2 encntr_id = f8
       2 association_id = f8
       2 assoc_person_r_id = f8
       2 device_cd = f8
       2 location_cd = f8
       2 alternate_device_cd = f8
       2 strmesg = vc
       2 status_flag = i4
       2 status_message = vc
       2 curr_updt_cnt = i4
     1 statusupdate = i2
     1 ierrnum = i2
     1 serrmsg = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET stat = alterlist(req_dissoc_device->dissoc_list,1)
   SELECT INTO "nl:"
    FROM bmdi_acquired_data_track badt
    WHERE (badt.person_id=request->person_id)
     AND active_ind=1
    DETAIL
     req_dissoc_device->dissoc_list[1].association_id = badt.association_id
    WITH nocounter
   ;end select
   SET req_dissoc_device->dissoc_list[1].dis_association_prsnl_id = reqinfo->updt_id
   SET req_dissoc_device->dissoc_list[1].dis_association_dt_tm = cnvtdatetime(sysdate)
   CALL echorecord(req_dissoc_device)
   EXECUTE bmdi_dissoc_device  WITH replace("REQUEST","REQ_DISSOC_DEVICE"), replace("REPLY",
    "REP_DISSOC_DEVICE")
   CALL echorecord(rep_dissoc_device)
   IF ((rep_dissoc_device->status_data.status != "S"))
    SET reply->status = rep_dissoc_device->statusupdate
    SET reply->ierrnum = rep_dissoc_device->ierrnum
    SET reply->serrmsg = rep_dissoc_device->serrmsg
    SET reply->status_flag = rep_dissoc_device->assoc_list[1].status_flag
    SET reply->status_message = rep_dissoc_device->assoc_list[1].status_message
    SET failure = "U"
    GO TO get_data_failure
   ENDIF
 END ;Subroutine
 SUBROUTINE (perform239ejscall(monitor_name=vc,device_id=vc) =vc)
   CALL echo("Entering perform239EJSCall subroutine..")
   CALL msgwrite("Entering perform239EJSCall subroutine. ")
   DECLARE hmsg = i4 WITH private, noconstant(0)
   DECLARE hreq = i4 WITH private, noconstant(0)
   DECLARE hrep = i4 WITH private, noconstant(0)
   DECLARE hconfig = i4 WITH private, noconstant(0)
   SET hmsg = uar_srvselectmessage(request_id)
   CALL echo(build("hMsg : ",hmsg))
   SET hreq = uar_srvcreaterequest(hmsg)
   CALL echo(build("hReq : ",hreq))
   SET hrep = uar_srvcreatereply(hmsg)
   CALL echo(build("hRep : ",hrep))
   CALL msgwrite(build2("hMsg :",hmsg,"hReq :",hreq,"hRep :",
     hrep))
   CALL echo(build("DEVICE ID TRACE1: ",device_id))
   SET stat = uar_srvsetstring(hreq,"m_device_id",nullterm(device_id))
   SET stat = uar_srvsetstring(hreq,"m_monitor_name",nullterm(monitor_name))
   CALL echo(build("GetNew -> DEVICE ID TRACE2: ",uar_srvgetstringptr(hreq,"m_device_id")))
   SET stat_srvexecute = uar_srvexecute(hmsg,hreq,hrep)
   CALL echo("Executed perform239EJSCall subroutine..")
   CALL msgwrite("Executed perform239EJSCall subroutine")
   CALL msgwrite(build2("stat_SrvExecute :",stat_srvexecute))
   CALL echo(build("stat_SrvExecute : ",stat_srvexecute))
   SET sstatus = uar_srvgetstringptr(hrep,"m_status")
   SET smonitor = uar_srvgetstringptr(hrep,"m_monitor_name")
   CALL echo(build("sStatus : ",sstatus))
   CALL msgwrite(build2("sStatus in 239 reply :",sstatus))
   CALL echo(build("sMonitor : ",smonitor))
   CALL msgwrite(build2("sMonitor in 239 reply :",smonitor))
   SET status = sstatus
   CALL echo(build("status 111 : ",status))
   IF (hrep)
    CALL uar_srvdestroyinstance(hrep)
   ENDIF
   IF (hreq)
    CALL uar_srvdestroyinstance(hreq)
   ENDIF
   IF (hmsg)
    CALL uar_srvdestroymessage(hmsg)
   ENDIF
   RETURN(sstatus)
 END ;Subroutine
#get_data_failure
 IF (failure="T")
  IF (validate(ierrcode,0) > 0)
   SET stat = alter(reply->status_data.subeventstatus,1)
  ELSE
   SET stat = alter(reply->status_data.subeventstatus,1)
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_manage_adt"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Data Addition failed!"
  IF (validate(ierrcode,0) > 0)
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
 IF (failure="N")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_manage_adt"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to find device_alias in bmdi_monitored_device table."
  GO TO exit_script
 ENDIF
 IF (failure="B")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_manage_adt"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to disassociation in iBus."
  GO TO exit_script
 ENDIF
 IF (failure="U")
  IF (validate(ierrcode,0) > 0)
   SET stat = alter(reply->status_data.subeventstatus,1)
  ELSE
   SET stat = alter(reply->status_data.subeventstatus,1)
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_manage_adt"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Data Update failed!"
  IF (validate(ierrcode,0) > 0)
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
 IF (failure="C")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_manage_adt"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PersonID conflict assocation!"
  IF (validate(ierrcode,0) > 0)
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
 IF (failure="D")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_manage_adt"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Logical domain has duplicate alias match found!"
  IF (validate(ierrcode,0) > 0)
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
#exit_script
 IF (((failure="T") OR (failure="U")) )
  IF (validate(ierrcode,0) > 0)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
  ROLLBACK
 ELSE
  IF (failure="N")
   SET reply->status_data.status = "F"
   ROLLBACK
  ELSEIF (failure="B")
   SET reply->status_data.status = "F"
   ROLLBACK
  ELSEIF (failure="C")
   SET reply->status_data.status = "F"
   ROLLBACK
  ELSEIF (failure="D")
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "S"
   COMMIT
  ENDIF
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE readconfig(null)
   IF (validate(execmsgrtl,999)=999)
    EXECUTE msgrtl
   ENDIF
   SET msg_default = uar_msgdefhandle()
   SET msg_debug = uar_msgopen("bmdi_manage_adt")
   CALL uar_msgsetlevel(msg_debug,emsglvl_debug)
   DECLARE msgout = vc
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=info_domain
      AND di.info_name=info_name)
    DETAIL
     log_msgview = cnvtint(di.info_number)
    WITH nocounter
   ;end select
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (msgwrite(msg=vc) =i2)
  SET log_msgview = 1
  IF (log_msgview=1)
   CALL uar_msgwrite(msg_debug,emsglog_commit,nullterm("BMDI"),emsglvl_debug,nullterm(msg))
  ENDIF
 END ;Subroutine
END GO
