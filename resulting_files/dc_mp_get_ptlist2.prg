CREATE PROGRAM dc_mp_get_ptlist2
 IF ( NOT (validate(listreply)))
  RECORD listreply(
    1 domainid = f8
    1 domaingrpid = f8
    1 username = vc
    1 prsnlname = vc
    1 positioncd = f8
    1 appxe = vc
    1 list_cnt = i4
    1 ptlist[*]
      2 listid = f8
      2 listnm = vc
      2 listtypecd = f8
      2 defaultloccd = f8
      2 listseq = i4
      2 ownerid = f8
      2 prsnlid = f8
      2 appcntxid = f8
      2 appid = i4
      2 clientnm = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE listtypecd = f8 WITH constant(uar_get_code_by("MEANING",27360,"LOCATION")), protect
 DECLARE viewname = vc WITH constant("PATLISTVIEW"), protect
 DECLARE ptlistidvc = vc WITH constant("PATIENTLISTID"), protect
 DECLARE displayseq = vc WITH constant("DISPLAY_SEQ"), protect
 DECLARE statusscript = c25 WITH constant("dc_mp_get_ptlist2"), protect
 DECLARE cntx = i4 WITH protect
 DECLARE now = i4 WITH protect
 DECLARE appnmbr = i4 WITH protect
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE jrec = i4 WITH protect
 DECLARE listloc = f8 WITH protect
 SET listreply->status_data.status = "F"
 DECLARE errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) = null
 IF (checkdic("PRSNL.LOGICAL_DOMAIN_ID","A",0)=2)
  SELECT INTO "NL:"
   p.name_full_formatted, p.position_cd, p.username,
   p.logical_domain_grp_id, p.logical_domain_id
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id=reqinfo->updt_id))
   DETAIL
    listreply->domainid = p.logical_domain_id, listreply->domaingrpid = p.logical_domain_grp_id,
    listreply->username = p.username,
    listreply->prsnlname = p.name_full_formatted, listreply->positioncd = p.position_cd
   WITH nocounter, separator = " ", format
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","PRSNL LOGICAL DOMAIN ID",errmsg)
  ENDIF
 ENDIF
 SELECT INTO "NL:"
  ac.applctx, ac.application_image
  FROM application_context ac
  PLAN (ac
   WHERE (ac.applctx=reqinfo->updt_applctx))
  DETAIL
   listreply->appxe = build(trim(ac.application_image),".EXE")
  WITH nocounter, separator = " ", format
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Active Application",errmsg)
 ENDIF
 SELECT INTO "NL:"
  d.detail_prefs_id, d.prsnl_id, n.pvc_name,
  n.pvc_value
  FROM detail_prefs d,
   view_prefs v,
   name_value_prefs n
  PLAN (d
   WHERE (d.prsnl_id=reqinfo->updt_id)
    AND d.view_name=viewname
    AND (d.application_number=reqinfo->updt_app)
    AND d.active_ind=1)
   JOIN (v
   WHERE v.prsnl_id=d.prsnl_id
    AND v.application_number=d.application_number
    AND v.view_seq=d.view_seq
    AND v.active_ind=1)
   JOIN (n
   WHERE ((n.parent_entity_id=d.detail_prefs_id
    AND cnvtupper(n.pvc_name)=ptlistidvc
    AND n.active_ind=1) OR (n.parent_entity_id=v.view_prefs_id
    AND cnvtupper(n.pvc_name)=displayseq
    AND n.active_ind=1)) )
  ORDER BY d.detail_prefs_id
  HEAD REPORT
   cntr = 0
  HEAD d.detail_prefs_id
   cntr = (cntr+ 1)
   IF (mod(cntr,10)=1)
    now = alterlist(listreply->ptlist,(cntr+ 9))
   ENDIF
   listreply->ptlist[cntr].prsnlid = d.prsnl_id, listreply->ptlist[cntr].appid = v.application_number
  DETAIL
   IF (cnvtupper(n.pvc_name)=displayseq)
    listreply->ptlist[cntr].listseq = cnvtreal(n.pvc_value)
   ELSEIF (cnvtupper(n.pvc_name)=ptlistidvc)
    listreply->ptlist[cntr].listid = cnvtreal(n.pvc_value)
   ENDIF
  FOOT REPORT
   listreply->list_cnt = cntr, now = alterlist(listreply->ptlist,cntr)
  WITH nocounter, separator = " ", format
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Active Patient Lists",errmsg)
 ENDIF
 SELECT INTO "NL:"
  a.person_id, default_loc_cd = cnvtreal(a.default_location), loc_disp = trim(uar_get_code_display(
    cnvtreal(a.default_location))),
  a.updt_applctx, a.applctx
  FROM application_context a,
   dummyt d1
  PLAN (a
   WHERE (a.applctx=reqinfo->updt_applctx)
    AND ((a.person_id+ 0)=reqinfo->updt_id))
   JOIN (d1
   WHERE cnvtreal(a.default_location) > 0)
  HEAD REPORT
   IF ((listreply->list_cnt > 0))
    FOR (x = 1 TO listreply->list_cnt)
      listreply->ptlist[x].listseq = (listreply->ptlist[x].listseq+ 1)
    ENDFOR
   ENDIF
   cntr = listreply->list_cnt
  DETAIL
   cntr = (cntr+ 1), now = alterlist(listreply->ptlist,cntr), listreply->ptlist[cntr].listnm =
   loc_disp,
   listreply->ptlist[cntr].listtypecd = listtypecd, listreply->ptlist[cntr].ownerid = a.person_id,
   listreply->ptlist[cntr].prsnlid = a.person_id,
   listreply->ptlist[cntr].listseq = 1, listreply->ptlist[cntr].listid = 0.0, listreply->ptlist[cntr]
   .defaultloccd = default_loc_cd
  FOOT REPORT
   listreply->list_cnt = cntr
  WITH nocounter, separator = " ", format
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Default location",errmsg)
 ENDIF
 CALL echorecord(listreply)
 IF ((listreply->list_cnt=0))
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  d.name, d.owner_prsnl_id, d_patient_list_type_disp = uar_get_code_display(d.patient_list_type_cd)
  FROM (dummyt d1  WITH seq = value(listreply->list_cnt)),
   dcp_patient_list d
  PLAN (d1
   WHERE (listreply->ptlist[d1.seq].listid > 0))
   JOIN (d
   WHERE (d.patient_list_id=listreply->ptlist[d1.seq].listid))
  DETAIL
   listreply->ptlist[d1.seq].listnm = d.name, listreply->ptlist[d1.seq].listtypecd = d
   .patient_list_type_cd, listreply->ptlist[d1.seq].ownerid = d.owner_prsnl_id
  WITH nocounter, separator = " ", format
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","List Name/Type",errmsg)
 ENDIF
 CALL echorecord(listreply)
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(listreply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (listreply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET lstat = alter(listreply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET listreply->status_data.status = "F"
   SET listreply->status_data.subeventstatus[error_cnt].operationname = statusscript
   SET listreply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET listreply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET listreply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
 SET listreply->status_data.status = "S"
#exit_script
 CALL echo("SCRIPT VERSION IS 01/28/2010 Initial Release Christopher Canida")
 CALL echorecord(listreply)
 IF (validate(_memory_reply_string))
  SET _memory_reply_string = cnvtrectojson(listreply)
 ELSE
  CALL echojson(listreply, $1)
 ENDIF
 SELECT INTO "nl:"
  DETAIL
   row + 0
  WITH nocounter
 ;end select
END GO
