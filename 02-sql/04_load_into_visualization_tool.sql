
-- Queries for fact tables to load into the visualization tool
-- Facts_Inschrijvingen
SELECT
    inschr.academiejaar,
    inschr.instellingsnummer,
    -- Abbreviate values in column geslacht
    CASE
        WHEN inschr.geslacht = 'Mannelijk' THEN 'Man'
        WHEN inschr.geslacht = 'Vrouwelijk' THEN 'Vrouw'
        ELSE 'Onbekend'
    END AS geslacht,
    inschr.geboortejaar,
    inschr.belg_nietbelg,
    inschr.eu_nieteu,
    inschr.leeftijd,
    inschr.leeftijdscategorie,
    inschr.generatiestudent,
    CONCAT(inschr.opleidingsvarieteit_code, '.', inschr.opleidingsvarieteit, '.', inschr.studiegebied) AS opleiding,
    inschr.woonplaats_provincie_naam,
    inschr.woonplaats_huidige_fusiegemeente_naam,
    inschr.woonplaats_huidige_fusiegemeente_nis,
    inschr.aantal_inschrijvingen
FROM inschrijvingen AS inschr
LEFT JOIN opleidingen AS opl
ON inschr.opleidingsvarieteit_code = opl.opleidingsvarieteit_code
    AND inschr.opleidingsvarieteit = opl.opleidingsvarieteit
    AND inschr.studiegebied = opl.studiegebied
WHERE opl.type_opleiding IN ('Academisch gerichte bachelor', 'Master')
    AND opl.studiegebied IN ('Farmaceutische wetenschappen', 'Geneeskunde', 'Biomedische wetenschappen', 'Wetenschappen'); -- Select other related degrees for comparison
-- Facts_Studiebewijzen
SELECT
    studieb.academiejaar,
    studieb.instellingsnummer,
    -- Abbreviate values in column geslacht
    CASE
        WHEN studieb.geslacht = 'Mannelijk' THEN 'Man'
        WHEN studieb.geslacht = 'Vrouwelijk' THEN 'Vrouw'
        ELSE 'Onbekend'
    END AS geslacht,
    studieb.geboortejaar,
    studieb.belg_nietbelg,
    studieb.eu_nieteu,
    studieb.leeftijd,
    studieb.leeftijdscategorie,
    CONCAT(studieb.opleidingsvarieteit_code, '.', studieb.opleidingsvarieteit, '.', studieb.studiegebied) AS opleiding,
    studieb.woonplaats_provincie_naam,
    studieb.aantal_studiebewijzen
FROM studiebewijzen AS studieb
LEFT JOIN opleidingen AS opl
ON studieb.opleidingsvarieteit_code = opl.opleidingsvarieteit_code
    AND studieb.opleidingsvarieteit = opl.opleidingsvarieteit
    AND studieb.studiegebied = opl.studiegebied
WHERE opl.type_opleiding IN ('Academisch gerichte bachelor', 'Master')
    AND opl.studiegebied IN ('Farmaceutische wetenschappen', 'Geneeskunde', 'Biomedische wetenschappen', 'Wetenschappen'); -- Select other related degrees for comparison




-- Queries for dimension tables opleidingen, instellingen and academiejaren
-- Dim_Opleidingen
SELECT
    opleidingsvarieteit_code,
    opleidingsvarieteit,
    studiegebied,
    CONCAT(opleidingsvarieteit_code, '.', opleidingsvarieteit, '.', studiegebied) AS opleiding,
    aard_opleiding,
    type_opleiding,
    onderwijstaal,
    is_lerarenopleiding,
    stem_opleiding,
    soort_contract
FROM opleidingen
WHERE type_opleiding IN ('Academisch gerichte bachelor', 'Master')
    AND studiegebied IN ('Farmaceutische wetenschappen', 'Geneeskunde', 'Biomedische wetenschappen', 'Wetenschappen'); -- Select other related degrees for comparison
-- Dim_Instellingen
SELECT
    instellingsnummer,
    instelling_naam_huidig,
    instelling_naam,
    CASE
        WHEN instelling_naam_huidig = 'Katholieke Universiteit Leuven' THEN 'KU Leuven'
        WHEN instelling_naam_huidig = 'Universiteit Gent' THEN 'UGent'
        WHEN instelling_naam_huidig = 'Universiteit Antwerpen' THEN 'UAntwerpen'
        WHEN instelling_naam_huidig = 'Vrije Universiteit Brussel' THEN 'VUB'
        WHEN instelling_naam_huidig = 'Universiteit Hasselt' THEN 'UHasselt'
        WHEN instelling_naam_huidig = 'transnationale Universiteit Limburg' THEN 'tUL'
        ELSE instelling_naam_huidig
    END AS instelling_naam_beknopt,
    CASE
        WHEN instelling_naam_huidig = 'Katholieke Universiteit Leuven' THEN 'KUL'
        WHEN instelling_naam_huidig = 'Universiteit Gent' THEN 'UGent'
        WHEN instelling_naam_huidig = 'Universiteit Antwerpen' THEN 'UA'
        WHEN instelling_naam_huidig = 'Vrije Universiteit Brussel' THEN 'VUB'
        WHEN instelling_naam_huidig = 'Universiteit Hasselt' THEN 'UHasselt'
        WHEN instelling_naam_huidig = 'transnationale Universiteit Limburg' THEN 'tUL'
        ELSE instelling_naam_huidig
    END AS instelling_naam_kort,
    soort_instelling,
    associatie
