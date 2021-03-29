DROP TABLE IF EXISTS :cdm_schmea.f_person;

CREATE TABLE :cdm_schmea.f_person (
	person_id int4 NOT NULL,
	family_name varchar(255) NULL,
	given1_name varchar(255) NULL,
	given2_name varchar(255) NULL,
	prefix_name varchar(255) NULL,
	suffix_name varchar(255) NULL,
	preferred_language varchar(255) NULL,
	ssn varchar(12) NULL,
	active int2 NULL DEFAULT 1,
	contact_point1 varchar(255) NULL,
	contact_point2 varchar(255) NULL,
	contact_point3 varchar(255) NULL,
	maritalstatus varchar(255) NULL
);

INSERT INTO :cdm_schema.f_person(person_id) SELECT person_id FROM :cdm_schema.person;
