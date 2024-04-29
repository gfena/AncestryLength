
input="/home/Desktop/Giacomo/LAI/inputbychr/"

for chr in {1..22}
do
ruby measure_ancestry_lengthv4.7.rb -i $input/chm_$chr.csv -o $input/Roma.chr$chr.ancestrylength.csv --MB --nohap
done

