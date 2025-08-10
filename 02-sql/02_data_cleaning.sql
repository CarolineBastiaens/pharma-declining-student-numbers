-- Drop unnecessary columns
-- Inschrijvingen
ALTER TABLE inschrijvingen
DROP COLUMN teldatum;
ALTER TABLE inschrijvingen
DROP COLUMN status_inschrijving;


-- Add a serial key
ALTER TABLE inschrijvingen
ADD COLUMN inschrijvingen_id SERIAL PRIMARY KEY;
ALTER TABLE studiebewijzen
ADD COLUMN studiebewijzen_id SERIAL PRIMARY KEY;


-- Create dimension table for institutions: instellingen
CREATE TABLE instellingen ( 
    instellingsnummer INTEGER,
    instelling_naam_huidig TEXT,
    instelling_naam TEXT,
    soort_instelling TEXT,
    associatie TEXT
);


-- Check table structure for table instellingen
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'instellingen'
ORDER BY ordinal_position;


-- Inspect columns that are to be inserted for dimension table instellingen
-- instellingsnummer: check for duplicates
SELECT
    instellingsnummer,
    COUNT(*)
FROM inschrijvingen
GROUP BY instellingsnummer
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;
SELECT
    DISTINCT instellingsnummer,
    COUNT(*)
FROM studiebewijzen
GROUP BY instellingsnummer;
-- instellingsnummer: check for NULL values
SELECT instellingsnummer, instelling_naam_huidig, instelling_naam, soort_instelling, associatie
FROM inschrijvingen
WHERE instellingsnummer IS NULL;
SELECT instellingsnummer, instelling_naam_huidig, instelling_naam, soort_instelling, associatie
FROM studiebewijzen
WHERE instellingsnummer IS NULL;
-- instelling_naam_huidig
SELECT
    instelling_naam_huidig,
    COUNT(*)
FROM inschrijvingen
GROUP BY instelling_naam_huidig;
SELECT
    instelling_naam_huidig,
    COUNT(*)
FROM studiebewijzen
GROUP BY instelling_naam_huidig;
-- instelling_naam
SELECT
    instelling_naam,
    COUNT(*)
FROM inschrijvingen
GROUP BY instelling_naam;
SELECT
    instelling_naam,
    COUNT(*)
FROM studiebewijzen
GROUP BY instelling_naam;
-- soort_instelling
SELECT
    soort_instelling,
    COUNT(*)
FROM inschrijvingen
GROUP BY soort_instelling;
SELECT
    soort_instelling,
    COUNT(*)
FROM studiebewijzen
GROUP BY soort_instelling;
-- associatie
SELECT
    associatie,
    COUNT(*)
FROM inschrijvingen
GROUP BY associatie;
SELECT
    associatie,
    COUNT(*)
FROM studiebewijzen
GROUP BY associatie;


--Data cleaning
-- instelling_naam, table inschrijvingen + studiebewijzen: several values for Karel de Grote Hogeschool, Katholieke Hogeschool Antwerpen: Karel de Grote-Hogeschool - Katholieke Hogeschool Antwerpen, Karel de Grote-Hogeschool Katholieke Hogeschool Antwerpen, Karel de Grote-Hogeschool, Katholieke Hogeschool Antwerpen
UPDATE inschrijvingen
SET instelling_naam = 'Karel de Grote Hogeschool, Katholieke Hogeschool Antwerpen'
WHERE instelling_naam IN ('Karel de Grote-Hogeschool - Katholieke Hogeschool Antwerpen', 'Karel de Grote-Hogeschool Katholieke Hogeschool Antwerpen', 'Karel de Grote-Hogeschool, Katholieke Hogeschool Antwerpen');
UPDATE studiebewijzen
SET instelling_naam = 'Karel de Grote Hogeschool, Katholieke Hogeschool Antwerpen'
WHERE instelling_naam IN ('Karel de Grote-Hogeschool - Katholieke Hogeschool Antwerpen', 'Karel de Grote-Hogeschool Katholieke Hogeschool Antwerpen', 'Karel de Grote-Hogeschool, Katholieke Hogeschool Antwerpen');
-- Check results
SELECT
    instelling_naam,
    COUNT(*)
FROM inschrijvingen
GROUP BY instelling_naam;
SELECT
    instelling_naam,
    COUNT(*)
