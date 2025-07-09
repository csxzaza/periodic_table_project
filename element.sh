#!/bin/bash

if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
  exit 0
fi

ARG="$1"

RESULT=$(psql -U postgres -d periodic_table -t -A -F $'\t' -c "
SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
FROM elements e
JOIN properties p ON e.atomic_number = p.atomic_number
JOIN types t ON p.type_id = t.type_id
WHERE e.atomic_number::text = '$ARG'
   OR e.symbol = '$ARG'
   OR LOWER(e.name) = LOWER('$ARG')
LIMIT 1;
")

if [ -z "$RESULT" ]; then
  echo "I could not find that element in the database."
  exit 0
fi

# Parse tab-separated result
atomic_number=$(echo "$RESULT" | cut -f1)
name=$(echo "$RESULT" | cut -f2)
symbol=$(echo "$RESULT" | cut -f3)
type=$(echo "$RESULT" | cut -f4)
atomic_mass=$(echo "$RESULT" | cut -f5)
melting_point=$(echo "$RESULT" | cut -f6)
boiling_point=$(echo "$RESULT" | cut -f7)

# Final output
echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
