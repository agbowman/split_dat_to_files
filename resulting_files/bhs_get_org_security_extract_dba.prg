CREATE PROGRAM bhs_get_org_security_extract:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "1- Select an Org." = value(),
  "2- Select Logic 1:" = 2,
  "3- Select Logic 2:" = 1
  WITH outdev, org_id, logic1,
  logic2
 IF (( $LOGIC1=1))
  SELECT INTO  $OUTDEV
   p_position_disp = uar_get_code_display(p.position_cd), name = p.name_full_formatted
   FROM prsnl p
   PLAN (p
    WHERE p.active_ind=1
     AND p.username > ""
     AND p.position_cd > 0
     AND (p.physician_ind= $LOGIC2)
     AND p.person_id IN (
    (SELECT
     po.person_id
     FROM prsnl_org_reltn po
     WHERE po.person_id=p.person_id
      AND po.active_ind=1
      AND po.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND (po.organization_id= $ORG_ID))))
   ORDER BY name
   WITH nocounter
  ;end select
 ELSEIF (( $LOGIC1=2))
  SELECT INTO  $OUTDEV
   p_position_disp = uar_get_code_display(p.position_cd), name = p.name_full_formatted
   FROM prsnl p
   PLAN (p
    WHERE p.active_ind=1
     AND p.username > ""
     AND p.position_cd > 0
     AND (p.physician_ind= $LOGIC2)
     AND  NOT (p.person_id IN (
    (SELECT
     po.person_id
     FROM prsnl_org_reltn po
     WHERE po.person_id=p.person_id
      AND po.active_ind=1
      AND po.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND (po.organization_id= $ORG_ID)))))
   ORDER BY name
   WITH nocounter, seperator = ","
  ;end select
 ENDIF
END GO
