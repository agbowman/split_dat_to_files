CREATE PROGRAM bed_get_form_statuses:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 synonyms[*]
      2 synonym_id = f8
      2 statuses[*]
        3 facility_code_value = f8
        3 inpatient_code_value = f8
        3 outpatient_code_value = f8
        3 rx_synonym_visibility_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE syn_cnt = i4 WITH private, noconstant(0)
 DECLARE fac_cnt = i4 WITH private, noconstant(0)
 DECLARE syn_size = i4 WITH private, noconstant(0)
 DECLARE fac_size = i4 WITH private, noconstant(0)
 DECLARE req_count = i4 WITH protect, noconstant(0)
 DECLARE rx_syn_vsby_ind_col_exist = i2 WITH protect, noconstant(0)
 IF (checkdic("OCS_FACILITY_FORMULARY_R.RX_SYNONYM_VISIBILITY_IND","A",0) > 0)
  SET rx_syn_vsby_ind_col_exist = 1
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET req_count = size(request->synonyms,5)
 IF (req_count=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(request->synonyms,5))),
   ocs_facility_formulary_r ocsfr,
   code_value cv
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ocsfr
   WHERE (ocsfr.synonym_id=request->synonyms[d.seq].synonym_id))
   JOIN (cv
   WHERE cv.code_value=ocsfr.facility_cd)
  ORDER BY ocsfr.synonym_id, ocsfr.facility_cd
  HEAD REPORT
   syn_cnt = 0, syn_size = 0
  HEAD ocsfr.synonym_id
   syn_cnt = (syn_cnt+ 1)
   IF (syn_size < syn_cnt)
    syn_size = (syn_size+ 10), nstat = alterlist(reply->synonyms,syn_size)
   ENDIF
   reply->synonyms[syn_cnt].synonym_id = ocsfr.synonym_id, fac_cnt = 0, fac_size = 0
  HEAD ocsfr.facility_cd
   IF (((cv.code_value=0) OR (cv.active_ind=1)) )
    fac_cnt = (fac_cnt+ 1)
    IF (fac_size < fac_cnt)
     fac_size = (fac_size+ 10), nstat = alterlist(reply->synonyms[syn_cnt].statuses,(fac_cnt+ 9))
    ENDIF
    reply->synonyms[syn_cnt].statuses[fac_cnt].facility_code_value = ocsfr.facility_cd, reply->
    synonyms[syn_cnt].statuses[fac_cnt].inpatient_code_value = ocsfr.inpatient_formulary_status_cd,
    reply->synonyms[syn_cnt].statuses[fac_cnt].outpatient_code_value = ocsfr
    .outpatient_formulary_status_cd
    IF (rx_syn_vsby_ind_col_exist=1)
     stat = assign(validate(reply->synonyms[syn_cnt].statuses[fac_cnt].rx_synonym_visibility_ind),
      validate(ocsfr.rx_synonym_visibility_ind,0))
    ENDIF
   ENDIF
  FOOT  ocsfr.facility_cd
   row + 0
  FOOT  ocsfr.synonym_id
   nstat = alterlist(reply->synonyms[syn_cnt].statuses,fac_cnt)
  FOOT REPORT
   nstat = alterlist(reply->synonyms,syn_cnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
