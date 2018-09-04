-- Simple example that computes the average HDL levels of everyone
-- in the database since the start of 2017
SELECT subject.reference,
       AVG(value.quantity.value) avg_hdl
FROM observation o,
     UNNEST(o.code.coding) c
WHERE c.system = 'http://loinc.org' AND
      c.code = '2085-9' AND
      o.effectivedatetime > '2017'
GROUP BY subject.reference
