CREATE PROGRAM bmdi_assoc_device:dba
 FREE SET insert_request
 RECORD insert_request(
   1 association_id = f8
   1 statusinsert = i2
   1 ierrnum = i2
   1 serrmsg = vc
   1 upd_dt_tm = dq8
   1 cnt = i2
   1 person_alias = vc
   1 encntr_alias = vc
   1 person_alias_type_cd = f8
   1 encntr_alias_type_cd = f8
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 assoc_list[*]
      2 device_category_cd = f8
      2 device_alias = vc
      2 device_cd = f8
      2 device_id = f8
      2 alternate_device_cd = f8
      2 location_cd = f8
      2 loc_room_cd = f8
      2 loc_unit_cd = f8
      2 person_name = vc
      2 person_name_middle = vc
      2 person_name_last = vc
      2 person_name_first = vc
      2 person_id = f8
      2 encntr_id = f8
      2 reg_dt_tm = f8
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
 ENDIF
 DECLARE bmdi_cqm_dnld(req_ind=i2) = i2
 SUBROUTINE bmdi_cqm_dnld(req_ind)
   DECLARE sub_stat = i2 WITH private, noconstant(0)
   DECLARE alt_dev_cd = f8 WITH private, noconstant(value(0.0))
   FREE SET sub_req
   RECORD sub_req(
     1 queue_id = f8
     1 contrib_id = f8
     1 trigger_id = f8
     1 listener_id = f8
     1 statusinsert = i2
     1 ierrnum = i2
     1 serrmsg = vc
   )
   IF ((reply->assoc_list[req_ind].alternate_device_cd=0))
    SET sub_stat = 1
    CALL echo(build("alt_dev_cd = ",reply->assoc_list[req_ind].alternate_device_cd))
    RETURN(sub_stat)
   ENDIF
   IF ((reply->assoc_list[req_ind].assoc_person_r_id=0))
    SET sub_stat = 2
    RETURN(sub_stat)
   ENDIF
   CALL echo(build("BEF fetching contrib_id, alt_dev_cd = ",reply->assoc_list[req_ind].
     alternate_device_cd))
   SELECT INTO "nl:"
    ccc.contributor_id
    FROM cqm_contributor_config ccc,
     (dummyt d  WITH seq = value(req_ind))
    PLAN (d)
     JOIN (ccc
     WHERE ccc.contributor_alias=trim(cnvtstring(reply->assoc_list[d.seq].alternate_device_cd)))
    DETAIL
     sub_req->contrib_id = ccc.contributor_id
    WITH nocounter
   ;end select
   IF ((sub_req->contrib_id=0))
    SET sub_stat = 3
    RETURN(sub_stat)
   ENDIF
   SELECT INTO "nl:"
    nextseqnum = seq(cqm_queue_id_seq,nextval)"##################;RP0"
    FROM dual
    DETAIL
     sub_req->queue_id = cnvtreal(nextseqnum)
    WITH nocounter
   ;end select
   IF ((sub_req->queue_id=0))
    SET sub_stat = 4
    CALL echo(build("sub_stat = ",sub_stat," error in getting sequence number"))
    RETURN(sub_stat)
   ENDIF
   CALL echo(build("BEF inserting cqm, contrib_id = ",sub_req->contrib_id,"queue_id = ",sub_req->
     queue_id))
   INSERT  FROM cqm_gnlbdnld_que c,
     (dummyt d  WITH seq = value(req_ind))
    SET c.queue_id = sub_req->queue_id, c.contributor_id = sub_req->contrib_id, c.create_dt_tm =
     cnvtdatetime(curdate,curtime3),
     c.contributor_refnum = cnvtstring(reply->assoc_list[d.seq].assoc_person_r_id), c
     .process_status_flag = 10, c.priority = 1,
     c.trig_create_start_dt_tm = cnvtdatetime(curdate,curtime3), c.trig_create_end_dt_tm =
     cnvtdatetime(curdate,curtime3), c.active_ind = 1,
     c.class = cnvtstring(reply->assoc_list[d.seq].alternate_device_cd), c.debug_ind = 1, c
     .verbosity_flag = 3,
     c.message = reply->assoc_list[d.seq].strmesg, c.message_len = value(size(reply->assoc_list[
       req_ind].strmesg,4)), c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = 0,
     c.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (c)
    WITH status(sub_req->statusinsert,sub_req->ierrnum,sub_req->serrmsg), notrim
   ;end insert
   IF (curqual=0)
    SET sub_stat = 5
    SET reply->statusupdate = sub_req->statusinsert
    SET reply->ierrnum = sub_req->ierrnum
    SET reply->serrmsg = sub_req->serrmsg
    IF (validate(error)=1)
     SET ierrcode = error(serrmsg,1)
    ELSE
     SET ierrcode = 0
    ENDIF
    SET failure = "T"
    SET reply->assoc_list[req_ind].status_message = sub_req->serrmsg
   ELSE
    SELECT INTO "nl:"
     clc.listener_id
     FROM cqm_listener_config clc,
      (dummyt d  WITH seq = value(req_ind))
     PLAN (d)
      JOIN (clc
      WHERE clc.listener_alias=trim(cnvtstring(reply->assoc_list[d.seq].alternate_device_cd)))
     DETAIL
      sub_req->listener_id = clc.listener_id
     WITH nocounter
    ;end select
    IF ((sub_req->listener_id=0))
     SET sub_stat = 6
     RETURN(sub_stat)
    ENDIF
    SELECT INTO "nl:"
     nextseqnum = seq(cqm_trigger_id_seq,nextval)"##################;RP0"
     FROM dual
     DETAIL
      sub_req->trigger_id = cnvtreal(nextseqnum)
     WITH nocounter
    ;end select
    IF ((sub_req->trigger_id=0))
     SET sub_stat = 7
     CALL echo(build("sub_stat = ",sub_stat," error in getting sequence number"))
     RETURN(sub_stat)
    ENDIF
    INSERT  FROM cqm_gnlbdnld_tr_1 c
     SET c.trigger_id = sub_req->trigger_id, c.queue_id = sub_req->queue_id, c.listener_id = sub_req
      ->listener_id,
      c.create_dt_tm = cnvtdatetime(curdate,curtime3), c.process_start_dt_tm = cnvtdatetime(curdate,
       curtime3), c.schedule_dt_tm = cnvtdatetime(curdate,curtime3),
      c.priority = 99, c.active_ind = 1, c.number_of_retries = 0,
      c.process_status_flag = 10, c.debug_ind = 1, c.verbosity_flag = 3,
      c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_task = reqinfo->updt_task, c.updt_cnt = 0,
      c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET sub_stat = 8
     SET reply->statusupdate = sub_req->statusinsert
     SET reply->ierrnum = sub_req->ierrnum
     SET reply->serrmsg = sub_req->serrmsg
     IF (validate(error)=1)
      SET ierrcode = error(serrmsg,1)
     ELSE
      SET ierrcode = 0
     ENDIF
     SET failure = "T"
     SET reply->assoc_list[req_ind].status_message = sub_req->serrmsg
    ENDIF
   ENDIF
   RETURN(sub_stat)
 END ;Subroutine
 RECORD check_adt(
   1 exist_device_cnt = i2
   1 exist_device_person_cnt = i2
   1 statactiveassociationexists = c2
   1 statstubrowexists = c2
   1 assoc_list[*]
     2 association_id = f8
 )
 SET check_adt->exist_device_cnt = 0
 SET check_adt->statactiveassociationexists = "F"
 SET check_adt->statstubrowexists = "F"
 SET serrmsg = fillstring(132," ")
 SET reply->status_data.status = "F"
 SET failure = "F"
 DECLARE error_message = vc WITH private, noconstant("")
 DECLARE i = i2 WITH private, noconstant(0)
 DECLARE j = i2 WITH noconstant(0)
 DECLARE cnt = i2 WITH private, noconstant(0)
 DECLARE upd_association_id = f8 WITH private, noconstant(0.0)
 DECLARE assoc_person_r_id = f8 WITH private, noconstant(0.0)
 DECLARE sub_update_badt(req_ind=i2) = f8 WITH private
 DECLARE sub_insert_bapr(assoc_id=f8,req_ind=i2) = f8 WITH private
 DECLARE strvalidaliasconf = vc WITH private, noconstant("")
 DECLARE device_alias = vc WITH private, noconstant("")
 DECLARE device_cd = f8 WITH private, noconstant(0.0)
 DECLARE status_flag = i2 WITH private, noconstant(0)
 DECLARE sub_format_cqmmessage(request_ind=i4) = i2 WITH private
 DECLARE unittypecd = f8 WITH constant(uar_get_code_by("MEANING",222,"NURSEUNIT"))
 DECLARE ambulatorytypecd = f8 WITH constant(uar_get_code_by("MEANING",222,"AMBULATORY"))
 DECLARE roomtypecd = f8 WITH constant(uar_get_code_by("MEANING",222,"ROOM"))
 CALL echo("Calling Program")
 SET stat = alterlist(reply->assoc_list,size(request->assoc_list,5))
 IF (size(request->assoc_list,5) < 1)
  SET error_message = "No request set"
  SET failure = "R"
 ENDIF
 FOR (i = 1 TO size(request->assoc_list,5))
   SET device_cd = 0.0
   SET device_alias = ""
   IF (validate(request->assoc_list[i].person_alias_list,"N")="N"
    AND validate(request->assoc_list[i].encntr_alias_list,"N")="N")
    SET reply->assoc_list[i].status_flag = 27
    SET reply->assoc_list[i].status_message = build(
     "Either a person_alias or an encounter_alias should be set in request")
   ELSEIF (validate(request->assoc_list[i].person_alias_list,"N") != "N"
    AND validate(request->assoc_list[i].encntr_alias_list,"N")="N")
    IF (size(request->assoc_list[i].person_alias_list,5) > 1)
     SET reply->assoc_list[i].status_flag = 8
     SET reply->assoc_list[i].status_message = build(
      "Current support is for person_alias_size of 1 in request")
    ELSEIF (size(request->assoc_list[i].person_alias_list,5)=1)
     IF ((((request->assoc_list[i].person_alias_list[1].person_alias_type_cd < 1.0)) OR (size(trim(
       request->assoc_list[i].person_alias_list[1].alias),1) <= 0)) )
      SET reply->assoc_list[i].status_flag = 11
      SET reply->assoc_list[i].status_message = build("Invalid values: person_alias_type_cd = ",
       request->assoc_list[i].person_alias_list[1].person_alias_type_cd," alias size = ",request->
       assoc_list[i].person_alias_list[1].alias)
     ENDIF
    ELSE
     SET reply->assoc_list[i].status_flag = 12
     SET reply->assoc_list[i].status_message = build("Invalid: person_alias list size is zero")
    ENDIF
   ELSEIF (validate(request->assoc_list[i].person_alias_list,"N")="N"
    AND validate(request->assoc_list[i].encntr_alias_list,"N") != "N")
    IF (size(request->assoc_list[i].encntr_alias_list,5) > 1)
     SET reply->assoc_list[i].status_flag = 9
     SET reply->assoc_list[i].status_message = build(
      "Current support is for encntr_alias_size of 1 in request")
    ELSEIF (size(request->assoc_list[i].encntr_alias_list,5)=1)
     IF ((((request->assoc_list[i].encntr_alias_list[1].encntr_alias_type_cd < 1.0)) OR (size(trim(
       request->assoc_list[i].encntr_alias_list[1].alias),1) <= 0)) )
      SET reply->assoc_list[i].status_flag = 13
      SET reply->assoc_list[i].status_message = build("Invalid values: encntr_alias_type_cd = ",
       request->assoc_list[i].encntr_alias_list[1].encntr_alias_type_cd," alias size = ",request->
       assoc_list[i].encntr_alias_list[1].alias)
     ENDIF
    ELSE
     SET reply->assoc_list[i].status_flag = 14
     SET reply->assoc_list[i].status_message = build("Invalid: encntr_alias list size is zero")
    ENDIF
   ELSE
    IF (size(request->assoc_list[i].person_alias_list,5) < 1
     AND size(request->assoc_list[i].encntr_alias_list,5) < 1)
     SET reply->assoc_list[i].status_flag = 15
     SET reply->assoc_list[i].status_message = build(
      "Either person alias or encounter alias lists that are set should be allocated")
    ENDIF
   ENDIF
   IF ((reply->assoc_list[i].status_flag=0))
    SET reply->assoc_list[i].device_category_cd = validate(request->assoc_list[i].device_category_cd,
     0.0)
    SET reply->assoc_list[i].device_alias = request->assoc_list[i].device_alias
    SET reply->assoc_list[i].person_id = request->assoc_list[i].person_id
    SET reply->assoc_list[i].encntr_id = request->assoc_list[i].encntr_id
    SET reply->assoc_list[i].person_name = request->assoc_list[i].person_name
    SET reply->assoc_list[i].status_flag = 0
    SET reply->assoc_list[i].status_message = "SUCCESS"
    IF (validate(request->assoc_list[i].person_id,0.0) <= 0)
     SET reply->assoc_list[i].status_flag = 17
     SET reply->assoc_list[i].status_message = build("Invalid entry for association: person_id = ",
      request->assoc_list[i].person_id)
    ELSE
     SELECT INTO "nl:"
      FROM person p,
       (dummyt d  WITH seq = value(i))
      PLAN (d)
       JOIN (p
       WHERE (p.person_id=request->assoc_list[d.seq].person_id)
        AND p.active_ind=1)
      DETAIL
       reply->assoc_list[d.seq].person_name_first = p.name_first, reply->assoc_list[d.seq].
       person_name_last = p.name_last, reply->assoc_list[d.seq].person_name_middle = p.name_middle
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET reply->assoc_list[i].status_flag = 18
      SET reply->assoc_list[i].status_message = build("Active entry for person_id = ",request->
       assoc_list[i].person_id," does not exist in person data model")
     ELSE
      SELECT INTO "nl:"
       FROM bmdi_monitored_device bmd,
        (dummyt d  WITH seq = value(i))
       PLAN (d)
        JOIN (bmd
        WHERE (bmd.device_alias=request->assoc_list[d.seq].device_alias))
       DETAIL
        reply->assoc_list[d.seq].device_cd = bmd.device_cd, request->assoc_list[d.seq].device_cd =
        bmd.device_cd, reply->assoc_list[d.seq].location_cd = bmd.location_cd,
        request->assoc_list[d.seq].location_cd = bmd.location_cd, reply->assoc_list[d.seq].
        alternate_device_cd = bmd.alternate_device_cd, reply->assoc_list[d.seq].device_id = bmd
        .monitored_device_id
       WITH nocounter
      ;end select
      IF ((reply->assoc_list[i].device_cd <= 0))
       SET reply->assoc_list[i].status_flag = 1
       SET reply->assoc_list[i].status_message = build(
        "Invalid entry for association: device_alias = ",request->assoc_list[i].device_alias,
        " does not exist in bmdi_monitored_device database table")
      ELSE
       SET check_adt->exist_device_cnt = 0
       SET check_adt->exist_device_person_cnt = 0
       SET check_adt->statactiveassociationexists = "F"
       SET check_adt->statstubrowexists = "F"
       SELECT INTO "nl:"
        FROM bmdi_acquired_data_track badt,
         (dummyt d  WITH seq = value(i))
        PLAN (d)
         JOIN (badt
         WHERE (((badt.device_cd=reply->assoc_list[d.seq].device_cd)
          AND (badt.location_cd=request->assoc_list[d.seq].location_cd)
          AND badt.person_id=0
          AND badt.parent_entity_id=0) OR ((badt.device_cd=reply->assoc_list[d.seq].device_cd)
          AND (badt.location_cd=request->assoc_list[d.seq].location_cd)
          AND badt.active_ind=1)) )
        HEAD REPORT
         check_adt->exist_device_cnt = 0, check_adt->exist_device_person_cnt = 0
        DETAIL
         IF (badt.person_id=0
          AND badt.parent_entity_id=0)
          check_adt->statstubrowexists = "T", check_adt->exist_device_cnt = (check_adt->
          exist_device_cnt+ 1)
         ELSEIF (badt.active_ind=1)
          check_adt->statactiveassociationexists = "T", check_adt->exist_device_cnt = (check_adt->
          exist_device_cnt+ 1)
          IF ((badt.person_id=request->assoc_list[d.seq].person_id))
           check_adt->exist_device_person_cnt = (check_adt->exist_device_person_cnt+ 1), stat =
           alterlist(check_adt->assoc_list,(size(check_adt->assoc_list,5)+ 1)), check_adt->
           assoc_list[size(check_adt->assoc_list,5)].association_id = badt.association_id
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
       IF ((check_adt->exist_device_cnt=0))
        SET reply->assoc_list[i].status_flag = 2
        SET reply->assoc_list[i].status_message = build(
         "Neither stub row nor associated row exists for device_alias = ",request->assoc_list[i].
         device_alias," location_cd = ",request->assoc_list[i].location_cd," device_cd = ",
         reply->assoc_list[i].device_cd)
       ELSEIF ((check_adt->exist_device_cnt=1))
        IF ((check_adt->statactiveassociationexists="T"))
         IF ((check_adt->exist_device_person_cnt=1))
          SET reply->assoc_list[i].association_id = check_adt->assoc_list[1].association_id
          SET status_flag = 0
          SET assoc_person_r_id = 0.0
          SELECT INTO "nl:"
           FROM bmdi_adt_person_r bapr
           WHERE (bapr.association_id=check_adt->assoc_list[1].association_id)
            AND bapr.active_ind=1
           DETAIL
            assoc_person_r_id = bapr.bmdi_adt_person_r_id
           WITH nocounter
          ;end select
          IF (curqual > 0)
           SET reply->assoc_list[i].status_flag = 27
           SET reply->assoc_list[i].status_message = build(
            "Active association exists for device: association_id = ",check_adt->assoc_list[1].
            association_id)
          ELSE
           SET reply->assoc_list[i].association_id = check_adt->assoc_list[1].association_id
           SET assoc_person_r_id = 0.0
           SET assoc_person_r_id = sub_insert_bapr(check_adt->assoc_list[1].association_id,i)
           IF (assoc_person_r_id > 0.0)
            SET reply->assoc_list[i].assoc_person_r_id = assoc_person_r_id
            SET status_flag = 0
            SET status_flag = sub_format_cqmmessage(i)
            IF (status_flag=0)
             SET status_flag = bmdi_cqm_dnld(i)
             CALL echo(build("AFT1 CQM insert status_flag = ",status_flag))
             IF (status_flag > 0)
              IF (status_flag=1)
               SET reply->assoc_list[i].status_flag = 19
               SET reply->assoc_list[i].status_message = build(
                "Alternate device code not set for device_alias: ",request->assoc_list[i].
                device_alias)
              ELSEIF (status_flag=2)
               SET reply->assoc_list[i].status_flag = 20
               SET reply->assoc_list[i].status_message = build(
                "Association person identifier not set for associating device_alias: ",request->
                assoc_list[i].device_alias)
              ELSEIF (status_flag=3)
               SET reply->assoc_list[i].status_flag = 21
               SET reply->assoc_list[i].status_message = build(
                "Contributor config identifier not set for associating device_alias: ",request->
                assoc_list[i].device_alias)
              ELSEIF (status_flag=4)
               SET reply->assoc_list[i].status_flag = 22
               SET reply->assoc_list[i].status_message = build(
                "Error in getting database sequence number from cqm_queue_id_seq",request->
                assoc_list[i].device_alias)
              ELSEIF (status_flag=5)
               SET reply->assoc_list[i].status_flag = 23
               SET reply->assoc_list[i].status_message = build("No insertion in CQM table")
              ELSEIF (status_flag=6)
               SET reply->assoc_list[i].status_flag = 24
               SET reply->assoc_list[i].status_message = build(
                "Listener identifier not set for associating device_alias: ",request->assoc_list[i].
                device_alias)
              ELSEIF (status_flag=7)
               SET reply->assoc_list[i].status_flag = 25
               SET reply->assoc_list[i].status_message = build(
                "Error in getting database sequence number from cqm_trigger_id_seq",request->
                assoc_list[i].device_alias)
              ELSEIF (status_flag=8)
               SET reply->assoc_list[i].status_flag = 26
               SET reply->assoc_list[i].status_message = build(
                "No insertion in CQM_gnlbdnld_tr_1 trigger table")
              ENDIF
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ELSE
          SET reply->assoc_list[i].status_flag = 3
          SET reply->assoc_list[i].status_message = build(
           "Active association exists for another person for device_alias = ",request->assoc_list[i].
           device_alias," location_cd = ",request->assoc_list[i].location_cd," device_cd = ",
           request->assoc_list[i].device_cd)
         ENDIF
        ELSE
         SET upd_association_id = 0.0
         SET upd_association_id = sub_update_badt(i)
         IF ((reply->assoc_list[i].status_flag=0))
          SET assoc_person_r_id = 0.0
          SET assoc_person_r_id = sub_insert_bapr(upd_association_id,i)
          IF (assoc_person_r_id > 0.0)
           SET reply->assoc_list[i].assoc_person_r_id = assoc_person_r_id
           SET status_flag = 0
           SET reply->assoc_list[i].association_id = upd_association_id
           SET status_flag = sub_format_cqmmessage(i)
           IF (status_flag=0)
            SET status_flag = bmdi_cqm_dnld(i)
            CALL echo(build("AFT2 CQM insert status_flag = ",status_flag))
            IF (status_flag > 0)
             IF (status_flag=1)
              SET reply->assoc_list[i].status_flag = 19
              SET reply->assoc_list[i].status_message = build(
               "Alternate device code not set for device_alias: ",request->assoc_list[i].device_alias
               )
             ELSEIF (status_flag=2)
              SET reply->assoc_list[i].status_flag = 20
              SET reply->assoc_list[i].status_message = build(
               "Association person identifier not set for associating device_alias: ",request->
               assoc_list[i].device_alias)
             ELSEIF (status_flag=3)
              SET reply->assoc_list[i].status_flag = 21
              SET reply->assoc_list[i].status_message = build(
               "Contributor config identifier not set for associating device_alias: ",request->
               assoc_list[i].device_alias)
             ELSEIF (status_flag=4)
              SET reply->assoc_list[i].status_flag = 22
              SET reply->assoc_list[i].status_message = build(
               "Error in getting database sequence number from cqm_queue_id_seq",request->assoc_list[
               i].device_alias)
             ELSEIF (status_flag=5)
              SET reply->assoc_list[i].status_flag = 23
              SET reply->assoc_list[i].status_message = build(
               "No insertion in CQM_gnlbdnld_que table")
             ELSEIF (status_flag=6)
              SET reply->assoc_list[i].status_flag = 24
              SET reply->assoc_list[i].status_message = build(
               "Listener identifier not set for associating device_alias: ",request->assoc_list[i].
               device_alias)
             ELSEIF (status_flag=7)
              SET reply->assoc_list[i].status_flag = 25
              SET reply->assoc_list[i].status_message = build(
               "Error in getting database sequence number from cqm_trigger_id_seq",request->
               assoc_list[i].device_alias)
             ELSEIF (status_flag=8)
              SET reply->assoc_list[i].status_flag = 26
              SET reply->assoc_list[i].status_message = build(
               "No insertion in CQM_gnlbdnld_tr_1 trigger table")
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ELSE
        SET reply->assoc_list[i].status_flag = 4
        SET reply->assoc_list[i].status_message = build(
         "More than one associated row exists for device_alias = ",request->assoc_list[i].
         device_alias," location_cd = ",request->assoc_list[i].location_cd," device_cd = ",
         request->assoc_list[i].device_cd)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 FOR (i = 1 TO size(reply->assoc_list,5))
   IF ((reply->assoc_list[i].status_flag > 0))
    SET failure = "R"
    SET error_message = reply->assoc_list[i].status_message
    GO TO get_data_failure
   ENDIF
 ENDFOR
 SUBROUTINE sub_update_badt(req_ind)
   FREE SET upd_badt_req
   RECORD upd_badt_req(
     1 upd_association_id = f8
     1 curr_updt_cnt = i4
   )
   FREE SET update_request
   RECORD update_request(
     1 statusupdate = i2
     1 ierrnum = i2
     1 serrmsg = vc
   )
   SELECT INTO "nl:"
    FROM bmdi_acquired_data_track badt,
     (dummyt d  WITH seq = value(req_ind))
    PLAN (d)
     JOIN (badt
     WHERE (badt.device_cd=reply->assoc_list[d.seq].device_cd)
      AND (badt.location_cd=request->assoc_list[d.seq].location_cd)
      AND badt.person_id=0.0
      AND badt.parent_entity_id=0.0)
    DETAIL
     upd_badt_req->upd_association_id = badt.association_id, request->assoc_list[d.seq].updt_cnt =
     badt.updt_cnt, upd_badt_req->curr_updt_cnt = badt.updt_cnt
    WITH nocounter, forupdate(badt)
   ;end select
   IF (curqual=0)
    SET reply->assoc_list[req_ind].status_flag = 5
    SET reply->assoc_list[req_ind].status_message = build(
     "Database row locked by another update process for device_alias = ",request->assoc_list[req_ind]
     .device_alias," location_cd = ",request->assoc_list[req_ind].location_cd," device_cd = ",
     reply->assoc_list[req_ind].device_cd," person_id = ",request->assoc_list[req_ind].person_id)
   ENDIF
   IF ((request->assoc_list[req_ind].updt_cnt != upd_badt_req->curr_updt_cnt))
    SET reply->assoc_list[req_ind].status_flag = 6
    SET reply->assoc_list[req_ind].status_message = build(
     "Database row updated by another process after getting query for device_alias = ",request->
     assoc_list[req_ind].device_alias," location_cd = ",request->assoc_list[req_ind].location_cd,
     " device_cd = ",
     reply->assoc_list[req_ind].device_cd," person_id = ",request->assoc_list[req_ind].person_id)
   ENDIF
   IF ((reply->assoc_list[req_ind].status_flag=0))
    UPDATE  FROM bmdi_acquired_data_track badt,
      (dummyt d  WITH seq = value(req_ind))
     SET badt.association_dt_tm = cnvtdatetime(curdate,curtime3), badt.person_id = request->
      assoc_list[d.seq].person_id, badt.active_ind = 1,
      badt.updt_dt_tm = cnvtdatetime(curdate,curtime3), badt.updt_cnt = (badt.updt_cnt+ 1), badt
      .updt_id = reqinfo->updt_id,
      badt.updt_task = reqinfo->updt_task, badt.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (badt
      WHERE (badt.association_id=upd_badt_req->upd_association_id))
     WITH status(update_request->statusupdate,update_request->ierrnum,update_request->serrmsg)
    ;end update
    IF (curqual=1)
     SET reply->assoc_list[req_ind].association_id = upd_badt_req->upd_association_id
    ENDIF
    IF (curqual=0)
     SET reply->statusupdate = update_request->statusupdate
     SET reply->ierrnum = update_request->ierrnum
     SET reply->serrmsg = update_request->serrmsg
     SET reply->assoc_list[req_ind].status_flag = 7
     SET reply->assoc_list[req_ind].status_message = build("Error during update for device_alias = ",
      request->assoc_list[req_ind].device_alias," location_cd = ",request->assoc_list[req_ind].
      location_cd," device_cd = ",
      request->assoc_list[req_ind].device_cd," person_id = ",request->assoc_list[req_ind].person_id,
      " ErrNum = ",update_request->ierrnum,
      " ErrMsg = ",update_request->serrmsg)
     IF (validate(error)=1)
      SET ierrcode = error(serrmsg,1)
     ELSE
      SET ierrcode = 0
     ENDIF
     SET failure = "U"
     GO TO get_data_failure
    ENDIF
   ENDIF
   RETURN(upd_badt_req->upd_association_id)
 END ;Subroutine
 SUBROUTINE sub_insert_bapr(upd_association_id,req_ind)
   SELECT INTO "nl:"
    nextseqnum = seq(bmdi_seq,nextval)"##################;RP0"
    FROM dual
    DETAIL
     insert_request->association_id = cnvtreal(nextseqnum)
    WITH nocounter
   ;end select
   SET insert_request->upd_dt_tm = cnvtdatetime(curdate,curtime3)
   SET insert_request->person_alias_type_cd = value(uar_get_code_by("MEANING",4,"MRN"))
   SET insert_request->person_alias = ""
   SET j = 0
   FOR (j = 1 TO value(size(request->assoc_list[req_ind].person_alias_list,5)))
     IF ((request->assoc_list[req_ind].person_alias_list[j].person_alias_type_cd=insert_request->
     person_alias_type_cd))
      SET insert_request->person_alias = request->assoc_list[req_ind].person_alias_list[j].alias
      SET j = value(size(request->assoc_list[req_ind].person_alias_list,5))
     ENDIF
   ENDFOR
   SET j = 0
   SET insert_request->encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
   SET insert_request->encntr_alias = ""
   FOR (j = 1 TO value(size(request->assoc_list[req_ind].encntr_alias_list,5)))
     IF ((request->assoc_list[req_ind].encntr_alias_list[j].encntr_alias_type_cd=insert_request->
     encntr_alias_type_cd))
      SET insert_request->encntr_alias = request->assoc_list[req_ind].encntr_alias_list[j].alias
      SET j = value(size(request->assoc_list[req_ind].encntr_alias_list,5))
     ENDIF
   ENDFOR
   IF ((insert_request->encntr_alias="")
    AND (insert_request->person_alias=""))
    SET reply->assoc_list[req_ind].status_flag = 28
    SET reply->assoc_list[req_ind].status_message = build(
     "person_alias MRN and encounter alias FIN NBR not present")
   ELSE
    INSERT  FROM bmdi_adt_person_r bapr,
      (dummyt d  WITH seq = value(req_ind))
     SET bapr.bmdi_adt_person_r_id = insert_request->association_id, bapr.association_id =
      upd_association_id, bapr.person_alias_type_cd = insert_request->person_alias_type_cd,
      bapr.person_alias = insert_request->person_alias, bapr.encntr_alias_type_cd = insert_request->
      encntr_alias_type_cd, bapr.encntr_alias = insert_request->encntr_alias,
      bapr.encntr_id = request->assoc_list[d.seq].encntr_id, bapr.person_name = request->assoc_list[d
      .seq].person_name, bapr.person_weight = request->assoc_list[d.seq].person_weight,
      bapr.weight_units_cd = request->assoc_list[d.seq].weight_units_cd, bapr.person_height = request
      ->assoc_list[d.seq].person_height, bapr.height_units_cd = request->assoc_list[d.seq].
      height_units_cd,
      bapr.person_gender_cd = request->assoc_list[d.seq].person_gender_cd, bapr.person_birth_dt_tm =
      cnvtdatetime(request->assoc_list[d.seq].person_birth_dt_tm), bapr.status_flag = 10,
      bapr.status_message = "PENDING - DEVICE HL7 DEMOGRAPHICS", bapr.association_prsnl_id = request
      ->assoc_list[d.seq].association_prsnl_id, bapr.active_ind = 1,
      bapr.updt_dt_tm = cnvtdatetime(insert_request->upd_dt_tm), bapr.updt_cnt = 0, bapr.updt_id =
      reqinfo->updt_id,
      bapr.updt_task = reqinfo->updt_task, bapr.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (bapr)
     WITH status(insert_request->statusinsert,insert_request->ierrnum,insert_request->serrmsg)
    ;end insert
    IF (curqual=0)
     SET reply->statusupdate = insert_request->statusinsert
     SET reply->ierrnum = insert_request->ierrnum
     SET reply->serrmsg = insert_request->serrmsg
     IF (validate(error)=1)
      SET ierrcode = error(serrmsg,1)
     ELSE
      SET ierrcode = 0
     ENDIF
     SET failure = "T"
     SET reply->assoc_list[req_ind].status_flag = 18
     SET reply->assoc_list[req_ind].status_message = insert_request->serrmsg
    ENDIF
   ENDIF
   RETURN(insert_request->association_id)
 END ;Subroutine
 SUBROUTINE sub_format_cqmmessage(req_ind)
   FREE SET ret_flag
   DECLARE ret_flag = i2 WITH private, noconstant(0)
   DECLARE patient_class = c2 WITH constant("I")
   SELECT INTO "nl:"
    FROM location_group lg,
     (dummyt d  WITH seq = value(req_ind))
    PLAN (d)
     JOIN (lg
     WHERE (lg.child_loc_cd=reply->assoc_list[d.seq].location_cd)
      AND lg.location_group_type_cd=roomtypecd
      AND ((lg.root_loc_cd+ 0)=0.0)
      AND lg.active_ind=1)
    DETAIL
     reply->assoc_list[d.seq].loc_room_cd = lg.parent_loc_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM location_group lg,
     (dummyt d  WITH seq = value(req_ind))
    PLAN (d)
     JOIN (lg
     WHERE (lg.child_loc_cd=reply->assoc_list[d.seq].loc_room_cd)
      AND lg.location_group_type_cd IN (unittypecd, ambulatorytypecd)
      AND ((lg.root_loc_cd+ 0)=0.0)
      AND lg.active_ind=1)
    DETAIL
     reply->assoc_list[d.seq].loc_unit_cd = lg.parent_loc_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM encounter e,
     (dummyt d  WITH seq = value(req_ind))
    PLAN (d)
     JOIN (e
     WHERE (e.encntr_id=reply->assoc_list[d.seq].encntr_id))
    DETAIL
     reply->assoc_list[d.seq].reg_dt_tm = e.reg_dt_tm
    WITH nocounter
   ;end select
   SET reply->assoc_list[req_ind].strmesg = concat(fillstring(27," "),reply->assoc_list[req_ind].
    strmesg,"MSH^0^10^1^0^",trim(cnvtstring(reply->assoc_list[req_ind].association_id)),
    "|PID^0^3^1^0^",
    trim(insert_request->person_alias),"\4^1^0^",trim(insert_request->encntr_alias),"\6^1^0^",trim(
     reply->assoc_list[req_ind].person_name_last),
    "\6^2^0^",trim(reply->assoc_list[req_ind].person_name_first),"\6^3^0^",trim(reply->assoc_list[
     req_ind].person_name_middle),"\8^1^0^",
    format(request->assoc_list[req_ind].person_birth_dt_tm,"YYYYMMDDHHMMSS;2;Q"),"\9^1^0^",substring(
     1,1,trim(uar_get_code_meaning(request->assoc_list[req_ind].person_gender_cd))),"|PV1^0^3^1^0^",
    trim(patient_class),
    "\4^1^0^",trim(uar_get_code_display(reply->assoc_list[req_ind].loc_unit_cd)),"\4^2^0^",trim(
     uar_get_code_display(reply->assoc_list[req_ind].loc_room_cd)),"\4^3^0^",
    trim(uar_get_code_display(reply->assoc_list[req_ind].location_cd)),"\20^1^0^",trim(cnvtstring(
      reply->assoc_list[req_ind].encntr_id)),"\45^1^0^",format(reply->assoc_list[req_ind].reg_dt_tm,
     "YYYYMMDDHHMMSS;2;Q"),
    "|OBX^1^4^1^1^","WEIGHT","\6^1^0^",request->assoc_list[req_ind].person_weight,"\7^1^0^",
    trim(uar_get_code_meaning(request->assoc_list[req_ind].weight_units_cd)),"|OBX^2^4^1^1^","HEIGHT",
    "\6^1^0^",request->assoc_list[req_ind].person_height,
    "\7^1^0^",trim(uar_get_code_meaning(request->assoc_list[req_ind].height_units_cd)),
    "|ZDL^0^3^1^0^",trim(request->assoc_list[req_ind].device_alias),"\4^1^0^",
    "AP","\5^1^0^",format(request->assoc_list[req_ind].association_dt_tm,"YYYYMMDDHHMMSS;2;Q"),
    "\6^1^0^",trim(cnvtstring(request->assoc_list[req_ind].association_prsnl_id)),
    char(04))
   CALL echo(build("size of strMesg = ",size(reply->assoc_list[req_ind].strmesg,4)))
   SET ret_flag = 0
   RETURN(ret_flag)
 END ;Subroutine
#get_data_failure
 IF (failure="R")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "REQUEST"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_assoc_device"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_message
  GO TO exit_script
 ELSEIF (failure="T")
  IF (ierrcode > 0)
   SET stat = alter(reply->status_data.subeventstatus,2)
  ELSE
   SET stat = alter(reply->status_data.subeventstatus,1)
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_assoc_device"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Data Addition failed for bmdi_ADT_person_r!"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ELSEIF (failure="U")
  IF (ierrcode > 0)
   SET stat = alter(reply->status_data.subeventstatus,1)
  ELSE
   SET stat = alter(reply->status_data.subeventstatus,1)
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_assoc_device"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Data Update failed for bmdi_acquired_data_track!"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
#exit_script
 IF (((failure="T") OR (failure="U")) )
  IF (ierrcode > 0)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
  ROLLBACK
  SET reqinfo->commit_ind = 0
 ELSEIF (failure="R")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  COMMIT
 ENDIF
END GO
