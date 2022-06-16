rm vrf.log
make verify > vrf.log
echo "True: "
grep -o true vrf.log | wc -l
echo "False: "
grep -o false vrf.log | wc -l