FROM studiebewijzen
GROUP BY instelling_naam;

-- Insert institutions into dimension table instellingen
INSERT INTO instellingen (
    instellingsnummer,
    instelling_naam_huidig,
    instelling_naam,
    soort_instelling,
    associatie
)
SELECT DISTINCT
    instellingsnummer,
    instelling_naam_huidig,
    instelling_naam,
    soort_instelling,
    associatie
FROM
    (SELECT
        instellingsnummer,
        instelling_naam_huidig,
        instelling_naam,
        soort_instelling,
        associatie
    FROM inschrijvingen
    UNION
    SELECT
        instellingsnummer,
        instelling_naam_huidig,
        instelling_naam,
        soort_instelling,
        associatie
    FROM studiebewijzen) AS combined;


-- Inspect columns dimension table instellingen
SELECT COUNT(*)
FROM instellingen;
SELECT *
FROM instellingen;
-- instellingsnummer
SELECT
    instellingsnummer,
    COUNT(*)
FROM instellingen
GROUP BY instellingsnummer
ORDER BY COUNT(*) DESC;
-- instelling_naam_huidig
SELECT
    instelling_naam_huidig,
    COUNT(*)
FROM instellingen
GROUP BY instelling_naam_huidig;
-- instelling_naam
SELECT
    instelling_naam,
    COUNT(*)
FROM instellingen
GROUP BY instelling_naam;
-- soort_instelling
SELECT
    soort_instelling,
    COUNT(*)
FROM instellingen
GROUP BY soort_instelling;
-- associatie
SELECT
    associatie,
    COUNT(*)
FROM instellingen
GROUP BY associatie;


-- Create dimension table for study areas
CREATE TABLE opleidingen ( 
    type_opleiding TEXT,
    aard_opleiding TEXT,
    soort_contract TEXT,
    studiegebied TEXT,
    opleidingsvarieteit_code INTEGER,
    opleidingsvarieteit TEXT,
    onderwijstaal TEXT,
    is_lerarenopleiding TEXT,
    stem_opleiding TEXT
);


-- Check table structure for table opleidingen
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'opleidingen'
ORDER BY ordinal_position;


-- Inspect columns that are to be inserted for dimension table opleidingen
-- type_opleiding
SELECT
    type_opleiding,
    COUNT(*)
FROM inschrijvingen
GROUP BY type_opleiding;
SELECT
    type_opleiding,
    COUNT(*)
FROM studiebewijzen
GROUP BY type_opleiding;
-- aard_opleiding
SELECT
    aard_opleiding,
    COUNT(*)
FROM inschrijvingen
GROUP BY aard_opleiding;
SELECT
    aard_opleiding,
    COUNT(*)
FROM studiebewijzen
GROUP BY aard_opleiding;
-- soort_contract / type_studiebewijs
SELECT
    soort_contract,
    COUNT(*)
FROM inschrijvingen
GROUP BY soort_contract;
SELECT
    type_studiebewijs,
    COUNT(*)
FROM studiebewijzen
GROUP BY type_studiebewijs;
-- studiegebied
SELECT
    studiegebied,
    COUNT(*)
FROM inschrijvingen
GROUP BY studiegebied;
SELECT
    studiegebied,
    COUNT(*)
FROM studiebewijzen
GROUP BY studiegebied;
-- opleidingsvarieteit_code: check for duplicates
SELECT
    opleidingsvarieteit_code,
    COUNT(*)
FROM inschrijvingen
GROUP BY opleidingsvarieteit_code
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;
SELECT
    opleidingsvarieteit_code,
    COUNT(*)
FROM studiebewijzen
GROUP BY opleidingsvarieteit_code
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;
-- opleidingsvarieteit_code: check for NULL values
SELECT type_opleiding, aard_opleiding, soort_contract, studiegebied, opleidingsvarieteit_code, opleidingsvarieteit, onderwijstaal, is_lerarenopleiding, stem_opleiding
FROM inschrijvingen
WHERE opleidingsvarieteit_code IS NULL;
SELECT type_opleiding, aard_opleiding, type_studiebewijs, studiegebied, opleidingsvarieteit_code, opleidingsvarieteit, onderwijstaal, is_lerarenopleiding, stem_opleiding
FROM studiebewijzen
WHERE opleidingsvarieteit_code IS NULL;
-- opleidingsvarieteit
SELECT
    opleidingsvarieteit,
    COUNT(*)
