-- Count the number of records for each view in total.
SELECT COUNT(*) FROM inschrijvingen_farmacie_bachelor; -- 12460
SELECT COUNT(*) FROM inschrijvingen_farmacie_master; -- 7515
SELECT COUNT(*) FROM studiebewijzen_farmacie_bachelor; -- 1060
SELECT COUNT(*) FROM studiebewijzen_farmacie_master; -- 1360


-- Count the number of students per academic year for each view.
SELECT
    academiejaar,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen
FROM inschrijvingen_farmacie_bachelor
GROUP BY academiejaar
ORDER BY academiejaar;
SELECT
    academiejaar,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen
FROM inschrijvingen_farmacie_master
GROUP BY academiejaar
ORDER BY academiejaar;
SELECT
    academiejaar,
    SUM(aantal_studiebewijzen) AS aantal_studiebewijzen
FROM studiebewijzen_farmacie_bachelor
GROUP BY academiejaar
ORDER BY academiejaar;
SELECT
    academiejaar,
    SUM(aantal_studiebewijzen) AS aantal_studiebewijzen
FROM studiebewijzen_farmacie_master
GROUP BY academiejaar
ORDER BY academiejaar; 


-- Check the evolution of generation students in the bachelor's degree Pharmaceutical Sciences 
SELECT
    academiejaar,
    SUM(aantal_inschrijvingen) AS aantal_generatiestudenten
FROM inschrijvingen_farmacie_bachelor
WHERE generatiestudent = 'Inschrijving van een generatiestudent'
GROUP BY academiejaar
ORDER BY academiejaar;


-- Check the distribution of male vs. female students 
SELECT
    academiejaar,
    geslacht,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen,
    ROUND(100.0 * SUM(aantal_inschrijvingen)
        /
        SUM(SUM(aantal_inschrijvingen)) OVER (PARTITION BY academiejaar),
        2) AS percentage
FROM inschrijvingen_farmacie_bachelor
GROUP BY academiejaar, geslacht
ORDER BY academiejaar, geslacht;


-- Check the distribution of age
SELECT
    academiejaar,
    leeftijdscategorie,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen,
    ROUND(100.0 * SUM(aantal_inschrijvingen)
        /
        SUM(SUM(aantal_inschrijvingen)) OVER (PARTITION BY academiejaar),
        2) AS percentage
FROM inschrijvingen_farmacie_bachelor
GROUP BY academiejaar, leeftijdscategorie
ORDER BY academiejaar, leeftijdscategorie;
-- Check specifically for generation students
SELECT
    academiejaar,
    leeftijdscategorie,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen,
    ROUND(100.0 * SUM(aantal_inschrijvingen)
        /
        SUM(SUM(aantal_inschrijvingen)) OVER (PARTITION BY academiejaar),
        2) AS percentage
FROM inschrijvingen_farmacie_bachelor
WHERE generatiestudent = 'Inschrijving van een generatiestudent'
GROUP BY academiejaar, leeftijdscategorie
ORDER BY academiejaar, leeftijdscategorie;


-- Check the distribution of geographic origin (provinces)
SELECT
    academiejaar,
    woonplaats_provincie_naam,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen,
    ROUND(100.0 * SUM(aantal_inschrijvingen)
        /
        SUM(SUM(aantal_inschrijvingen)) OVER (PARTITION BY academiejaar),
        2) AS percentage
FROM inschrijvingen_farmacie_bachelor
GROUP BY academiejaar, woonplaats_provincie_naam
ORDER BY academiejaar, woonplaats_provincie_naam;
-- Check the distribution of Belgian vs. non-Belgian students
SELECT
    academiejaar,
    belg_nietbelg,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen,
    ROUND(100.0 * SUM(aantal_inschrijvingen)
        /
        SUM(SUM(aantal_inschrijvingen)) OVER (PARTITION BY academiejaar),
        2) AS percentage
FROM inschrijvingen_farmacie_bachelor
GROUP BY academiejaar, belg_nietbelg
ORDER BY academiejaar, belg_nietbelg;
-- Check for Belgian students vs. non-Belgian students and differences across institutions
SELECT
    instelling_naam_huidig,
    belg_nietbelg,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen,
    ROUND(100.0 * SUM(aantal_inschrijvingen)
        /
        SUM(SUM(aantal_inschrijvingen)) OVER (PARTITION BY instelling_naam_huidig),
        2) AS percentage
FROM inschrijvingen_farmacie_bachelor
GROUP BY instelling_naam_huidig, belg_nietbelg
ORDER BY instelling_naam_huidig, belg_nietbelg;


-- Check the distribution of students per institution (instelling_naam_huidig)
SELECT DISTINCT instelling_naam_huidig
FROM inschrijvingen_farmacie_bachelor;
SELECT DISTINCT instelling_naam_huidig
FROM inschrijvingen_farmacie_master;


-- Check the evolution of the number of students in higher education in bachelor degrees in Flanders
SELECT
    inschr.academiejaar,
    SUM(inschr.aantal_inschrijvingen) AS aantal_inschrijvingen
FROM inschrijvingen AS inschr
LEFT JOIN opleidingen AS opl
ON inschr.opleidingsvarieteit_code = opl.opleidingsvarieteit_code
    AND inschr.opleidingsvarieteit = opl.opleidingsvarieteit
    AND inschr.studiegebied = opl.studiegebied
WHERE opl.type_opleiding = 'Academisch gerichte bachelor'
GROUP BY inschr.academiejaar
ORDER BY inschr.academiejaar;


