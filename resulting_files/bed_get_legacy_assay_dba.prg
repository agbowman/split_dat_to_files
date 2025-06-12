CREATE PROGRAM bed_get_legacy_assay:dba
 FREE SET reply
 RECORD reply(
   1 assay_list[*]
     2 dta_id = f8
     2 facility = vc
     2 display = c40
     2 description = c60
     2 result_type = c30
     2 data_map[*]
       3 service_resource_display = vc
       3 min_digits = i4
       3 max_digits = i4
       3 dec_place = i4
     2 rr_list[*]
       3 def_value = f8
       3 uom_display = c40
       3 from_age = i4
       3 from_age_unit_display = c40
       3 to_age = i4
       3 to_age_unit_display = c40
       3 unknown_age_ind = i2
       3 sex_code_value = f8
       3 sex_display = c40
       3 service_resource_display = c40
       3 ref_low = f8
       3 ref_high = f8
       3 ref_ind = i2
       3 crit_low = f8
       3 crit_high = f8
       3 crit_ind = i2
       3 review_low = f8
       3 review_high = f8
       3 review_ind = i2
       3 linear_low = f8
       3 linear_high = f8
       3 linear_ind = i2
       3 dilute_ind = i2
       3 feasible_low = f8
       3 feasible_high = f8
       3 feasible_ind = i2
       3 alpha_list[*]
         4 display = c40
         4 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 SET dta_cnt = 0
 SET dta_cnt = size(request->assay_list,5)
 SET load_alpha_responses = 0
 SET wcard = "*"
 DECLARE searchparse = vc
 IF (trim(request->search_txt) > " ")
  IF ((request->search_type_flag="S"))
   SET searchparse = concat("(cnvtupper(b.short_desc) = '",trim(cnvtupper(request->search_txt)),wcard,
    "' or ","cnvtupper(b.long_desc) = '",
    trim(cnvtupper(request->search_txt)),wcard,"')")
  ELSE
   SET searchparse = concat("(cnvtupper(b.short_desc) = '",wcard,trim(cnvtupper(request->search_txt)),
    wcard,"' or ",
    "cnvtupper(b.long_desc) = '",wcard,trim(cnvtupper(request->search_txt)),wcard,"')")
  ENDIF
 ENDIF
 DECLARE resultparse = vc
 SET type_cnt = 0
 SET type_cnt = size(request->result_list,5)
 IF (type_cnt > 0
  AND (request->result_list[1].result_type > "   "))
  FOR (i = 1 TO type_cnt)
   IF (cnvtupper(request->result_list[i].result_type)="ALPHA")
    SET load_alpha_responses = 1
   ENDIF
   IF (i=1)
    SET resultparse = concat("(cnvtupper(b.result_type) = '",cnvtupper(trim(request->result_list[i].
       result_type)),"'")
   ELSE
    SET resultparse = concat(resultparse," or cnvtupper(b.result_type) = '",cnvtupper(trim(request->
       result_list[i].result_type)),"'")
   ENDIF
  ENDFOR
  SET resultparse = concat(resultparse,")")
  IF (load_alpha_responses=1)
   SET resultparse = "(cnvtupper(b.result_type) = '*')"
  ENDIF
  IF (searchparse > " ")
   SET searchparse = concat(searchparse," and ",resultparse)
  ELSE
   SET searchparse = concat(resultparse)
  ENDIF
 ENDIF
 SET stat = alterlist(reply->assay_list,100)
 SET count = 0
 SET tot_count = 0
 SET rrf_count = 0
 SET rrf_tot_count = 0
 SET dm_count = 0
 SET dm_tot_count = 0
 SET ar_count = 0
 SET ar_tot_count = 0
 SET male_code_value = 0.0
 SET female_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=57
   AND cv.active_ind=1
   AND ((cv.cdf_meaning="FEMALE") OR (cv.cdf_meaning="MALE"))
  DETAIL
   IF (cv.cdf_meaning="MALE")
    male_code_value = cv.code_value
   ELSE
    female_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO dta_cnt)
   IF ((request->assay_list[tot_count].dta_id > 0))
    SELECT INTO "NL:"
     FROM br_dta_work b,
      br_dta_rrf brrf,
      br_dta_alpha_responses bdar,
      br_legacy_sr bsr
     PLAN (b
      WHERE (b.dta_id=request->assay_list[x].dta_id))
      JOIN (brrf
      WHERE brrf.dta_id=b.dta_id)
      JOIN (bsr
      WHERE bsr.service_resource=brrf.service_resource
       AND bsr.active_ind=1)
      JOIN (bdar
      WHERE bdar.rrf_id=outerjoin(brrf.rrf_id))
     ORDER BY brrf.sex DESC
     HEAD b.dta_id
      tot_count = (tot_count+ 1), count = (count+ 1)
      IF (count > 100)
       stat = alterlist(reply->assay_list,(tot_count+ 100)), count = 1
      ENDIF
      reply->assay_list[tot_count].dta_id = b.dta_id, reply->assay_list[tot_count].facility = b
      .facility, reply->assay_list[tot_count].display = b.short_desc,
      reply->assay_list[tot_count].description = b.long_desc, reply->assay_list[tot_count].
      result_type = b.result_type, rrf_tot_count = 0,
      rrf_count = 0, stat = alterlist(reply->assay_list[tot_count].rr_list,20)
     HEAD brrf.rrf_id
      rrf_tot_count = (rrf_tot_count+ 1), rrf_count = (rrf_count+ 1)
      IF (rrf_count > 20)
       stat = alterlist(reply->assay_list[tot_count].rr_list,(rrf_tot_count+ 20)), rrf_count = 1
      ENDIF
      reply->assay_list[tot_count].rr_list[rrf_tot_count].uom_display = brrf.uom, reply->assay_list[
      tot_count].rr_list[rrf_tot_count].from_age = brrf.age_from, reply->assay_list[tot_count].
      rr_list[rrf_tot_count].from_age_unit_display = brrf.age_from_units,
      reply->assay_list[tot_count].rr_list[rrf_tot_count].to_age = brrf.age_to, reply->assay_list[
      tot_count].rr_list[rrf_tot_count].to_age_unit_display = brrf.age_to_units, reply->assay_list[
      tot_count].rr_list[rrf_tot_count].sex_display = brrf.sex
      IF (((brrf.sex="M*") OR (brrf.sex="m*")) )
       reply->assay_list[tot_count].rr_list[rrf_tot_count].sex_code_value = male_code_value
      ELSE
       reply->assay_list[tot_count].rr_list[rrf_tot_count].sex_code_value = female_code_value
      ENDIF
      reply->assay_list[tot_count].rr_list[rrf_tot_count].ref_low = brrf.normal_low, reply->
      assay_list[tot_count].rr_list[rrf_tot_count].ref_high = brrf.normal_high, reply->assay_list[
      tot_count].rr_list[rrf_tot_count].ref_ind = brrf.normal_ind,
      reply->assay_list[tot_count].rr_list[rrf_tot_count].crit_low = brrf.critical_low, reply->
      assay_list[tot_count].rr_list[rrf_tot_count].crit_high = brrf.critical_high, reply->assay_list[
      tot_count].rr_list[rrf_tot_count].crit_ind = brrf.critical_ind,
      reply->assay_list[tot_count].rr_list[rrf_tot_count].review_low = brrf.review_low, reply->
      assay_list[tot_count].rr_list[rrf_tot_count].review_high = brrf.review_high, reply->assay_list[
      tot_count].rr_list[rrf_tot_count].review_ind = brrf.review_ind,
      reply->assay_list[tot_count].rr_list[rrf_tot_count].linear_low = brrf.linear_low, reply->
      assay_list[tot_count].rr_list[rrf_tot_count].linear_high = brrf.linear_high, reply->assay_list[
      tot_count].rr_list[rrf_tot_count].linear_ind = brrf.linear_ind,
      reply->assay_list[tot_count].rr_list[rrf_tot_count].dilute_ind = brrf.dilute_ind, reply->
      assay_list[tot_count].rr_list[rrf_tot_count].feasible_low = brrf.feasible_low, reply->
      assay_list[tot_count].rr_list[rrf_tot_count].feasible_high = brrf.feasible_high,
      reply->assay_list[tot_count].rr_list[rrf_tot_count].feasible_ind = brrf.feasible_ind, reply->
      assay_list[tot_count].rr_list[rrf_tot_count].service_resource_display = brrf.service_resource,
      reply->assay_list[tot_count].rr_list[rrf_tot_count].unknown_age_ind = brrf.unknown_age_ind,
      ar_count = 0, ar_tot_count = 0
     DETAIL
      IF (bdar.rrf_id > 0)
       IF (ar_count=0)
        stat = alterlist(reply->assay_list[tot_count].rr_list[rrf_tot_count].alpha_list,10)
       ENDIF
       ar_tot_count = (ar_tot_count+ 1), ar_count = (ar_count+ 1)
       IF (ar_count > 10)
        stat = alterlist(reply->assay_list[tot_count].rr_list[rrf_tot_count].alpha_list,(ar_tot_count
         + 10)), ar_count = 1
       ENDIF
       reply->assay_list[tot_count].rr_list[rrf_tot_count].alpha_list[ar_tot_count].display = bdar.ar,
       reply->assay_list[tot_count].rr_list[rrf_tot_count].alpha_list[ar_tot_count].sequence = bdar
       .sequence
      ENDIF
     FOOT  brrf.rrf_id
      stat = alterlist(reply->assay_list[tot_count].rr_list[rrf_tot_count].alpha_list,ar_tot_count)
     FOOT  b.dta_id
      stat = alterlist(reply->assay_list[tot_count].rr_list,rrf_tot_count)
     WITH nocounter
    ;end select
    SET dm_count = 0
    SET dm_tot_count = 0
    SET stat = alterlist(reply->assay_list[tot_count].data_map,5)
    SELECT INTO "NL:"
     FROM br_dta_data_map bddm
     PLAN (bddm
      WHERE (bddm.dta_id=request->assay_list[tot_count].dta_id))
     DETAIL
      dm_tot_count = (dm_tot_count+ 1), dm_count = (dm_count+ 1)
      IF (dm_count > 5)
       stat = alterlist(reply->assay_list[tot_count].data_map,(dm_tot_count+ 5)), dm_count = 1
      ENDIF
      reply->assay_list[tot_count].data_map[dm_tot_count].service_resource_display = bddm
      .service_resource, reply->assay_list[tot_count].data_map[dm_tot_count].min_digits = bddm
      .min_digits, reply->assay_list[tot_count].data_map[dm_tot_count].max_digits = bddm.max_digits,
      reply->assay_list[tot_count].data_map[dm_tot_count].dec_place = bddm.min_decimal_places
     WITH nocounter
    ;end select
    SET stat = alterlist(reply->assay_list[tot_count].data_map,dm_tot_count)
   ENDIF
 ENDFOR
 CALL echo(searchparse)
 IF (((searchparse > "  *") OR (load_alpha_responses=1)) )
  IF (load_alpha_responses=0)
   SELECT INTO "NL:"
    FROM br_dta_work b,
     br_dta_rrf brrf,
     br_legacy_sr bsr
    PLAN (b
     WHERE parser(searchparse))
     JOIN (brrf
     WHERE brrf.dta_id=b.dta_id)
     JOIN (bsr
     WHERE bsr.service_resource=brrf.service_resource
      AND bsr.active_ind=1)
    ORDER BY b.dta_id, brrf.rrf_id, brrf.service_resource
    HEAD b.dta_id
     tot_count = (tot_count+ 1), count = (count+ 1)
     IF (count > 100)
      stat = alterlist(reply->assay_list,(tot_count+ 100)), count = 1
     ENDIF
     reply->assay_list[tot_count].dta_id = b.dta_id, reply->assay_list[tot_count].facility = b
     .facility, reply->assay_list[tot_count].display = b.short_desc,
     reply->assay_list[tot_count].description = b.long_desc, reply->assay_list[tot_count].result_type
      = b.result_type
    FOOT REPORT
     stat = alterlist(reply->assay_list,tot_count)
    WITH nocounter
   ;end select
   FOR (i = 1 TO tot_count)
     SET dm_count = 0
     SET dm_tot_count = 0
     SELECT INTO "NL:"
      FROM br_dta_data_map bddm,
       br_legacy_sr bsr
      PLAN (bddm
       WHERE (bddm.dta_id=reply->assay_list[i].dta_id))
       JOIN (bsr
       WHERE bsr.service_resource=bddm.service_resource
        AND bsr.active_ind=1)
      DETAIL
       IF (dm_tot_count=0)
        stat = alterlist(reply->assay_list[i].data_map,5)
       ENDIF
       dm_tot_count = (dm_tot_count+ 1), dm_count = (dm_count+ 1)
       IF (dm_count > 5)
        stat = alterlist(reply->assay_list[i].data_map,(dm_tot_count+ 5)), dm_count = 1
       ENDIF
       reply->assay_list[i].data_map[dm_tot_count].service_resource_display = bddm.service_resource,
       reply->assay_list[i].data_map[dm_tot_count].min_digits = bddm.min_digits, reply->assay_list[i]
       .data_map[dm_tot_count].max_digits = bddm.max_digits,
       reply->assay_list[i].data_map[dm_tot_count].dec_place = bddm.min_decimal_places
      FOOT REPORT
       stat = alterlist(reply->assay_list[i].data_map,dm_tot_count)
      WITH nocounter
     ;end select
   ENDFOR
  ELSE
   SELECT INTO "NL:"
    FROM br_dta_work b,
     br_dta_rrf brrf,
     br_dta_alpha_responses bdar,
     br_legacy_sr bsr
    PLAN (b
     WHERE parser(searchparse))
     JOIN (brrf
     WHERE brrf.dta_id=b.dta_id)
     JOIN (bdar
     WHERE bdar.rrf_id=brrf.rrf_id)
     JOIN (bsr
     WHERE bsr.service_resource=brrf.service_resource
      AND bsr.active_ind=1)
    ORDER BY b.dta_id, brrf.sex, brrf.rrf_id
    HEAD b.dta_id
     tot_count = (tot_count+ 1), count = (count+ 1)
     IF (count > 100)
      stat = alterlist(reply->assay_list,(tot_count+ 100)), count = 1
     ENDIF
     reply->assay_list[tot_count].dta_id = b.dta_id, reply->assay_list[tot_count].facility = b
     .facility, reply->assay_list[tot_count].display = b.short_desc,
     reply->assay_list[tot_count].description = b.long_desc, reply->assay_list[tot_count].result_type
      = b.result_type, rrf_tot_count = 0,
     rrf_count = 0, stat = alterlist(reply->assay_list[tot_count].rr_list,20)
    HEAD brrf.rrf_id
     rrf_tot_count = (rrf_tot_count+ 1), rrf_count = (rrf_count+ 1)
     IF (rrf_count > 20)
      stat = alterlist(reply->assay_list[tot_count].rr_list,(rrf_tot_count+ 20)), rrf_count = 1
     ENDIF
     reply->assay_list[tot_count].rr_list[rrf_tot_count].uom_display = brrf.uom, reply->assay_list[
     tot_count].rr_list[rrf_tot_count].from_age = brrf.age_from, reply->assay_list[tot_count].
     rr_list[rrf_tot_count].from_age_unit_display = brrf.age_from_units,
     reply->assay_list[tot_count].rr_list[rrf_tot_count].to_age = brrf.age_to, reply->assay_list[
     tot_count].rr_list[rrf_tot_count].to_age_unit_display = brrf.age_to_units, reply->assay_list[
     tot_count].rr_list[rrf_tot_count].sex_display = brrf.sex
     IF (((brrf.sex="M*") OR (brrf.sex="m*")) )
      reply->assay_list[tot_count].rr_list[rrf_tot_count].sex_code_value = male_code_value
     ELSE
      reply->assay_list[tot_count].rr_list[rrf_tot_count].sex_code_value = female_code_value
     ENDIF
     reply->assay_list[tot_count].rr_list[rrf_tot_count].ref_low = brrf.normal_low, reply->
     assay_list[tot_count].rr_list[rrf_tot_count].ref_high = brrf.normal_high, reply->assay_list[
     tot_count].rr_list[rrf_tot_count].ref_ind = brrf.normal_ind,
     reply->assay_list[tot_count].rr_list[rrf_tot_count].crit_low = brrf.critical_low, reply->
     assay_list[tot_count].rr_list[rrf_tot_count].crit_high = brrf.critical_high, reply->assay_list[
     tot_count].rr_list[rrf_tot_count].crit_ind = brrf.critical_ind,
     reply->assay_list[tot_count].rr_list[rrf_tot_count].review_low = brrf.review_low, reply->
     assay_list[tot_count].rr_list[rrf_tot_count].review_high = brrf.review_high, reply->assay_list[
     tot_count].rr_list[rrf_tot_count].review_ind = brrf.review_ind,
     reply->assay_list[tot_count].rr_list[rrf_tot_count].linear_low = brrf.linear_low, reply->
     assay_list[tot_count].rr_list[rrf_tot_count].linear_high = brrf.linear_high, reply->assay_list[
     tot_count].rr_list[rrf_tot_count].linear_ind = brrf.linear_ind,
     reply->assay_list[tot_count].rr_list[rrf_tot_count].dilute_ind = brrf.dilute_ind, reply->
     assay_list[tot_count].rr_list[rrf_tot_count].feasible_low = brrf.feasible_low, reply->
     assay_list[tot_count].rr_list[rrf_tot_count].feasible_high = brrf.feasible_high,
     reply->assay_list[tot_count].rr_list[rrf_tot_count].feasible_ind = brrf.feasible_ind, reply->
     assay_list[tot_count].rr_list[rrf_tot_count].service_resource_display = brrf.service_resource,
     reply->assay_list[tot_count].rr_list[rrf_tot_count].unknown_age_ind = brrf.unknown_age_ind,
     ar_count = 0, ar_tot_count = 0, stat = alterlist(reply->assay_list[tot_count].rr_list[
      rrf_tot_count].alpha_list,10)
    DETAIL
     ar_tot_count = (ar_tot_count+ 1), ar_count = (ar_count+ 1)
     IF (ar_count > 10)
      stat = alterlist(reply->assay_list[tot_count].rr_list[rrf_tot_count].alpha_list,(ar_tot_count+
       10)), ar_count = 1
     ENDIF
     reply->assay_list[tot_count].rr_list[rrf_tot_count].alpha_list[ar_tot_count].display = bdar.ar,
     reply->assay_list[tot_count].rr_list[rrf_tot_count].alpha_list[ar_tot_count].sequence = bdar
     .sequence
    FOOT  brrf.rrf_id
     stat = alterlist(reply->assay_list[tot_count].rr_list[rrf_tot_count].alpha_list,ar_tot_count)
    FOOT  b.dta_id
     stat = alterlist(reply->assay_list[tot_count].rr_list,rrf_tot_count)
    FOOT REPORT
     stat = alterlist(reply->assay_list,tot_count)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#enditnow
 SET stat = alterlist(reply->assay_list,tot_count)
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