FROM inschrijvingen
GROUP BY opleidingsvarieteit;
SELECT
    opleidingsvarieteit,
    COUNT(*)
FROM studiebewijzen
GROUP BY opleidingsvarieteit;
-- onderwijstaal
SELECT
    onderwijstaal,
    COUNT(*)
FROM inschrijvingen
GROUP BY onderwijstaal;
SELECT
    onderwijstaal,
    COUNT(*)
FROM studiebewijzen
GROUP BY onderwijstaal;
-- is_lerarenopleiding
SELECT
    is_lerarenopleiding,
    COUNT(*)
FROM inschrijvingen
GROUP BY is_lerarenopleiding;
SELECT
    is_lerarenopleiding,
    COUNT(*)
FROM studiebewijzen
GROUP BY is_lerarenopleiding;
-- stem_opleiding
SELECT
    stem_opleiding,
    COUNT(*)
FROM inschrijvingen
GROUP BY stem_opleiding;
SELECT
    stem_opleiding,
    COUNT(*)
FROM studiebewijzen
GROUP BY stem_opleiding;


-- Rename column type_studiebewijs
ALTER TABLE studiebewijzen
RENAME COLUMN type_studiebewijs TO soort_contract;


-- Data cleaning
-- type_studiebewijs, table studiebewijzen: 'Diploma' or 'Getuigschrift' / soort_contract, table inschrijvingen: 'Diplomagetuigschrift': to align
UPDATE studiebewijzen
SET soort_contract = 'Diplomacontract'
WHERE soort_contract = 'Diploma';
-- Check results
SELECT
    soort_contract,
    COUNT(*)
FROM studiebewijzen
GROUP BY soort_contract;


-- Insert study areas into dimension table
INSERT INTO opleidingen (
    type_opleiding,
    aard_opleiding,
    soort_contract,
    studiegebied,
    opleidingsvarieteit_code,
    opleidingsvarieteit,
    onderwijstaal,
    is_lerarenopleiding,
    stem_opleiding
)
SELECT DISTINCT
    type_opleiding,
    aard_opleiding,
    soort_contract,
    studiegebied,
    opleidingsvarieteit_code,
    opleidingsvarieteit,
    onderwijstaal,
    is_lerarenopleiding,
    stem_opleiding
FROM(
    SELECT
        type_opleiding,
        aard_opleiding,
        soort_contract,
        studiegebied,
        opleidingsvarieteit_code,
        opleidingsvarieteit,
        onderwijstaal,
        is_lerarenopleiding,
        stem_opleiding
    FROM inschrijvingen
    UNION
    SELECT
        type_opleiding,
        aard_opleiding,
        soort_contract,
        studiegebied,
        opleidingsvarieteit_code,
        opleidingsvarieteit,
        onderwijstaal,
        is_lerarenopleiding,
        stem_opleiding
    FROM studiebewijzen) AS combined;


-- Inspect columns dimension table opleidingen
-- type_opleiding
SELECT
    type_opleiding,
    COUNT(*)
FROM opleidingen
GROUP BY type_opleiding;
-- aard_opleiding
SELECT
    aard_opleiding,
    COUNT(*)
FROM opleidingen
GROUP BY aard_opleiding;
-- soort_contract
SELECT
    soort_contract,
    COUNT(*)
FROM opleidingen
GROUP BY soort_contract;
-- studiegebied
SELECT
    studiegebied,
    COUNT(*)
FROM opleidingen
GROUP BY studiegebied;
-- opleidingsvarieteit_code
SELECT
    opleidingsvarieteit_code,
    COUNT(*)
FROM opleidingen
GROUP BY opleidingsvarieteit_code
ORDER BY COUNT(*) DESC;
-- opleidingsvarieteit
SELECT
    opleidingsvarieteit,
    COUNT(*)
FROM opleidingen
GROUP BY opleidingsvarieteit;
-- onderwijstaal
SELECT
    onderwijstaal,
    COUNT(*)
FROM opleidingen
GROUP BY onderwijstaal;
-- is_lerarenopleiding
SELECT
    is_lerarenopleiding,
    COUNT(*)
