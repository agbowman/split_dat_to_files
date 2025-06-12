CREATE PROGRAM ams_del_proposed_order:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter the Encntr_id of the Encounter with the Proposed Order" = 0,
  "Select the Order That Has a Proposal To Remove" = 0,
  "Select the Order Proposal to Remove" = 0,
  "Select the Status to Change the Order Proposal" = ""
  WITH outdev, encntrid, proid,
  notifid, status
 DECLARE prog_name = vc
 DECLARE run_ind = i2
 DECLARE notif_id = f8
 DECLARE ord_status = i4
 SET prog_name = "AMS_DEL_PROPOSED_ORDER"
 SET run_ind = 0
 SET notif_id = cnvtreal( $NOTIFID)
 SET ord_status = cnvtint( $STATUS)
 SET run_ind = amsuser(reqinfo->updt_id)
 IF (run_ind=1)
  UPDATE  FROM order_proposal_notif o
   SET o.notification_status_flag = cnvtint( $STATUS), o.updt_id = reqinfo->updt_id, o.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    o.updt_cnt = (updt_cnt+ 1)
   WHERE o.order_proposal_notif_id=cnvtreal( $NOTIFID)
   WITH nocounter
  ;end update
  COMMIT
  SELECT INTO  $1
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "UPDATED FOLLOWING PROPOSALS:",
    row 4, col 20, "Order_proposal_notif_id:",
    notif_id, row 5, col 20,
    "Status:", ord_status
   WITH nocounter
  ;end select
  CALL updtdminfo(prog_name)
 ELSE
  SELECT INTO  $1
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "THIS PROGRAM IS INTENDED FOR USE BY AMS ASSOCIATES ONLY"
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE updtdminfo(prog_name)
   DECLARE found = i2
   DECLARE info_nbr = i4
   SET found = 0
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="AMS_TOOLKIT"
     AND d.info_name=prog_name
    DETAIL
     found = 1, info_nbr = (d.info_number+ 1)
    WITH nocounter
   ;end select
   IF (found=0)
    INSERT  FROM dm_info d
     SET d.info_domain = "AMS_TOOLKIT", d.info_name = prog_name, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = info_nbr
     WHERE d.info_domain="AMS_TOOLKIT"
      AND d.info_name=prog_name
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE amsuser(person_id)
   DECLARE user_ind = i2
   DECLARE prsnl_cd = f8
   SET user_ind = 0
   SET prsnl_cd = uar_get_code_by("MEANING",213,"PRSNL")
   SELECT
    p.person_id
    FROM person_name p
    WHERE (p.person_id=reqinfo->updt_id)
     AND p.name_type_cd=prsnl_cd
     AND p.name_title="Cerner AMS"
    DETAIL
     IF (p.person_id > 0)
      user_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   RETURN(user_ind)
 END ;Subroutine
 SET script_ver = "001 04/11/2012"
END GO
