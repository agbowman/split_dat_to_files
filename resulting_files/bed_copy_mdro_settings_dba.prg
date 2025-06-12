CREATE PROGRAM bed_copy_mdro_settings:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD delrequest(
   1 facilities[*]
     2 facility_cd = f8
 )
 RECORD delreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD tempevents(
   1 events[*]
     2 br_mdro_cat_id = f8
     2 event_cd = f8
     2 br_mdro_cat_event_id = f8
     2 normalcy_codes[*]
       3 normalcy_cd = f8
     2 br_mdro_id = f8
     2 lookback_time_span_nbr = i4
     2 lookback_time_span_unit_cd = f8
 )
 RECORD temporganisms(
   1 organisms[*]
     2 br_mdro_cat_id = f8
     2 group_resistant_cnt = i4
     2 organism_cd = f8
     2 br_mdro_cat_organism_id = f8
     2 antibiotics_txt = vc
     2 drug_groups[*]
       3 br_drug_group_id = f8
       3 br_drug_group_organism_id = f8
       3 drug_resistant_cnt = i4
       3 drugs[*]
         4 antibiotic_cd = f8
         4 br_drug_group_antibiotic_id = f8
         4 interp[*]
           5 interp_result_cd = f8
     2 br_mdro_id = f8
     2 lookback_time_span_nbr = i4
     2 lookback_time_span_unit_cd = f8
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE fac_cnt = i4 WITH protect, noconstant(0)
 DECLARE org_cnt = i4 WITH protect, noconstant(0)
 DECLARE dgo_cnt = i4 WITH protect, noconstant(0)
 DECLARE dg_cnt = i4 WITH protect, noconstant(0)
 DECLARE int_cnt = i4 WITH protect, noconstant(0)
 SET fac_cnt = size(request->to_facilities,5)
 SET stat = alterlist(delrequest->facilities,fac_cnt)
 IF (fac_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = fac_cnt)
  DETAIL
   delrequest->facilities[d.seq].facility_cd = request->to_facilities[d.seq].facility_cd
  WITH nocounter
 ;end select
 EXECUTE bed_del_mdro_settings  WITH replace("REQUEST",delrequest), replace("REPLY",delreply)
 IF ((delreply->status_data.status="F"))
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname =
  "Failure returned from bed_del_mdro_settings"
  GO TO exit_script
 ENDIF
 SET event_cnt = 0
 SELECT INTO "nl:"
  FROM br_mdro_cat_event e
  WHERE (e.location_cd=request->from_facility_cd)
  DETAIL
   event_cnt = (event_cnt+ 1), stat = alterlist(tempevents->events,event_cnt), tempevents->events[
   event_cnt].br_mdro_cat_id = e.br_mdro_cat_id,
   tempevents->events[event_cnt].event_cd = e.event_cd, tempevents->events[event_cnt].
   br_mdro_cat_event_id = e.br_mdro_cat_event_id, tempevents->events[event_cnt].br_mdro_id = e
   .br_mdro_id,
   tempevents->events[event_cnt].lookback_time_span_nbr = e.lookback_time_span_nbr, tempevents->
   events[event_cnt].lookback_time_span_unit_cd = e.lookback_time_span_unit_cd
  WITH nocounter
 ;end select
 IF (event_cnt > 0)
  SET norm_cnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = event_cnt),
    br_cat_event_normalcy cen
   PLAN (d)
    JOIN (cen
    WHERE (cen.br_mdro_cat_event_id=tempevents->events[d.seq].br_mdro_cat_event_id))
   HEAD d.seq
    norm_cnt = 0
   DETAIL
    norm_cnt = (norm_cnt+ 1), stat = alterlist(tempevents->events[d.seq].normalcy_codes,norm_cnt),
    tempevents->events[d.seq].normalcy_codes[norm_cnt].normalcy_cd = cen.normalcy_cd
   WITH nocounter
  ;end select
 ENDIF
 SET org_cnt = 0
 SELECT INTO "nl:"
  FROM br_mdro_cat_organism o
  WHERE (o.location_cd=request->from_facility_cd)
  DETAIL
   org_cnt = (org_cnt+ 1), stat = alterlist(temporganisms->organisms,org_cnt), temporganisms->
   organisms[org_cnt].br_mdro_cat_id = o.br_mdro_cat_id,
   temporganisms->organisms[org_cnt].group_resistant_cnt = o.group_resistant_cnt, temporganisms->
   organisms[org_cnt].organism_cd = o.organism_cd, temporganisms->organisms[org_cnt].
   br_mdro_cat_organism_id = o.br_mdro_cat_organism_id,
   temporganisms->organisms[org_cnt].br_mdro_id = o.br_mdro_id, temporganisms->organisms[org_cnt].
   antibiotics_txt = o.antibiotics_txt, temporganisms->organisms[org_cnt].lookback_time_span_nbr = o
   .lookback_time_span_nbr,
   temporganisms->organisms[org_cnt].lookback_time_span_unit_cd = o.lookback_time_span_unit_cd
  WITH nocounter
 ;end select
 IF (org_cnt > 0)
  SET int_cnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = org_cnt),
    br_drug_group_organism dgo
   PLAN (d)
    JOIN (dgo
    WHERE (dgo.br_mdro_cat_organism_id=temporganisms->organisms[d.seq].br_mdro_cat_organism_id))
   ORDER BY d.seq, dgo.br_drug_group_id
   HEAD d.seq
    dgo_cnt = 0
   HEAD dgo.br_drug_group_id
    dgo_cnt = (dgo_cnt+ 1), stat = alterlist(temporganisms->organisms[d.seq].drug_groups,dgo_cnt),
    temporganisms->organisms[d.seq].drug_groups[dgo_cnt].br_drug_group_id = dgo.br_drug_group_id,
    temporganisms->organisms[d.seq].drug_groups[dgo_cnt].br_drug_group_organism_id = dgo
    .br_drug_group_organism_id, temporganisms->organisms[d.seq].drug_groups[dgo_cnt].
    drug_resistant_cnt = dgo.drug_resistant_cnt
   WITH nocounter
  ;end select
  CALL bederrorcheck("Drug Group Selection Failure")
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = org_cnt),
    (dummyt d2  WITH seq = 0),
    br_drug_group_antibiotic dga
   PLAN (d1
    WHERE maxrec(d2,size(temporganisms->organisms[d1.seq].drug_groups,5)))
    JOIN (d2)
    JOIN (dga
    WHERE (dga.br_drug_group_id=temporganisms->organisms[d1.seq].drug_groups[d2.seq].br_drug_group_id
    ))
   ORDER BY d1.seq, d2.seq, dga.br_drug_group_id,
    dga.antibiotic_cd
   HEAD d1.seq
    dg_cnt = 0
   HEAD d2.seq
    dg_cnt = 0
   HEAD dga.antibiotic_cd
    dg_cnt = (dg_cnt+ 1), stat = alterlist(temporganisms->organisms[d1.seq].drug_groups[d2.seq].drugs,
     dg_cnt), temporganisms->organisms[d1.seq].drug_groups[d2.seq].drugs[dg_cnt].antibiotic_cd = dga
    .antibiotic_cd,
    temporganisms->organisms[d1.seq].drug_groups[d2.seq].drugs[dg_cnt].br_drug_group_antibiotic_id =
    dga.br_drug_group_antibiotic_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("Drug Selection Failure")
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = org_cnt),
    (dummyt d2  WITH seq = 0),
    (dummyt d3  WITH seq = 0),
    br_organism_drug_result odr
   PLAN (d1
    WHERE maxrec(d2,size(temporganisms->organisms[d1.seq].drug_groups,5)))
    JOIN (d2
    WHERE maxrec(d3,size(temporganisms->organisms[d1.seq].drug_groups[d2.seq].drugs,5)))
    JOIN (d3)
    JOIN (odr
    WHERE (odr.br_drug_group_organism_id=temporganisms->organisms[d1.seq].drug_groups[d2.seq].
    br_drug_group_organism_id)
     AND (odr.br_drug_group_antibiotic_id=temporganisms->organisms[d1.seq].drug_groups[d2.seq].drugs[
    d3.seq].br_drug_group_antibiotic_id))
   ORDER BY d1.seq, d2.seq, d3.seq,
    odr.br_drug_group_organism_id, odr.br_drug_group_antibiotic_id, odr.result_cd
   HEAD d1.seq
    int_cnt = 0
   HEAD d2.seq
    int_cnt = 0
   HEAD d3.seq
    int_cnt = 0
   HEAD odr.result_cd
    int_cnt = (int_cnt+ 1), stat = alterlist(temporganisms->organisms[d1.seq].drug_groups[d2.seq].
     drugs[d3.seq].interp,int_cnt), temporganisms->organisms[d1.seq].drug_groups[d2.seq].drugs[d3.seq
    ].interp[int_cnt].interp_result_cd = odr.result_cd
   WITH nocounter
  ;end select
  CALL bederrorcheck("Drug Selection Failure")
 ENDIF
 FOR (i = 1 TO org_cnt)
   FOR (j = 1 TO fac_cnt)
     SET cato_id = 0.0
     SELECT INTO "nl:"
      temp = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       cato_id = cnvtreal(temp)
      WITH nocounter
     ;end select
     SET ierrcode = 0
     INSERT  FROM br_mdro_cat_organism cat_o
      SET cat_o.br_mdro_cat_organism_id = cato_id, cat_o.organism_cd = temporganisms->organisms[i].
       organism_cd, cat_o.br_mdro_cat_id = temporganisms->organisms[i].br_mdro_cat_id,
       cat_o.group_resistant_cnt = temporganisms->organisms[i].group_resistant_cnt, cat_o
       .antibiotics_txt = temporganisms->organisms[i].antibiotics_txt, cat_o.lookback_time_span_nbr
        = temporganisms->organisms[i].lookback_time_span_nbr,
       cat_o.lookback_time_span_unit_cd = temporganisms->organisms[i].lookback_time_span_unit_cd,
       cat_o.updt_cnt = 0, cat_o.updt_id = reqinfo->updt_id,
       cat_o.updt_dt_tm = cnvtdatetime(curdate,curtime), cat_o.updt_task = reqinfo->updt_task, cat_o
       .updt_applctx = reqinfo->updt_applctx,
       cat_o.location_cd = request->to_facilities[j].facility_cd, cat_o.br_mdro_id = temporganisms->
       organisms[i].br_mdro_id
      PLAN (cat_o)
      WITH nocounter
     ;end insert
     CALL bederrorcheck(concat("Error on Inserting Organism Value",trim(cnvtstring(temporganisms->
         organisms[i].organism_cd)),"."))
     FOR (k = 1 TO size(temporganisms->organisms[i].drug_groups,5))
       SET dgo_id = 0.0
       SELECT INTO "nl:"
        temp = seq(bedrock_seq,nextval)
        FROM dual
        DETAIL
         dgo_id = cnvtreal(temp)
        WITH nocounter
       ;end select
       SET ierrcode = 0
       INSERT  FROM br_drug_group_organism dgo
        SET dgo.br_drug_group_organism_id = dgo_id, dgo.br_mdro_cat_organism_id = cato_id, dgo
         .br_drug_group_id = temporganisms->organisms[i].drug_groups[k].br_drug_group_id,
         dgo.drug_resistant_cnt = temporganisms->organisms[i].drug_groups[k].drug_resistant_cnt, dgo
         .updt_cnt = 0, dgo.updt_id = reqinfo->updt_id,
         dgo.updt_dt_tm = cnvtdatetime(curdate,curtime), dgo.updt_task = reqinfo->updt_task, dgo
         .updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       CALL bederrorcheck(concat("Error on Inserting Drug groups for the Organism:",trim(cnvtstring(
           temporganisms->organisms[i].organism_cd)),"."))
       FOR (l = 1 TO size(temporganisms->organisms[i].drug_groups[k].drugs,5))
         FOR (m = 1 TO size(temporganisms->organisms[i].drug_groups[k].drugs[l].interp,5))
           SET int_id = 0.0
           SELECT INTO "nl:"
            temp = seq(bedrock_seq,nextval)
            FROM dual
            DETAIL
             int_id = cnvtreal(temp)
            WITH nocounter
           ;end select
           SET antibiotic_id = 0.0
           INSERT  FROM br_organism_drug_result odr
            SET odr.br_organism_drug_result_id = int_id, odr.br_drug_group_organism_id = dgo_id, odr
             .br_drug_group_antibiotic_id = temporganisms->organisms[i].drug_groups[k].drugs[l].
             br_drug_group_antibiotic_id,
             odr.result_cd = temporganisms->organisms[i].drug_groups[k].drugs[l].interp[m].
             interp_result_cd, odr.updt_cnt = 0, odr.updt_id = reqinfo->updt_id,
             odr.updt_dt_tm = cnvtdatetime(curdate,curtime), odr.updt_task = reqinfo->updt_task, odr
             .updt_applctx = reqinfo->updt_applctx
            WITH nocounter
           ;end insert
           CALL bederrorcheck(concat("Error on Inserting Interpretation Results for the Organism:",
             trim(cnvtstring(temporganisms->organisms[i].organism_cd)),"."))
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 FOR (i = 1 TO event_cnt)
   FOR (j = 1 TO fac_cnt)
     SET cate_id = 0.0
     SELECT INTO "nl:"
      temp = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       cate_id = cnvtreal(temp)
      WITH nocounter
     ;end select
     SET ierrcode = 0
     INSERT  FROM br_mdro_cat_event cat_e
      SET cat_e.br_mdro_cat_event_id = cate_id, cat_e.event_cd = tempevents->events[i].event_cd,
       cat_e.br_mdro_cat_id = tempevents->events[i].br_mdro_cat_id,
       cat_e.lookback_time_span_nbr = tempevents->events[i].lookback_time_span_nbr, cat_e
       .lookback_time_span_unit_cd = tempevents->events[i].lookback_time_span_unit_cd, cat_e.updt_cnt
        = 0,
       cat_e.updt_id = reqinfo->updt_id, cat_e.updt_dt_tm = cnvtdatetime(curdate,curtime), cat_e
       .updt_task = reqinfo->updt_task,
       cat_e.updt_applctx = reqinfo->updt_applctx, cat_e.location_cd = request->to_facilities[j].
       facility_cd, cat_e.br_mdro_id = tempevents->events[i].br_mdro_id
      PLAN (cat_e)
      WITH nocounter
     ;end insert
     CALL bederrorcheck(concat("Error on Inserting Event Value",trim(cnvtstring(tempevents->events[i]
         .event_cd)),"."))
     FOR (k = 1 TO size(tempevents->events[i].normalcy_codes,5))
       SET cen_id = 0.0
       SELECT INTO "nl:"
        temp = seq(bedrock_seq,nextval)
        FROM dual
        DETAIL
         cen_id = cnvtreal(temp)
        WITH nocounter
       ;end select
       SET ierrcode = 0
       INSERT  FROM br_cat_event_normalcy cen
        SET cen.br_cat_event_normalcy_id = cen_id, cen.br_mdro_cat_event_id = cate_id, cen
         .normalcy_cd = tempevents->events[i].normalcy_codes[k].normalcy_cd,
         cen.updt_cnt = 0, cen.updt_id = reqinfo->updt_id, cen.updt_dt_tm = cnvtdatetime(curdate,
          curtime),
         cen.updt_task = reqinfo->updt_task, cen.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       CALL bederrorcheck(concat(
         "Error on Inserting normalcy codes for the Serology Results/Event code:",trim(cnvtstring(
           tempevents->events[i].event_cd)),"."))
     ENDFOR
   ENDFOR
 ENDFOR
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 CALL echorecord(reply)
END GO