FROM opleidingen
GROUP BY is_lerarenopleiding;
-- stem_opleiding
SELECT
    stem_opleiding,
    COUNT(*)
FROM opleidingen
GROUP BY stem_opleiding;


-- Note opleidingsvarieteit_code is not a unique identifier
-- table opleidingen has 2939 records:
SELECT COUNT(*)
FROM opleidingen;
-- opleidingsvarieteit_code yields 1787 records:
SELECT COUNT (DISTINCT opleidingsvarieteit_code)
FROM opleidingen;
-- combination opleidingsvarieteit_code and opleidingsvariteit yields 1925 records
SELECT COUNT(*)
FROM
    (SELECT DISTINCT opleidingsvarieteit_code, opleidingsvarieteit
    FROM opleidingen
) AS subquery;
-- Combination opleidingsvarieteit_code and onderwijstaal yields 1787 records
SELECT COUNT(*)
FROM
    (SELECT DISTINCT opleidingsvarieteit_code, onderwijstaal
    FROM opleidingen
) AS subquery;
-- Check which records yield duplicates
SELECT o.*
FROM opleidingen AS o
INNER JOIN (
    SELECT 
        opleidingsvarieteit_code, 
        opleidingsvarieteit
    FROM opleidingen
    GROUP BY opleidingsvarieteit_code, opleidingsvarieteit
    HAVING COUNT(*) >= 2
) AS duplicates
ON o.opleidingsvarieteit_code = duplicates.opleidingsvarieteit_code
AND o.opleidingsvarieteit = duplicates.opleidingsvarieteit;
-- We notice many of these records have aard_opleiding = 'Voortgezette opleidingen'. These records are beyond the scope of the project and can be excluded.
-- table opleidingen, excluding aard_opleiding = 'Voortgezette opleidingen', has 1644 records:
SELECT COUNT(*)
FROM opleidingen
WHERE aard_opleiding <> 'Voortgezette opleidingen';
-- opleidingsvarieteit_code, excluding aard_opleiding = 'Voortgezette opleidingen', yields 1501 records:
SELECT COUNT (DISTINCT opleidingsvarieteit_code)
FROM opleidingen
WHERE aard_opleiding <> 'Voortgezette opleidingen';
-- combination opleidingsvarieteit_code and opleidingsvariteit, excluding aard_opleiding = 'Voortgezette opleidingen', yields 1630 records
SELECT COUNT(*)
FROM
    (SELECT DISTINCT opleidingsvarieteit_code, opleidingsvarieteit
    FROM opleidingen
    WHERE aard_opleiding <> 'Voortgezette opleidingen'
) AS subquery;
-- combination opleidingsvarieteit_code and studiegebied, excluding aard_opleiding = 'Voortgezette opleidingen', yields 1516 records
SELECT COUNT(*)
FROM
    (SELECT DISTINCT opleidingsvarieteit_code, studiegebied
    FROM opleidingen
    WHERE aard_opleiding <> 'Voortgezette opleidingen'
) AS subquery;
WHERE aard_opleiding <> 'Voortgezette opleidingen';
-- combination opleidingsvarieteit_code, opleidingsvariteit and studiegebied, excluding aard_opleiding = 'Voortgezette opleidingen', yields 1644 records
SELECT COUNT(*)
FROM
    (SELECT DISTINCT opleidingsvarieteit_code, opleidingsvarieteit, studiegebied
    FROM opleidingen
    WHERE aard_opleiding <> 'Voortgezette opleidingen'
) AS subquery;
-- Unique key (when exluding 'Voortgezette opleidingen') = opleidingsvarieteit_code, opleidingsvarieteit and studiegebied


