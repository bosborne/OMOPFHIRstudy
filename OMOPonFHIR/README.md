# Installation of GT-FHIR2 OMOPonFHIR
Steps for installing the [GT-FHIR2](http://omoponfhir.org/) OMOPonFHIR server
in the test environment.

## Overview
This document describes the installation of the [GT-FHIR2](http://omoponfhir.org/)
“OMOPonFHIR” server in the test environment. Because this environment include
two different verions of the OMOP CDM we will install two different versions
of the server.

OMOPonFHIR operates as a Tomcap app between a FHIR server and the PostgreSQL
RDBMS hosting the OMOP CDM schemas. The [HAPI FHIR server](https://hapifhir.io)
provides the FHIR API.

Both versions of the OMOPonFHIR server will be run via Docker.

## Prepare database
Here we address two issues in deploying OMOPonFHIR. The first is two missing
steps in the OMOPonFHIR documentation, namely the creation of a required
table and a required view. The second results from the OHDSI ETL-Syntha process,
where the missing value for certain identifies is represented in some tables
as 0 instead of NULL; this causes errors in the OMOPonFHIR server. The steps
are:
- Add a new table, `f_person`, to the OMOP CDM schema(s)
and populate `person_id` from the OMOP CDM `person` table (see `f_person.sql`)
- Add a new view, `f_observation_view`, to the OMOP CDM schema(s) (see `f_observation_view.sql`)
- Update tables in the OMOP CDM schema(s) where the ETL process inserted
0 as a missing value for one or both of `provider_id` and `visit_detail_id`
(see `clean_zeros.sql`)

## Installation 
### OMOP CDM v6 to FHIR R4
As of this writing, this is the default version of the OMOPonFHIR server.
The source for the server is [here](https://github.com/omoponfhir/omoponfhir-main)
and basic instructions for configuration and running are covered there; however,
as noted above those instructions miss two important steps that must be performed in the
RDBMS hosting the OMOP CDM. Presuming the steps to prepare the database
have been completed, the basic overview of the instalation of the default 
version of the server is:
- Change directory to `omoponfhir/v6` 
- Clone (recursively) the `omoponfhir-main` repository and cd to `omoponfhir-main/`
- Add appropriate environment variables to the OMOPonFHIR `Dockerfile`
  - set the `JDBC_URL` variable to reference the RDS endpoint and specify
the OMOP CDM v6 schema via `currentSchema`
  - set `JDBC_USERNAME` and `JDBC_PASSWORD` to the values used in RDS configuration
  - set `AUTH_BASIC` to some "username:password"; this will be used for client access

(If you start the server before creating the `f_person` table and 
`f_observation_view` view, the server will attempt to create them both as empty tables.)

### OMOP CDM v5 to FHIR R4
The OMOPonFHIR repository does not make use releases in a way that facilitates
download of the set of submodules required to install this version of the 
server; some additional effort is required. Here the steps are:
- Change directory to `omoponfhir/v5` 
- Clone (non-recursively) the `omoponfhir-main` repository and cd to `omoponfhir-main`
- Remove directories for v6 mapping and JPA base:
  - `omoponfhir-omopv6-r4-mapping`
  - `omoponfhir-omopv6-jpabase `
- Clone the v5 mapping and JPA base repositories into the omoponfhir-main directory:
  - `git clone https://github.com/omoponfhir/omoponfhir-omopv5-r4-mapping`
  - `git clone https://github.com/omoponfhir/omoponfhir-omopv5-jpabase`
- Edit the `pom.xml` file to replace module definitions for v6 with the v5 versions
- Edit `omoponfhir-r4-server/pom.xml` to replace the artifactId referencing the
v6 mapping module with the v5 module and adjust the version numbers for the
v5-mapping and v5-jpabase modules to match those in their pom.xml files
- Add appropriate environment variables to the OMOPonFHIR `Dockerfile`
  - set the `JDBC_URL` variable to reference the RDS endpoint and specify
the OMOP CDM v6 schema via `currentSchema`
  - set `JDBC_USERNAME` and `JDBC_PASSWORD` to the values used in RDS configuration
  - set `AUTH_BASIC` to some "username:password"; this will be used for client access

## Running the servers
The `docker-compose.yml` file at the top level of this repository includes 
blocks for both servers. As configured, the v6 server will run on port 8080,
the v5 server on port 8081.

```
$ docker-compose up --build --detach
```
