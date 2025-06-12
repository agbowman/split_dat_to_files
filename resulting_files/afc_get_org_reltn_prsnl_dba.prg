CREATE PROGRAM afc_get_org_reltn_prsnl:dba
 SET afc_get_org_reltn_prsnl_vrsn = "323720.004"
 RECORD reply(
   1 organization_qual = i4
   1 organization[*]
     2 org_name = vc
     2 organization_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE dauthcd = f8
 SET stat = uar_get_meaning_by_codeset(8,"AUTH",1,dauthcd)
 DECLARE dclient = f8
 SET stat = uar_get_meaning_by_codeset(278,"CLIENT",1,dclient)
 SET cntorg = 0
 DECLARE user_id = f8
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.username=cnvtupper(request->username)
  DETAIL
   user_id = p.person_id
  WITH nocounter
 ;end select
 CALL echo(build("user_id: ",cnvtreal(user_id)))
 SELECT INTO "nl:"
  FROM prsnl_org_reltn p,
   organization o
  PLAN (p
   WHERE p.person_id=user_id
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND p.active_ind=1)
   JOIN (o
   WHERE o.organization_id=p.organization_id
    AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND o.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND o.data_status_cd=dauthcd
    AND o.active_ind=1
    AND  EXISTS (
   (SELECT
    b.organization_id
    FROM bill_org_payor b
    WHERE b.organization_id=o.organization_id
     AND (b.bill_org_type_cd=
    (SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=13031
      AND cv.cdf_meaning="TIERGROUP"
      AND cv.active_ind=1))
     AND b.active_ind=1)))
  DETAIL
   cntorg += 1, stat = alterlist(reply->organization,cntorg), reply->organization[cntorg].org_name =
   o.org_name,
   reply->organization[cntorg].organization_id = o.organization_id
  WITH nocounter
 ;end select
 SET reply->organization_qual = cntorg
 IF ((reply->organization_qual=0))
  SET cntorg = 0
  SELECT INTO "nl:"
   FROM org_type_reltn otr,
    organization o
   PLAN (otr
    WHERE otr.org_type_cd=dclient
     AND otr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND otr.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND otr.active_ind=1)
    JOIN (o
    WHERE o.organization_id=otr.organization_id
     AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND o.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND o.data_status_cd=dauthcd
     AND o.active_ind=1
     AND  EXISTS (
    (SELECT
     b.organization_id
     FROM bill_org_payor b
     WHERE b.organization_id=o.organization_id
      AND (b.bill_org_type_cd=
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=13031
       AND cv.cdf_meaning="TIERGROUP"
       AND cv.active_ind=1))
      AND b.active_ind=1)))
   DETAIL
    cntorg += 1, stat = alterlist(reply->organization,cntorg), reply->organization[cntorg].org_name
     = o.org_name,
    reply->organization[cntorg].organization_id = o.organization_id
   WITH nocounter
  ;end select
  SET reply->organization_qual = cntorg
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "person_org_reltn"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 CALL echo(build("status: ",reply->status_data.status))
END GO