-- Drop columns from fact tables
-- instelling_naam_huidig
ALTER TABLE inschrijvingen
DROP COLUMN instelling_naam_huidig;
ALTER TABLE studiebewijzen
DROP COLUMN instelling_naam_huidig;
-- instelling_naam
ALTER TABLE inschrijvingen
DROP COLUMN instelling_naam;
ALTER TABLE studiebewijzen
DROP COLUMN instelling_naam;
-- soort_instelling
ALTER TABLE inschrijvingen
DROP COLUMN soort_instelling;
ALTER TABLE studiebewijzen
DROP COLUMN soort_instelling;
-- associatie
ALTER TABLE inschrijvingen
DROP COLUMN associatie;
ALTER TABLE studiebewijzen
DROP COLUMN associatie;
-- type_opleiding
ALTER TABLE inschrijvingen
DROP COLUMN type_opleiding;
ALTER TABLE studiebewijzen
DROP COLUMN type_opleiding;
-- aard_opleiding
ALTER TABLE inschrijvingen
DROP COLUMN aard_opleiding;
ALTER TABLE studiebewijzen
DROP COLUMN aard_opleiding;
-- soort_contract
ALTER TABLE inschrijvingen
DROP COLUMN soort_contract;
ALTER TABLE studiebewijzen
DROP COLUMN soort_contract;
-- is_lerarenopleiding
ALTER TABLE inschrijvingen
DROP COLUMN is_lerarenopleiding;
ALTER TABLE studiebewijzen
DROP COLUMN is_lerarenopleiding;
-- stem_opleiding
ALTER TABLE inschrijvingen
DROP COLUMN stem_opleiding;
ALTER TABLE studiebewijzen
DROP COLUMN stem_opleiding;


-- Inspect columns fact tables
-- Check table structure for tables inschrijvingen and studiebewijzen
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'inschrijvingen'
ORDER BY ordinal_position;
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'studiebewijzen'
ORDER BY ordinal_position;
-- Check some records
SELECT *
FROM inschrijvingen
LIMIT 10;
SELECT *
FROM studiebewijzen
LIMIT 10;
-- Inspect columns for tables inschrijvingen and studiebewijzen
-- academiejaar
SELECT
    academiejaar,
    COUNT(*)
FROM inschrijvingen
GROUP BY academiejaar;
SELECT
    academiejaar,
    COUNT(*)
FROM studiebewijzen
GROUP BY academiejaar;
-- geslacht
SELECT
    geslacht,
    COUNT(*)
FROM inschrijvingen
GROUP BY geslacht;
SELECT
    geslacht,
    COUNT(*)
FROM studiebewijzen
GROUP BY geslacht;
-- geboortejaar
SELECT
    geboortejaar,
    COUNT(*)
FROM inschrijvingen
GROUP BY geboortejaar;
SELECT
    geboortejaar,
    COUNT(*)
FROM studiebewijzen
GROUP BY geboortejaar;
-- belg_nietbelg
SELECT
    belg_nietbelg,
    COUNT(*)
FROM inschrijvingen
GROUP BY belg_nietbelg;
SELECT
    belg_nietbelg,
    COUNT(*)
FROM studiebewijzen
GROUP BY belg_nietbelg;
-- eu_nieteu
SELECT
    eu_nieteu,
    COUNT(*)
FROM inschrijvingen
GROUP BY eu_nieteu;
SELECT
    eu_nieteu,
    COUNT(*)
FROM studiebewijzen
GROUP BY eu_nieteu;
-- leeftijd
SELECT
    leeftijd,
    COUNT(*)
FROM inschrijvingen
GROUP BY leeftijd;
SELECT
    leeftijd,
    COUNT(*)
FROM studiebewijzen
GROUP BY leeftijd;
-- leeftijdscategorie 
SELECT
    leeftijdscategorie,
    COUNT(*)
FROM inschrijvingen
GROUP BY leeftijdscategorie;
SELECT
    leeftijd,
    COUNT(*)
FROM studiebewijzen
GROUP BY leeftijd;
-- generatiestudent
SELECT
    generatiestudent,
    COUNT(*)
FROM inschrijvingen
GROUP BY generatiestudent;
-- woonplaats_provincie_naam
SELECT
    woonplaats_provincie_naam,
    COUNT(*)
FROM inschrijvingen
GROUP BY woonplaats_provincie_naam;
SELECT
    woonplaats_provincie_naam,
    COUNT(*)
FROM studiebewijzen
GROUP BY woonplaats_provincie_naam;
-- woonplaats_huidige_fusiegemeente_naam
SELECT
    woonplaats_huidige_fusiegemeente_naam,
    COUNT(*)
FROM inschrijvingen
GROUP BY woonplaats_huidige_fusiegemeente_naam;
-- woonplaats_huidige_fusiegemeente_nis
SELECT
    woonplaats_huidige_fusiegemeente_nis,
    COUNT(*)
