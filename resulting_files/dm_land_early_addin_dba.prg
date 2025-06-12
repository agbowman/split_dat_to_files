CREATE PROGRAM dm_land_early_addin:dba
 FREE RECORD le_addin
 RECORD le_addin(
   1 le_add[*]
     2 end_state = vc
     2 component_type = vc
     2 exist_ind = i2
     2 updt_ind = i2
 )
 SET land_early_version_addin = "000"
 DECLARE cnt = i4
 DECLARE cnt1 = i4
 DECLARE x = i4
 DECLARE a = i4
 DECLARE inhsechk = i4
 SET cnt = 0
 SET cnt1 = 0
 SET x = 0
 SET a = 0
 SET inhsechk = 0
 SET cnt = size(requestin->list_0,5)
 SET stat = alterlist(le_addin->le_add,cnt)
 FOR (a = 1 TO cnt)
  SET le_addin->le_add[a].end_state = trim(requestin->list_0[a].end_state,3)
  SET le_addin->le_add[a].component_type = trim(requestin->list_0[a].component_type,3)
 ENDFOR
 SELECT INTO "nl:"
  FROM ocd_readme_component orc,
   (dummyt dt  WITH seq = value(size(le_addin->le_add,5)))
  PLAN (dt)
   JOIN (orc
   WHERE cnvtupper(orc.end_state)=cnvtupper(le_addin->le_add[dt.seq].end_state))
  DETAIL
   le_addin->le_add[dt.seq].exist_ind = 1
   IF (cnvtupper(le_addin->le_add[dt.seq].component_type) != cnvtupper(orc.component_type))
    le_addin->le_add[dt.seq].updt_ind = 1
   ENDIF
  WITH counter
 ;end select
 INSERT  FROM ocd_readme_component o,
   (dummyt dt  WITH seq = value(size(le_addin->le_add,5)))
  SET o.product_area_name = "DATA MANAGEMENT", o.end_state = cnvtupper(le_addin->le_add[dt.seq].
    end_state), o.manual_ind = 1,
   o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.product_area_number = 426, o.component_type =
   cnvtupper(le_addin->le_add[dt.seq].component_type)
  PLAN (dt
   WHERE (le_addin->le_add[dt.seq].exist_ind=0))
   JOIN (o)
  WITH nocounter
 ;end insert
 UPDATE  FROM ocd_readme_component o,
   (dummyt dt  WITH seq = value(size(le_addin->le_add,5)))
  SET o.component_type = cnvtupper(le_addin->le_add[dt.seq].component_type), o.product_area_number =
   426, o.manual_ind = 1
  PLAN (dt
   WHERE (le_addin->le_add[dt.seq].updt_ind=1))
   JOIN (o)
  WITH nocounter
 ;end update
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   inhsechk = 1
  WITH nocounter
 ;end select
 IF (inhsechk=1)
  INSERT  FROM dm_component_audit dca,
    (dummyt dt  WITH seq = value(size(le_addin->le_add,5)))
   SET dca.comp_object_type = "LE", dca.comp_object_name = cnvtupper(le_addin->le_add[dt.seq].
     end_state), dca.comp_audit_uid = curuser,
    dca.comp_audit_dt_tm = cnvtdatetime(curdate,curtime3), dca.comp_audit_comment =
    "AUTO-COMMENT.  COMPONENT ROW INSERTED SUCCESSFULLY FROM R3666 ADD-IN."
   PLAN (dt
    WHERE (le_addin->le_add[dt.seq].exist_ind=0))
    JOIN (dca)
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
END GO
