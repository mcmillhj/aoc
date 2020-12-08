#!perl

use strict; 
use warnings; 

use feature qw(say);

chomp(my @expenses = readline(\*DATA));

{ 
# Part 1
# After saving Christmas five years in a row, you've decided to take a vacation at a nice resort on a tropical island. Surely, Christmas will go on without you.

# The tropical island has its own currency and is entirely cash-only. The gold coins used there have a little picture of a starfish; the locals just call them stars. None of the currency exchanges seem to have heard of them, but somehow, you'll need to find fifty of these coins by the time you arrive so you can pay the deposit on your room.

# To save your vacation, you need to get all fifty stars by December 25th.

# Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!

# Before you leave, the Elves in accounting just need you to fix your expense report (your puzzle input); apparently, something isn't quite adding up.

# Specifically, they need you to find the two entries that sum to 2020 and then multiply those two numbers together.

# For example, suppose your expense report contained the following:

# 1721
# 979
# 366
# 299
# 675
# 1456

# In this list, the two entries that sum to 2020 are 1721 and 299. Multiplying them together produces 1721 * 299 = 514579, so the correct answer is 514579.

# Of course, your expense report is much larger. Find the two entries that sum to 2020; what do you get if you multiply them together?

  my %filter; 
  foreach my $expense (@expenses) {
    if (exists $filter{2020 - $expense}) {
      say $expense * (2020 - $expense);
      last;
    }
    $filter{$expense} = 1;
  }
  # ANSWER = 365619
}

{ 
# Part 2
# The Elves in accounting are thankful for your help; one of them even offers you a starfish coin they had left over from a past vacation. They offer you a second one if you can find three numbers in your expense report that meet the same criteria.

# Using the above example again, the three entries that sum to 2020 are 979, 366, and 675. Multiplying them together produces the answer, 241861950.

# In your expense report, what is the product of the three entries that sum to 2020?

  my %filter;
LOOP:
  foreach my $i (0 .. $#expenses) {
    my $expense = $expenses[$i];
    foreach my $j ($i + 1 .. $#expenses) {
      my $other_expense = $expenses[$j];
      if (exists $filter{2020 - $expense - $other_expense}) {
        say $expense * $other_expense * (2020 - $expense - $other_expense);
        last LOOP;
      }
      $filter{$other_expense} = 1;
    }
  }
  # ANSWER2 = 236873508
}

__DATA__
1786
571
1689
1853
1817
1549
1079
1755
1973
1453
1139
1576
1928
1634
1961
1995
1272
1839
1976
1664
1956
1933
1981
1665
1057
1798
1485
2004
1990
2002
82
1922
1544
201
1730
1607
1597
1098
1490
1955
1194
1733
1245
1761
1709
1143
1828
1450
1569
1997
1943
1555
1958
1176
1858
1937
1560
1979
1962
1658
1959
2007
1636
1460
348
1084
1952
1162
1772
701
1462
1680
1639
1625
1060
1600
1631
1638
1350
1675
1366
1244
1413
994
1533
1199
1653
1902
1340
1819
1676
1081
1953
1993
1652
1214
1815
1977
1939
2000
1879
1948
1982
1983
1247
1969
1149
1682
1456
2001
1674
1531
1464
1243
1511
1867
1479
1873
1136
1087
1651
1855
1122
1505
1974
1692
1992
1361
1666
1100
1193
1978
1529
1903
1510
1152
1514
1591
1753
1744
1985
1459
1954
1579
1307
1975
1934
1589
971
1603
1980
1942
1160
1986
1963
1921
1481
1736
1616
1968
1201
1489
1781
1021
1452
1570
1326
1831
2006
1541
1690
1877
1447
1988
1411
1535
1799
1587
1255
1611
1419
1947
1626
132
1946
1950
1487
1496
1949
1155
1628
1738
2010
1446
1466
1630
1784
1989
1458
1741