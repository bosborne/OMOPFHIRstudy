# Exploration of OMOP and FHIR
Base project for exploration of OMOP to FHIR conversion

## Background

## Base infrastructure
For this project we use a PostgreSQL instance in AWS RDS and a single 
EC2 instance.

You can use the terraform scripts to create a user account and the EC2 
instance and RDS database.


## Setup
You'll need to install the following on your test host
. git
. psql
. java
. R, including devtools

## Create database and schemas 

```
psql -h <RDS endpoint> -U <username> -P <password> postgres
postgres=> CREATE DATABASE omopfhir;
postgres=> \connect omopfhir
omopfhir=> CREATE SCHEMA cdm60;
omopfhir=> CREATE SCHEMA cdm53;
omopfhir=> CREATE SCHEMA native;
```
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
Have a look at `https://github.com/OHDSI/ETL-Synthea`. Once you have 
successfully installed R and devtools, you can follow directions there
to 




Now, we're going to run this twice because we are going to use different
schemas with different versions of the CDM for our test datasets.

For the first pass, configure as


