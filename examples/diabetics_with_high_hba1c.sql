-- Example query that creates multiple views of underlying FHIR resources,
-- then uses them to find all diabetics with a high HbA1c level.

-- A real query would likely use a valueset rather than specified code values,
-- but this query illustrates the pattern of layering views of underlying data
-- to analyze FHIR resources at scale.

-- Create a view of everyone with a diabetes condition
WITH diabetics as (

  SELECT DISTINCT subject.reference person_ref
  FROM condition,
       UNNEST(code.coding) coding
  WHERE verificationstatus = 'confirmed' AND
        coding.system = 'http://snomed.info/sct' AND
        (coding.code = '15777000' OR -- Prediabetes
         coding.code = '44054006') -- Diabetes
),

-- Create a view of all HbA1c values.
hba1c_values as (
  SELECT subject.reference person_ref,
         value.quantity.value,
         value.quantity.unit,
         coding.system,
         coding.code,
         coding.display,
         effectivedatetime
  FROM observation o,
       UNNEST(code.coding) coding
  WHERE coding.system = 'http://loinc.org' AND
        coding.code = '4548-4' AND
        status = 'final'

)
-- Use the above views to find diabetics who have had a
-- high HbA1c value since the start of 2017
SELECT d.person_ref,
       h.value,
       h.display result_display,
       h.effectivedatetime
FROM diabetics d
JOIN hba1c_values h ON d.person_ref = h.person_ref
WHERE h.value > 6.5 AND
      h.effectivedatetime > '2017'
