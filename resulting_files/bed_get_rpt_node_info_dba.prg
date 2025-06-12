CREATE PROGRAM bed_get_rpt_node_info:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 rowlist[*]
      2 report_name = vc
      2 username = vc
      2 date_created = vc
      2 date_completed = vc
      2 node_name = vc
      2 report_status = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE bed_is_logical_domain(dummyvar=i2) = i2
 DECLARE bed_get_logical_domain(dummyvar=i2) = f8
 SUBROUTINE bed_is_logical_domain(dummyvar)
   RETURN(checkprg("ACM_GET_CURR_LOGICAL_DOMAIN"))
 END ;Subroutine
 SUBROUTINE bed_get_logical_domain(dummyvar)
  IF (bed_is_logical_domain(null))
   IF (validate(ld_concept_person)=0)
    DECLARE ld_concept_person = i2 WITH public, constant(1)
   ENDIF
   IF (validate(ld_concept_prsnl)=0)
    DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
   ENDIF
   IF (validate(ld_concept_organization)=0)
    DECLARE ld_concept_organization = i2 WITH public, constant(3)
   ENDIF
   IF (validate(ld_concept_healthplan)=0)
    DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
   ENDIF
   IF (validate(ld_concept_alias_pool)=0)
    DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
   ENDIF
   IF (validate(ld_concept_minvalue)=0)
    DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
   ENDIF
   IF (validate(ld_concept_maxvalue)=0)
    DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
   ENDIF
   RECORD acm_get_curr_logical_domain_req(
     1 concept = i4
   )
   RECORD acm_get_curr_logical_domain_rep(
     1 logical_domain_id = f8
     1 status_block
       2 status_ind = i2
       2 error_code = i4
   )
   SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
   EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
   replace("REPLY",acm_get_curr_logical_domain_rep)
   IF ( NOT (acm_get_curr_logical_domain_rep->status_block.status_ind)
    AND checkfun("BEDERROR"))
    CALL bederror(build("Logical Domain Error: ",acm_get_curr_logical_domain_rep->status_block.
      error_code))
   ENDIF
   RETURN(acm_get_curr_logical_domain_rep->logical_domain_id)
  ENDIF
  RETURN(null)
 END ;Subroutine
 DECLARE logical_domain_id = f8 WITH protect, constant(bed_get_logical_domain(0))
 DECLARE info_domain_name = vc WITH protect, constant("Bedrock Report Node")
 DECLARE counter = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM dm_info d,
   person p
  PLAN (d
   WHERE d.info_domain=patstring(concat("*",info_domain_name,"*"))
    AND d.info_domain_id=logical_domain_id)
   JOIN (p
   WHERE p.person_id=d.updt_id)
  ORDER BY d.updt_dt_tm DESC
  DETAIL
   counter = (counter+ 1), stat = alterlist(reply->rowlist,counter), reply->rowlist[counter].
   report_name = substring(1,(findstring(".csv",d.info_name,1,1)+ 3),d.info_name),
   reply->rowlist[counter].username = p.name_full_formatted, reply->rowlist[counter].date_created =
   format(cnvtdatetime(d.info_date),"DD-MMM-YYYY HH:MM:SS;;D"), reply->rowlist[counter].
   date_completed = evaluate(d.info_char,"Completed",format(cnvtdatetime(d.updt_dt_tm),
     "DD-MMM-YYYY HH:MM:SS;;D"),""),
   reply->rowlist[counter].node_name = substring(1,(findstring(";",d.info_domain,1,1) - 1),d
    .info_domain), reply->rowlist[counter].report_status = d.info_char
  WITH format
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
