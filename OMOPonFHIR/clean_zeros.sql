UPDATE :cdm_schema.drug_exposure SET provider_id=null WHERE provider_id=0;
UPDATE :cdm_schema.measurement SET provider_id=null WHERE provider_id=0;

UPDATE :cdm_schema.condition_occurrence SET visit_detail_id=null WHERE visit_detail_id=0;
UPDATE :cdm_schema.drug_exposure SET visit_detail_id=null WHERE visit_detail_id=0;
UPDATE :cdm_schema.measurement SET visit_detail_id=null WHERE visit_detail_id=0;
UPDATE :cdm_schema.observation SET visit_detail_id=null WHERE visit_detail_id=0;
UPDATE :cdm_schema.procedure_occurrence SET visit_detail_id=null WHERE visit_detail_id=0;

