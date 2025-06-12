CREATE PROGRAM bhs_athn_get_dose_calc_uoms
 FREE RECORD result
 RECORD result(
   1 list[*]
     2 uom_cd = f8
     2 uom_disp = vc
     2 uom_base_nbr = i4
     2 uom_branch_nbr = i4
     2 uom_denominator_cd = f8
     2 uom_denominator_disp = vc
     2 uom_numerator_cd = f8
     2 uom_numerator_disp = vc
     2 uom_multiply_factor = f8
     2 uom_type_flag = i2
     2 uom_type_flag_disp = vc
     2 strength_unit_ind = i2
     2 volume_unit_ind = i2
     2 rate_unit_ind = i2
     2 documentation_dose_rate_ind = i2
     2 quantity_unit_ind = i2
     2 duration_unit_ind = i2
     2 normalized_unit_ind = i2
     2 no_unit_ind = i2
     2 display_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE getuoms(null) = i2
 DECLARE filteruoms(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 SET result->status_data.status = "F"
 SET stat = getuoms(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = filteruoms(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v0 = vc WITH protect, noconstant("")
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  DECLARE v6 = vc WITH protect, noconstant("")
  DECLARE v7 = vc WITH protect, noconstant("")
  DECLARE v8 = vc WITH protect, noconstant("")
  DECLARE v9 = vc WITH protect, noconstant("")
  DECLARE v10 = vc WITH protect, noconstant("")
  DECLARE v11 = vc WITH protect, noconstant("")
  DECLARE v12 = vc WITH protect, noconstant("")
  DECLARE v13 = vc WITH protect, noconstant("")
  DECLARE v14 = vc WITH protect, noconstant("")
  DECLARE v15 = vc WITH protect, noconstant("")
  DECLARE v16 = vc WITH protect, noconstant("")
  DECLARE v17 = vc WITH protect, noconstant("")
  DECLARE v18 = vc WITH protect, noconstant("")
  DECLARE v19 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v0 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v0, row + 1, col + 1,
    "<UOMs>", row + 1
    FOR (idx = 1 TO size(result->list,5))
      IF (((( $3=1)) OR ((result->list[idx].display_ind=1))) )
       col + 1, "<UOM>", row + 1,
       v1 = build("<UOMCd>",cnvtint(result->list[idx].uom_cd),"</UOMCd>"), col + 1, v1,
       row + 1, v2 = build("<UOMDisplay>",trim(replace(replace(replace(replace(replace(result->list[
              idx].uom_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
          ),3),"</UOMDisplay>"), col + 1,
       v2, row + 1, v3 = build("<BaseNbr>",result->list[idx].uom_base_nbr,"</BaseNbr>"),
       col + 1, v3, row + 1,
       v4 = build("<BranchNbr>",result->list[idx].uom_branch_nbr,"</BranchNbr>"), col + 1, v4,
       row + 1, v7 = build("<NumeratorCd>",cnvtint(result->list[idx].uom_numerator_cd),
        "</NumeratorCd>"), col + 1,
       v7, row + 1, v8 = build("<Numerator>",trim(replace(replace(replace(replace(replace(result->
              list[idx].uom_numerator_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
          '"',"&quot;",0),3),"</Numerator>"),
       col + 1, v8, row + 1,
       v5 = build("<DenominatorCd>",cnvtint(result->list[idx].uom_denominator_cd),"</DenominatorCd>"),
       col + 1, v5,
       row + 1, v6 = build("<Denominator>",trim(replace(replace(replace(replace(replace(result->list[
              idx].uom_denominator_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
          '"',"&quot;",0),3),"</Denominator>"), col + 1,
       v6, row + 1, v9 = build("<MultiplyFactor>",cnvtint(result->list[idx].uom_multiply_factor),
        "</MultiplyFactor>"),
       col + 1, v9, row + 1,
       v10 = build("<TypeFlag>",result->list[idx].uom_type_flag,"</TypeFlag>"), col + 1, v10,
       row + 1, v11 = build("<TypeFlagDisplay>",trim(replace(replace(replace(replace(replace(result->
              list[idx].uom_type_flag_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
          '"',"&quot;",0),3),"</TypeFlagDisplay>"), col + 1,
       v11, row + 1, v12 = build("<StrengthUnitInd>",result->list[idx].strength_unit_ind,
        "</StrengthUnitInd>"),
       col + 1, v12, row + 1,
       v13 = build("<VolumeUnitInd>",result->list[idx].volume_unit_ind,"</VolumeUnitInd>"), col + 1,
       v13,
       row + 1, v14 = build("<RateUnitInd>",result->list[idx].rate_unit_ind,"</RateUnitInd>"), col +
       1,
       v14, row + 1, v15 = build("<DocumentationDoseRateInd>",result->list[idx].
        documentation_dose_rate_ind,"</DocumentationDoseRateInd>"),
       col + 1, v15, row + 1,
       v16 = build("<QuantityUnitInd>",result->list[idx].quantity_unit_ind,"</QuantityUnitInd>"), col
        + 1, v16,
       row + 1, v17 = build("<DurationUnitInd>",result->list[idx].duration_unit_ind,
        "</DurationUnitInd>"), col + 1,
       v17, row + 1, v18 = build("<NormalizedUnitInd>",result->list[idx].normalized_unit_ind,
        "</NormalizedUnitInd>"),
       col + 1, v18, row + 1,
       v19 = build("<DisplayInd>",result->list[idx].display_ind,"</DisplayInd>"), col + 1, v19,
       row + 1, col + 1, "</UOM>",
       row + 1
      ENDIF
    ENDFOR
    col + 1, "</UOMs>", row + 1,
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 SUBROUTINE getuoms(null)
   DECLARE rcnt = i4 WITH protect, noconstant(0)
   DECLARE sortkey = vc WITH protect, noconstant("")
   SELECT INTO "NL:"
    sortkey = cnvtupper(uar_get_code_display(dcu.uom_cd))
    FROM dose_calculator_uom dcu,
     code_value cv
    PLAN (dcu
     WHERE dcu.uom_cd > 0.0)
     JOIN (cv
     WHERE cv.code_value=dcu.uom_cd
      AND cv.code_set=54)
    ORDER BY sortkey
    DETAIL
     pos = locateval(locidx,1,rcnt,dcu.uom_cd,result->list[locidx].uom_cd)
     IF (pos=0)
      rcnt += 1, stat = alterlist(result->list,rcnt), result->list[rcnt].uom_cd = dcu.uom_cd,
      result->list[rcnt].uom_disp = uar_get_code_display(dcu.uom_cd), result->list[rcnt].uom_base_nbr
       = dcu.uom_base_nbr, result->list[rcnt].uom_branch_nbr = dcu.uom_branch_nbr,
      result->list[rcnt].uom_denominator_cd = dcu.uom_denominator_cd, result->list[rcnt].
      uom_denominator_disp = uar_get_code_display(dcu.uom_denominator_cd), result->list[rcnt].
      uom_numerator_cd = dcu.uom_numerator_cd,
      result->list[rcnt].uom_numerator_disp = uar_get_code_display(dcu.uom_numerator_cd), result->
      list[rcnt].uom_multiply_factor = dcu.uom_multiply_factor, result->list[rcnt].uom_type_flag =
      dcu.uom_type_flag,
      result->list[rcnt].uom_type_flag_disp = evaluate(dcu.uom_type_flag,0,"Basic Unit",1,
       "Administered Time",
       2,"Administered Volume",3,"Patient Weight",4,
       "Patient Weight time","Unknown")
     ENDIF
    WITH nocounter, time = 30
   ;end select
   RETURN(success)
 END ;Subroutine
 SUBROUTINE filteruoms(null)
   DECLARE fieldval = vc WITH protect, noconstant("")
   DECLARE uom_strength_bit = i2 WITH protect, constant(1)
   DECLARE uom_volume_bit = i2 WITH protect, constant(2)
   DECLARE uom_quantity_bit = i2 WITH protect, constant(4)
   DECLARE uom_duration_bit = i2 WITH protect, constant(8)
   DECLARE uom_rate_bit = i2 WITH protect, constant(16)
   DECLARE uom_normalized_bit = i2 WITH protect, constant(32)
   DECLARE uom_docdoserate_bit = i2 WITH protect, constant(64)
   DECLARE type_flag_basic = i2 WITH protect, constant(0)
   DECLARE type_flag_weight = i2 WITH protect, constant(3)
   SELECT INTO "NL:"
    FROM code_value_extension cve
    PLAN (cve
     WHERE expand(idx,1,size(result->list,5),cve.code_value,result->list[idx].uom_cd))
    DETAIL
     fieldval = trim(cve.field_value,3)
     IF (textlen(fieldval) > 0
      AND isnumeric(fieldval)=1)
      pos = locateval(locidx,1,size(result->list,5),cve.code_value,result->list[locidx].uom_cd)
      IF (pos > 0)
       IF (band(cnvtint(fieldval),uom_strength_bit)=uom_strength_bit)
        result->list[pos].strength_unit_ind = 1
       ENDIF
       IF (band(cnvtint(fieldval),uom_volume_bit)=uom_volume_bit)
        result->list[pos].volume_unit_ind = 1
       ENDIF
       IF (band(cnvtint(fieldval),uom_quantity_bit)=uom_quantity_bit)
        result->list[pos].quantity_unit_ind = 1
       ENDIF
       IF (band(cnvtint(fieldval),uom_duration_bit)=uom_duration_bit)
        result->list[pos].duration_unit_ind = 1
       ENDIF
       IF (band(cnvtint(fieldval),uom_rate_bit)=uom_rate_bit)
        result->list[pos].rate_unit_ind = 1
       ENDIF
       IF (band(cnvtint(fieldval),uom_normalized_bit)=uom_normalized_bit)
        result->list[pos].normalized_unit_ind = 1
       ENDIF
       IF (band(cnvtint(fieldval),uom_docdoserate_bit)=uom_docdoserate_bit)
        result->list[pos].documentation_dose_rate_ind = 1
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter, expand = 1, time = 30
   ;end select
   FOR (idx = 1 TO size(result->list,5))
     IF ((result->list[idx].strength_unit_ind=0)
      AND (result->list[idx].volume_unit_ind=0)
      AND (result->list[idx].rate_unit_ind=0)
      AND (result->list[idx].quantity_unit_ind=0)
      AND (result->list[idx].duration_unit_ind=0)
      AND (result->list[idx].normalized_unit_ind=0))
      SET result->list[idx].no_unit_ind = 1
     ENDIF
   ENDFOR
   FOR (idx = 1 TO size(result->list,5))
     IF (( $2=0)
      AND (((result->list[idx].normalized_unit_ind=1)) OR ((result->list[idx].no_unit_ind=1)))
      AND (result->list[idx].uom_numerator_cd > 0)
      AND hasdenomvolunitdependency(result->list[idx].uom_denominator_cd)=0
      AND isdoseunit(result->list[idx].uom_type_flag,result->list[idx].uom_numerator_cd,result->list[
      idx].uom_denominator_cd))
      SET result->list[idx].display_ind = 1
     ELSEIF (( $2=1)
      AND (result->list[idx].uom_numerator_cd > 0))
      SET result->list[idx].display_ind = 1
     ENDIF
   ENDFOR
   RETURN(success)
 END ;Subroutine
 SUBROUTINE (isdoseunit(type_flag=i2,numer_unit_cd=f8,denom_unit_cd=f8) =i2)
   DECLARE numer_mean = vc WITH protect, constant(uar_get_code_meaning(numer_unit_cd))
   DECLARE denom_mean = vc WITH protect, constant(uar_get_code_meaning(denom_unit_cd))
   IF (type_flag=type_flag_basic
    AND ((numer_mean="ML"
    AND denom_mean != "M2") OR (denom_mean="ML")) )
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (hasdenomvolunitdependency(denom_unit_cd=f8) =i2)
  IF (((denom_unit_cd=0) OR (uar_get_code_meaning(denom_unit_cd) IN ("KG", "M2"))) )
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
END GO
