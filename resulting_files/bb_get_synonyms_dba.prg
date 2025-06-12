CREATE PROGRAM bb_get_synonyms:dba
 RECORD reply(
   1 synonyms[*]
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 synonym_id = f8
     2 mnemonic = vc
     2 oe_format_id = f8
     2 orderable_type_flag = i2
     2 bb_processing_cd = f8
     2 bb_processing_disp = c40
     2 bb_processing_desc = vc
     2 bb_processing_mean = c12
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 activity_type_desc = vc
     2 activity_type_mean = c12
     2 specimen_type_cd = f8
     2 specimen_type_disp = c40
     2 specimen_type_desc = vc
     2 specimen_type_mean = c12
     2 components[*]
       3 synonym_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET modify = predeclare
 DECLARE script_name = c15 WITH constant("bb_get_synonyms")
 DECLARE activity_type_cs = i4 WITH constant(106)
 DECLARE catalog_types_cs = i4 WITH constant(6000)
 DECLARE specimen_types_cs = i4 WITH constant(2052)
 DECLARE activity_bb_mean = c12 WITH constant("BB")
 DECLARE activity_bb_cd = f8 WITH noconstant(0.0)
 DECLARE activity_bb_product_mean = c12 WITH constant("BB PRODUCT")
 DECLARE activity_bb_product_cd = f8 WITH noconstant(0.0)
 DECLARE laboratory_catalog_type_mean = c12 WITH constant("GENERAL LAB")
 DECLARE laboratory_catalog_type_cd = f8 WITH noconstant(0.0)
 DECLARE specimen_type_mean = c12 WITH constant("BLOOD")
 DECLARE specimen_type_cd = f8 WITH noconstant(0.0)
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 DECLARE uar_error = vc WITH noconstant("")
 DECLARE orderable_count = i4 WITH noconstant(0)
 SET activity_bb_cd = uar_get_code_by("MEANING",activity_type_cs,nullterm(activity_bb_mean))
 IF (activity_bb_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve activity type code with meaning of ",trim(
    activity_bb_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET activity_bb_product_cd = uar_get_code_by("MEANING",activity_type_cs,nullterm(
   activity_bb_product_mean))
 IF (activity_bb_product_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve activity type code with meaning of ",trim(
    activity_bb_product_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET laboratory_catalog_type_cd = uar_get_code_by("MEANING",catalog_types_cs,nullterm(
   laboratory_catalog_type_mean))
 IF (laboratory_catalog_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve catalog type code with meaning of ",trim(
    laboratory_catalog_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET specimen_type_cd = uar_get_code_by("MEANING",specimen_types_cs,nullterm(specimen_type_mean))
 IF (specimen_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve specimen type code with meaning of ",trim(
    specimen_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SELECT INTO "nl:"
  sd.*
  FROM order_catalog oc,
   service_directory sd,
   order_catalog_synonym ocs,
   procedure_specimen_type pst
  PLAN (oc
   WHERE oc.catalog_type_cd=laboratory_catalog_type_cd
    AND oc.activity_type_cd IN (activity_bb_cd, activity_bb_product_cd)
    AND oc.active_ind=1)
   JOIN (sd
   WHERE (sd.catalog_cd= Outerjoin(oc.catalog_cd))
    AND (sd.active_ind= Outerjoin(1)) )
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.active_ind=1)
   JOIN (pst
   WHERE (pst.catalog_cd= Outerjoin(ocs.catalog_cd))
    AND (pst.specimen_type_cd= Outerjoin(specimen_type_cd)) )
  HEAD REPORT
   orderable_count = 0
  DETAIL
   orderable_count += 1
   IF (mod(orderable_count,10)=1)
    stat = alterlist(reply->synonyms,(orderable_count+ 9))
   ENDIF
   reply->synonyms[orderable_count].catalog_cd = oc.catalog_cd, reply->synonyms[orderable_count].
   catalog_type_cd = oc.catalog_type_cd, reply->synonyms[orderable_count].mnemonic = ocs.mnemonic,
   reply->synonyms[orderable_count].oe_format_id = oc.oe_format_id, reply->synonyms[orderable_count].
   synonym_id = ocs.synonym_id, reply->synonyms[orderable_count].activity_type_cd = oc
   .activity_type_cd,
   reply->synonyms[orderable_count].bb_processing_cd = sd.bb_processing_cd, reply->synonyms[
   orderable_count].orderable_type_flag = oc.orderable_type_flag, reply->synonyms[orderable_count].
   specimen_type_cd = pst.specimen_type_cd
  FOOT REPORT
   stat = alterlist(reply->synonyms,orderable_count)
  WITH nocounter
 ;end select
 IF (size(reply->synonyms,5) > 0)
  SELECT INTO "nl:"
   cs.*
   FROM (dummyt d  WITH seq = value(size(reply->synonyms,5))),
    cs_component cc
   PLAN (d
    WHERE (reply->synonyms[d.seq].orderable_type_flag=2))
    JOIN (cc
    WHERE (cc.catalog_cd=reply->synonyms[d.seq].catalog_cd))
   ORDER BY d.seq
   HEAD d.seq
    component_count = 0
   DETAIL
    component_count += 1
    IF (mod(component_count,10)=1)
     stat = alterlist(reply->synonyms[d.seq].components,(component_count+ 9))
    ENDIF
    reply->synonyms[d.seq].components[component_count].synonym_id = cc.comp_id
   FOOT  d.seq
    stat = alterlist(reply->synonyms[d.seq].components,component_count)
   WITH nocounter
  ;end select
 ENDIF
 GO TO set_status
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#set_status
 IF (orderable_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