-- Check market shares across institutions for bachelor degrees across all subjects
SELECT
  inst.instelling_naam_huidig AS instelling,
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
GROUP BY inst.instelling_naam_huidig, inschr.academiejaar
ORDER BY inst.instelling_naam_huidig, inschr.academiejaar;
-- Check market shares across institutions for master degrees across all subjects
SELECT
  inst.instelling_naam_huidig AS instelling,
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
GROUP BY inst.instelling_naam_huidig, inschr.academiejaar
ORDER BY inst.instelling_naam_huidig, inschr.academiejaar;


-- Evolution in student numbers for the degree of Pharmaceutical Sciences
-- Use the earlier created views
-- Evolution student numbers for the bachelor's degree
SELECT
    academiejaar,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen
FROM inschrijvingen_farmacie_bachelor
GROUP BY academiejaar
ORDER BY academiejaar;
-- Evolution for generation students
SELECT
    academiejaar,
    SUM(aantal_inschrijvingen) AS aantal_generatiestudenten
FROM inschrijvingen_farmacie_bachelor
WHERE generatiestudent = 'Inschrijving van een generatiestudent'
GROUP BY academiejaar
ORDER BY academiejaar;
-- Evolution for obtained degrees bachelor
SELECT
    academiejaar,
    SUM(aantal_studiebewijzen) AS aantal_studiebewijzen
FROM studiebewijzen_farmacie_bachelor
GROUP BY academiejaar
ORDER BY academiejaar;
-- Evolution student numbers for the master's degrees
SELECT
    academiejaar,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen
FROM inschrijvingen_farmacie_master
GROUP BY academiejaar
ORDER BY academiejaar;
-- Evolution for obtained degrees master
SELECT
    academiejaar,
    SUM(aantal_studiebewijzen) AS aantal_studiebewijzen
FROM studiebewijzen_farmacie_master
GROUP BY academiejaar
ORDER BY academiejaar;


-- Compare market share for the bachelor degree Pharmaceutical Sciences
-- Use the earlier created views
SELECT
    instelling_naam_huidig,
    academiejaar,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen,
    ROUND(100.0 * SUM(aantal_inschrijvingen)
            /
            SUM(SUM(aantal_inschrijvingen)) OVER (PARTITION BY academiejaar),
            2) AS marktaandeel
FROM inschrijvingen_farmacie_bachelor
GROUP BY instelling_naam_huidig, academiejaar
ORDER BY instelling_naam_huidig, academiejaar;
-- Compare market share for generation students
SELECT
    instelling_naam_huidig,
    academiejaar,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen,
    ROUND(100.0 * SUM(aantal_inschrijvingen)
            /
            SUM(SUM(aantal_inschrijvingen)) OVER (PARTITION BY academiejaar),
            2) AS marktaandeel
FROM inschrijvingen_farmacie_bachelor
WHERE generatiestudent = 'Inschrijving van een generatiestudent'
GROUP BY instelling_naam_huidig, academiejaar
ORDER BY instelling_naam_huidig, academiejaar;
-- Compare market share for completed degree in the bachelor Pharmaceutical Sciences
SELECT
    instelling_naam_huidig,
    academiejaar,
    SUM(aantal_studiebewijzen) AS aantal_studiebewijzen,
    ROUND(100.0 * SUM(aantal_studiebewijzen)
            /
            SUM(SUM(aantal_studiebewijzen)) OVER (PARTITION BY academiejaar),
            2) AS marktaandeel
FROM studiebewijzen_farmacie_bachelor
GROUP BY instelling_naam_huidig, academiejaar
ORDER BY instelling_naam_huidig, academiejaar;
-- Compare market share for the master's degree Pharmaceutical Sciences
SELECT
    instelling_naam_huidig,
    academiejaar,
    SUM(aantal_inschrijvingen) AS aantal_inschrijvingen,
    ROUND(100.0 * SUM(aantal_inschrijvingen)
            /
            SUM(SUM(aantal_inschrijvingen)) OVER (PARTITION BY academiejaar),
            2) AS marktaandeel
FROM inschrijvingen_farmacie_master
GROUP BY instelling_naam_huidig, academiejaar
ORDER BY instelling_naam_huidig, academiejaar;
-- Compare market share for completed degree in the master Pharmaceutical Sciences
SELECT
    instelling_naam_huidig,
    academiejaar,
    SUM(aantal_studiebewijzen) AS aantal_studiebewijzen,
    ROUND(100.0 * SUM(aantal_studiebewijzen)
            /
            SUM(SUM(aantal_studiebewijzen)) OVER (PARTITION BY academiejaar),
            2) AS marktaandeel
FROM studiebewijzen_farmacie_master
GROUP BY instelling_naam_huidig, academiejaar
ORDER BY instelling_naam_huidig, academiejaar;


-- Check the related degrees in the database
SELECT DISTINCT
    opl.studiegebied,
    opl.type_opleiding,
    opl.opleidingsvarieteit,
    inst.instelling_naam_huidig AS instelling
FROM inschrijvingen AS inschr
LEFT JOIN opleidingen AS opl
ON inschr.opleidingsvarieteit_code = opl.opleidingsvarieteit_code
    AND inschr.opleidingsvarieteit = opl.opleidingsvarieteit
    AND inschr.studiegebied = opl.studiegebied
LEFT JOIN instellingen AS inst
ON inschr.instellingsnummer = inst.instellingsnummer
WHERE opl.type_opleiding IN ('Academisch gerichte bachelor', 'Master')
    AND opl.studiegebied IN ('Farmaceutische wetenschappen', 'Geneeskunde', 'Biomedische wetenschappen', 'Wetenschappen')
ORDER BY type_opleiding, studiegebied, instelling, opleidingsvarieteit;