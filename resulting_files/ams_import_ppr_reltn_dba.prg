CREATE PROGRAM ams_import_ppr_reltn:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter PERSON_ID values" = "",
  "Enter SERVICE_RESOUCE_CD Value" = 0
  WITH outdev, p_person_ids, p_src
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE dserviceresourcecd = f8 WITH protect, noconstant(0.00)
 DECLARE smessage = vc WITH protect, noconstant("")
 DECLARE pknt = i4 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE bvalidserviceresourcecode = i2 WITH protect, noconstant(false)
 DECLARE bfoundvalidprsnlid = i2 WITH protect, noconstant(false)
 DECLARE bfoundrelationshiptoadd = i2 WITH protect, noconstant(false)
 DECLARE smsg_0 = vc WITH protect, constant("PRSNL_ID Does Not Exist")
 DECLARE smsg_1 = vc WITH protect, constant("Invalid PRSNL_ID Value")
 DECLARE smsg_2 = vc WITH protect, constant("SUCCESS: Relationship Added")
 DECLARE smsg_3 = vc WITH protect, constant("Relationship Already Exist")
 DECLARE iexpidx = i4 WITH protect, noconstant(0)
 DECLARE ilocidx = i4 WITH protect, noconstant(0)
 DECLARE ipos = i4 WITH protect, noconstant(0)
 FREE RECORD rprsnl
 RECORD rprsnl(
   1 qual_knt = i4
   1 qual[*]
     2 id = f8
     2 raw = vc
     2 flg = i2
     2 username = vc
     2 name = vc
 )
 DECLARE subparseprsnlids(sinputstr=vc,cdelimiter=c1) = i2
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 SET stat = subparseprsnlids( $P_PERSON_IDS,",")
 IF ((rprsnl->qual_knt > 0))
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE expand(iexpidx,1,rprsnl->qual_knt,p.person_id,rprsnl->qual[iexpidx].id,
     0,rprsnl->qual[iexpidx].flg)
     AND p.username != null
     AND p.active_ind=1)
   ORDER BY p.person_id
   DETAIL
    ilocidx = 0, ipos = locateval(ilocidx,1,rprsnl->qual_knt,p.person_id,rprsnl->qual[ilocidx].id)
    IF (ipos > 0)
     rprsnl->qual[ipos].name = trim(p.name_full_formatted,3), rprsnl->qual[ipos].username = trim(p
      .username,3), rprsnl->qual[ipos].flg = 2,
     bfoundvalidprsnlid = true
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET failed = input_error
  SET serrmsg = concat("No Valid PRSNL_ID Values (",trim( $P_PERSON_IDS,3),")")
  GO TO exit_script
 ENDIF
 IF (bfoundvalidprsnlid=false)
  SET failed = input_error
  SET serrmsg = concat("No Valid PRSNL_ID Values Found (",trim( $P_PERSON_IDS,3),")")
  GO TO exit_script
 ENDIF
 IF (isnumeric( $P_SRC))
  SET dserviceresourcecd = cnvtreal( $P_SRC)
 ELSE
  SET failed = input_error
  SET serrmsg = concat("Invalid SERVICE_RESOURCE_CD Value (",trim( $P_SRC,3),")")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_value=cnvtreal(dserviceresourcecd)
    AND cv.code_set=221)
  DETAIL
   bvalidserviceresourcecode = true
  WITH nocounter
 ;end select
 IF (bvalidserviceresourcecode=false)
  SET failed = input_error
  SET serrmsg = concat("Invalid SERVICE_RESOURCE_CD Value (",trim( $P_SRC,3),")")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl_service_resource_reltn psrr
  PLAN (psrr
   WHERE expand(iexpidx,1,rprsnl->qual_knt,psrr.person_id,rprsnl->qual[iexpidx].id,
    2,rprsnl->qual[iexpidx].flg)
    AND psrr.service_resource_cd=dserviceresourcecd)
  ORDER BY psrr.prsnl_id
  DETAIL
   ilocidx = 0, ipos = locateval(ilocidx,1,rprsnl->qual_knt,psrr.person_id,rprsnl->qual[ilocidx].id)
   IF (ipos > 0)
    rprsnl->qual[ipos].flg = 3
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 INSERT  FROM prsnl_service_resource_reltn psrr,
   (dummyt d  WITH seq = value(rprsnl->qual_knt))
  SET psrr.prsnl_id = rprsnl->qual[d.seq].id, psrr.service_resource_cd = dserviceresourcecd, psrr
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pssr.updt_id = reqinfo->updt_id, pssr.updt_task = 5574, pssr.updt_applctx = 5574,
   pssr.updt_cnt = 0
  PLAN (d
   WHERE (rprsnl->qual[d.seq].flg=2))
   JOIN (psrr
   WHERE 1=1)
  WITH nocounter, maxcommit = 1000
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = insert_error
  SET serrmsg = concat("ERROR >> ",trim(serrmsg,3))
  GO TO exit_script
 ENDIF
 COMMIT
 SELECT INTO value( $OUTDEV)
  prsnl_id = trim(cnvtstring(rprsnl->qual[d.seq].id),3), raw_id = trim(substring(1,100,rprsnl->qual[d
    .seq].raw),3), username = trim(substring(1,100,rprsnl->qual[d.seq].username),3),
  prsnl_name = trim(substring(1,100,rprsnl->qual[d.seq].name),3), service_resource_cd = trim(
   substring(1,100, $P_SRC),3), message =
  IF ((rprsnl->qual[d.seq].flg=0)) trim(substring(1,100,smsg_0),3)
  ELSEIF ((rprsnl->qual[d.seq].flg=1)) trim(substring(1,100,smsg_1),3)
  ELSEIF ((rprsnl->qual[d.seq].flg=2)) trim(substring(1,100,smsg_2),3)
  ELSEIF ((rprsnl->qual[d.seq].flg=3)) trim(substring(1,100,smsg_3),3)
  ENDIF
  FROM (dummyt d  WITH seq = value(rprsnl->qual_knt))
  PLAN (d)
  WITH nocounter, format, separator = " "
 ;end select
 SUBROUTINE subparseprsnlids(sinputstr,cdelimiter)
   SET stemp = trim(sinputstr,3)
   IF (substring(textlen(stemp),1,stemp)=cdelimiter)
    SET stemp = replace(sinputstr,cdelimiter,"",2)
   ENDIF
   IF (findstring(cdelimiter,stemp,1))
    SET ipos = findstring(cdelimiter,stemp,1)
    WHILE (ipos > 0)
      SET wknt = (wknt+ 1)
      SET pknt = (pknt+ 1)
      IF (pknt > size(rprsnl->qual,5))
       SET stat = alterlist(rprsnl->qual,(pknt+ 4))
      ENDIF
      SET rprsnl->qual[pknt].raw = trim(substring(1,(ipos - 1),stemp),3)
      IF (isnumeric(rprsnl->qual[pknt].raw))
       SET rprsnl->qual[pknt].id = cnvtreal(rprsnl->qual[pknt].raw)
      ELSE
       SET rprsnl->qual[pknt].flg = 1
      ENDIF
      SET stemp = trim(substring((ipos+ 1),(textlen(stemp) - ipos),stemp),3)
      SET ipos = findstring(cdelimiter,stemp,1)
      IF (ipos < 1)
       SET pknt = (pknt+ 1)
       SET stat = alterlist(rprsnl->qual,pknt)
       SET rprsnl->qual[pknt].raw = trim(stemp,3)
       IF (isnumeric(rprsnl->qual[pknt].raw))
        SET rprsnl->qual[pknt].id = cnvtreal(rprsnl->qual[pknt].raw)
       ELSE
        SET rprsnl->qual[pknt].flg = 1
       ENDIF
      ENDIF
    ENDWHILE
   ELSE
    SET pknt = (pknt+ 1)
    SET stat = alterlist(rprsnl->qual,pknt)
    SET rprsnl->qual[pknt].raw = trim(stemp,3)
    IF (isnumeric(rprsnl->qual[pknt].raw))
     SET rprsnl->qual[pknt].id = cnvtreal(rprsnl->qual[pknt].raw)
    ELSE
     SET rprsnl->qual[pknt].flg = 1
    ENDIF
   ENDIF
   SET rprsnl->qual_knt = pknt
   RETURN(0)
 END ;Subroutine
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF ( NOT (failed IN (exe_error, insert_error)))
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 SET script_ver = "001 07/02/14 Mods to Add to AMS Toolkit"
END GO