FROM instellingen
WHERE instellingsnummer IN (
    SELECT DISTINCT instellingsnummer
    FROM inschrijvingen AS inschr
    LEFT JOIN opleidingen AS opl
    ON inschr.opleidingsvarieteit_code = opl.opleidingsvarieteit_code
        AND inschr.opleidingsvarieteit = opl.opleidingsvarieteit
        AND inschr.studiegebied = opl.studiegebied
    WHERE opl.type_opleiding IN ('Academisch gerichte bachelor', 'Master')
);
-- Dim_Academiejaren
SELECT DISTINCT
    -- Subtract year from academiejaar (first year)
    CAST(LEFT(academiejaar, 4) AS INTEGER) AS jaar,
    academiejaar,
   -- Create short version of academiejaar
    CONCAT(SUBSTRING(academiejaar FROM 3 FOR 2), '-', SUBSTRING(academiejaar FROM 8 FOR 2)) AS academiejaar_kort
FROM inschrijvingen
UNION
SELECT DISTINCT
-- Subtract year from academiejaar (first year)
    CAST(LEFT(academiejaar, 4) AS INTEGER) AS jaar,
    academiejaar,
   -- Create short version of academiejaar
    CONCAT(SUBSTRING(academiejaar FROM 3 FOR 2), '-', SUBSTRING(academiejaar FROM 8 FOR 2)) AS academiejaar_kort
FROM studiebewijzen
ORDER BY jaar;


-- Aggregation tables with market shares across all bachelor and master degrees within Flanders
-- Market shares for all bachelor degrees
SELECT
    inst.instellingsnummer,
    inschr.academiejaar,
    SUM(inschr.aantal_inschrijvingen) AS aantal_inschrijvingen,
    ROUND(100.0 * SUM(inschr.aantal_inschrijvingen)
        /
        SUM(SUM(inschr.aantal_inschrijvingen)) OVER (PARTITION BY inschr.academiejaar),
        2) AS marktaandeel
FROM inschrijvingen AS inschr
LEFT JOIN opleidingen AS opl
ON inschr.opleidingsvarieteit_code = opl.opleidingsvarieteit_code
    AND inschr.opleidingsvarieteit = opl.opleidingsvarieteit
    AND inschr.studiegebied = opl.studiegebied
LEFT JOIN instellingen AS inst
ON inschr.instellingsnummer = inst.instellingsnummer
WHERE opl.type_opleiding = 'Academisch gerichte bachelor'
GROUP BY inst.instellingsnummer, inschr.academiejaar
ORDER BY inst.instellingsnummer, inschr.academiejaar;
-- Market shares for all bachelor degrees, generation students only
SELECT
  inst.instellingsnummer,
  inschr.academiejaar,
  SUM(inschr.aantal_inschrijvingen) AS aantal_inschrijvingen,
  ROUND(100.0 * SUM(inschr.aantal_inschrijvingen)
        /
        SUM(SUM(inschr.aantal_inschrijvingen)) OVER (PARTITION BY inschr.academiejaar),
        2) AS marktaandeel
FROM inschrijvingen AS inschr
LEFT JOIN opleidingen AS opl
ON inschr.opleidingsvarieteit_code = opl.opleidingsvarieteit_code
    AND inschr.opleidingsvarieteit = opl.opleidingsvarieteit
    AND inschr.studiegebied = opl.studiegebied
LEFT JOIN instellingen AS inst
ON inschr.instellingsnummer = inst.instellingsnummer
WHERE opl.type_opleiding = 'Academisch gerichte bachelor'
    AND inschr.generatiestudent = 'Inschrijving van een generatiestudent'
GROUP BY inst.instellingsnummer, inschr.academiejaar
ORDER BY inst.instellingsnummer, inschr.academiejaar;
-- Market shares for all bachelor degrees obtained
SELECT
  inst.instellingsnummer,
  studieb.academiejaar,
  SUM(studieb.aantal_studiebewijzen) AS aantal_studiebewijzen,
  ROUND(100.0 * SUM(studieb.aantal_studiebewijzen)
        /
        SUM(SUM(studieb.aantal_studiebewijzen)) OVER (PARTITION BY studieb.academiejaar),
        2) AS marktaandeel
FROM studiebewijzen AS studieb
LEFT JOIN opleidingen AS opl
ON studieb.opleidingsvarieteit_code = opl.opleidingsvarieteit_code
    AND studieb.opleidingsvarieteit = opl.opleidingsvarieteit
    AND studieb.studiegebied = opl.studiegebied
