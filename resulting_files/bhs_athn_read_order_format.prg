CREATE PROGRAM bhs_athn_read_order_format
 RECORD orequest(
   1 oeformatid = f8
   1 actiontypecd = f8
   1 positioncd = f8
   1 ordlocationcd = f8
   1 patlocationcd = f8
   1 applicationcd = f8
   1 encntrtypecd = f8
   1 includepromptind = i2
   1 catalogcd = f8
   1 origordasflag = i2
 )
 RECORD oreply(
   1 status = i4
   1 oeformatname = c200
   1 fieldlist[*]
     2 oefieldid = f8
     2 acceptflag = i2
     2 defaultvalue = c100
     2 inputmask = c50
     2 requirecosignind = i2
     2 prologmethod = i4
     2 epilogmethod = i4
     2 statusline = c200
     2 labeltext = c200
     2 groupseq = i4
     2 fieldseq = i4
     2 valuerequiredind = i2
     2 maxnbroccur = i4
     2 description = c100
     2 codeset = i4
     2 oefieldmeaningid = f8
     2 oefieldmeaning = c25
     2 request = i4
     2 minval = f8
     2 maxval = f8
     2 fieldtypeflag = i2
     2 field_type = vc
     2 acceptsize = i4
     2 validationtypeflag = i2
     2 helpcontextid = f8
     2 allowmultipleind = i2
     2 spinincrementcnt = i4
     2 clinlineind = i2
     2 clinlinelabel = c25
     2 clinsuffixind = i2
     2 deptlineind = i2
     2 deptlinelabel = c25
     2 deptsuffixind = i2
     2 dispyesnoflag = i2
     2 defprevorderind = i2
     2 dispdeptyesnoflag = i2
     2 promptentityname = c32
     2 promptentityid = f8
     2 commonflag = i2
     2 eventcd = f8
     2 filterparams = c255
     2 deplist[*]
       3 dependencyfieldid = f8
       3 depseqlist[*]
         4 dependencyseq = i4
         4 dependencymethod = i4
         4 dependencyaction = i4
         4 depdomseqlist[*]
           5 depdomainseq = i4
           5 dependencyvalue = c200
           5 dependencyoperator = i4
     2 cki = c30
     2 coreind = i2
     2 defaultparententityid = f8
     2 lockonmodifyflag = i2
     2 carryforwardplanind = i2
   1 status_data
     2 status = vc
     2 subeventstatus[*]
       3 operationname = vc
       3 operationstatus = vc
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD t_record(
   1 status = i4
   1 oeformatname = vc
   1 field_cnt = i4
   1 fieldlist[*]
     2 fieldtypeflag = i2
     2 field_type = vc
     2 oefieldid = vc
     2 oefieldmeaningid = vc
     2 oefieldmeaning = vc
     2 labeltext = vc
     2 description = vc
     2 defaultvalue = vc
     2 acceptflag = vc
     2 validationtypeflag = vc
     2 commonflag = vc
     2 valuerequiredind = vc
     2 requirecosignind = vc
     2 groupseq = i4
     2 fieldseq = i4
     2 clinlineind = vc
     2 clinlinelabel = vc
     2 clinsuffixind = vc
     2 deptlineind = vc
     2 deptlinelabel = vc
     2 deptsuffixind = vc
     2 allowmultipleind = vc
     2 maxnbroccur = i4
     2 acceptsize = i4
     2 minval = vc
     2 maxval = vc
     2 codeset = i4
     2 inputmask = vc
     2 spinincrementcnt = i4
     2 promptentityid = vc
     2 promptentityname = vc
     2 filterparams = vc
 )
 IF (( $2 > 0))
  SET orequest->oeformatid =  $2
 ENDIF
 IF (( $3 > 0))
  SELECT INTO "nl:"
   FROM order_catalog_synonym ocs
   PLAN (ocs
    WHERE (ocs.synonym_id= $3))
   DETAIL
    orequest->oeformatid = ocs.oe_format_id
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6003
    AND (cv.display_key= $4))
  DETAIL
   orequest->actiontypecd = cv.code_value
  WITH nocounter
 ;end select
 IF (( $5="NormalOrder"))
  SET orequest->origordasflag = 0
 ELSE
  SET orequest->origordasflag = 1
 ENDIF
 SET orequest->patlocationcd =  $6
 SET orequest->encntrtypecd =  $7
 SET orequest->positioncd =  $8
 SET orequest->includepromptind =  $9
 SET orequest->ordlocationcd =  $10
 SET orequest->applicationcd =  $11
 SET stat = tdbexecute(3200000,3200081,560000,"REC",orequest,
  "REC",oreply,4)
 SET t_record->status = oreply->status
 SET t_record->oeformatname = oreply->oeformatname
 SET t_record->field_cnt = size(oreply->fieldlist,5)
 SET stat = alterlist(t_record->fieldlist,t_record->field_cnt)
 FOR (i = 1 TO size(oreply->fieldlist,5))
   SET t_record->fieldlist[i].fieldtypeflag = oreply->fieldlist[i].fieldtypeflag
   IF ((oreply->fieldlist[i].fieldtypeflag=0))
    SET t_record->fieldlist[i].field_type = "AlphaNumericField"
   ELSEIF ((oreply->fieldlist[i].fieldtypeflag=1))
    SET t_record->fieldlist[i].field_type = "IntegerField"
   ELSEIF ((oreply->fieldlist[i].fieldtypeflag=2))
    SET t_record->fieldlist[i].field_type = "DecimalField"
   ELSEIF ((oreply->fieldlist[i].fieldtypeflag=3))
    SET t_record->fieldlist[i].field_type = "DateField"
   ELSEIF ((oreply->fieldlist[i].fieldtypeflag=5))
    SET t_record->fieldlist[i].field_type = "DateTimeField"
   ELSEIF ((oreply->fieldlist[i].fieldtypeflag=6))
    SET t_record->fieldlist[i].field_type = "CodesetField"
   ELSEIF ((oreply->fieldlist[i].fieldtypeflag=7))
    SET t_record->fieldlist[i].field_type = "IndicatorField"
   ELSEIF ((oreply->fieldlist[i].fieldtypeflag=8))
    SET t_record->fieldlist[i].field_type = "UnknownField"
   ELSEIF ((oreply->fieldlist[i].fieldtypeflag=9))
    SET t_record->fieldlist[i].field_type = "LocationField"
   ELSEIF ((oreply->fieldlist[i].fieldtypeflag=10))
    SET t_record->fieldlist[i].field_type = "DiagnosisField"
   ELSEIF ((oreply->fieldlist[i].fieldtypeflag=11))
    SET t_record->fieldlist[i].field_type = "UnknownField"
   ELSEIF ((oreply->fieldlist[i].fieldtypeflag=12))
    SET t_record->fieldlist[i].field_type = "ListField"
   ELSEIF ((oreply->fieldlist[i].fieldtypeflag=13))
    SET t_record->fieldlist[i].field_type = "UnknownField"
   ELSEIF ((oreply->fieldlist[i].fieldtypeflag=14))
    SET t_record->fieldlist[i].field_type = "UnknownField"
   ELSEIF ((oreply->fieldlist[i].fieldtypeflag=15))
    SET t_record->fieldlist[i].field_type = "UnknownField"
   ENDIF
   SET t_record->fieldlist[i].oefieldid = cnvtstring(oreply->fieldlist[i].oefieldid)
   SET t_record->fieldlist[i].oefieldmeaningid = cnvtstring(oreply->fieldlist[i].oefieldmeaningid)
   SET t_record->fieldlist[i].oefieldmeaning = oreply->fieldlist[i].oefieldmeaning
   SET t_record->fieldlist[i].labeltext = oreply->fieldlist[i].labeltext
   SET t_record->fieldlist[i].description = oreply->fieldlist[i].description
   SET t_record->fieldlist[i].defaultvalue = oreply->fieldlist[i].defaultvalue
   IF ((oreply->fieldlist[i].acceptflag=0))
    SET t_record->fieldlist[i].acceptflag = "Required"
   ELSEIF ((oreply->fieldlist[i].acceptflag=1))
    SET t_record->fieldlist[i].acceptflag = "Optional"
   ELSEIF ((oreply->fieldlist[i].acceptflag=2))
    SET t_record->fieldlist[i].acceptflag = "NoDisplay"
   ELSEIF ((oreply->fieldlist[i].acceptflag=3))
    SET t_record->fieldlist[i].acceptflag = "DisplayOnly"
   ENDIF
   IF ((oreply->fieldlist[i].validationtypeflag=0))
    SET t_record->fieldlist[i].validationtypeflag = "None"
   ELSEIF ((oreply->fieldlist[i].validationtypeflag=1))
    SET t_record->fieldlist[i].validationtypeflag = "CodeSet"
   ELSEIF ((oreply->fieldlist[i].validationtypeflag=2))
    SET t_record->fieldlist[i].validationtypeflag = "Request"
   ELSEIF ((oreply->fieldlist[i].validationtypeflag=3))
    SET t_record->fieldlist[i].validationtypeflag = "Range"
   ENDIF
   IF ((oreply->fieldlist[i].commonflag=0))
    SET t_record->fieldlist[i].commonflag = "ShowInCommonOrderDetails"
   ELSEIF ((oreply->fieldlist[i].commonflag=1))
    SET t_record->fieldlist[i].commonflag = "ShowInCommonOrderDetails"
   ELSEIF ((oreply->fieldlist[i].commonflag=2))
    SET t_record->fieldlist[i].commonflag = "HideFromCommonOrderDetails"
   ENDIF
   IF ((oreply->fieldlist[i].valuerequiredind=1))
    SET t_record->fieldlist[i].valuerequiredind = "true"
   ELSE
    SET t_record->fieldlist[i].valuerequiredind = "false"
   ENDIF
   IF ((oreply->fieldlist[i].requirecosignind=1))
    SET t_record->fieldlist[i].requirecosignind = "true"
   ELSE
    SET t_record->fieldlist[i].requirecosignind = "false"
   ENDIF
   SET t_record->fieldlist[i].groupseq = oreply->fieldlist[i].groupseq
   SET t_record->fieldlist[i].fieldseq = oreply->fieldlist[i].fieldseq
   IF ((oreply->fieldlist[i].clinlineind=1))
    SET t_record->fieldlist[i].clinlineind = "true"
   ELSE
    SET t_record->fieldlist[i].clinlineind = "false"
   ENDIF
   SET t_record->fieldlist[i].clinlinelabel = oreply->fieldlist[i].clinlinelabel
   IF ((oreply->fieldlist[i].clinsuffixind=1))
    SET t_record->fieldlist[i].clinsuffixind = "true"
   ELSE
    SET t_record->fieldlist[i].clinsuffixind = "false"
   ENDIF
   IF ((oreply->fieldlist[i].deptlineind=1))
    SET t_record->fieldlist[i].deptlineind = "true"
   ELSE
    SET t_record->fieldlist[i].deptlineind = "false"
   ENDIF
   SET t_record->fieldlist[i].deptlinelabel = oreply->fieldlist[i].deptlinelabel
   IF ((oreply->fieldlist[i].deptsuffixind=1))
    SET t_record->fieldlist[i].deptsuffixind = "true"
   ELSE
    SET t_record->fieldlist[i].deptsuffixind = "false"
   ENDIF
   IF ((oreply->fieldlist[i].allowmultipleind=1))
    SET t_record->fieldlist[i].allowmultipleind = "true"
   ELSE
    SET t_record->fieldlist[i].allowmultipleind = "false"
   ENDIF
   SET t_record->fieldlist[i].maxnbroccur = oreply->fieldlist[i].maxnbroccur
   SET t_record->fieldlist[i].acceptsize = oreply->fieldlist[i].acceptsize
   SET t_record->fieldlist[i].minval = cnvtstring(oreply->fieldlist[i].minval)
   SET t_record->fieldlist[i].maxval = cnvtstring(oreply->fieldlist[i].maxval)
   SET t_record->fieldlist[i].inputmask = oreply->fieldlist[i].inputmask
   SET t_record->fieldlist[i].spinincrementcnt = oreply->fieldlist[i].spinincrementcnt
   SET t_record->fieldlist[i].promptentityid = cnvtstring(oreply->fieldlist[i].promptentityid)
   SET t_record->fieldlist[i].promptentityname = oreply->fieldlist[i].promptentityname
   SET t_record->fieldlist[i].filterparams = oreply->fieldlist[i].filterparams
   SET t_record->fieldlist[i].codeset = oreply->fieldlist[i].codeset
 ENDFOR
 CALL echojson(t_record, $1)
END GO
