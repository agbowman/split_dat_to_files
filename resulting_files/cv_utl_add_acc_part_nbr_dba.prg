CREATE PROGRAM cv_utl_add_acc_part_nbr:dba
 PROMPT
  "Participant number=" = "",
  "Organization name=" = ""
 DECLARE g_dataset_id = f8 WITH protect, noconstant(0.0)
 DECLARE g_part_str = vc WITH protect, noconstant(trim( $1))
 DECLARE g_organization_id = f8 WITH protect, noconstant(0.0)
 DECLARE g_org_name = vc WITH protect, noconstant(cnvtupper(trim( $2)))
 DECLARE g_dataset_internal_name = vc WITH protect, noconstant("ACC03")
 SET g_organization_id = cnvtreal( $2)
 IF (size(g_part_str)=0)
  CALL echo("Must enter a participant_nbr")
  GO TO exit_script
 ENDIF
 IF (size(g_org_name)=0)
  CALL echo("Must enter an org_name")
  GO TO exit_script
 ENDIF
 DECLARE tmp_str = vc WITH protect
 DECLARE tmp_char = c1 WITH protect
 DECLARE i = i4 WITH protect
 FOR (i = 1 TO size(g_org_name))
  SET tmp_char = substring(i,1,g_org_name)
  IF (tmp_char IN ("*", "?", "A", "B", "C",
  "D", "E", "F", "G", "H",
  "I", "J", "K", "L", "M",
  "N", "O", "P", "Q", "R",
  "S", "T", "U", "V", "W",
  "X", "Y", "Z", "0", "1",
  "2", "3", "4", "5", "6",
  "7", "8", "9"))
   SET tmp_str = build(tmp_str,tmp_char)
  ENDIF
 ENDFOR
 SET g_org_name = tmp_str
 SELECT INTO "nl:"
  FROM organization o
  WHERE o.org_name_key=patstring(g_org_name)
  DETAIL
   g_organization_id = o.organization_id
  WITH nocounter
 ;end select
 IF (curqual != 1)
  CALL echo(concat("Org_name pattern yielded ",cnvtstring(curqual)," organizations. Exiting"))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM cv_dataset d
  WHERE dataset_internal_name=g_dataset_internal_name
  DETAIL
   g_dataset_id = d.dataset_id
  WITH nocounter
 ;end select
 IF (curqual != 1)
  CALL echo(concat("Did not find unique dataset for",g_dataset_internal_name))
  GO TO exit_script
 ENDIF
 FREE RECORD request
 RECORD request(
   1 application_nbr = i4
   1 parent_entity_id = f8
   1 parent_entity_name = c32
   1 person_id = f8
   1 pref_cd = f8
   1 pref_domain = vc
   1 pref_dt_tm = dq8
   1 pref_id = f8
   1 pref_name = vc
   1 pref_nbr = i4
   1 pref_section = vc
   1 pref_str = vc
   1 reference_ind = i2
 )
 SET request->application_nbr = 4100522
 SET request->pref_domain = "CVNET"
 SET request->pref_section = concat("ENABLE_RLTN_",g_part_str)
 SET request->pref_name = g_dataset_internal_name
 SET request->pref_str = g_part_str
 SET request->parent_entity_id = g_organization_id
 SET request->parent_entity_name = "ORGANIZATION"
 SET request->pref_dt_tm = cnvtdatetime(curdate,curtime3)
 SET request->reference_ind = 1
 SELECT INTO "nl:"
  FROM dm_prefs dp
  WHERE (dp.pref_domain=request->pref_domain)
   AND (dp.pref_section=request->pref_section)
   AND (dp.pref_name=request->pref_name)
   AND (dp.application_nbr=request->application_nbr)
  DETAIL
   request->pref_id = dp.pref_id
  WITH nocounter
 ;end select
 IF ((request->pref_id > 0.0))
  CALL echo("Updating relation")
  EXECUTE dm_upd_dm_prefs
 ELSE
  CALL echo("Creating new relation")
  EXECUTE dm_ins_dm_prefs
 ENDIF
#exit_script
 CALL echo("Existing relations:")
 SELECT INTO "nl:"
  FROM dm_prefs dp,
   cv_dataset d,
   organization o
  PLAN (dp
   WHERE dp.pref_domain="CVNET"
    AND dp.pref_section="ENABLE_RLTN*"
    AND dp.parent_entity_name="ORGANIZATION")
   JOIN (d
   WHERE d.dataset_internal_name=outerjoin(dp.pref_name))
   JOIN (o
   WHERE o.organization_id=outerjoin(dp.parent_entity_id))
  DETAIL
   CALL echo(concat(trim(o.org_name),"=",trim(dp.pref_str)," for ",trim(dp.pref_name),
    "   (id=",cnvtstring(dp.pref_id),")"))
  WITH nocounter
 ;end select
 DECLARE cv_utl_add_acc_part_nbr_vrsn = vc WITH private, constant("MOD 001 BM9013 02/24/06")
END GO
