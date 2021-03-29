# Exploration of OMOP and FHIR
Base project for exploration of OMOP to FHIR&reg; conversion.

## Overview
This document describes the creation of a test environment using synthetic
clinical data to explore the 
[GT-FHIR2 OMOP on FHIR project](http://omoponfhir.org/) with two different versions
of the OMOP CDM.
Included here are terraform scripts to set up resources in AWS and instructions
to perform the following:
1. Configure a PostgreSQL database for mulitple versions of the OMOP CDM
2. Use the [SYNTHEA&trade;](https://synthetichealth.github.io/synthea/) 
software package to generate sample data 
3. Use the ETL-Synthea tools to create the CDM schemas, load vocabularies,
and load synthetic data
4. Configure multiple versions of the GT-FHIR2 mapper and run via Docker

One can certainly just work with a single version of the OMOP CDM. In that
case you can ignore the redundant steps.

## Base infrastructure
For this project we use a PostgreSQL instance in AWS RDS and a single 
EC2 instance.

You can use the terraform scripts provided here (`tf/`) to create a user account 
with appropriate permissions and with this user account create the EC2 
instance and RDS database. The scripts make use of AWS Secrets Manager
for the database credentials.

## Setup
You'll need to install the following on your test host
- git
- Docker
- docker-compose
- psql client
- java
- R, including devtools

## Create database and schemas 

```
psql -h <RDS endpoint> -U <username> -P <password> postgres
postgres=> CREATE DATABASE omopfhir;
postgres=> \connect omopfhir
omopfhir=> CREATE SCHEMA cdm60;
omopfhir=> CREATE SCHEMA cdm53;
omopfhir=> CREATE SCHEMA native60;
omopfhir=> CREATE SCHEMA native53;
```
The cdm{53,60} schemas will store the OMOP CDM (versions 5.3.1 and 6.0, respectively); 
the native{53,60} schemas will store the untransformed synthetic data.

## Synthetic data
For the purposes of this project we will generate two synthetic datasets
using the Synthea system.

### Install Synthea

```
git clone https://github.com/synthetichealth/synthea
cd synthea
./gradlew build check test
```

### Configure to generate CSV output 
We will make use of the OHDSI ETL-Synthea loader. For this we need Synthea
to create CSV output. We will be making two distict datasets to compare 
across populations so we also configure the system to create separate output
directories. Edit `src/main/resources/synthea.properties`

```
exporter.csv.export = true
exporter.csv.folder_per_run = true
```

You may want to disable FHIR output to save disk space.

### Create test datasets
```
./run_synthea -s 2020 -p 10000 Massachusetts
./run_synthea -s 2020 -p 10000 Illinois
```
This will create output files in timestamped subdirectories in synthea/output/csv

## Get OMOP vocabulary files
Note that the ELT-Synthea concept loader expects lowercase filenames.

## OHDSI Synthea data loader
Have a look at [`https://github.com/OHDSI/ETL-Synthea`](https://github.com/OHDSI/ETL-Synthea).
Once you have 
successfully installed R and devtools, you can follow directions there
to load the native and cdm schemas.

Now, we're going to run this twice because we are going to use different
schemas with different versions of the CDM for our test datasets.

For the first pass, set cdmSchema to "cdm53" and syntheaSchema to "native53", 
and point sytheaFileLoc to one of the CSV output directories. For the second
pass, use "cdm60" and "native60".

As an optimization, you can use the vocabulary files from the first schema
to populate the second. For this you would use the `LoadVocabFromSchema.r`
script instead of `LoadVocabFromCsv.r`, specifying "vocabSchema". This is much faster.


## GT-FHIR2 Server
Instructions for setting up multiple versions of the GT-FHIR2 system can
be found in the `omoponfhir` directory.
