CREATE PROGRAM bed_get_facs_from_oc_match:dba
 FREE SET reply
 RECORD reply(
   1 facilities[*]
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 facilities[*]
     2 display = vc
     2 oc_match_ind = i2
 )
 SET reply->status_data.status = "F"
 SET fcnt = 0
 SELECT DISTINCT INTO "NL:"
  FROM br_oc_work bow
  PLAN (bow
   WHERE bow.match_orderable_cd > 0
    AND ((bow.alias1 > " ") OR (((bow.alias2 > " ") OR (((bow.alias3 > " ") OR (((bow.alias4 > " ")
    OR (bow.alias5 > " ")) )) )) )) )
  ORDER BY bow.facility
  DETAIL
   fcnt = (fcnt+ 1), stat = alterlist(temp->facilities,fcnt), temp->facilities[fcnt].display = bow
   .facility
  WITH nocounter
 ;end select
 DECLARE oc_parse = vc
 SET oc_parse = build2(" oc.catalog_type_cd = ",request->catalog_type_code_value,
  " and oc.activity_type_cd = ",request->activity_type_code_value," and oc.active_ind = 1")
 IF ((request->subactivity_type_code_value > 0))
  SET oc_parse = build2(oc_parse," and oc.activity_subtype_cd = ",request->
   subactivity_type_code_value)
 ENDIF
 SELECT DISTINCT INTO "NL:"
  FROM (dummyt d  WITH seq = fcnt),
   br_oc_work bow,
   order_catalog oc
  PLAN (d)
   JOIN (bow
   WHERE (bow.facility=temp->facilities[d.seq].display)
    AND bow.match_orderable_cd > 0
    AND ((bow.alias1 > " ") OR (((bow.alias2 > " ") OR (((bow.alias3 > " ") OR (((bow.alias4 > " ")
    OR (bow.alias5 > " ")) )) )) )) )
   JOIN (oc
   WHERE parser(oc_parse)
    AND oc.catalog_cd=bow.match_orderable_cd)
  DETAIL
   temp->facilities[d.seq].oc_match_ind = 1
  WITH nocounter
 ;end select
 SET new_phasex_match_ind = 0
 SELECT INTO "NL:"
  FROM br_name_value bnv,
   dummyt d
  PLAN (bnv
   WHERE bnv.br_nv_key1="NEW_PHASE_X_MATCH")
   JOIN (d
   WHERE (cnvtreal(bnv.br_name)=request->catalog_type_code_value)
    AND (cnvtreal(bnv.br_value)=request->activity_type_code_value))
  DETAIL
   new_phasex_match_ind = 1
  WITH nocounter
 ;end select
 IF (new_phasex_match_ind=1)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = fcnt),
    br_oc_work bow,
    br_name_value bnv,
    order_catalog oc
   PLAN (d
    WHERE (temp->facilities[d.seq].oc_match_ind=0))
    JOIN (bow
    WHERE (bow.facility=temp->facilities[d.seq].display)
     AND bow.match_orderable_cd > 0
     AND ((bow.alias1 > " ") OR (((bow.alias2 > " ") OR (((bow.alias3 > " ") OR (((bow.alias4 > " ")
     OR (bow.alias5 > " ")) )) )) )) )
    JOIN (bnv
    WHERE bnv.br_nv_key1="PHASE_X_MATCH"
     AND cnvtreal(bnv.br_name)=bow.oc_id)
    JOIN (oc
    WHERE parser(oc_parse)
     AND oc.catalog_cd=cnvtreal(bnv.br_value))
   DETAIL
    temp->facilities[d.seq].oc_match_ind = 1
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = fcnt),
    br_oc_work bow,
    br_auto_order_catalog baoc,
    order_catalog oc
   PLAN (d
    WHERE (temp->facilities[d.seq].oc_match_ind=0))
    JOIN (bow
    WHERE (bow.facility=temp->facilities[d.seq].display)
     AND bow.match_orderable_cd > 0
     AND ((bow.alias1 > " ") OR (((bow.alias2 > " ") OR (((bow.alias3 > " ") OR (((bow.alias4 > " ")
     OR (bow.alias5 > " ")) )) )) )) )
    JOIN (baoc
    WHERE baoc.catalog_cd=bow.match_orderable_cd)
    JOIN (oc
    WHERE parser(oc_parse)
     AND oc.concept_cki=baoc.concept_cki)
   DETAIL
    temp->facilities[d.seq].oc_match_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SET rcnt = 0
 FOR (f = 1 TO fcnt)
   IF ((temp->facilities[f].oc_match_ind=1))
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->facilities,rcnt)
    IF ((temp->facilities[f].display=" "))
     SET reply->facilities[rcnt].display = "<facility not defined>"
    ELSE
     SET reply->facilities[rcnt].display = temp->facilities[f].display
    ENDIF
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
