-- Simple example showing the use of the valueset_codes table in queries.
-- The WITH expression here could be replaced and inlined with the primary
-- SELECT statement, but this pattern of modular views can make larger
-- queries easier to read and work with.

WITH cholesterol_codes AS (
  SELECT system,
         code
  FROM valueset_codes vc
  WHERE vc.valueseturi = 'http://hl7.org/fhir/ValueSet/example-extensional' AND
        vc.valuesetversion = '20150622'
)
SELECT o.subject.reference person_ref,
       o.value.quantity.value,
       o.value.quantity.unit,
       c.display
FROM observation o,
     UNNEST(code.coding) c,
     cholesterol_codes cc
WHERE c.system = cc.system AND c.code = cc.code
