#!/bin/bash

input="/yourdirectory/inputbychr/"
out="yourdirectory/output/"

for chr in {1..22}
do
ruby AncestryLength.rb -i $input/chr.$chr.csv -o $out/chr$chr.ancestrylength.csv --MB --nohap
done