LEFT JOIN instellingen AS inst
ON studieb.instellingsnummer = inst.instellingsnummer
WHERE opl.type_opleiding = 'Academisch gerichte bachelor'
GROUP BY inst.instellingsnummer, studieb.academiejaar
ORDER BY inst.instellingsnummer, studieb.academiejaar;
-- Market shares for all master degrees
SELECT
  inst.instellingsnummer,
  inschr.academiejaar,
  SUM(inschr.aantal_inschrijvingen) AS aantal_inschrijvingen,
  ROUND(100.0 * SUM(inschr.aantal_inschrijvingen)
        /
        SUM(SUM(inschr.aantal_inschrijvingen)) OVER (PARTITION BY inschr.academiejaar),
        2) AS marktaandeel
FROM inschrijvingen AS inschr
LEFT JOIN opleidingen AS opl
ON inschr.opleidingsvarieteit_code = opl.opleidingsvarieteit_code
    AND inschr.opleidingsvarieteit = opl.opleidingsvarieteit
    AND inschr.studiegebied = opl.studiegebied
LEFT JOIN instellingen AS inst
ON inschr.instellingsnummer = inst.instellingsnummer
WHERE opl.type_opleiding = 'Master'
GROUP BY inst.instellingsnummer, inschr.academiejaar
ORDER BY inst.instellingsnummer, inschr.academiejaar;
-- Market shares for all master degrees obtained
SELECT
  inst.instellingsnummer,
  studieb.academiejaar,
  SUM(studieb.aantal_studiebewijzen) AS aantal_studiebewijzen,
  ROUND(100.0 * SUM(studieb.aantal_studiebewijzen)
        /
        SUM(SUM(studieb.aantal_studiebewijzen)) OVER (PARTITION BY studieb.academiejaar),
        2) AS marktaandeel
FROM studiebewijzen AS studieb
LEFT JOIN opleidingen AS opl
ON studieb.opleidingsvarieteit_code = opl.opleidingsvarieteit_code
    AND studieb.opleidingsvarieteit = opl.opleidingsvarieteit
    AND studieb.studiegebied = opl.studiegebied
LEFT JOIN instellingen AS inst
ON studieb.instellingsnummer = inst.instellingsnummer
WHERE opl.type_opleiding = 'Master'
GROUP BY inst.instellingsnummer, studieb.academiejaar
ORDER BY inst.instellingsnummer, studieb.academiejaar;


-- Aggregation tables regarding market share within Pharmaceutical Sciences
-- Use the earlier created views as necessary
-- Market shares for the bachelor degree Pharmaceutical Sciences
SELECT
    instellingsnummer,
    academiejaar,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen,
    ROUND(100.0 * SUM(aantal_inschrijvingen)
            /
            SUM(SUM(aantal_inschrijvingen)) OVER (PARTITION BY academiejaar),
            2) AS marktaandeel
FROM inschrijvingen_farmacie_bachelor
GROUP BY instellingsnummer, academiejaar
ORDER BY instellingsnummer, academiejaar;
-- Market shares for generation students bachelor degree Pharmaceutical Sciences
SELECT
    instellingsnummer,
    academiejaar,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen,
    ROUND(100.0 * SUM(aantal_inschrijvingen)
            /
            SUM(SUM(aantal_inschrijvingen)) OVER (PARTITION BY academiejaar),
            2) AS marktaandeel
FROM inschrijvingen_farmacie_bachelor
WHERE generatiestudent = 'Inschrijving van een generatiestudent'
GROUP BY instellingsnummer, academiejaar
ORDER BY instellingsnummer, academiejaar;
-- Market shares for the completed degree in the bachelor Pharmaceutical Sciences
SELECT
    instellingsnummer,
    academiejaar,
    SUM(aantal_studiebewijzen) AS aantal_studiebewijzen,
    ROUND(100.0 * SUM(aantal_studiebewijzen)
            /
            SUM(SUM(aantal_studiebewijzen)) OVER (PARTITION BY academiejaar),
            2) AS marktaandeel
FROM studiebewijzen_farmacie_bachelor
GROUP BY instellingsnummer, academiejaar
ORDER BY instellingsnummer, academiejaar;
-- Market shares for the master's degree Pharmaceutical Sciences
SELECT
    instellingsnummer,
    academiejaar,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen,
    ROUND(100.0 * SUM(aantal_inschrijvingen)
            /
            SUM(SUM(aantal_inschrijvingen)) OVER (PARTITION BY academiejaar),
            2) AS marktaandeel
FROM inschrijvingen_farmacie_master
GROUP BY instellingsnummer, academiejaar
ORDER BY instellingsnummer, academiejaar;
-- Market shares for completed degree in the master Pharmaceutical Sciences
SELECT
    instellingsnummer,
    academiejaar,
    SUM(aantal_studiebewijzen) AS aantal_studiebewijzen,
    ROUND(100.0 * SUM(aantal_studiebewijzen)
            /
            SUM(SUM(aantal_studiebewijzen)) OVER (PARTITION BY academiejaar),
            2) AS marktaandeel
FROM studiebewijzen_farmacie_master
GROUP BY instellingsnummer, academiejaar
ORDER BY instellingsnummer, academiejaar;