FROM inschrijvingen
GROUP BY woonplaats_huidige_fusiegemeente_nis;
-- vestiging_provincie_naam
SELECT
    vestiging_provincie_naam,
    COUNT(*)
FROM inschrijvingen
GROUP BY vestiging_provincie_naam;
SELECT
    vestiging_provincie_naam,
    COUNT(*)
FROM studiebewijzen
GROUP BY vestiging_provincie_naam;
-- vestiging
SELECT
    vestiging,
    COUNT(*)
FROM studiebewijzen
GROUP BY vestiging;
-- aantal_inschrijvingen / aantal_studiebewijzen
SELECT
    aantal_inschrijvingen,
    COUNT(*)
FROM inschrijvingen
GROUP BY aantal_inschrijvingen;
SELECT
    aantal_studiebewijzen,
    COUNT(*)
FROM studiebewijzen
GROUP BY aantal_studiebewijzen;


-- Create views
-- Note we don't need to specifically exclude aard_opleiding = 'Voorgezette opleidingen' because the values in type_opleiding already cause them to be excluded.
-- Create view for enrollments bachelor's degree Pharmaceutical Sciences
CREATE VIEW inschrijvingen_farmacie_bachelor AS
SELECT
    inschr.*,
    inst.instelling_naam_huidig
FROM inschrijvingen AS inschr
LEFT JOIN opleidingen AS opl
ON inschr.opleidingsvarieteit_code = opl.opleidingsvarieteit_code
    AND inschr.opleidingsvarieteit = opl.opleidingsvarieteit
    AND inschr.studiegebied = opl.studiegebied
LEFT JOIN instellingen AS inst
ON inschr.instellingsnummer = inst.instellingsnummer
WHERE opl.type_opleiding = 'Academisch gerichte bachelor'
    AND opl.studiegebied = 'Farmaceutische wetenschappen';
-- Create view for degrees bachelor's degree Pharmaceutical Sciences
CREATE VIEW studiebewijzen_farmacie_bachelor AS
SELECT
    studieb.*,
    inst.instelling_naam_huidig
FROM studiebewijzen AS studieb
LEFT JOIN opleidingen AS opl
ON studieb.opleidingsvarieteit_code = opl.opleidingsvarieteit_code
    AND studieb.opleidingsvarieteit = opl.opleidingsvarieteit
    AND studieb.studiegebied = opl.studiegebied
LEFT JOIN instellingen AS inst
ON studieb.instellingsnummer = inst.instellingsnummer
WHERE opl.type_opleiding = 'Academisch gerichte bachelor'
    AND opl.studiegebied = 'Farmaceutische wetenschappen';
-- Create view for enrollments Master's degree Pharmaceutical Sciences
CREATE VIEW inschrijvingen_farmacie_master AS
SELECT
    inschr.*,
    inst.instelling_naam_huidig
FROM inschrijvingen AS inschr
LEFT JOIN opleidingen AS opl
ON inschr.opleidingsvarieteit_code = opl.opleidingsvarieteit_code
    AND inschr.opleidingsvarieteit = opl.opleidingsvarieteit
    AND inschr.studiegebied = opl.studiegebied
LEFT JOIN instellingen AS inst
ON inschr.instellingsnummer = inst.instellingsnummer
WHERE opl.type_opleiding = 'Master'
    AND opl.studiegebied = 'Farmaceutische wetenschappen';
-- Create view for degrees Master's degree Pharmaceutical Sciences
CREATE VIEW studiebewijzen_farmacie_master AS
SELECT
    studieb.*,
    inst.instelling_naam_huidig
FROM studiebewijzen AS studieb
LEFT JOIN opleidingen AS opl
ON studieb.opleidingsvarieteit_code = opl.opleidingsvarieteit_code
    AND studieb.opleidingsvarieteit = opl.opleidingsvarieteit
    AND studieb.studiegebied = opl.studiegebied
LEFT JOIN instellingen AS inst
ON studieb.instellingsnummer = inst.instellingsnummer
WHERE opl.type_opleiding = 'Master'
    AND opl.studiegebied = 'Farmaceutische wetenschappen';


-- Check the views created
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public';